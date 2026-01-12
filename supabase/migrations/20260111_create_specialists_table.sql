-- Migration: Create specialists table
-- Description: Creates the specialists table for managing venue team members
-- Date: 2026-01-11

-- Create specialists table
CREATE TABLE IF NOT EXISTS specialists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 2 AND char_length(name) <= 50),
  profession TEXT NOT NULL CHECK (char_length(profession) >= 2 AND char_length(profession) <= 30),
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
  photo_url TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on venue_id for faster queries
CREATE INDEX IF NOT EXISTS idx_specialists_venue_id ON specialists(venue_id);

-- Create index on sort_order for ordering
CREATE INDEX IF NOT EXISTS idx_specialists_sort_order ON specialists(venue_id, sort_order);

-- Add RLS (Row Level Security) policies
ALTER TABLE specialists ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view all specialists
CREATE POLICY "Anyone can view specialists"
  ON specialists
  FOR SELECT
  USING (true);

-- Policy: Venue owners can insert their own specialists
CREATE POLICY "Owners can insert their venue specialists"
  ON specialists
  FOR INSERT
  WITH CHECK (
    venue_id IN (
      SELECT id FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Policy: Venue owners can update their own specialists
CREATE POLICY "Owners can update their venue specialists"
  ON specialists
  FOR UPDATE
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

-- Policy: Venue owners can delete their own specialists
CREATE POLICY "Owners can delete their venue specialists"
  ON specialists
  FOR DELETE
  USING (
    venue_id IN (
      SELECT id FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_specialists_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER specialists_updated_at
  BEFORE UPDATE ON specialists
  FOR EACH ROW
  EXECUTE FUNCTION update_specialists_updated_at();

-- Add comment
COMMENT ON TABLE specialists IS 'Stores venue team members/specialists information';
