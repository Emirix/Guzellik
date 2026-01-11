-- Migration: Update subscription filters to use venues_subscription table
-- Description: Updates all RLS policies and RPC functions to use venues_subscription instead of business_subscriptions
-- Dependency: Requires 20260111210000_migrate_to_venue_subscriptions.sql

-- 1. Update is_venue_subscribed helper function
CREATE OR REPLACE FUNCTION public.is_venue_subscribed(p_venue_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.venues_subscription vs 
    WHERE vs.venue_id = p_venue_id
      AND vs.status = 'active'
      AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Update RLS policy on venues table
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
      FROM public.venues_subscription vs 
      WHERE vs.venue_id = venues.id 
        AND vs.status = 'active' 
        AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
    )
  )
);

-- 3. Update RLS policy on venue_services table
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
          SELECT 1 FROM public.venues_subscription vs 
          WHERE vs.venue_id = v.id 
          AND vs.status = 'active' 
          AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 4. Update RLS policy on services table
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
          SELECT 1 FROM public.venues_subscription vsub 
          WHERE vsub.venue_id = v.id 
          AND vsub.status = 'active' 
          AND (vsub.expires_at IS NULL OR vsub.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 5. Update RLS policy on campaigns table
DROP POLICY IF EXISTS "Campaigns are viewable by everyone." ON public.campaigns;

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
          SELECT 1 FROM public.venues_subscription vs 
          WHERE vs.venue_id = v.id 
          AND vs.status = 'active' 
          AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 6. Update RLS policy on specialists table
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
          SELECT 1 FROM public.venues_subscription vs 
          WHERE vs.venue_id = v.id 
          AND vs.status = 'active' 
          AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 7. Update RLS policy on venue_photos table
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
          SELECT 1 FROM public.venues_subscription vs 
          WHERE vs.venue_id = v.id 
          AND vs.status = 'active' 
          AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
        )
      )
    )
  )
);

-- 8. Update featured_venues view
DROP VIEW IF EXISTS public.featured_venues;

CREATE OR REPLACE VIEW public.featured_venues AS
SELECT 
  v.*,
  COALESCE(v.rating, 0) as sort_rating
FROM public.venues v
WHERE v.is_active = true
  AND v.rating >= 4.0
  AND EXISTS (
    SELECT 1 
    FROM public.venues_subscription vs 
    WHERE vs.venue_id = v.id 
      AND vs.status = 'active' 
      AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
  )
ORDER BY sort_rating DESC, v.name ASC
LIMIT 10;

-- 9. Update get_nearby_venues RPC
DROP FUNCTION IF EXISTS public.get_nearby_venues(float, float, float);
DROP FUNCTION IF EXISTS public.get_nearby_venues(float, float, float, integer, integer);

CREATE OR REPLACE FUNCTION public.get_nearby_venues(
  p_lat float, 
  p_lng float, 
  p_radius_meters float,
  p_limit integer DEFAULT 20,
  p_offset integer DEFAULT 0
)
RETURNS SETOF venues AS $$
BEGIN
  RETURN QUERY
  SELECT v.*
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


-- 10. Update search_venues_advanced RPC (14 parameters to match Flutter)
DROP FUNCTION IF EXISTS public.search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID);
DROP FUNCTION IF EXISTS public.search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID, TEXT);
DROP FUNCTION IF EXISTS public.search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID, TEXT, UUID[], INTEGER, INTEGER);

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
  p_category_id UUID DEFAULT NULL,
  p_sort_by TEXT DEFAULT 'recommended',
  p_service_ids UUID[] DEFAULT NULL,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
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
  features TEXT[],
  is_following BOOLEAN,
  follower_count INTEGER,
  is_favorited BOOLEAN
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
    ) as features,
    EXISTS(SELECT 1 FROM follows f WHERE f.venue_id = v.id AND f.user_id = auth.uid()) as is_following,
    (SELECT COUNT(*)::INTEGER FROM follows f WHERE f.venue_id = v.id) as follower_count,
    EXISTS(SELECT 1 FROM user_favorites uf WHERE uf.venue_id = v.id AND uf.user_id = auth.uid()) as is_favorited
  FROM venues v
  LEFT JOIN venue_categories vc ON vc.id = v.category_id
  WHERE 
    v.is_active = true
    AND (
      -- SUBSCRIPTION FILTER
      EXISTS (
        SELECT 1 
        FROM public.venues_subscription vs 
        WHERE vs.venue_id = v.id 
          AND vs.status = 'active' 
          AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
      )
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
      p_service_ids IS NULL OR ARRAY_LENGTH(p_service_ids, 1) = 0 OR
      EXISTS (
        SELECT 1 
        FROM venue_services vs
        WHERE vs.venue_id = v.id 
          AND vs.is_active = true
          AND vs.service_category_id = ANY(p_service_ids)
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
    v.name ASC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Update elastic_search_venues RPC (14 parameters to match Flutter)
DROP FUNCTION IF EXISTS public.elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, INTEGER);
DROP FUNCTION IF EXISTS public.elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, INTEGER, UUID[]);
DROP FUNCTION IF EXISTS public.elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, UUID[], INTEGER, INTEGER);

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
  p_service_ids UUID[] DEFAULT NULL,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
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
  features TEXT[],
  is_following BOOLEAN,
  follower_count INTEGER,
  is_favorited BOOLEAN
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
    ) as features,
    EXISTS(SELECT 1 FROM follows f WHERE f.venue_id = v.id AND f.user_id = auth.uid()) as is_following,
    (SELECT COUNT(*)::INTEGER FROM follows f WHERE f.venue_id = v.id) as follower_count,
    EXISTS(SELECT 1 FROM user_favorites uf WHERE uf.venue_id = v.id AND uf.user_id = auth.uid()) as is_favorited
  FROM venues v
  LEFT JOIN provinces p ON p.id = v.province_id
  LEFT JOIN districts d ON d.id = v.district_id
  WHERE 
    v.is_active = true
    AND (
      -- SUBSCRIPTION FILTER
      EXISTS (
        SELECT 1 
        FROM public.venues_subscription vs 
        WHERE vs.venue_id = v.id 
          AND vs.status = 'active' 
          AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
      )
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
      p_service_ids IS NULL OR ARRAY_LENGTH(p_service_ids, 1) = 0 OR
      EXISTS (
        SELECT 1 
        FROM venue_services vs
        WHERE vs.venue_id = v.id 
          AND vs.is_active = true
          AND vs.service_category_id = ANY(p_service_ids)
      )
    )
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
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. Update search_venues_by_service RPC
DROP FUNCTION IF EXISTS public.search_venues_by_service(UUID);

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
    AND (
      EXISTS (
        SELECT 1 
        FROM public.venues_subscription vsub 
        WHERE vsub.venue_id = v.id 
          AND vsub.status = 'active' 
          AND (vsub.expires_at IS NULL OR vsub.expires_at > timezone('utc'::text, now()))
      )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 13. Grant permissions
GRANT EXECUTE ON FUNCTION public.is_venue_subscribed(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_nearby_venues(float, float, float, integer, integer) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.search_venues_advanced(TEXT, TEXT[], DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, UUID, TEXT, UUID[], INTEGER, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.elastic_search_venues(TEXT, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, DOUBLE PRECISION, BOOLEAN, BOOLEAN, BOOLEAN, DOUBLE PRECISION, TEXT, UUID[], INTEGER, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.search_venues_by_service(UUID) TO anon, authenticated;


