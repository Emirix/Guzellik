-- Migration: Fix get_business_venue to include hero images
-- Description: Updates get_business_venue RPC to populate hero_images from venue_photos table

DROP FUNCTION IF EXISTS get_business_venue(UUID);

CREATE OR REPLACE FUNCTION get_business_venue(p_profile_id UUID)
RETURNS TABLE (
  id UUID,
  name TEXT,
  description TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  image_url TEXT,
  hero_images JSONB,
  category_id UUID,
  icon TEXT,
  is_verified BOOLEAN,
  is_preferred BOOLEAN,
  is_hygienic BOOLEAN,
  working_hours JSONB,
  expert_team JSONB,
  certifications JSONB,
  payment_options JSONB,
  accessibility JSONB,
  faq JSONB,
  social_links JSONB,
  features JSONB,
  owner_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  rating NUMERIC,
  review_count INTEGER,
  province_id INTEGER,
  district_id UUID
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
    -- Populate hero_images from venue_photos table
    COALESCE(
      (
        SELECT jsonb_agg(vp.url ORDER BY vp.sort_order)
        FROM venue_photos vp
        WHERE vp.venue_id = v.id
      ),
      '[]'::jsonb
    ) as hero_images,
    v.category_id,
    v.icon,
    v.is_verified,
    v.is_preferred,
    v.is_hygienic,
    v.working_hours,
    v.expert_team,
    v.certifications,
    v.payment_options,
    v.accessibility,
    v.faq,
    v.social_links,
    v.features,
    v.owner_id,
    v.created_at,
    v.rating,
    v.review_count,
    v.province_id,
    v.district_id
  FROM public.venues v
  WHERE v.id = (
    -- First try to get business_venue_id from profile
    SELECT COALESCE(
      (SELECT p.business_venue_id FROM profiles p WHERE p.id = p_profile_id),
      -- If not set, get first venue owned by user
      (SELECT v2.id FROM venues v2 WHERE v2.owner_id = p_profile_id LIMIT 1)
    )
  )
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
