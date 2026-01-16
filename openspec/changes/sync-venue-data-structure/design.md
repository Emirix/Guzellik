# Design: Venue Data Synchronization

## Architectural Reasoning

The current hybrid approach (JSONB + Normalized Tables) is a common transition state. To resolve the conflict, we will implement a "Single Source of Truth" strategy where the normalized tables are primary, and the JSONB columns act as a high-performance "Materialized View" or "Denormalized Cache".

### Repository Join Strategy
We will modify `VenueRepository` to use Supabase's Power of Joins. Instead of multiple parallel calls in the provider, we will attempt to get a "Fat Venue Object" for detail views.

Example Query for `getVenueById`:
```dart
.from('venues')
.select('''
  *,
  venue_categories(*),
  specialists(*),
  venue_selected_features(
    venue_features(*)
  )
''')
```

### Model Mapping Layer
The `Venue.fromJson` method will be updated to:
1. Prefer data from joined relations (`specialists`, `venue_selected_features`).
2. Fallback to legacy JSONB columns (`expert_team`, `features`).
3. Flatten the joined features into the existing `features`, `paymentOptions`, and `accessibility` fields to avoid breaking existing UI components.

### Database Sync Triggers
We will ensure PostgreSQL triggers handle the denormalization:
- **Features Sync**: Updates `features`, `payment_options`, and `accessibility` JSONB arrays in `venues` whenever `venue_selected_features` changes.
- **Specialists Sync**: Updates `expert_team` JSONB array in `venues` whenever `specialists` changes.

## Trade-offs
- **Payload Size**: Joining everything increases the response size for a single venue. However, it reduces the number of Round Trip Times (RTT), which is usually more beneficial for mobile performance.
- **Redundancy**: Keeping data in both places uses more storage, but Postgres is efficient with JSONB and this is necessary for high-performance searching/filtering.
