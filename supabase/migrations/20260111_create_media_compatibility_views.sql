-- Migration: Create Compatibility Views for Media System
-- Description: Views to maintain backward compatibility while transitioning to new media system

-- ========================================
-- View: venues_with_media
-- Provides venues with their media in a backward-compatible format
-- ========================================
CREATE OR REPLACE VIEW public.venues_with_media AS
SELECT 
    v.*,
    -- Hero image (primary venue_hero)
    (
        SELECT m.storage_path
        FROM public.entity_media em
        JOIN public.media m ON em.media_id = m.id
        WHERE em.entity_id = v.id 
        AND em.entity_type = 'venue_hero'
        AND em.is_primary = true
        LIMIT 1
    ) AS hero_image_path,
    -- Gallery images (all venue_gallery)
    (
        SELECT json_agg(
            json_build_object(
                'id', m.id,
                'storage_path', m.storage_path,
                'metadata', m.metadata,
                'sort_order', em.sort_order
            ) ORDER BY em.sort_order
        )
        FROM public.entity_media em
        JOIN public.media m ON em.media_id = m.id
        WHERE em.entity_id = v.id 
        AND em.entity_type = 'venue_gallery'
    ) AS gallery_images,
    -- Total media count
    (
        SELECT COUNT(*)
        FROM public.entity_media em
        WHERE em.entity_id = v.id 
        AND em.entity_type IN ('venue_hero', 'venue_gallery')
    ) AS media_count
FROM public.venues v;

-- ========================================
-- View: profiles_with_media
-- Provides profiles with their avatar via media system
-- ========================================
CREATE OR REPLACE VIEW public.profiles_with_media AS
SELECT 
    p.*,
    -- Avatar (primary profile_avatar)
    (
        SELECT m.storage_path
        FROM public.entity_media em
        JOIN public.media m ON em.media_id = m.id
        WHERE em.entity_id = p.id 
        AND em.entity_type = 'profile_avatar'
        AND em.is_primary = true
        LIMIT 1
    ) AS avatar_path
FROM public.profiles p;

-- ========================================
-- View: specialists_with_media
-- Provides specialists with their photos and certificates
-- ========================================
CREATE OR REPLACE VIEW public.specialists_with_media AS
SELECT 
    s.*,
    -- Primary photo
    (
        SELECT m.storage_path
        FROM public.entity_media em
        JOIN public.media m ON em.media_id = m.id
        WHERE em.entity_id = s.id 
        AND em.entity_type = 'specialist_photo'
        AND em.is_primary = true
        LIMIT 1
    ) AS photo_path,
    -- Certificates
    (
        SELECT json_agg(
            json_build_object(
                'id', m.id,
                'storage_path', m.storage_path,
                'metadata', m.metadata,
                'sort_order', em.sort_order
            ) ORDER BY em.sort_order
        )
        FROM public.entity_media em
        JOIN public.media m ON em.media_id = m.id
        WHERE em.entity_id = s.id 
        AND em.entity_type = 'specialist_certificate'
    ) AS certificates
FROM public.specialists s;

-- ========================================
-- Function: get_entity_media
-- Helper function to fetch all media for an entity
-- ========================================
CREATE OR REPLACE FUNCTION public.get_entity_media(
    p_entity_id UUID,
    p_entity_type TEXT DEFAULT NULL
)
RETURNS TABLE (
    media_id UUID,
    storage_path TEXT,
    mime_type TEXT,
    size_bytes BIGINT,
    metadata JSONB,
    entity_type TEXT,
    is_primary BOOLEAN,
    sort_order INTEGER,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id,
        m.storage_path,
        m.mime_type,
        m.size_bytes,
        m.metadata,
        em.entity_type,
        em.is_primary,
        em.sort_order,
        m.created_at
    FROM public.entity_media em
    JOIN public.media m ON em.media_id = m.id
    WHERE em.entity_id = p_entity_id
    AND (p_entity_type IS NULL OR em.entity_type = p_entity_type)
    ORDER BY em.is_primary DESC, em.sort_order ASC, m.created_at ASC;
END;
$$ LANGUAGE plpgsql STABLE;

-- ========================================
-- Function: get_primary_media
-- Get the primary media for an entity
-- ========================================
CREATE OR REPLACE FUNCTION public.get_primary_media(
    p_entity_id UUID,
    p_entity_type TEXT
)
RETURNS TABLE (
    media_id UUID,
    storage_path TEXT,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id,
        m.storage_path,
        m.metadata
    FROM public.entity_media em
    JOIN public.media m ON em.media_id = m.id
    WHERE em.entity_id = p_entity_id
    AND em.entity_type = p_entity_type
    AND em.is_primary = true
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;

-- Grant permissions on views
GRANT SELECT ON public.venues_with_media TO anon, authenticated;
GRANT SELECT ON public.profiles_with_media TO anon, authenticated;
GRANT SELECT ON public.specialists_with_media TO anon, authenticated;

-- Add helpful comments
COMMENT ON VIEW public.venues_with_media IS 'Venues with their media (hero image and gallery) in a backward-compatible format';
COMMENT ON VIEW public.profiles_with_media IS 'Profiles with their avatar via the media system';
COMMENT ON VIEW public.specialists_with_media IS 'Specialists with their photos and certificates';
COMMENT ON FUNCTION public.get_entity_media(UUID, TEXT) IS 'Fetch all media for a given entity, optionally filtered by entity_type';
COMMENT ON FUNCTION public.get_primary_media(UUID, TEXT) IS 'Get the primary media for an entity of a specific type';
