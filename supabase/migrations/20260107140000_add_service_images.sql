-- Migration: Add image support to services
-- Description: Adds image_url to service_categories (default) and services (custom)
-- Updates get_venue_services RPC to include derived image_url

-- 1. Add image_url to service_categories (Default image)
ALTER TABLE public.service_categories
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 2. Add image_url to services (Custom image by venue)
ALTER TABLE public.services
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 3. Update get_venue_services RPC to return derived image_url
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
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(s.id, vs.id) as id, -- Fallback to vs.id if s doesn't exist
    vs.venue_id,
    vs.id as venue_service_id,
    COALESCE(s.name, sc.name) as name,
    sc.category,
    COALESCE(vs.custom_price, 0::numeric) as price,
    COALESCE(vs.custom_duration_minutes, sc.average_duration_minutes) as duration,
    s.description,
    s.before_photo_url,
    s.after_photo_url,
    s.expert_name,
    COALESCE(s.image_url, sc.image_url) as image_url,
    COALESCE(s.created_at, vs.created_at) as created_at
  FROM venue_services vs
  JOIN service_categories sc ON sc.id = vs.service_category_id
  LEFT JOIN services s ON s.venue_service_id = vs.id
  WHERE vs.venue_id = p_venue_id
    AND vs.is_available = true
  ORDER BY sc.category, sc.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Set some default images for categories
UPDATE public.service_categories
SET image_url = 'https://images.unsplash.com/photo-1562322140-8baeececf3df?q=80&w=1000'
WHERE category LIKE 'Kuaför%';

UPDATE public.service_categories
SET image_url = 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?q=80&w=1000'
WHERE category LIKE 'Tırnak%';

UPDATE public.service_categories
SET image_url = 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000'
WHERE category LIKE 'Cilt%';

UPDATE public.service_categories
SET image_url = 'https://images.unsplash.com/photo-1544161515-4af6b1d462c2?q=80&w=1000'
WHERE category LIKE 'Masaj%';

UPDATE public.service_categories
SET image_url = 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?q=80&w=1000'
WHERE category LIKE 'Makyaj%';

UPDATE public.service_categories
SET image_url = 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'
WHERE category LIKE 'Epilasyon%';

UPDATE public.service_categories
SET image_url = 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000'
WHERE category LIKE 'Hamam%';

-- 5. Update popular_services view to include image_url
CREATE OR REPLACE VIEW popular_services AS
SELECT
  sc.id,
  sc.name,
  sc.icon,
  sc.image_url,
  COUNT(DISTINCT vs.venue_id) as venue_count,
  0 as search_count
FROM service_categories sc
LEFT JOIN venue_services vs ON sc.id = vs.service_category_id
WHERE vs.is_available = true
GROUP BY sc.id, sc.name, sc.icon, sc.image_url
HAVING COUNT(DISTINCT vs.venue_id) > 0
ORDER BY venue_count DESC, sc.name ASC
LIMIT 20;

GRANT SELECT ON popular_services TO anon, authenticated;
