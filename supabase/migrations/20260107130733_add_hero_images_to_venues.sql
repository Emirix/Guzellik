-- Add hero_images column to venues table for carousel support
ALTER TABLE venues ADD COLUMN IF NOT EXISTS hero_images JSONB DEFAULT '[]'::jsonb;

-- Backfill existing image_url values into hero_images array
UPDATE venues 
SET hero_images = jsonb_build_array(image_url)
WHERE image_url IS NOT NULL 
  AND (hero_images IS NULL OR hero_images = '[]'::jsonb);

-- Add index for hero_images queries
CREATE INDEX IF NOT EXISTS idx_venues_hero_images ON venues USING GIN (hero_images);
