-- Migration: Create specialists table
-- Created: 2026-01-11
-- Description: Creates specialists table to replace JSONB expert_team in venues table

-- Create specialists table
CREATE TABLE IF NOT EXISTS public.specialists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  profession TEXT NOT NULL,
  gender TEXT CHECK (gender IN ('Kadın', 'Erkek', 'Belirtilmemiş')),
  photo_url TEXT,
  bio TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_specialists_venue_id ON public.specialists(venue_id);
CREATE INDEX IF NOT EXISTS idx_specialists_sort_order ON public.specialists(venue_id, sort_order);

-- Enable RLS
ALTER TABLE public.specialists ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Public can view specialists
CREATE POLICY "Public can view specialists"
  ON public.specialists
  FOR SELECT
  USING (true);

-- RLS Policy: Authenticated users can insert specialists for their own venues
CREATE POLICY "Venue owners can insert specialists"
  ON public.specialists
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.venues
      WHERE venues.id = specialists.venue_id
      AND venues.owner_id = auth.uid()
    )
  );

-- RLS Policy: Authenticated users can update their own venue's specialists
CREATE POLICY "Venue owners can update specialists"
  ON public.specialists
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.venues
      WHERE venues.id = specialists.venue_id
      AND venues.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.venues
      WHERE venues.id = specialists.venue_id
      AND venues.owner_id = auth.uid()
    )
  );

-- RLS Policy: Authenticated users can delete their own venue's specialists
CREATE POLICY "Venue owners can delete specialists"
  ON public.specialists
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.venues
      WHERE venues.id = specialists.venue_id
      AND venues.owner_id = auth.uid()
    )
  );

-- Create trigger for updated_at timestamp
CREATE OR REPLACE FUNCTION update_specialists_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER specialists_updated_at
  BEFORE UPDATE ON public.specialists
  FOR EACH ROW
  EXECUTE FUNCTION update_specialists_updated_at();

-- Add comment
COMMENT ON TABLE public.specialists IS 'Stores specialist/expert team members for venues';
COMMENT ON COLUMN public.specialists.gender IS 'Gender of the specialist: Kadın, Erkek, or Belirtilmemiş';
COMMENT ON COLUMN public.specialists.sort_order IS 'Display order for specialists (lower numbers first)';

-- Rollback command (for reference):
-- DROP TABLE IF EXISTS public.specialists CASCADE;
-- DROP FUNCTION IF EXISTS update_specialists_updated_at() CASCADE;
