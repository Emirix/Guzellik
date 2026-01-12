# Tasks: Filter Inactive Subscriptions

## Database Migration

- [x] **Create Migration File**
  - [x] Create `20260111220000_update_subscription_filters.sql` migration file
  
- [x] **Update Helper Function**
  - [x] Update `is_venue_subscribed` function to query `venues_subscription` table instead of `business_subscriptions`
  - [x] Ensure it checks: `venue_id`, `status = 'active'`, and `expires_at IS NULL OR expires_at > NOW()`

- [x] **Update RLS Policies**
  - [x] Update `venues` table SELECT policy to use `venues_subscription` table
  - [x] Update `venue_services` table SELECT policy to use `venues_subscription` table
  - [x] Update `services` table SELECT policy to use `venues_subscription` table
  - [x] Update `campaigns` table SELECT policy to use `venues_subscription` table
  - [x] Update `specialists` table SELECT policy to use `venues_subscription` table
  - [x] Update `venue_photos` table SELECT policy to use `venues_subscription` table

- [x] **Update RPC Functions**
  - [x] Update `get_nearby_venues` to use `venues_subscription` table in WHERE clause
  - [x] Update `search_venues_advanced` to use `venues_subscription` table in WHERE clause
  - [x] Update `elastic_search_venues` to use `venues_subscription` table in WHERE clause
  - [x] Update `search_venues_by_service` to use `venues_subscription` table in WHERE clause

- [x] **Update Views**
  - [x] Update `featured_venues` view to use `venues_subscription` table

## Validation

> **Note**: Migration file created at `supabase/migrations/20260111220000_update_subscription_filters.sql`
> 
> To apply this migration, run it through the Supabase SQL Editor at:
> https://bovusiymseuxvmgabtfi.supabase.co
> 
> After applying the migration, complete the validation tasks below.

- [ ] **Test Subscription Filtering**
  - [ ] Verify non-authenticated users only see venues with active subscriptions
  - [ ] Verify authenticated users (non-owners) only see venues with active subscriptions
  - [ ] Verify venue owners can see their own venues regardless of subscription status
  - [ ] Verify admins can see all venues (if admin role exists)

- [ ] **Test RPC Functions**
  - [ ] Test `get_nearby_venues` returns only subscribed venues
  - [ ] Test `search_venues_advanced` returns only subscribed venues
  - [ ] Test `elastic_search_venues` returns only subscribed venues
  - [ ] Test `search_venues_by_service` returns only subscribed venues

- [ ] **Test Related Data**
  - [ ] Verify venue_services are hidden for non-subscribed venues
  - [ ] Verify campaigns are hidden for non-subscribed venues
  - [ ] Verify specialists are hidden for non-subscribed venues
  - [ ] Verify venue_photos are hidden for non-subscribed venues

