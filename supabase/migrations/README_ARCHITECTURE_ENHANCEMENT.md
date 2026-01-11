# Architecture Scalability Enhancement - Database Migrations

This directory contains the database migrations for the architecture scalability enhancement project.

## Migration Order

Execute these migrations in the following order:

### Phase 1: Media System
1. **20260111_create_media_system.sql** - Creates `media` and `entity_media` tables
2. **20260111_media_storage_triggers.sql** - Adds storage organization and cleanup triggers
3. **20260111_migrate_existing_urls_to_media.sql** - Migrates existing image URLs to media system
4. **20260111_create_media_compatibility_views.sql** - Creates views for backward compatibility

### Phase 2: Structured Availability
5. **20260111_create_venue_hours.sql** - Creates `venue_hours` table
6. **20260111_migrate_working_hours_to_structured.sql** - Migrates JSONB working_hours to structured table
7. **20260111_venue_availability_functions.sql** - Creates helper functions for availability checks

### Phase 3: Reviews & Audit
8. **20260111_polymorphic_reviews.sql** - Extends reviews to support venues, services, and specialists
9. **20260111_create_audit_logs.sql** - Creates audit logging system
10. **20260111_attach_audit_triggers.sql** - Attaches audit triggers to sensitive tables

## Running Migrations

### Option 1: Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste each migration file in order
4. Execute each migration

### Option 2: Supabase CLI
```bash
# Make sure you're in the project root
cd c:\Users\Emir\Documents\Proje\Guzellik

# Run all migrations
supabase db push
```

## Verification

After running all migrations, verify the setup:

```sql
-- Check media system
SELECT COUNT(*) FROM public.media;
SELECT COUNT(*) FROM public.entity_media;

-- Check venue hours
SELECT COUNT(*) FROM public.venue_hours;
SELECT COUNT(DISTINCT venue_id) FROM public.venue_hours;

-- Check polymorphic reviews
SELECT target_type, COUNT(*) FROM public.reviews GROUP BY target_type;

-- Check audit logs
SELECT table_name, COUNT(*) FROM public.audit_logs GROUP BY table_name;

-- Test availability function
SELECT * FROM public.get_open_venues();

-- Test media views
SELECT COUNT(*) FROM public.venues_with_media;
```

## Key Features

### Media System
- Centralized asset management
- Polymorphic associations (venues, specialists, profiles)
- Automatic cleanup of orphaned media
- Backward-compatible views

### Structured Availability
- Per-day opening hours
- High-performance "Open Now" queries
- Support for midnight-crossing hours
- Turkish day names

### Polymorphic Reviews
- Review venues, services, or specialists
- Comprehensive rating summaries
- Efficient aggregation functions

### Audit Logging
- Automatic tracking of all changes
- Actor identification
- Field-level change tracking
- Immutable audit trail

## Important Notes

1. **Backward Compatibility**: The migrations maintain backward compatibility through views. Existing code will continue to work.

2. **Data Migration**: The migrations automatically migrate existing data. No manual data entry required.

3. **RLS Policies**: All tables have proper Row Level Security policies in place.

4. **Performance**: Indexes are created for all common query patterns.

5. **Cleanup**: Old columns (like `working_hours` JSONB) are NOT dropped automatically. This allows for a gradual transition and rollback if needed.

## Rollback Strategy

If you need to rollback:

1. The old columns (`hero_image`, `photo_url`, `avatar_url`, `working_hours`) are still intact
2. Simply drop the new tables and views
3. Remove the audit triggers

```sql
-- Rollback script (use with caution)
DROP TRIGGER IF EXISTS trigger_audit_venues ON public.venues;
DROP TRIGGER IF EXISTS trigger_audit_venue_subscriptions ON public.venue_subscriptions;
DROP TRIGGER IF EXISTS trigger_audit_profiles ON public.profiles;
DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.venue_hours CASCADE;
DROP TABLE IF EXISTS public.entity_media CASCADE;
DROP TABLE IF EXISTS public.media CASCADE;
```

## Next Steps

After running these migrations:

1. Update Flutter models to use new media structure
2. Update repositories to fetch data from new tables
3. Update UI to display structured hours
4. Implement audit log viewer in admin panel
5. Test thoroughly before removing old columns
