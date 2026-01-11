-- Migration: Update existing tables for admin panel
-- Description: Adds missing columns to venue_services, venue_photos, and campaigns tables
-- Date: 2026-01-11

-- ============================================
-- Update venue_services table
-- ============================================

-- Add custom fields for service customization
ALTER TABLE venue_services 
  ADD COLUMN IF NOT EXISTS custom_name TEXT,
  ADD COLUMN IF NOT EXISTS custom_description TEXT,
  ADD COLUMN IF NOT EXISTS custom_image_url TEXT,
  ADD COLUMN IF NOT EXISTS price DECIMAL(10, 2),
  ADD COLUMN IF NOT EXISTS duration_minutes INTEGER,
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Add constraints
ALTER TABLE venue_services
  ADD CONSTRAINT IF NOT EXISTS check_price_positive CHECK (price IS NULL OR price >= 0),
  ADD CONSTRAINT IF NOT EXISTS check_duration_positive CHECK (duration_minutes IS NULL OR duration_minutes > 0);

-- Create index for sorting
CREATE INDEX IF NOT EXISTS idx_venue_services_sort_order ON venue_services(venue_id, sort_order);

-- Update RLS policies for venue_services
DROP POLICY IF EXISTS "Anyone can view venue services" ON venue_services;
DROP POLICY IF EXISTS "Owners can manage their venue services" ON venue_services;

-- Enable RLS if not already enabled
ALTER TABLE venue_services ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view active services
CREATE POLICY "Anyone can view active venue services"
  ON venue_services
  FOR SELECT
  USING (is_active = true OR venue_id IN (
    SELECT id FROM venues WHERE owner_id = auth.uid()
  ));

-- Policy: Owners can manage all their venue services
CREATE POLICY "Owners can manage their venue services"
  ON venue_services
  FOR ALL
  USING (
    venue_id IN (
      SELECT id FROM venues WHERE owner_id = auth.uid()
    )
  )
  WITH CHECK (
    venue_id IN (
      SELECT id FROM venues WHERE owner_id = auth.uid()
    )
  );

-- ============================================
-- Update venue_photos table
-- ============================================

-- Add hero image and sort order if not exists
ALTER TABLE venue_photos
  ADD COLUMN IF NOT EXISTS is_hero_image BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS caption TEXT;

-- Create index for sorting
CREATE INDEX IF NOT EXISTS idx_venue_photos_sort_order ON venue_photos(venue_id, sort_order);

-- Create index for hero image lookup
CREATE INDEX IF NOT EXISTS idx_venue_photos_hero ON venue_photos(venue_id, is_hero_image) WHERE is_hero_image = true;

-- Update RLS policies for venue_photos
DROP POLICY IF EXISTS "Anyone can view venue photos" ON venue_photos;
DROP POLICY IF EXISTS "Owners can manage their venue photos" ON venue_photos;

-- Enable RLS if not already enabled
ALTER TABLE venue_photos ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view photos
CREATE POLICY "Anyone can view venue photos"
  ON venue_photos
  FOR SELECT
  USING (true);

-- Policy: Owners can manage their venue photos
CREATE POLICY "Owners can manage their venue photos"
  ON venue_photos
  FOR ALL
  USING (
    venue_id IN (
      SELECT id FROM venues WHERE owner_id = auth.uid()
    )
  )
  WITH CHECK (
    venue_id IN (
      SELECT id FROM venues WHERE owner_id = auth.uid()
    )
  );

-- ============================================
-- Update campaigns table
-- ============================================

-- Ensure campaigns table has all required columns
ALTER TABLE campaigns
  ADD COLUMN IF NOT EXISTS title TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS description TEXT,
  ADD COLUMN IF NOT EXISTS discount_percentage DECIMAL(5, 2),
  ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10, 2),
  ADD COLUMN IF NOT EXISTS start_date DATE,
  ADD COLUMN IF NOT EXISTS end_date DATE,
  ADD COLUMN IF NOT EXISTS image_url TEXT,
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Add constraints
ALTER TABLE campaigns
  ADD CONSTRAINT IF NOT EXISTS check_discount_percentage CHECK (discount_percentage IS NULL OR (discount_percentage >= 0 AND discount_percentage <= 100)),
  ADD CONSTRAINT IF NOT EXISTS check_discount_amount CHECK (discount_amount IS NULL OR discount_amount >= 0),
  ADD CONSTRAINT IF NOT EXISTS check_dates CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
  ADD CONSTRAINT IF NOT EXISTS check_has_discount CHECK (discount_percentage IS NOT NULL OR discount_amount IS NOT NULL);

-- Create index for active campaigns
CREATE INDEX IF NOT EXISTS idx_campaigns_active ON campaigns(venue_id, is_active, start_date, end_date);

-- Update RLS policies for campaigns
DROP POLICY IF EXISTS "Anyone can view campaigns" ON campaigns;
DROP POLICY IF EXISTS "Owners can manage their campaigns" ON campaigns;

-- Enable RLS if not already enabled
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view active campaigns within date range
CREATE POLICY "Anyone can view active campaigns"
  ON campaigns
  FOR SELECT
  USING (
    is_active = true 
    AND (start_date IS NULL OR start_date <= CURRENT_DATE)
    AND (end_date IS NULL OR end_date >= CURRENT_DATE)
    OR venue_id IN (
      SELECT id FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Policy: Owners can manage their campaigns
CREATE POLICY "Owners can manage their campaigns"
  ON campaigns
  FOR ALL
  USING (
    venue_id IN (
      SELECT id FROM venues WHERE owner_id = auth.uid()
    )
  )
  WITH CHECK (
    venue_id IN (
      SELECT id FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Add comments
COMMENT ON COLUMN venue_services.custom_name IS 'Optional custom name override for the service';
COMMENT ON COLUMN venue_services.custom_description IS 'Optional custom description override';
COMMENT ON COLUMN venue_services.custom_image_url IS 'Optional custom image URL override';
COMMENT ON COLUMN venue_services.is_active IS 'Whether the service is currently active/visible';
COMMENT ON COLUMN venue_services.sort_order IS 'Display order for services';

COMMENT ON COLUMN venue_photos.is_hero_image IS 'Whether this is the primary/hero image for the venue';
COMMENT ON COLUMN venue_photos.sort_order IS 'Display order for photos in gallery';

COMMENT ON COLUMN campaigns.is_active IS 'Whether the campaign is currently active';
