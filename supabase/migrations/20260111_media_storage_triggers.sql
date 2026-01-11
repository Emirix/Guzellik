-- Migration: Media Storage Triggers
-- Description: Automatic folder organization and cleanup for Supabase Storage

-- Function to automatically organize storage paths
CREATE OR REPLACE FUNCTION public.organize_media_storage_path()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure storage_path follows the pattern: {entity_type}/{entity_id}/{filename}
    -- This is validated on insert/update
    IF NEW.storage_path !~ '^[a-z_]+/[a-f0-9-]+/.*' THEN
        RAISE EXCEPTION 'Invalid storage_path format. Expected: entity_type/entity_id/filename';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_organize_media_storage_path
    BEFORE INSERT OR UPDATE ON public.media
    FOR EACH ROW
    EXECUTE FUNCTION public.organize_media_storage_path();

-- Function to clean up orphaned media records
-- This should be run periodically (e.g., via a cron job)
CREATE OR REPLACE FUNCTION public.cleanup_orphaned_media()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Delete media records that have no entity_media associations
    -- and are older than 24 hours (to allow for upload completion)
    DELETE FROM public.media
    WHERE id NOT IN (SELECT DISTINCT media_id FROM public.entity_media)
    AND created_at < NOW() - INTERVAL '24 hours';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to cascade delete entity_media when entity is deleted
-- This ensures referential integrity for polymorphic relationships
CREATE OR REPLACE FUNCTION public.cleanup_entity_media_on_entity_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete all entity_media records for this entity
    DELETE FROM public.entity_media
    WHERE entity_id = OLD.id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Attach cleanup triggers to relevant tables
-- Venues
DROP TRIGGER IF EXISTS trigger_cleanup_venue_media ON public.venues;
CREATE TRIGGER trigger_cleanup_venue_media
    BEFORE DELETE ON public.venues
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_entity_media_on_entity_delete();

-- Specialists
DROP TRIGGER IF EXISTS trigger_cleanup_specialist_media ON public.specialists;
CREATE TRIGGER trigger_cleanup_specialist_media
    BEFORE DELETE ON public.specialists
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_entity_media_on_entity_delete();

-- Profiles (if they get deleted)
DROP TRIGGER IF EXISTS trigger_cleanup_profile_media ON public.profiles;
CREATE TRIGGER trigger_cleanup_profile_media
    BEFORE DELETE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.cleanup_entity_media_on_entity_delete();

-- Helper function to get media URL from storage_path
CREATE OR REPLACE FUNCTION public.get_media_url(storage_path TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Returns the full Supabase storage URL
    -- Format: https://{project_ref}.supabase.co/storage/v1/object/public/{bucket}/{path}
    RETURN 'https://' || current_setting('app.settings.supabase_url', true) || 
           '/storage/v1/object/public/media/' || storage_path;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION public.cleanup_orphaned_media() IS 'Removes media records with no entity associations older than 24 hours';
COMMENT ON FUNCTION public.get_media_url(TEXT) IS 'Converts storage_path to full Supabase storage URL';
