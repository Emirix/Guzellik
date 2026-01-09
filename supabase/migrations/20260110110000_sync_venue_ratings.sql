-- Migration: Sync venue ratings from reviews
-- Description: One-time sync to calculate rating and review_count from actual reviews data
-- This fixes the issue where venues have 0 rating/review_count despite having reviews

-- Update all venues with their actual rating and review count from reviews table
UPDATE venues v SET
  rating = COALESCE(
    (SELECT AVG(r.rating) FROM reviews r WHERE r.venue_id = v.id),
    0
  ),
  review_count = (
    SELECT COUNT(*) FROM reviews r WHERE r.venue_id = v.id
  );

-- Add a comment explaining this was a one-time fix
COMMENT ON COLUMN venues.rating IS 'Average rating from reviews. Auto-updated by trigger_update_venue_rating on reviews table changes.';
COMMENT ON COLUMN venues.review_count IS 'Total number of reviews. Auto-updated by trigger_update_venue_rating on reviews table changes.';
