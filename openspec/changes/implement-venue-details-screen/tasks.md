# Tasks: Implement Venue Details Screen

## Data & Models
1. [x] Create `Service` model in `lib/data/models/service.dart` with category, price, and duration.
2. [x] Update `VenueRepository` to include `getServicesByVenueId(String venueId)`.
3. [x] Create `VenueDetailsProvider` in `lib/presentation/providers/venue_details_provider.dart` to manage single venue state and services.

## UI Components
4. [x] Create `VenueDetailsScreen` scaffolding in `lib/presentation/screens/venue/venue_details_screen.dart` using `CustomScrollView` and `SliverAppBar`.
5. [x] Implement `VenueHero` component with image carousel and trust badge overlays.
6. [x] Implement `VenueActionButtons` for Follow, Contact, and Directions.
7. [x] Implement `VenueTabSwitcher` using `SliverPersistentHeader`.
8. [x] Create `ServicesTabContent` with categorized expandable/scrollable lists.
9. [x] Create `AboutTabContent` with Map preview, working hours, and amenities.
10. [x] Create `ExpertsTabContent` showing staff profiles.

## Integration & Navigation
11. [x] Register `VenueDetailsScreen` in `main.dart` or the app's routing configuration.
12. [x] Update `VenueCard` in `lib/presentation/widgets/venue/venue_card.dart` to handle `onTap` and navigate to details.
13. [x] Connect `DiscoveryProvider` map markers to navigate to details.

## Validation
14. [x] Verify that clicking a venue from the list correctly loads its details and services.
15. [x] Verify that all trust badges are displayed correctly as per the design.
16. [x] Verify that "Get Directions" opens external maps.
17. [x] Run `flutter test` to ensure no regressions in existing discovery flows.
