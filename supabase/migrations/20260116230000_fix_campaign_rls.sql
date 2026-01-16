-- Migration: Fix campaign RLS policies
-- Created: 2026-01-16
-- Description: Adds missing INSERT, UPDATE, DELETE policies for venue owners and ensures owners can view all their campaigns.

-- Allow owners to insert campaigns
CREATE POLICY "Venue owners can insert campaigns"
  ON public.campaigns
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.venues
      WHERE venues.id = campaigns.venue_id
      AND venues.owner_id = auth.uid()
    )
  );

-- Allow owners to update campaigns
CREATE POLICY "Venue owners can update campaigns"
  ON public.campaigns
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.venues
      WHERE venues.id = campaigns.venue_id
      AND venues.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.venues
      WHERE venues.id = campaigns.venue_id
      AND venues.owner_id = auth.uid()
    )
  );

-- Allow owners to delete campaigns
CREATE POLICY "Venue owners can delete campaigns"
  ON public.campaigns
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.venues
      WHERE venues.id = campaigns.venue_id
      AND venues.owner_id = auth.uid()
    )
  );

-- Allow owners to see all their campaigns (including inactive/expired)
CREATE POLICY "Venue owners can view all their campaigns"
  ON public.campaigns
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.venues
      WHERE venues.id = campaigns.venue_id
      AND venues.owner_id = auth.uid()
    )
  );
