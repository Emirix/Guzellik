# Change: Filter Inactive Subscriptions

## Why
To monetize the platform and ensure that only paying businesses receive visibility and customer leads. Businesses that do not have an active subscription should not benefit from the platform's discovery features.

Following the migration from `business_subscriptions` to `venues_subscription` table (completed in migration `20260111210000_migrate_to_venue_subscriptions.sql`), the existing subscription visibility filters need to be updated to reference the new table structure.

## What Changes
- **BREAKING**: Updated Row Level Security (RLS) policies on `venues` and related tables to use `venues_subscription` instead of `business_subscriptions`.
- Updated `is_venue_subscribed` helper function to query `venues_subscription` table directly.
- Updated `search_venues_advanced` RPC to filter by active subscription using the new table.
- Updated `get_nearby_venues` RPC to filter by active subscription using the new table.
- Updated `elastic_search_venues` RPC to filter by active subscription using the new table.
- Updated `search_venues_by_service` RPC to filter by active subscription using the new table.
- Updated RLS policies on `venue_services`, `services`, `campaigns`, `specialists`, and `venue_photos` to use the new subscription table.

## Impact
- Affected specs: `database`
- Affected code: Supabase RLS policies and search RPC functions.
- Migration dependency: Requires `20260111210000_migrate_to_venue_subscriptions.sql` to be applied first.
