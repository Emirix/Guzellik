-- Migration: Fix search vector trigger and RPC to use sub_category
-- Description: Corrects the column name from 'category' to 'sub_category' in service_categories join

-- Fix update_venue_search_vector to use sub_category instead of category
CREATE OR REPLACE FUNCTION public.update_venue_search_vector()
 RETURNS trigger
 LANGUAGE plpgsql
 AS $function$
 DECLARE
   province_name TEXT;
   district_name TEXT;
   service_names TEXT;
 BEGIN
   -- Get province name
   SELECT p.name INTO province_name
   FROM provinces p
   WHERE p.id = NEW.province_id;

   -- Get district name
   SELECT d.name INTO district_name
   FROM districts d
   WHERE d.id = NEW.district_id;

   -- Get all service names for this venue (normalized)
   SELECT STRING_AGG(normalize_turkish(sc.name) || ' ' || normalize_turkish(COALESCE(sc.sub_category, '')), ' ') INTO service_names
   FROM venue_services vs
   JOIN service_categories sc ON sc.id = vs.service_category_id
   WHERE vs.venue_id = NEW.id AND vs.is_available = true;

   -- Build the search vector using normalized text
   NEW.search_vector := 
     SETWEIGHT(TO_TSVECTOR('simple', COALESCE(normalize_turkish(NEW.name), '')), 'A') ||
     SETWEIGHT(TO_TSVECTOR('simple', COALESCE(normalize_turkish(NEW.description), '')), 'B') ||
     SETWEIGHT(TO_TSVECTOR('simple', COALESCE(normalize_turkish(NEW.address), '')), 'B') ||
     SETWEIGHT(TO_TSVECTOR('simple', COALESCE(normalize_turkish(province_name), '')), 'A') ||
     SETWEIGHT(TO_TSVECTOR('simple', COALESCE(normalize_turkish(district_name), '')), 'A') ||
     SETWEIGHT(TO_TSVECTOR('simple', COALESCE(service_names, '')), 'B');

   RETURN NEW;
 END;
 $function$;

 -- Fix elastic_search_venues to use sub_category instead of category
 CREATE OR REPLACE FUNCTION elastic_search_venues(
   p_query TEXT,
   p_lat DOUBLE PRECISION DEFAULT NULL,
   p_lng DOUBLE PRECISION DEFAULT NULL,
   p_province_id INTEGER DEFAULT NULL,
   p_district_id UUID DEFAULT NULL,
   p_max_dist_meters DOUBLE PRECISION DEFAULT NULL,
   p_limit INTEGER DEFAULT 20
 )
 RETURNS TABLE (
   id UUID,
   name TEXT,
   description TEXT,
   address TEXT,
   latitude DOUBLE PRECISION,
   longitude DOUBLE PRECISION,
   image_url TEXT,
   hero_images JSONB,
   is_verified BOOLEAN,
   is_preferred BOOLEAN,
   is_hygienic BOOLEAN,
   rating NUMERIC,
   review_count INTEGER,
   province_id INTEGER,
   district_id UUID,
   category_id UUID,
   distance_meters DOUBLE PRECISION,
   search_rank REAL
 ) AS $$
 DECLARE
   normalized_query TEXT;
   tsquery_val TSQUERY;
 BEGIN
   -- Normalize Turkish characters in query
   normalized_query := normalize_turkish(p_query);
   
   -- Create tsquery from normalized query (split by spaces, prefix match)
   tsquery_val := TO_TSQUERY('simple', 
     REGEXP_REPLACE(
       TRIM(normalized_query), 
       '\s+', 
       ':* & ', 
       'g'
     ) || ':*'
   );

   RETURN QUERY
   SELECT 
     v.id,
     v.name,
     v.description,
     v.address,
     v.latitude,
     v.longitude,
     v.image_url,
     v.hero_images,
     v.is_verified,
     v.is_preferred,
     v.is_hygienic,
     v.rating,
     v.review_count,
     v.province_id,
     v.district_id,
     v.category_id,
     CASE 
       WHEN p_lat IS NOT NULL AND p_lng IS NOT NULL THEN
         ST_Distance(
           v.location,
           ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
         )
       ELSE NULL
     END as distance_meters,
     (
       -- Combined ranking: full-text match + trigram similarity
       TS_RANK(v.search_vector, tsquery_val) * 2 +
       GREATEST(
         SIMILARITY(LOWER(v.name), normalized_query),
         SIMILARITY(LOWER(COALESCE(v.address, '')), normalized_query)
       ) +
       -- Boost for province/district match
       CASE 
         WHEN p.name IS NOT NULL AND normalize_turkish(p.name) ILIKE '%' || normalized_query || '%' THEN 1.0
         ELSE 0
       END +
       CASE 
         WHEN d.name IS NOT NULL AND normalize_turkish(d.name) ILIKE '%' || normalized_query || '%' THEN 1.0
         ELSE 0
       END
     )::REAL as search_rank
   FROM venues v
   LEFT JOIN provinces p ON p.id = v.province_id
   LEFT JOIN districts d ON d.id = v.district_id
   WHERE 
     v.is_active = true
     -- Full-text search OR trigram similarity
     AND (
       v.search_vector @@ tsquery_val
       OR SIMILARITY(LOWER(v.name), normalized_query) > 0.2
       OR SIMILARITY(LOWER(COALESCE(v.address, '')), normalized_query) > 0.2
       OR (p.name IS NOT NULL AND normalize_turkish(p.name) ILIKE '%' || normalized_query || '%')
       OR (d.name IS NOT NULL AND normalize_turkish(d.name) ILIKE '%' || normalized_query || '%')
       -- Search in services
       OR EXISTS (
         SELECT 1 
         FROM venue_services vs
         JOIN service_categories sc ON sc.id = vs.service_category_id
         WHERE vs.venue_id = v.id 
           AND vs.is_available = true
           AND (
             SIMILARITY(LOWER(sc.name), normalized_query) > 0.3
             OR normalize_turkish(sc.name) ILIKE '%' || normalized_query || '%'
             OR normalize_turkish(COALESCE(sc.sub_category, '')) ILIKE '%' || normalized_query || '%'
           )
       )
     )
     -- Optional province filter
     AND (p_province_id IS NULL OR v.province_id = p_province_id)
     -- Optional district filter
     AND (p_district_id IS NULL OR v.district_id = p_district_id)
     -- Optional distance filter
     AND (
       p_max_dist_meters IS NULL 
       OR (p_lat IS NOT NULL AND p_lng IS NOT NULL AND 
           ST_DWithin(v.location, ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography, p_max_dist_meters))
     )
   ORDER BY 
     search_rank DESC,
     v.rating DESC,
     distance_meters ASC NULLS LAST
   LIMIT p_limit;
 END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;
