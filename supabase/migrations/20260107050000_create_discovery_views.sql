-- Migration: Create popular services and featured venues views
-- Description: Creates views for discovering popular services and featured venues

-- Create popular_services view
-- This view aggregates services by their popularity based on venue count
CREATE OR REPLACE VIEW popular_services AS
SELECT 
  s.id,
  s.name,
  s.icon,
  COUNT(DISTINCT vs.venue_id) as venue_count,
  0 as search_count -- Placeholder for future search tracking
FROM services s
LEFT JOIN venue_services vs ON s.id = vs.service_id
GROUP BY s.id, s.name, s.icon
HAVING COUNT(DISTINCT vs.venue_id) > 0
ORDER BY venue_count DESC, s.name ASC
LIMIT 20;

-- Create featured_venues view
-- This view shows high-rated venues that can be featured on the home screen
CREATE OR REPLACE VIEW featured_venues AS
SELECT 
  v.*,
  COALESCE(v.rating, 0) as sort_rating
FROM venues v
WHERE v.is_active = true
  AND v.rating >= 4.0
ORDER BY sort_rating DESC, v.name ASC
LIMIT 10;

-- Grant permissions
GRANT SELECT ON popular_services TO anon, authenticated;
GRANT SELECT ON featured_venues TO anon, authenticated;
