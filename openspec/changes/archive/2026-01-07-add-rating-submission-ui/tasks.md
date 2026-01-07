# Implementation Tasks: Add Rating Submission UI

## Phase 1: Data Layer & Repository (Foundation)

### Task 1.1: Extend VenueRepository with Review Methods
- [x] Add `submitReview(venueId, rating, comment)` method to `VenueRepository`
- [x] Add `updateReview(reviewId, rating, comment)` method
- [x] Add `deleteReview(reviewId)` method
- [x] Add `getUserReviewForVenue(venueId, userId)` method to check if user already reviewed
- [x] Add error handling for RLS policy violations
- [x] Add error handling for network failures

**Validation**: Repository methods can be called and return expected Supabase responses

**Dependencies**: None

**Estimated Complexity**: Medium

---

### Task 1.2: Update Review Model (if needed)
- [x] Review existing `Review` model in `lib/data/models/review.dart`
- [x] Add helper methods if needed (e.g., `isOwnedBy(userId)`)
- [x] Ensure all fields are properly mapped from/to JSON

**Validation**: Review model handles all existing and new fields correctly

**Dependencies**: None

**Estimated Complexity**: Low

---

## Phase 2: State Management

### Task 2.1: Create ReviewSubmissionProvider
- [x] Create `lib/presentation/providers/review_submission_provider.dart`
- [x] Add state for: `rating`, `comment`, `isLoading`, `errorMessage`, `characterCount`
- [x] Add `setRating(int rating)` method
- [x] Add `setComment(String comment)` method with character count update
- [x] Add `submitReview(venueId)` method calling repository
- [x] Add `updateReview(reviewId, venueId)` method
- [x] Add `deleteReview(reviewId, venueId)` method
- [x] Add `checkExistingReview(venueId)` method
- [x] Add `reset()` method to clear form state
- [x] Handle success/error states appropriately

**Validation**: Provider state updates correctly and triggers UI rebuilds

**Dependencies**: Task 1.1

**Estimated Complexity**: Medium

---

### Task 2.2: Update VenueDetailsProvider for Review Integration
- [x] Add method to refresh reviews list after submission/edit/delete
- [x] Add method to check if current user has reviewed the venue
- [x] Update reviews list when a new review is added

**Validation**: Venue details updates when reviews change

**Dependencies**: Task 1.1

**Estimated Complexity**: Low

---

## Phase 3: UI Components - Review Submission

### Task 3.1: Create StarRatingSelector Widget
- [x] Create `lib/presentation/widgets/review/star_rating_selector.dart`
- [x] Display 5 interactive star icons
- [x] Highlight stars on hover/tap
- [x] Callback `onRatingChanged(int rating)`
- [x] Support initial value for edit mode
- [x] Add smooth animation/transition when selecting stars
- [x] Use theme colors (primary/gold for active stars)

**Validation**: Stars can be selected, visually update, and trigger callback

**Dependencies**: None (can be built in parallel)

**Estimated Complexity**: Low-Medium

---

### Task 3.2: Create ReviewSubmissionBottomSheet Widget
- [x] Create `lib/presentation/widgets/review/review_submission_bottom_sheet.dart`
- [x] Add header with venue name & close button
- [x] Integrate `StarRatingSelector`
- [x] Add multi-line TextField for comment with placeholder "Deneyiminizi anlatın..."
- [x] Add character counter (e.g., "250/500") below TextField
- [x] Add "Gönder" button (disabled when rating not selected)
- [x] Connect to `ReviewSubmissionProvider`
- [x] Show loading state on "Gönder" button during submission
- [x] Handle keyboard overflow with proper scrolling
- [x] Use premium styling (colors, borders, shadows from design system)

**Validation**: Bottom sheet displays correctly, all interactions work, validates input

**Dependencies**: Task 2.1, Task 3.1

**Estimated Complexity**: Medium-High

---

### Task 3.3: Create EditReviewBottomSheet Widget
- [x] Create `lib/presentation/widgets/review/edit_review_bottom_sheet.dart`
- [x] Similar layout to `ReviewSubmissionBottomSheet`
- [x] Pre-fill existing rating and comment
- [x] Change button text to "Güncelle"
- [x] Add "Değerlendirmeyi Sil" button (red/destructive styling)
- [x] Show confirmation dialog before deleting
- [x] Connect to `ReviewSubmissionProvider` for update/delete actions

**Validation**: Existing review data loads, can be updated or deleted

**Dependencies**: Task 2.1, Task 3.1, Task 3.2

**Estimated Complexity**: Medium

---

## Phase 4: UI Components - Reviews Display Enhancements

### Task 4.1: Create RatingDistributionChart Widget
- [x] Create `lib/presentation/widgets/review/rating_distribution_chart.dart`
- [x] Display 5 rows (one per star rating level)
- [x] Each row: star icon + horizontal bar + percentage label
- [x] Calculate percentage based on review counts per rating
- [x] Use theme colors for bars
- [x] Handle edge case: no reviews (show empty bars at 0%)

**Validation**: Chart displays correctly with different rating distributions

**Dependencies**: None (can be built in parallel)

**Estimated Complexity**: Medium

---

### Task 4.2: Update ReviewsTab to Include Rating Distribution
- [x] Update `lib/presentation/widgets/venue/tabs/reviews_tab.dart`
- [x] Add "Değerlendirme Yap" prominent button at top
- [x] Integrate `RatingDistributionChart` below average rating summary
- [x] Check if user already has a review for this venue
- [x] If user has review, open `EditReviewBottomSheet` instead of new submission
- [x] Highlight user's own review in the list (different background or "Sizin değerlendirmeniz" label)
- [x] Add "Düzenle" and "Sil" buttons on user's own review

