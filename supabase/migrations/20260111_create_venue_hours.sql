-- Migration: Create Structured Venue Hours System
-- Description: Implements venue_hours table for granular opening hour storage

-- Create venue_hours table
CREATE TABLE IF NOT EXISTS public.venue_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Sunday, 6=Saturday
    open_time TIME,
    close_time TIME,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(venue_id, day_of_week)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_venue_hours_venue_id ON public.venue_hours(venue_id);
CREATE INDEX IF NOT EXISTS idx_venue_hours_day ON public.venue_hours(day_of_week);
CREATE INDEX IF NOT EXISTS idx_venue_hours_open_status ON public.venue_hours(venue_id, is_closed);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION public.update_venue_hours_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_venue_hours_updated_at
    BEFORE UPDATE ON public.venue_hours
    FOR EACH ROW
    EXECUTE FUNCTION public.update_venue_hours_updated_at();

-- Enable RLS
ALTER TABLE public.venue_hours ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Anyone can view venue hours
CREATE POLICY "Venue hours are viewable by everyone"
    ON public.venue_hours FOR SELECT
    USING (true);

-- Venue owners can insert their venue hours
CREATE POLICY "Venue owners can insert their venue hours"
    ON public.venue_hours FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.venues v 
            WHERE v.id = venue_id 
            AND v.owner_id = auth.uid()
        )
    );

-- Venue owners can update their venue hours
CREATE POLICY "Venue owners can update their venue hours"
    ON public.venue_hours FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.venues v 
            WHERE v.id = venue_id 
            AND v.owner_id = auth.uid()
        )
    );

-- Venue owners can delete their venue hours
CREATE POLICY "Venue owners can delete their venue hours"
    ON public.venue_hours FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.venues v 
            WHERE v.id = venue_id 
            AND v.owner_id = auth.uid()
        )
    );

-- Grant permissions
GRANT SELECT ON public.venue_hours TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.venue_hours TO authenticated;

-- Add helpful comment
COMMENT ON TABLE public.venue_hours IS 'Structured storage of venue opening hours by day of week';
COMMENT ON COLUMN public.venue_hours.day_of_week IS '0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday';
COMMENT ON COLUMN public.venue_hours.is_closed IS 'True if the venue is closed on this day';
