-- Migration: Fix Review Stats and Visibility
-- Description: Updates the rating sync trigger to only include approved reviews and fixes current stats.

-- 1. Update the rating & review count sync function
CREATE OR REPLACE FUNCTION public.update_venue_rating_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- We only want to count and average reviews with 'approved' status
  UPDATE public.venues
  SET
    rating = COALESCE((
      SELECT AVG(rating) 
      FROM public.reviews 
      WHERE venue_id = COALESCE(NEW.venue_id, OLD.venue_id) 
      AND status = 'approved'
    ), 0),
    review_count = (
      SELECT COUNT(*) 
      FROM public.reviews 
      WHERE venue_id = COALESCE(NEW.venue_id, OLD.venue_id) 
      AND status = 'approved'
    )
  WHERE id = COALESCE(NEW.venue_id, OLD.venue_id);
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Recalculate all venue stats once to fix existing issues
UPDATE public.venues v
SET
  rating = COALESCE((
    SELECT AVG(r.rating) 
    FROM public.reviews r 
    WHERE r.venue_id = v.id 
    AND r.status = 'approved'
  ), 0),
  review_count = (
    SELECT COUNT(*) 
    FROM public.reviews r 
    WHERE r.venue_id = v.id 
    AND r.status = 'approved'
  );

-- 3. Ensure get_venue_reviews_advanced also filters by status (it already did, but let's double check RLS)
-- The RLS policy for public already filters status = 'approved', so direct queries from public also work.
