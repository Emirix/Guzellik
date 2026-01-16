-- Migration: Update get_nearby_venues to return distance_meters
-- Description: Changes get_nearby_venues to return a table including the calculated distance for UI display

DROP FUNCTION IF EXISTS public.get_nearby_venues(float, float, float);
DROP FUNCTION IF EXISTS public.get_nearby_venues(float, float, float, integer, integer);

CREATE OR REPLACE FUNCTION public.get_nearby_venues(
  p_lat float, 
  p_lng float, 
  p_radius_meters float,
  p_limit integer DEFAULT 20,
  p_offset integer DEFAULT 0
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
  features JSONB,
  follower_count INTEGER,
  is_active BOOLEAN,
  icon TEXT
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
    v.hero_images,
    v.is_verified,
    v.is_preferred,
    v.is_hygienic,
    v.rating,
    v.review_count,
    ST_Distance(
      v.location,
      ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
    ) as distance_meters,
    v.category_id,
    v.features,
    v.follower_count,
    v.is_active,
    v.icon
  FROM venues v
  WHERE v.is_active = true
    AND ST_DWithin(
      v.location,
      ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
      p_radius_meters
    )
    AND EXISTS (
      SELECT 1 
      FROM public.venues_subscription vs 
      WHERE vs.venue_id = v.id 
        AND vs.status = 'active' 
        AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
    )
  ORDER BY v.location <-> ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.get_nearby_venues(float, float, float, integer, integer) TO anon, authenticated;