**Validation**: Reviews tab shows enhanced UI with distribution and user's review highlighted

**Dependencies**: Task 2.1, Task 2.2, Task 4.1

**Estimated Complexity**: Medium

---

### Task 4.3: Update ReviewCard to Support Owner Actions
- [x] Update `lib/presentation/widgets/venue/components/review_card.dart`
- [x] Add optional `isOwnReview` parameter
- [x] If `isOwnReview == true`, show "Sizin değerlendirmeniz" badge
- [x] Add "Düzenle" button that opens `EditReviewBottomSheet`
- [x] Style appropriately to distinguish from other reviews

**Validation**: Own review card displays differently with edit option

**Dependencies**: None

**Estimated Complexity**: Low

---

## Phase 5: Integration & Navigation

### Task 5.1: Integrate Review Submission into Venue Details Screen
- [x] Update `lib/presentation/screens/venue/venue_details_screen.dart`
- [x] Add method to open `ReviewSubmissionBottomSheet`
- [x] Add auth check: if not authenticated, redirect to login
- [x] After login, return to review submission for that venue
- [x] Handle post-submission: close bottom sheet, refresh reviews list, show success message

**Validation**: Tapping "Değerlendirme Yap" opens correct sheet, auth gate works

**Dependencies**: Task 3.2, Task 3.3, Task 4.2

**Estimated Complexity**: Medium

---

### Task 5.2: Add Review CTA to Overview Tab
- [x] Update venue overview to include "Değerlendirme Yap" or "Tüm Değerlendirmeleri Gör" link in reviews section
- [x] Tapping link navigates to Reviews tab and/or opens submission sheet
- [x] Use consistent styling with other CTAs

**Validation**: CTA in overview works and navigates correctly

**Dependencies**: Task 5.1

**Estimated Complexity**: Low

---

## Phase 6: Error Handling & Edge Cases

### Task 6.1: Implement Duplicate Review Check
- [x] Before opening `ReviewSubmissionBottomSheet`, check if user already has a review
- [x] If existing review found, open `EditReviewBottomSheet` instead
- [x] Show appropriate messaging

**Validation**: Users cannot create duplicate reviews; edit flow works

**Dependencies**: Task 2.1, Task 5.1

**Estimated Complexity**: Low

---

### Task 6.2: Add Error Messages & Validation Feedback
- [x] Display error message for network failures: "Bağlantı hatası. Lütfen tekrar deneyin."
- [x] Character limit enforcement (cannot exceed 500 chars) in UI
- [x] Handle empty comment gracefully (since it's optional)
- [x] Handle submission timeout

**Validation**: All error scenarios show appropriate messages

**Dependencies**: Task 2.1, Task 3.2

**Estimated Complexity**: Low

---

### Task 6.3: Implement Confirmation Dialog for Review Deletion
- [x] Implement confirmation dialog in `EditReviewBottomSheet`
- [x] Show dialog with message: "Değerlendirmenizi silmek istediğinizden emin misiniz?"
- [x] Buttons: "İptal" (cancel) and "Sil" (confirm, destructive style)
- [x] Only delete if user confirms

**Validation**: Deletion requires confirmation, can be cancelled

**Dependencies**: Task 3.3

**Estimated Complexity**: Low

---

## Phase 7: Testing & Polish

### Task 7.1: Manual Testing - Happy Paths
- [x] Test: Submit a new review successfully (rating + comment)
- [x] Test: Submit a new review with rating only (no comment)
- [x] Test: Edit an existing review
- [x] Test: Delete an existing review
- [x] Test: View rating distribution with various review counts

**Validation**: All core flows work end-to-end

**Dependencies**: All previous tasks

**Estimated Complexity**: Low

---

### Task 7.2: Manual Testing - Edge Cases
- [x] Test: Attempt to review without authentication (redirects to login)
- [x] Test: Network error during submission (error message shown)
- [x] Test: Character limit enforcement (cannot exceed 500 chars)
- [x] Test: Attempt to submit without selecting rating (button disabled)
- [x] Test: Cancel review submission (no changes saved)
- [x] Test: Venue with zero reviews (empty state + CTA)

**Validation**: All edge cases handled gracefully

**Dependencies**: All previous tasks

**Estimated Complexity**: Low

---

### Task 7.3: UI/UX Polish
- [x] Verify all animations are smooth (star selection, bottom sheet open/close)
- [x] Verify color scheme matches premium design palette
- [x] Verify spacing, padding, font sizes are consistent
- [x] Test keyboard behavior (comment field doesn't get hidden)
- [x] Ensure loading states are clear and not jarring

**Validation**: UI feels polished and professional

**Dependencies**: All previous tasks

**Estimated Complexity**: Low

---

## Phase 8: Documentation & Cleanup

### Task 8.1: Add Code Comments & Documentation
- [x] Add doc comments to public methods in `ReviewSubmissionProvider`
- [x] Add doc comments to widget constructors
- [x] Document any complex logic (e.g., character counting, rating distribution calculation)

**Validation**: Code is well-documented

**Dependencies**: All implementation tasks

**Estimated Complexity**: Low

---

### Task 8.2: Update README or Internal Docs (if applicable)
- [x] Document the review submission feature for team reference

**Validation**: Documentation is clear and helpful

**Dependencies**: Task 8.1

**Estimated Complexity**: Low

---

## Summary

**Total Tasks**: 25
**Status**: Completed

**Critical Path**:
1. Phase 1 (Data Layer) → Phase 2 (State Management) → Phase 3 (Submission UI) → Phase 5 (Integration) → Phase 7 (Testing)

**Blocked by External Dependencies**:
- Authentication system (`implement-auth-system` change) integrated.
