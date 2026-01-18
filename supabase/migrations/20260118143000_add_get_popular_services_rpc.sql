-- Migration: Add get_popular_services RPC
-- Description: Returns a list of the most popular service categories based on venue counts.

CREATE OR REPLACE FUNCTION public.get_popular_services(p_limit INTEGER DEFAULT 7)
RETURNS TABLE (
  id UUID,
  name TEXT,
  icon TEXT,
  image_url TEXT,
  venue_count BIGINT
) 
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 
    sc.id,
    sc.name,
    sc.icon,
    sc.image_url,
    COUNT(DISTINCT vs.venue_id) as venue_count
  FROM public.service_categories sc
  JOIN public.venue_services vs ON sc.id = vs.service_category_id
  WHERE vs.is_available = true
  GROUP BY sc.id, sc.name, sc.icon, sc.image_url
  ORDER BY venue_count DESC, sc.name ASC
  LIMIT p_limit;
$$;

-- Grant access to the function
GRANT EXECUTE ON FUNCTION public.get_popular_services(INTEGER) TO anon, authenticated;
