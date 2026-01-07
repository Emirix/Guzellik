# Tasks: Populate Venue Details Mock Data

## 1. Infrastructure & Data Layer
- [x] 1.1 Create `reviews` table in Supabase via migration. <!-- id: 0 -->
- [x] 1.2 Update `seed.sql` with comprehensive test data for 3 venues (Services, Reviews, Experts). <!-- id: 1 -->
- [x] 1.3 Apply migration and seed to Supabase. <!-- id: 2 -->

## 2. Flutter Data Layer
- [x] 2.1 Implement `Review` model in `lib/data/models/review.dart`. <!-- id: 3 -->
- [x] 2.2 Update `VenueRepository` with `getReviewsByVenueId(venueId)`. <!-- id: 4 -->
- [x] 2.3 Update `VenueDetailsProvider` to fetch and store reviews. <!-- id: 5 -->

## 3. UI Implementation
- [x] 3.1 Create `ReviewCard` widget in `lib/presentation/widgets/venue/components/review_card.dart`. <!-- id: 6 -->
- [x] 3.2 Implement `ReviewsTab` in `lib/presentation/widgets/venue/tabs/reviews_tab.dart`. <!-- id: 7 -->
- [x] 3.3 Update `VenueDetailsScreen` to replace placeholder with `ReviewsTab`. <!-- id: 8 -->

## 4. Validation
- [x] 4.1 Verify each tab displays correct data for multiple venues. <!-- id: 9 -->
- [x] 4.2 Check loading and empty states for each tab. <!-- id: 10 -->
