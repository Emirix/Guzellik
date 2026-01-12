-- Migration: Attach Audit Triggers to Sensitive Tables
-- Description: Enables audit logging for venues, venue_subscriptions, and profiles

-- ========================================
-- Attach Audit Trigger to venues table
-- ========================================
DROP TRIGGER IF EXISTS trigger_audit_venues ON public.venues;
CREATE TRIGGER trigger_audit_venues
    AFTER INSERT OR UPDATE OR DELETE ON public.venues
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_trigger_function();

COMMENT ON TRIGGER trigger_audit_venues ON public.venues IS 
    'Audit trail for venue changes including creation, updates, and deletion';

-- ========================================
-- Attach Audit Trigger to venue_subscriptions table
-- ========================================
DROP TRIGGER IF EXISTS trigger_audit_venue_subscriptions ON public.venue_subscriptions;
CREATE TRIGGER trigger_audit_venue_subscriptions
    AFTER INSERT OR UPDATE OR DELETE ON public.venue_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_trigger_function();

COMMENT ON TRIGGER trigger_audit_venue_subscriptions ON public.venue_subscriptions IS 
    'Audit trail for subscription changes including assignments, renewals, and cancellations';

-- ========================================
-- Attach Audit Trigger to profiles table
-- ========================================
DROP TRIGGER IF EXISTS trigger_audit_profiles ON public.profiles;
CREATE TRIGGER trigger_audit_profiles
    AFTER INSERT OR UPDATE OR DELETE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_trigger_function();

COMMENT ON TRIGGER trigger_audit_profiles ON public.profiles IS 
    'Audit trail for profile changes including account modifications';

-- ========================================
-- Optional: Attach to other sensitive tables
-- ========================================

-- Specialists (track who added/modified specialists)
DROP TRIGGER IF EXISTS trigger_audit_specialists ON public.specialists;
CREATE TRIGGER trigger_audit_specialists
    AFTER INSERT OR UPDATE OR DELETE ON public.specialists
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_trigger_function();

COMMENT ON TRIGGER trigger_audit_specialists ON public.specialists IS 
    'Audit trail for specialist changes';

-- Venue Services (track service additions/removals)
DROP TRIGGER IF EXISTS trigger_audit_venue_services ON public.venue_services;
CREATE TRIGGER trigger_audit_venue_services
    AFTER INSERT OR UPDATE OR DELETE ON public.venue_services
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_trigger_function();

COMMENT ON TRIGGER trigger_audit_venue_services ON public.venue_services IS 
    'Audit trail for venue service changes';

-- Venue Hours (track schedule changes)
DROP TRIGGER IF EXISTS trigger_audit_venue_hours ON public.venue_hours;
CREATE TRIGGER trigger_audit_venue_hours
    AFTER INSERT OR UPDATE OR DELETE ON public.venue_hours
    FOR EACH ROW
    EXECUTE FUNCTION public.audit_trigger_function();

COMMENT ON TRIGGER trigger_audit_venue_hours ON public.venue_hours IS 
    'Audit trail for venue hours changes';

-- ========================================
-- Create a view for easy audit log access
-- ========================================
CREATE OR REPLACE VIEW public.audit_logs_summary AS
SELECT 
    al.id,
    al.table_name,
    al.record_id,
    al.action,
    al.changed_fields,
    al.actor_email,
    al.created_at,
    -- For venues, include venue name
    CASE 
        WHEN al.table_name = 'venues' THEN 
            COALESCE(
                al.new_data->>'name',
                al.old_data->>'name'
            )
        ELSE NULL
    END AS entity_name,
    -- Summary of changes
    CASE 
        WHEN al.action = 'INSERT' THEN 'Created'
        WHEN al.action = 'DELETE' THEN 'Deleted'
        WHEN al.action = 'UPDATE' AND al.changed_fields IS NOT NULL THEN 
            'Updated: ' || array_to_string(al.changed_fields, ', ')
        ELSE 'Updated'
    END AS change_summary
FROM public.audit_logs al
ORDER BY al.created_at DESC;

GRANT SELECT ON public.audit_logs_summary TO authenticated;

COMMENT ON VIEW public.audit_logs_summary IS 
    'User-friendly view of audit logs with entity names and change summaries';

-- ========================================
-- Test the audit system
-- ========================================
DO $$
BEGIN
    RAISE NOTICE 'Audit triggers successfully attached to:';
    RAISE NOTICE '  - venues';
    RAISE NOTICE '  - venue_subscriptions';
    RAISE NOTICE '  - profiles';
    RAISE NOTICE '  - specialists';
    RAISE NOTICE '  - venue_services';
    RAISE NOTICE '  - venue_hours';
    RAISE NOTICE '';
    RAISE NOTICE 'All changes to these tables will now be automatically logged.';
END $$;
