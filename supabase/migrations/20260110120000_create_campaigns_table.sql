-- Migration: Create campaigns table
-- Created: 2026-01-10
-- Description: Adds campaigns table for venue promotional offers

-- Create campaigns table
CREATE TABLE IF NOT EXISTS campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  discount_percentage INTEGER CHECK (discount_percentage >= 0 AND discount_percentage <= 100),
  discount_amount DECIMAL(10, 2) CHECK (discount_amount >= 0),
  start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_date TIMESTAMPTZ NOT NULL,
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- At least one discount type must be present
  CONSTRAINT check_discount CHECK (
    discount_percentage IS NOT NULL OR discount_amount IS NOT NULL
  ),
  
  -- End date must be after start date
  CONSTRAINT check_dates CHECK (end_date > start_date)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_campaigns_venue_id ON campaigns(venue_id);
CREATE INDEX IF NOT EXISTS idx_campaigns_is_active ON campaigns(is_active);
CREATE INDEX IF NOT EXISTS idx_campaigns_dates ON campaigns(start_date, end_date);

-- Enable RLS
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Public can read active campaigns
CREATE POLICY "Public can view active campaigns"
  ON campaigns
  FOR SELECT
  USING (
    is_active = true 
    AND end_date > NOW()
  );

-- RLS Policy: Authenticated users can view all campaigns (for venue owners in future)
CREATE POLICY "Authenticated users can view all campaigns"
  ON campaigns
  FOR SELECT
  TO authenticated
  USING (true);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_campaigns_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER campaigns_updated_at
  BEFORE UPDATE ON campaigns
  FOR EACH ROW
  EXECUTE FUNCTION update_campaigns_updated_at();

-- Add comment
COMMENT ON TABLE campaigns IS 'Stores promotional campaigns created by venues';
COMMENT ON COLUMN campaigns.discount_percentage IS 'Percentage discount (0-100), mutually exclusive with discount_amount';
COMMENT ON COLUMN campaigns.discount_amount IS 'Fixed amount discount in TRY, mutually exclusive with discount_percentage';
COMMENT ON COLUMN campaigns.is_active IS 'Admin flag to enable/disable campaign regardless of dates';

-- Rollback command (for reference):
-- DROP TABLE IF EXISTS campaigns CASCADE;
-- DROP FUNCTION IF EXISTS update_campaigns_updated_at() CASCADE;
