-- Migration: Enforce business subscription status for venue visibility
-- Description: Ensures that only venues with active subscriptions are visible to users.

-- 1. DROP existing functions to avoid "cannot change return type" errors
DROP FUNCTION IF EXISTS public.get_nearby_venues(double precision, double precision, double precision);
DROP FUNCTION IF EXISTS public.get_nearby_venues(float, float, float);
DROP FUNCTION IF EXISTS public.search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID);
DROP FUNCTION IF EXISTS public.elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, INTEGER);
DROP FUNCTION IF EXISTS public.search_venues_by_service(UUID);

-- 2. Create a helper function to check if a venue has an active subscription
CREATE OR REPLACE FUNCTION public.is_venue_subscribed(p_venue_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_owner_id UUID;
BEGIN
  SELECT owner_id INTO v_owner_id FROM public.venues WHERE id = p_venue_id;
  
  IF v_owner_id IS NULL THEN
    RETURN FALSE;
  END IF;

  RETURN EXISTS (
    SELECT 1 
    FROM public.business_subscriptions bs 
    WHERE bs.profile_id = v_owner_id
      AND bs.status = 'active'
      AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Update RLS on venues table
DROP POLICY IF EXISTS "Venues are viewable by everyone." ON public.venues;

CREATE POLICY "Venues are viewable by everyone." ON public.venues 
FOR SELECT 
USING (
  is_active = true 
  AND (
    auth.uid() = owner_id 
    OR 
    EXISTS (
      SELECT 1 
      FROM public.business_subscriptions bs 
      WHERE bs.profile_id = venues.owner_id 
        AND bs.status = 'active' 
        AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
    )
  )
);

-- 4. Update featured_venues view
CREATE OR REPLACE VIEW public.featured_venues AS
SELECT 
  v.*,
  COALESCE(v.rating, 0) as sort_rating
FROM public.venues v
WHERE v.is_active = true
  AND v.rating >= 4.0
  AND EXISTS (
    SELECT 1 
    FROM public.business_subscriptions bs 
    WHERE bs.profile_id = v.owner_id 
      AND bs.status = 'active' 
      AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
  )
ORDER BY sort_rating DESC, v.name ASC
LIMIT 10;

-- 5. get_nearby_venues RPC
CREATE OR REPLACE FUNCTION public.get_nearby_venues(lat float, lng float, radius_meters float)
RETURNS SETOF venues AS $$
BEGIN
  RETURN QUERY
  SELECT v.*
  FROM venues v
  WHERE v.is_active = true
    AND ST_DWithin(
      v.location,
      ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
      radius_meters
    )
    AND EXISTS (
      SELECT 1 
      FROM public.business_subscriptions bs 
      WHERE bs.profile_id = v.owner_id 
        AND bs.status = 'active' 
        AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
    )
  ORDER BY v.location <-> ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. search_venues_advanced RPC
CREATE OR REPLACE FUNCTION public.search_venues_advanced(
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
    AND EXISTS (
      SELECT 1 
      FROM public.business_subscriptions bs 
      WHERE bs.profile_id = v.owner_id 
        AND bs.status = 'active' 
        AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
    )
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

-- 7. elastic_search_venues RPC
CREATE OR REPLACE FUNCTION public.elastic_search_venues(
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
    AND EXISTS (
      SELECT 1 
      FROM public.business_subscriptions bs 
      WHERE bs.profile_id = v.owner_id 
        AND bs.status = 'active' 
        AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
    )
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

-- 8. search_venues_by_service RPC
CREATE OR REPLACE FUNCTION public.search_venues_by_service(p_service_category_id UUID)
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
    AND v.is_active = true
    AND EXISTS (
      SELECT 1 
      FROM public.business_subscriptions bs 
      WHERE bs.profile_id = v.owner_id 
        AND bs.status = 'active' 
        AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. venue_services RLS
ALTER TABLE public.venue_services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Venue services are viewable by everyone." ON public.venue_services;
CREATE POLICY "Venue services are viewable by everyone." ON public.venue_services 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.venues v
    WHERE v.id = venue_services.venue_id
    AND (
      v.is_active = true 
      AND (
        auth.uid() = v.owner_id 
        OR 
        EXISTS (
          SELECT 1 FROM public.business_subscriptions bs 
          WHERE bs.profile_id = v.owner_id 
          AND bs.status = 'active' 
          AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 10. services RLS
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Services are viewable by everyone." ON public.services;
CREATE POLICY "Services are viewable by everyone." ON public.services 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.venue_services vs
    JOIN public.venues v ON v.id = vs.venue_id
    WHERE vs.id = services.venue_service_id
    AND (
      v.is_active = true 
      AND (
        auth.uid() = v.owner_id 
        OR 
        EXISTS (
          SELECT 1 FROM public.business_subscriptions bs 
          WHERE bs.profile_id = v.owner_id 
          AND bs.status = 'active' 
          AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 11. campaigns RLS
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view active campaigns" ON public.campaigns;
DROP POLICY IF EXISTS "Authenticated users can view all campaigns" ON public.campaigns;

CREATE POLICY "Campaigns are viewable by everyone." ON public.campaigns
FOR SELECT
USING (
  is_active = true 
  AND end_date > timezone('utc'::text, now())
  AND EXISTS (
    SELECT 1 FROM public.venues v
    WHERE v.id = campaigns.venue_id
    AND (
      v.is_active = true 
      AND (
        auth.uid() = v.owner_id 
        OR 
        EXISTS (
          SELECT 1 FROM public.business_subscriptions bs 
          WHERE bs.profile_id = v.owner_id 
          AND bs.status = 'active' 
          AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 12. specialists RLS
ALTER TABLE public.specialists ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Specialists are viewable by everyone." ON public.specialists;
CREATE POLICY "Specialists are viewable by everyone." ON public.specialists 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.venues v
    WHERE v.id = specialists.venue_id
    AND (
      v.is_active = true 
      AND (
        auth.uid() = v.owner_id 
        OR 
        EXISTS (
          SELECT 1 FROM public.business_subscriptions bs 
          WHERE bs.profile_id = v.owner_id 
          AND bs.status = 'active' 
          AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 13. venue_photos RLS
ALTER TABLE public.venue_photos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Venue photos are viewable by everyone." ON public.venue_photos;
CREATE POLICY "Venue photos are viewable by everyone." ON public.venue_photos 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.venues v
    WHERE v.id = venue_photos.venue_id
    AND (
      v.is_active = true 
      AND (
        auth.uid() = v.owner_id 
        OR 
        EXISTS (
          SELECT 1 FROM public.business_subscriptions bs 
          WHERE bs.profile_id = v.owner_id 
          AND bs.status = 'active' 
          AND (bs.expires_at IS NULL OR bs.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 14. Grant permissions
GRANT EXECUTE ON FUNCTION public.get_nearby_venues(float, float, float) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.search_venues_by_service(UUID) TO anon, authenticated;
