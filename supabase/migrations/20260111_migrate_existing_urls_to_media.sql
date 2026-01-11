-- Migration: Migrate Existing URLs to Media System
-- Description: Moves existing photo_url, avatar_url, and hero_image to centralized media system

-- This migration script will:
-- 1. Extract all unique image URLs from venues, profiles, and specialists
-- 2. Create media records for each unique URL
-- 3. Create entity_media associations
-- 4. Preserve existing functionality during transition

DO $$
DECLARE
    v_record RECORD;
    v_media_id UUID;
    v_storage_path TEXT;
BEGIN
    RAISE NOTICE 'Starting media migration...';
    
    -- ========================================
    -- 1. Migrate Venue Hero Images
    -- ========================================
    RAISE NOTICE 'Migrating venue hero images...';
    
    FOR v_record IN 
        SELECT id, hero_image 
        FROM public.venues 
        WHERE hero_image IS NOT NULL 
        AND hero_image != ''
    LOOP
        -- Extract storage path from URL
        -- Assuming format: https://.../storage/v1/object/public/media/{path}
        v_storage_path := regexp_replace(v_record.hero_image, '^.*/storage/v1/object/public/media/', '');
        
        -- If it's a full URL without our storage pattern, use the original URL as path
        IF v_storage_path = v_record.hero_image THEN
            v_storage_path := 'legacy/venues/' || v_record.id || '/hero_' || md5(v_record.hero_image) || '.jpg';
        END IF;
        
        -- Insert or get existing media record
        INSERT INTO public.media (storage_path, mime_type, metadata)
        VALUES (
            v_storage_path,
            'image/jpeg',
            jsonb_build_object('legacy_url', v_record.hero_image, 'migrated_at', NOW())
        )
        ON CONFLICT (storage_path) DO UPDATE SET storage_path = EXCLUDED.storage_path
        RETURNING id INTO v_media_id;
        
        -- Create entity_media association
        INSERT INTO public.entity_media (media_id, entity_id, entity_type, is_primary, sort_order)
        VALUES (v_media_id, v_record.id, 'venue_hero', true, 0)
        ON CONFLICT (media_id, entity_id, entity_type) DO NOTHING;
    END LOOP;
    
    -- ========================================
    -- 2. Migrate Venue Gallery Images (photo_url)
    -- ========================================
    RAISE NOTICE 'Migrating venue gallery images...';
    
    FOR v_record IN 
        SELECT id, photo_url 
        FROM public.venues 
        WHERE photo_url IS NOT NULL 
        AND photo_url != ''
        AND photo_url != hero_image -- Don't duplicate hero images
    LOOP
        v_storage_path := regexp_replace(v_record.photo_url, '^.*/storage/v1/object/public/media/', '');
        
        IF v_storage_path = v_record.photo_url THEN
            v_storage_path := 'legacy/venues/' || v_record.id || '/gallery_' || md5(v_record.photo_url) || '.jpg';
        END IF;
        
        INSERT INTO public.media (storage_path, mime_type, metadata)
        VALUES (
            v_storage_path,
            'image/jpeg',
            jsonb_build_object('legacy_url', v_record.photo_url, 'migrated_at', NOW())
        )
        ON CONFLICT (storage_path) DO UPDATE SET storage_path = EXCLUDED.storage_path
        RETURNING id INTO v_media_id;
        
        INSERT INTO public.entity_media (media_id, entity_id, entity_type, is_primary, sort_order)
        VALUES (v_media_id, v_record.id, 'venue_gallery', false, 1)
        ON CONFLICT (media_id, entity_id, entity_type) DO NOTHING;
    END LOOP;
    
    -- ========================================
    -- 3. Migrate Profile Avatars
    -- ========================================
    RAISE NOTICE 'Migrating profile avatars...';
    
    FOR v_record IN 
        SELECT id, avatar_url 
        FROM public.profiles 
        WHERE avatar_url IS NOT NULL 
        AND avatar_url != ''
    LOOP
        v_storage_path := regexp_replace(v_record.avatar_url, '^.*/storage/v1/object/public/media/', '');
        
        IF v_storage_path = v_record.avatar_url THEN
            v_storage_path := 'legacy/profiles/' || v_record.id || '/avatar_' || md5(v_record.avatar_url) || '.jpg';
        END IF;
        
        INSERT INTO public.media (storage_path, mime_type, metadata)
        VALUES (
            v_storage_path,
            'image/jpeg',
            jsonb_build_object('legacy_url', v_record.avatar_url, 'migrated_at', NOW())
        )
        ON CONFLICT (storage_path) DO UPDATE SET storage_path = EXCLUDED.storage_path
        RETURNING id INTO v_media_id;
        
        INSERT INTO public.entity_media (media_id, entity_id, entity_type, is_primary, sort_order)
        VALUES (v_media_id, v_record.id, 'profile_avatar', true, 0)
        ON CONFLICT (media_id, entity_id, entity_type) DO NOTHING;
    END LOOP;
    
    -- ========================================
    -- 4. Migrate Specialist Photos
    -- ========================================
    RAISE NOTICE 'Migrating specialist photos...';
    
    FOR v_record IN 
        SELECT id, photo_url 
        FROM public.specialists 
        WHERE photo_url IS NOT NULL 
        AND photo_url != ''
    LOOP
        v_storage_path := regexp_replace(v_record.photo_url, '^.*/storage/v1/object/public/media/', '');
        
        IF v_storage_path = v_record.photo_url THEN
            v_storage_path := 'legacy/specialists/' || v_record.id || '/photo_' || md5(v_record.photo_url) || '.jpg';
        END IF;
        
        INSERT INTO public.media (storage_path, mime_type, metadata)
        VALUES (
            v_storage_path,
            'image/jpeg',
            jsonb_build_object('legacy_url', v_record.photo_url, 'migrated_at', NOW())
        )
        ON CONFLICT (storage_path) DO UPDATE SET storage_path = EXCLUDED.storage_path
        RETURNING id INTO v_media_id;
        
        INSERT INTO public.entity_media (media_id, entity_id, entity_type, is_primary, sort_order)
        VALUES (v_media_id, v_record.id, 'specialist_photo', true, 0)
        ON CONFLICT (media_id, entity_id, entity_type) DO NOTHING;
    END LOOP;
    
    RAISE NOTICE 'Media migration completed successfully!';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during migration: %', SQLERRM;
        RAISE;
END $$;

-- Verification queries
DO $$
DECLARE
    media_count INTEGER;
    entity_media_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO media_count FROM public.media;
    SELECT COUNT(*) INTO entity_media_count FROM public.entity_media;
    
    RAISE NOTICE 'Migration Summary:';
    RAISE NOTICE '  - Total media records: %', media_count;
    RAISE NOTICE '  - Total entity_media associations: %', entity_media_count;
END $$;
