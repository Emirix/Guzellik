-- Migration: Create Centralized Media System
-- Description: Implements media and entity_media tables for centralized asset management

-- Create media table to store all platform assets
CREATE TABLE IF NOT EXISTS public.media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    storage_path TEXT NOT NULL UNIQUE,
    mime_type TEXT,
    size_bytes BIGINT,
    metadata JSONB DEFAULT '{}'::jsonb, -- width, height, blurhash, alt_text
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create entity_media join table for polymorphic associations
CREATE TABLE IF NOT EXISTS public.entity_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    media_id UUID NOT NULL REFERENCES public.media(id) ON DELETE CASCADE,
    entity_id UUID NOT NULL, -- venue_id, specialist_id, profile_id, etc.
    entity_type TEXT NOT NULL, -- 'venue_hero', 'venue_gallery', 'specialist_photo', 'profile_avatar', 'specialist_certificate'
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(media_id, entity_id, entity_type)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_media_storage_path ON public.media(storage_path);
CREATE INDEX IF NOT EXISTS idx_entity_media_entity ON public.entity_media(entity_id, entity_type);
CREATE INDEX IF NOT EXISTS idx_entity_media_media_id ON public.entity_media(media_id);
CREATE INDEX IF NOT EXISTS idx_entity_media_primary ON public.entity_media(entity_id, entity_type, is_primary) WHERE is_primary = true;

-- Add updated_at trigger for media table
CREATE OR REPLACE FUNCTION public.update_media_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_media_updated_at
    BEFORE UPDATE ON public.media
    FOR EACH ROW
    EXECUTE FUNCTION public.update_media_updated_at();

-- Enable RLS on media tables
ALTER TABLE public.media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entity_media ENABLE ROW LEVEL SECURITY;

-- RLS Policies for media table
-- Anyone can view media
CREATE POLICY "Media is viewable by everyone"
    ON public.media FOR SELECT
    USING (true);

-- Authenticated users can insert media
CREATE POLICY "Authenticated users can insert media"
    ON public.media FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Users can update their own media (via entity_media ownership)
CREATE POLICY "Users can update their own media"
    ON public.media FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.entity_media em
            WHERE em.media_id = media.id
            AND (
                -- Profile avatar
                (em.entity_type = 'profile_avatar' AND em.entity_id = auth.uid())
                OR
                -- Venue media (owner check)
                (em.entity_type IN ('venue_hero', 'venue_gallery') AND EXISTS (
                    SELECT 1 FROM public.venues v WHERE v.id = em.entity_id AND v.owner_id = auth.uid()
                ))
                OR
                -- Specialist media (owner check via venue)
                (em.entity_type IN ('specialist_photo', 'specialist_certificate') AND EXISTS (
                    SELECT 1 FROM public.specialists s
                    JOIN public.venues v ON s.venue_id = v.id
                    WHERE s.id = em.entity_id AND v.owner_id = auth.uid()
                ))
            )
        )
    );

-- Users can delete their own media
CREATE POLICY "Users can delete their own media"
    ON public.media FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.entity_media em
            WHERE em.media_id = media.id
            AND (
                (em.entity_type = 'profile_avatar' AND em.entity_id = auth.uid())
                OR
                (em.entity_type IN ('venue_hero', 'venue_gallery') AND EXISTS (
                    SELECT 1 FROM public.venues v WHERE v.id = em.entity_id AND v.owner_id = auth.uid()
                ))
                OR
                (em.entity_type IN ('specialist_photo', 'specialist_certificate') AND EXISTS (
                    SELECT 1 FROM public.specialists s
                    JOIN public.venues v ON s.venue_id = v.id
                    WHERE s.id = em.entity_id AND v.owner_id = auth.uid()
                ))
            )
        )
    );

-- RLS Policies for entity_media table
-- Anyone can view entity_media associations
CREATE POLICY "Entity media is viewable by everyone"
    ON public.entity_media FOR SELECT
    USING (true);

-- Authenticated users can insert entity_media
CREATE POLICY "Authenticated users can insert entity_media"
    ON public.entity_media FOR INSERT
    TO authenticated
    WITH CHECK (
        -- Profile avatar
        (entity_type = 'profile_avatar' AND entity_id = auth.uid())
        OR
        -- Venue media (owner check)
        (entity_type IN ('venue_hero', 'venue_gallery') AND EXISTS (
            SELECT 1 FROM public.venues v WHERE v.id = entity_id AND v.owner_id = auth.uid()
        ))
        OR
        -- Specialist media (owner check via venue)
        (entity_type IN ('specialist_photo', 'specialist_certificate') AND EXISTS (
            SELECT 1 FROM public.specialists s
            JOIN public.venues v ON s.venue_id = v.id
            WHERE s.id = entity_id AND v.owner_id = auth.uid()
        ))
    );

-- Users can update their own entity_media
CREATE POLICY "Users can update their own entity_media"
    ON public.entity_media FOR UPDATE
    TO authenticated
    USING (
        (entity_type = 'profile_avatar' AND entity_id = auth.uid())
        OR
        (entity_type IN ('venue_hero', 'venue_gallery') AND EXISTS (
            SELECT 1 FROM public.venues v WHERE v.id = entity_id AND v.owner_id = auth.uid()
        ))
        OR
        (entity_type IN ('specialist_photo', 'specialist_certificate') AND EXISTS (
            SELECT 1 FROM public.specialists s
            JOIN public.venues v ON s.venue_id = v.id
            WHERE s.id = entity_id AND v.owner_id = auth.uid()
        ))
    );

-- Users can delete their own entity_media
CREATE POLICY "Users can delete their own entity_media"
    ON public.entity_media FOR DELETE
    TO authenticated
    USING (
        (entity_type = 'profile_avatar' AND entity_id = auth.uid())
        OR
        (entity_type IN ('venue_hero', 'venue_gallery') AND EXISTS (
            SELECT 1 FROM public.venues v WHERE v.id = entity_id AND v.owner_id = auth.uid()
        ))
        OR
        (entity_type IN ('specialist_photo', 'specialist_certificate') AND EXISTS (
            SELECT 1 FROM public.specialists s
            JOIN public.venues v ON s.venue_id = v.id
            WHERE s.id = entity_id AND v.owner_id = auth.uid()
        ))
    );

-- Grant necessary permissions
GRANT SELECT ON public.media TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.media TO authenticated;
GRANT SELECT ON public.entity_media TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.entity_media TO authenticated;
