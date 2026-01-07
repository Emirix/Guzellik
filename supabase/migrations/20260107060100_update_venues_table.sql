-- Migration: Update venues table for service catalog compatibility
-- Description: Adds missing columns to venues table and updates existing data structure

-- 1. Add missing columns to venues table
ALTER TABLE public.venues
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS image_url TEXT,
ADD COLUMN IF NOT EXISTS features JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS rating NUMERIC(3,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS review_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- 2. Create index on rating for featured venues view
CREATE INDEX IF NOT EXISTS idx_venues_rating ON public.venues(rating DESC);
CREATE INDEX IF NOT EXISTS idx_venues_is_active ON public.venues(is_active);

-- 3. Update existing venues to extract latitude/longitude from location
UPDATE public.venues
SET
  latitude = ST_Y(location::geometry),
  longitude = ST_X(location::geometry)
WHERE location IS NOT NULL AND latitude IS NULL;

-- 4. Create trigger to auto-update latitude/longitude when location changes
CREATE OR REPLACE FUNCTION update_venue_coordinates()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.location IS NOT NULL THEN
    NEW.latitude = ST_Y(NEW.location::geometry);
    NEW.longitude = ST_X(NEW.location::geometry);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_venue_coordinates ON public.venues;
CREATE TRIGGER trigger_update_venue_coordinates
  BEFORE INSERT OR UPDATE OF location ON public.venues
  FOR EACH ROW
  EXECUTE FUNCTION update_venue_coordinates();

-- 5. Create trigger to update rating when reviews change
CREATE OR REPLACE FUNCTION update_venue_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.venues
  SET
    rating = (
      SELECT COALESCE(AVG(rating), 0)
      FROM public.reviews
      WHERE venue_id = COALESCE(NEW.venue_id, OLD.venue_id)
    ),
    review_count = (
      SELECT COUNT(*)
      FROM public.reviews
      WHERE venue_id = COALESCE(NEW.venue_id, OLD.venue_id)
    )
  WHERE id = COALESCE(NEW.venue_id, OLD.venue_id);

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_venue_rating ON public.reviews;
CREATE TRIGGER trigger_update_venue_rating
  AFTER INSERT OR UPDATE OR DELETE ON public.reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_venue_rating();
