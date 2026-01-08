-- Migration: Add Elastic Search with Full-Text Search
-- Description: Enables comprehensive fuzzy search across venues, locations, and services

-- 1. Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- 2. Create Turkish-friendly text normalization function
CREATE OR REPLACE FUNCTION normalize_turkish(input_text TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN LOWER(
    TRANSLATE(
      input_text,
      'ÇŞĞÜÖİçşğüöı',
      'CSGUOIcsguoi'
    )
  );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 3. Add search_vector column to venues table
ALTER TABLE public.venues 
ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- 4. Create GIN index for fast full-text search
CREATE INDEX IF NOT EXISTS idx_venues_search_vector 
ON public.venues USING GIN(search_vector);

-- 5. Create trigram indexes for fuzzy matching
CREATE INDEX IF NOT EXISTS idx_venues_name_trgm 
ON public.venues USING GIN(LOWER(name) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_venues_address_trgm 
ON public.venues USING GIN(LOWER(address) gin_trgm_ops);

-- 6. Create function to update search vector
CREATE OR REPLACE FUNCTION update_venue_search_vector()
RETURNS TRIGGER AS $$
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

  -- Get all service names for this venue
  SELECT STRING_AGG(sc.name || ' ' || sc.category, ' ') INTO service_names
  FROM venue_services vs
  JOIN service_categories sc ON sc.id = vs.service_category_id
  WHERE vs.venue_id = NEW.id AND vs.is_available = true;

  -- Build the search vector
  NEW.search_vector := 
    SETWEIGHT(TO_TSVECTOR('simple', COALESCE(NEW.name, '')), 'A') ||
    SETWEIGHT(TO_TSVECTOR('simple', COALESCE(NEW.description, '')), 'B') ||
    SETWEIGHT(TO_TSVECTOR('simple', COALESCE(NEW.address, '')), 'B') ||
    SETWEIGHT(TO_TSVECTOR('simple', COALESCE(province_name, '')), 'A') ||
    SETWEIGHT(TO_TSVECTOR('simple', COALESCE(district_name, '')), 'A') ||
    SETWEIGHT(TO_TSVECTOR('simple', COALESCE(service_names, '')), 'B');

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Create trigger for automatic search vector updates
DROP TRIGGER IF EXISTS trigger_update_venue_search_vector ON public.venues;
CREATE TRIGGER trigger_update_venue_search_vector
  BEFORE INSERT OR UPDATE ON public.venues
  FOR EACH ROW
  EXECUTE FUNCTION update_venue_search_vector();

-- 8. Update existing venues to populate search_vector
UPDATE public.venues SET name = name WHERE id IS NOT NULL;

-- 9. Create the elastic search RPC function
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
            OR normalize_turkish(sc.category) ILIKE '%' || normalized_query || '%'
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

-- 10. Grant execute permissions
GRANT EXECUTE ON FUNCTION elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION normalize_turkish(TEXT) TO anon, authenticated;

-- 11. Create a helper function to refresh venue search vector (for service changes)
CREATE OR REPLACE FUNCTION refresh_venue_search_vector(p_venue_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE venues 
  SET name = name  -- This triggers the search vector update
  WHERE id = p_venue_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION refresh_venue_search_vector(UUID) TO anon, authenticated;

-- 12. Create trigger to refresh search vector when venue_services change
CREATE OR REPLACE FUNCTION trigger_refresh_venue_search_on_service_change()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM refresh_venue_search_vector(COALESCE(NEW.venue_id, OLD.venue_id));
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_venue_services_search_update ON public.venue_services;
CREATE TRIGGER trigger_venue_services_search_update
  AFTER INSERT OR UPDATE OR DELETE ON public.venue_services
  FOR EACH ROW
  EXECUTE FUNCTION trigger_refresh_venue_search_on_service_change();
