---
name: supabase-integration
description: Manages Supabase database operations, RPC functions, migrations, and real-time features for the Guzellik beauty platform. Use when working with database queries, authentication, storage, or real-time subscriptions.
---

# Supabase Integration

## When to use this skill
- Database queries and mutations
- Creating or modifying RPC functions
- Writing database migrations
- Setting up real-time subscriptions
- User mentions "database", "supabase", "query", "migration", "RPC", "veritabanı"
- Working with venue, user, or subscription data

## Project Database Context

### Core Tables
- `profiles` - User profiles (includes `is_business_account`, `business_venue_id`)
- `venues` - Beauty service venues (salons, clinics, etc.)
- `services` - Services offered by venues
- `reviews` - User reviews and ratings
- `follows` - User-venue follow relationships
- `business_subscriptions` - Business account subscriptions
- `notifications` - In-app notifications

### Venue Types
1. Güzellik Salonları (Beauty Salons)
2. Solaryum (Solarium Centers)
3. Kuaför (Hair Salons)
4. Tırnak Stüdyoları (Nail Studios)
5. Estetik Klinikleri (Aesthetic Clinics)
6. Ayak Bakım (Foot Care)

## Migration Workflow

### Creating a New Migration

1. **Check Existing Migrations**
   ```bash
   ls supabase/migrations/
   ```

2. **Create Migration File**
   - Naming: `YYYYMMDDHHMMSS_descriptive_name.sql`
   - Example: `20260118000000_add_business_subscriptions.sql`

3. **Migration Template**
   ```sql
   -- Migration: [Description in Turkish]
   -- Created: YYYY-MM-DD
   
   BEGIN;
   
   -- Your changes here
   
   COMMIT;
   ```

4. **Apply Migration**
   Use the Supabase MCP server tool:
   ```
   mcp_supabase-mcp-server_apply_migration
   ```

### Migration Best Practices
- Always use transactions (BEGIN/COMMIT)
- Add comments in Turkish for business logic
- Include rollback instructions in comments
- Test on development branch first
- Never hardcode IDs in data migrations

## RPC Functions

### Common RPC Functions

#### `get_business_subscription(profile_id UUID)`
Returns active subscription for a business account.

```sql
CREATE OR REPLACE FUNCTION get_business_subscription(profile_id UUID)
RETURNS TABLE (
  id UUID,
  subscription_type TEXT,
  status TEXT,
  expires_at TIMESTAMPTZ,
  features JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT bs.id, bs.subscription_type, bs.status, bs.expires_at, bs.features
  FROM business_subscriptions bs
  WHERE bs.profile_id = $1
    AND bs.status = 'active'
    AND bs.expires_at > NOW()
  ORDER BY bs.created_at DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### `check_business_feature(profile_id UUID, feature TEXT)`
Checks if a business has access to a specific feature.

```sql
CREATE OR REPLACE FUNCTION check_business_feature(
  profile_id UUID,
  feature TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  has_feature BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM business_subscriptions bs
    WHERE bs.profile_id = $1
      AND bs.status = 'active'
      AND bs.expires_at > NOW()
      AND bs.features ? $2
      AND (bs.features->>$2)::boolean = true
  ) INTO has_feature;
  
  RETURN has_feature;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Creating RPC Functions

1. **Define Function Purpose**
   - What data does it return?
   - What parameters are needed?
   - Who can call it? (SECURITY DEFINER vs INVOKER)

2. **Write Function**
   - Use meaningful parameter names
   - Add Turkish comments for business logic
   - Handle edge cases
   - Return appropriate types

3. **Test Function**
   ```sql
   SELECT * FROM get_business_subscription('user-uuid-here');
   ```

4. **Add to Migration**
   - Include in a migration file
   - Apply using MCP server

## Flutter Integration

### Service Layer Pattern

```dart
// lib/data/services/supabase_service.dart
class SupabaseService {
  final SupabaseClient _client;
  
  SupabaseService(this._client);
  
  // Venue queries
  Future<List<Venue>> getVenuesNearby({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    final response = await _client
        .from('venues')
        .select('*')
        .gte('latitude', lat - radiusKm / 111.0)
        .lte('latitude', lat + radiusKm / 111.0)
        .gte('longitude', lng - radiusKm / 111.0)
        .lte('longitude', lng + radiusKm / 111.0);
    
    return (response as List)
        .map((json) => Venue.fromJson(json))
        .toList();
  }
  
  // RPC function call
  Future<BusinessSubscription?> getBusinessSubscription(String profileId) async {
    final response = await _client
        .rpc('get_business_subscription', params: {'profile_id': profileId});
    
    if (response == null || (response as List).isEmpty) return null;
    
    return BusinessSubscription.fromJson(response[0]);
  }
}
```

