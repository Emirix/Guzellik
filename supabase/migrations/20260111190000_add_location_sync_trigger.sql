-- Migration: Add reverse location sync trigger
-- Description: Updates location geography column when latitude or longitude columns are updated
-- Date: 2026-01-11

CREATE OR REPLACE FUNCTION update_venue_location_from_coords()
RETURNS TRIGGER AS $$
BEGIN
  -- Only update if latitude or longitude changed and they are not null
  IF (NEW.latitude IS DISTINCT FROM OLD.latitude OR NEW.longitude IS DISTINCT FROM OLD.longitude) 
     AND NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.location = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_venue_location_from_coords ON public.venues;
CREATE TRIGGER trigger_update_venue_location_from_coords
  BEFORE INSERT OR UPDATE OF latitude, longitude ON public.venues
  FOR EACH ROW
  EXECUTE FUNCTION update_venue_location_from_coords();
