# Design: Filter Inactive Subscriptions

## Context

The platform previously used a `business_subscriptions` table linked to `profile_id` (user accounts). Migration `20260111210000_migrate_to_venue_subscriptions.sql` introduced a new `venues_subscription` table linked directly to `venue_id`, which is more accurate since subscriptions are per-venue, not per-user.

However, migration `20260111204040_enforce_subscription_visibility.sql` (created before the table migration) still references the old `business_subscriptions` table in all RLS policies and RPC functions. This change updates all subscription filtering logic to use the new `venues_subscription` table.

## Architecture

The filtering is implemented primarily at the database level to ensure consistency across all access methods (direct REST API via RLS and RPC calls).

### 1. Subscription Definition

A venue is considered to have an active subscription if there is a record in the `venues_subscription` table where:
- `venue_id` matches the venue.
- `status = 'active'`.
- `expires_at` is NULL OR `expires_at > NOW()`.

### 2. Helper Function

The `is_venue_subscribed(p_venue_id UUID)` function provides a reusable way to check subscription status:
- Previously: Queried `business_subscriptions` by joining with `venues.owner_id`
- Updated: Queries `venues_subscription` directly by `venue_id`

This simplifies the logic and improves performance by removing unnecessary joins.

### 3. Row Level Security (RLS)

The RLS policies control what data users can see through direct table queries and the auto-generated REST API.

#### Venues Table Policy
```sql
CREATE POLICY "Venues are viewable by everyone." ON public.venues 
FOR SELECT 
USING (
  is_active = true 
  AND (
    auth.uid() = owner_id  -- Owners always see their venues
    OR 
    EXISTS (
      SELECT 1 
      FROM public.venues_subscription vs 
      WHERE vs.venue_id = venues.id 
        AND vs.status = 'active' 
        AND (vs.expires_at IS NULL OR vs.expires_at > NOW())
    )
  )
);
```

#### Related Tables
Similar policies are applied to:
- `venue_services`: Only visible if parent venue has active subscription
- `services`: Only visible if parent venue_service's venue has active subscription
- `campaigns`: Only visible if venue has active subscription
- `specialists`: Only visible if venue has active subscription
- `venue_photos`: Only visible if venue has active subscription

This cascading visibility ensures that all venue-related data is hidden when the subscription expires.

### 4. RPC Functions

Since some RPC functions are defined as `SECURITY DEFINER`, they bypass RLS. These functions must explicitly include the subscription check in their `WHERE` clauses.

#### Updated Functions:
- `get_nearby_venues`: Geospatial search for nearby venues
- `search_venues_advanced`: Multi-criteria venue search
- `elastic_search_venues`: Full-text search with ranking
- `search_venues_by_service`: Find venues offering specific services

Each function adds this filter:
```sql
AND EXISTS (
  SELECT 1 
  FROM public.venues_subscription vs 
  WHERE vs.venue_id = v.id 
    AND vs.status = 'active' 
    AND (vs.expires_at IS NULL OR vs.expires_at > NOW())
)
```

### 5. Views

The `featured_venues` view is updated to filter by subscription status, ensuring only subscribed venues appear in featured listings.

## Trade-offs

### Performance
- **Impact**: Adding an EXISTS check in search functions adds a small overhead
- **Mitigation**: The existing index on `venues_subscription(venue_id, status)` ensures fast lookups
- **Benefit**: Centralized filtering at the database level is more efficient than filtering in application code

### Simplicity
- **Before**: Complex joins between `business_subscriptions` → `profiles` → `venues`
- **After**: Direct lookup in `venues_subscription` by `venue_id`
- **Result**: Cleaner code, better performance, easier to understand

### Data Consistency
- **Approach**: Database-level enforcement ensures no venue data leaks regardless of which API endpoint is used
- **Alternative**: Application-level filtering would require changes in multiple repositories and could be bypassed
- **Decision**: Database-level is the only reliable approach for security-critical filtering

