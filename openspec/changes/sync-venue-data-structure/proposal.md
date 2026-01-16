# Proposal: Sync Venue Data Structure

## Problem
The venue data is currently split between legacy JSONB columns in the `venues` table (`expert_team`, `features`, `payment_options`, `accessibility`) and new normalized tables (`specialists`, `venue_features`, `venue_selected_features`). 
- `Venue.fromJson` primarily reads from the legacy columns.
- `VenueRepository` methods like `getVenueById` do not join with the new tables, leading to data staleness in components that rely solely on the `Venue` object.
- Administrative updates to specialists and features are not reflected in real-time in areas using the legacy columns unless explicitly synced.

## Solution
1. **Modernize Venue Model**: Update the `Venue` model to support data from both legacy and new structures, prioritizing the new structure when available.
2. **Join-based Fetching**: Update `VenueRepository.getVenueById` and other key methods to fetch specialists and selected features using Supabase joins, ensuring the returned `Venue` object is fully populated with the latest data.
3. **Database-level Synchronization**: Enhance database triggers to ensure that updates to `specialists` and `venue_selected_features` are automatically reflected in the `venues` table's JSONB columns (`expert_team`, `features`, `payment_options`, `accessibility`) to maintain performance for list views and search results.
4. **Clean up UI logic**: Update UI components (like `AboutTab`) to consistently use the unified data structure provided by the `Venue` model or the provider.

## Impact
- **Consistency**: Users will always see the most up-to-date venue information, specialists, and features.
- **Performance**: Joins in the repository will reduce the number of separate API calls needed to load a full venue profile.
- **Maintainability**: Clearer path for eventually deprecating legacy JSONB columns once the sync mechanism is solid.