### Repository Pattern

```dart
// lib/data/repositories/venue_repository.dart
class VenueRepository {
  final SupabaseService _supabaseService;
  
  VenueRepository(this._supabaseService);
  
  Future<List<Venue>> getNearbyVenues({
    required LatLng location,
    double radiusKm = 5.0,
  }) async {
    return await _supabaseService.getVenuesNearby(
      lat: location.latitude,
      lng: location.longitude,
      radiusKm: radiusKm,
    );
  }
}
```

## Real-time Subscriptions

### Setting Up Realtime

```dart
// Listen to venue updates
final subscription = supabase
    .from('venues')
    .stream(primaryKey: ['id'])
    .eq('id', venueId)
    .listen((data) {
      // Update UI with new data
      setState(() {
        venue = Venue.fromJson(data.first);
      });
    });

// Clean up
@override
void dispose() {
  subscription.cancel();
  super.dispose();
}
```

### Notification Subscriptions

```dart
// Listen to new notifications
final notificationStream = supabase
    .from('notifications')
    .stream(primaryKey: ['id'])
    .eq('user_id', userId)
    .eq('is_read', false)
    .listen((data) {
      // Show notification badge
      context.read<NotificationProvider>().updateUnreadCount(data.length);
    });
```

## Row Level Security (RLS)

### Common RLS Patterns

#### User Can Only See Their Own Data
```sql
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);
```

#### Business Owners Can Manage Their Venues
```sql
CREATE POLICY "Business owners can update their venues"
ON venues FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
      AND profiles.business_venue_id = venues.id
      AND profiles.is_business_account = true
  )
);
```

#### Public Read, Authenticated Write
```sql
CREATE POLICY "Anyone can view venues"
ON venues FOR SELECT
USING (true);

CREATE POLICY "Authenticated users can follow venues"
ON follows FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

## Checklist for Database Changes

### Before Making Changes
- [ ] Review existing schema in `supabase/migrations/`
- [ ] Check if similar functionality exists
- [ ] Plan RLS policies
- [ ] Consider performance implications
- [ ] Identify affected Flutter code

### During Implementation
- [ ] Create migration file with timestamp
- [ ] Add Turkish comments for business logic
- [ ] Include RLS policies
- [ ] Test RPC functions
- [ ] Update Flutter models if needed

### After Implementation
- [ ] Apply migration using MCP server
- [ ] Test in development environment
- [ ] Update Flutter services/repositories
- [ ] Update documentation if needed
- [ ] Verify RLS policies work correctly

## Common Queries

### Get Venues by Service
```dart
final venues = await supabase
    .from('venues')
    .select('*, services(*)')
    .contains('services.name', ['Botoks', 'Dolgu']);
```

### Get User's Followed Venues
```dart
final followedVenues = await supabase
    .from('follows')
    .select('venue:venues(*)')
    .eq('user_id', userId);
```

### Get Venue Reviews with User Info
```dart
final reviews = await supabase
    .from('reviews')
    .select('*, user:profiles(full_name, avatar_url)')
    .eq('venue_id', venueId)
    .order('created_at', ascending: false);
```

## Error Handling

```dart
try {
  final data = await supabase
      .from('venues')
      .select()
      .eq('id', venueId)
      .single();
  
  return Venue.fromJson(data);
} on PostgrestException catch (e) {
  // Database error
  print('Database error: ${e.message}');
  rethrow;
} catch (e) {
  // Other errors
  print('Unexpected error: $e');
  rethrow;
}
```

## Resources

### Key Files
- `supabase/migrations/` - Database migrations
- `lib/data/services/supabase_service.dart` - Supabase client wrapper
- `lib/data/repositories/` - Repository implementations
- `docs/API_DOCUMENTATION.md` - Database schema reference

### MCP Server Tools
- `mcp_supabase-mcp-server_apply_migration` - Apply migrations
- `mcp_supabase-mcp-server_execute_sql` - Run SQL queries
- `mcp_supabase-mcp-server_list_tables` - List database tables
- `mcp_supabase-mcp-server_get_project` - Get project details
