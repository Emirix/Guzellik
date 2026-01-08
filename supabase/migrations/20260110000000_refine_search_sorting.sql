-- Migration: Enhance search sorting
-- Description: Adds sorting options to search_venues_advanced and updates elastic_search_venues sorting logic

-- Drop existing functions to update parameters/return logic
DROP FUNCTION IF EXISTS search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID);
DROP FUNCTION IF EXISTS elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, INTEGER);

-- 1. Update search_venues_advanced with p_sort_by
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
  p_category_id UUID DEFAULT NULL,
  p_sort_by TEXT DEFAULT 'recommended'
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
        SELECT ARRAY_AGG(sc.name) 
        FROM venue_services vs 
        JOIN service_categories sc ON sc.id = vs.service_category_id 
        WHERE vs.venue_id = v.id AND vs.is_available = true
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
          AND vs.is_available = true
          AND sc.category = ANY(p_categories)
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
    CASE WHEN p_sort_by = 'nearest' AND p_lat IS NOT NULL AND p_lng IS NOT NULL THEN 
      ST_Distance(v.location, ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography) 
    END ASC NULLS LAST,
    CASE WHEN p_sort_by = 'highestRated' THEN v.rating END DESC,
    CASE WHEN p_sort_by = 'mostReviewed' THEN v.review_count END DESC,
    CASE WHEN p_sort_by = 'recommended' THEN v.rating END DESC,
    v.name ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Update elastic_search_venues sorting logic
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
        SELECT ARRAY_AGG(sc.name) 
        FROM venue_services vs 
        JOIN service_categories sc ON sc.id = vs.service_category_id 
        WHERE vs.venue_id = v.id AND vs.is_available = true
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
          AND vs.is_available = true
          AND (
            SIMILARITY(LOWER(sc.name), normalized_query) > 0.3
            OR normalize_turkish(sc.name) ILIKE '%' || normalized_query || '%'
            OR normalize_turkish(sc.category) ILIKE '%' || normalized_query || '%'
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
    CASE WHEN p_sort_by = 'nearest' AND p_lat IS NOT NULL AND p_lng IS NOT NULL THEN 
      ST_Distance(v.location, ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography) 
    END ASC NULLS LAST,
    CASE WHEN p_sort_by = 'highestRated' THEN v.rating END DESC,
    CASE WHEN p_sort_by = 'mostReviewed' THEN v.review_count END DESC,
    search_rank DESC,
    v.rating DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, INTEGER) TO anon, authenticated;
