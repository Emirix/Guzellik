# Tasks: Add Venue Category System

- [x] **Infrastructure**
  - [x] Create Supabase migration for `venue_categories` table and `venues.category_id` column.
  - [x] Seed initial category data into `venue_categories`.
  - [x] Update `VenueRepository` to include category information in queries.

- [x] **Data Model**
  - [x] Create `lib/data/models/venue_category.dart`.
  - [x] Update `lib/data/models/venue.dart` to include `VenueCategory? category`.

- [x] **State Management**
  - [x] Create `lib/presentation/providers/category_provider.dart` to manage category loading and selection.

- [ ] **UI Integration**
  - [ ] (Optional) Update discovery/search screens to use the new category IDs for filtering.
