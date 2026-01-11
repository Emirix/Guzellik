-- Migration: Add hero_images to search_venues_advanced
-- Description: Updates search_venues_advanced to include hero_images field for map view

DROP FUNCTION IF EXISTS search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID);

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
  hero_images JSONB,
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
    COALESCE(
      (
        SELECT jsonb_agg(vp.url ORDER BY vp.sort_order)
        FROM venue_photos vp
        WHERE vp.venue_id = v.id
      ),
      '[]'::jsonb
    ) as hero_images,
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

GRANT EXECUTE ON FUNCTION search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID) TO anon, authenticated;
