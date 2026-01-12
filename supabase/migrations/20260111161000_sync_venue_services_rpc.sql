-- Migration: Sync venue services RPC with admin panel customization
-- Description: Updates get_venue_services, search_venues_advanced, and elastic_search_venues 
-- to include custom_name, correct price/duration, sort_order and sub_category.

-- First, DROP existing functions because their return types (OUT parameters) are changing
DROP FUNCTION IF EXISTS get_venue_services(UUID);
DROP FUNCTION IF EXISTS search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID);
DROP FUNCTION IF EXISTS elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, INTEGER);
DROP FUNCTION IF EXISTS search_venues_by_service(UUID);

-- 1. Update get_venue_services RPC
CREATE OR REPLACE FUNCTION get_venue_services(p_venue_id UUID)
RETURNS TABLE (
  id UUID,
  venue_id UUID,
  venue_service_id UUID,
  name TEXT,
  category TEXT,
  price NUMERIC,
  duration INTEGER,
  description TEXT,
  before_photo_url TEXT,
  after_photo_url TEXT,
  expert_name TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  sort_order INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(s.id, vs.id) as id,
    vs.venue_id,
    vs.id as venue_service_id,
    COALESCE(vs.custom_name, s.name, sc.name) as name,
    sc.sub_category as category, -- category column was removed, using sub_category
    COALESCE(vs.price, 0::numeric) as price,
    COALESCE(vs.duration_minutes, sc.average_duration_minutes) as duration,
    COALESCE(vs.custom_description, s.description, sc.description) as description,
    s.before_photo_url,
    s.after_photo_url,
    s.expert_name,
    COALESCE(vs.custom_image_url, s.image_url, sc.image_url) as image_url,
    COALESCE(s.created_at, vs.created_at) as created_at,
    COALESCE(vs.sort_order, 0) as sort_order
  FROM venue_services vs
  JOIN service_categories sc ON sc.id = vs.service_category_id
  LEFT JOIN services s ON s.venue_service_id = vs.id
  WHERE vs.venue_id = p_venue_id
    AND vs.is_active = true
  ORDER BY vs.sort_order ASC, name ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Update search_venues_advanced to include custom service names in features
CREATE OR REPLACE FUNCTION search_venues_advanced(
  p_query TEXT DEFAULT NULL,
  p_categories TEXT[] DEFAULT NULL,
  p_lat DOUBLE PRECISION DEFAULT NULL,
  p_lng DOUBLE PRECISION DEFAULT NULL,
  p_max_dist_meters DOUBLE PRECISION DEFAULT NULL,
  p_only_verified BOOLEAN DEFAULT FALSE,
  p_only_preferred BOOLEAN DEFAULT FALSE,
  p_only_hygienic BOOLEAN DEFAULT FALSE,
  p_min_rating DOUBLE PRECISION DEFAULT NULL,
  p_category_id UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  description TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  image_url TEXT,
  is_verified BOOLEAN,
  is_preferred BOOLEAN,
  is_hygienic BOOLEAN,
  rating NUMERIC,
  review_count INTEGER,
  distance_meters DOUBLE PRECISION,
  category_id UUID,
  category_name TEXT,
  category_icon TEXT,
  features TEXT[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    v.id,
    v.name,
    v.description,
    v.address,
    v.latitude,
    v.longitude,
    v.image_url,
    v.is_verified,
    v.is_preferred,
    v.is_hygienic,
    v.rating,
    v.review_count,
    CASE 
      WHEN p_lat IS NOT NULL AND p_lng IS NOT NULL THEN
        ST_Distance(
          v.location,
          ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
        )
      ELSE NULL
    END as distance_meters,
    v.category_id,
    vc.name as category_name,
    vc.icon as category_icon,
    COALESCE(
      (
        SELECT ARRAY_AGG(COALESCE(vs_inner.custom_name, sc_inner.name) ORDER BY vs_inner.sort_order ASC)
        FROM venue_services vs_inner
        JOIN service_categories sc_inner ON sc_inner.id = vs_inner.service_category_id 
        WHERE vs_inner.venue_id = v.id AND vs_inner.is_active = true
      ),
      '{}'::TEXT[]
    ) as features
  FROM venues v
  LEFT JOIN venue_categories vc ON vc.id = v.category_id
  WHERE 
    v.is_active = true
    AND (
      p_query IS NULL OR 
      v.name ILIKE '%' || p_query || '%' OR 
      v.description ILIKE '%' || p_query || '%' OR 
      v.address ILIKE '%' || p_query || '%'
    )
    AND (
      p_category_id IS NULL OR v.category_id = p_category_id
    )
    AND (
      p_categories IS NULL OR ARRAY_LENGTH(p_categories, 1) = 0 OR
      vc.name = ANY(p_categories) OR
      EXISTS (
        SELECT 1 
        FROM venue_services vs
        JOIN service_categories sc ON sc.id = vs.service_category_id
        WHERE vs.venue_id = v.id 
          AND vs.is_active = true
          AND (sc.sub_category = ANY(p_categories))
      )
    )
    AND (
      p_max_dist_meters IS NULL OR 
      (p_lat IS NOT NULL AND p_lng IS NOT NULL AND 
       ST_DWithin(v.location, ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography, p_max_dist_meters))
    )
    AND (NOT p_only_verified OR v.is_verified = true)
    AND (NOT p_only_preferred OR v.is_preferred = true)
    AND (NOT p_only_hygienic OR v.is_hygienic = true)
    AND (p_min_rating IS NULL OR v.rating >= p_min_rating)
  ORDER BY 
    CASE WHEN p_lat IS NOT NULL AND p_lng IS NOT NULL THEN 
      ST_Distance(v.location, ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography) 
    ELSE 0 END ASC,
    v.rating DESC,
    v.name ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Update elastic_search_venues to include custom service names in features
CREATE OR REPLACE FUNCTION elastic_search_venues(
  p_query TEXT,
  p_lat DOUBLE PRECISION DEFAULT NULL,
  p_lng DOUBLE PRECISION DEFAULT NULL,
  p_province_id INTEGER DEFAULT NULL,
  p_district_id UUID DEFAULT NULL,
  p_max_dist_meters DOUBLE PRECISION DEFAULT NULL,
  p_only_verified BOOLEAN DEFAULT FALSE,
  p_only_preferred BOOLEAN DEFAULT FALSE,
  p_only_hygienic BOOLEAN DEFAULT FALSE,
  p_min_rating DOUBLE PRECISION DEFAULT NULL,
  p_sort_by TEXT DEFAULT 'recommended',
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
  search_rank REAL,
  features TEXT[]
) AS $$
DECLARE
  normalized_query TEXT;
  tsquery_val TSQUERY;
BEGIN
  normalized_query := normalize_turkish(p_query);
  
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
      TS_RANK(v.search_vector, tsquery_val) * 2 +
      GREATEST(
        SIMILARITY(LOWER(v.name), normalized_query),
        SIMILARITY(LOWER(COALESCE(v.address, '')), normalized_query)
      ) +
      CASE 
        WHEN p.name IS NOT NULL AND normalize_turkish(p.name) ILIKE '%' || normalized_query || '%' THEN 1.0
        ELSE 0
      END +
      CASE 
        WHEN d.name IS NOT NULL AND normalize_turkish(d.name) ILIKE '%' || normalized_query || '%' THEN 1.0
        ELSE 0
      END
    )::REAL as search_rank,
    COALESCE(
      (
        SELECT ARRAY_AGG(COALESCE(vs_inner.custom_name, sc_inner.name) ORDER BY vs_inner.sort_order ASC)
        FROM venue_services vs_inner
        JOIN service_categories sc_inner ON sc_inner.id = vs_inner.service_category_id 
        WHERE vs_inner.venue_id = v.id AND vs_inner.is_active = true
      ),
      '{}'::TEXT[]
    ) as features
  FROM venues v
  LEFT JOIN provinces p ON p.id = v.province_id
  LEFT JOIN districts d ON d.id = v.district_id
  WHERE 
    v.is_active = true
    AND (
      v.search_vector @@ tsquery_val
      OR SIMILARITY(LOWER(v.name), normalized_query) > 0.2
      OR SIMILARITY(LOWER(COALESCE(v.address, '')), normalized_query) > 0.2
      OR (p.name IS NOT NULL AND normalize_turkish(p.name) ILIKE '%' || normalized_query || '%')
      OR (d.name IS NOT NULL AND normalize_turkish(d.name) ILIKE '%' || normalized_query || '%')
      OR EXISTS (
        SELECT 1 
        FROM venue_services vs
        JOIN service_categories sc ON sc.id = vs.service_category_id
        WHERE vs.venue_id = v.id 
          AND vs.is_active = true
          AND (
            SIMILARITY(LOWER(sc.name), normalized_query) > 0.3
            OR normalize_turkish(sc.name) ILIKE '%' || normalized_query || '%'
            OR normalize_turkish(sc.sub_category) ILIKE '%' || normalized_query || '%'
          )
      )
    )
    AND (p_province_id IS NULL OR v.province_id = p_province_id)
    AND (p_district_id IS NULL OR v.district_id = p_district_id)
    AND (
      p_max_dist_meters IS NULL 
      OR (p_lat IS NOT NULL AND p_lng IS NOT NULL AND 
          ST_DWithin(v.location, ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography, p_max_dist_meters))
    )
    AND (NOT p_only_verified OR v.is_verified = true)
    AND (NOT p_only_preferred OR v.is_preferred = true)
    AND (NOT p_only_hygienic OR v.is_hygienic = true)
    AND (p_min_rating IS NULL OR v.rating >= p_min_rating)
  ORDER BY 
    CASE WHEN p_sort_by = 'distance' AND p_lat IS NOT NULL AND p_lng IS NOT NULL THEN distance_meters END ASC NULLS LAST,
    CASE WHEN p_sort_by = 'rating' THEN v.rating END DESC,
    search_rank DESC,
    v.rating DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Fix update_venue_search_vector to include custom_name and sub_category
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

   -- Get all service names for this venue, including custom names
   SELECT STRING_AGG(
     normalize_turkish(COALESCE(vs.custom_name, sc.name)) || ' ' || 
     normalize_turkish(COALESCE(sc.sub_category, '')), 
     ' '
   ) INTO service_names
   FROM venue_services vs
   JOIN service_categories sc ON sc.id = vs.service_category_id
   WHERE vs.venue_id = NEW.id AND vs.is_active = true;

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

-- 5. Update search_venues_by_service RPC
CREATE OR REPLACE FUNCTION search_venues_by_service(p_service_category_id UUID)
RETURNS TABLE (
  id UUID,
  name TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  rating NUMERIC,
  review_count INTEGER,
  image_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    v.id,
    v.name,
    v.address,
    v.latitude,
    v.longitude,
    v.rating,
    v.review_count,
    v.image_url
  FROM venues v
  JOIN venue_services vs ON vs.venue_id = v.id
  WHERE vs.service_category_id = p_service_category_id
    AND vs.is_active = true
    AND v.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions again
GRANT EXECUTE ON FUNCTION search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_venue_services(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION search_venues_by_service(UUID) TO anon, authenticated;
