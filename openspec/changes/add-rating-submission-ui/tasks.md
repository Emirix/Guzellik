# Implementation Tasks: Add Rating Submission UI

## Phase 1: Data Layer \u0026 Repository (Foundation)

### Task 1.1: Extend VenueRepository with Review Methods
- [ ] Add `submitReview(venueId, rating, comment)` method to `VenueRepository`
- [ ] Add `updateReview(reviewId, rating, comment)` method
- [ ] Add `deleteReview(reviewId)` method
- [ ] Add `getUserReviewForVenue(venueId, userId)` method to check if user already reviewed
- [ ] Add error handling for RLS policy violations
- [ ] Add error handling for network failures

**Validation**: Repository methods can be called and return expected Supabase responses

**Dependencies**: None

**Estimated Complexity**: Medium

---

### Task 1.2: Update Review Model (if needed)
- [ ] Review existing `Review` model in `lib/data/models/review.dart`
- [ ] Add helper methods if needed (e.g., `isOwnedBy(userId)`)
- [ ] Ensure all fields are properly mapped from/to JSON

**Validation**: Review model handles all existing and new fields correctly

**Dependencies**: None

**Estimated Complexity**: Low

---

## Phase 2: State Management

### Task 2.1: Create ReviewSubmissionProvider
- [ ] Create `lib/presentation/providers/review_submission_provider.dart`
- [ ] Add state for: `rating`, `comment`, `isLoading`, `errorMessage`, `characterCount`
- [ ] Add `setRating(int rating)` method
- [ ] Add `setComment(String comment)` method with character count update
- [ ] Add `submitReview(venueId)` method calling repository
- [ ] Add `updateReview(reviewId, venueId)` method
- [ ] Add `deleteReview(reviewId, venueId)` method
- [ ] Add `checkExistingReview(venueId)` method
- [ ] Add `reset()` method to clear form state
- [ ] Handle success/error states appropriately

**Validation**: Provider state updates correctly and triggers UI rebuilds

**Dependencies**: Task 1.1

**Estimated Complexity**: Medium

---

### Task 2.2: Update VenueDetailsProvider for Review Integration
- [ ] Add method to refresh reviews list after submission/edit/delete
- [ ] Add method to check if current user has reviewed the venue
- [ ] Update reviews list when a new review is added

**Validation**: Venue details updates when reviews change

**Dependencies**: Task 1.1

**Estimated Complexity**: Low

---

## Phase 3: UI Components - Review Submission

### Task 3.1: Create StarRatingSelector Widget
- [ ] Create `lib/presentation/widgets/review/star_rating_selector.dart`
- [ ] Display 5 interactive star icons
- [ ] Highlight stars on hover/tap
- [ ] Callback `onRatingChanged(int rating)`
- [ ] Support initial value for edit mode
- [ ] Add smooth animation/transition when selecting stars
- [ ] Use theme colors (primary/gold for active stars)

**Validation**: Stars can be selected, visually update, and trigger callback

**Dependencies**: None (can be built in parallel)

**Estimated Complexity**: Low-Medium

---

### Task 3.2: Create ReviewSubmissionBottomSheet Widget
- [ ] Create `lib/presentation/widgets/review/review_submission_bottom_sheet.dart`
- [ ] Add header with venue name \u0026 close button
- [ ] Integrate `StarRatingSelector`
- [ ] Add multi-line TextField for comment with placeholder "Deneyiminizi anlatın..."
- [ ] Add character counter (e.g., "250/500") below TextField
- [ ] Add "Gönder" button (disabled when rating not selected)
- [ ] Connect to `ReviewSubmissionProvider`
- [ ] Show loading state on "Gönder" button during submission
- [ ] Handle keyboard overflow with proper scrolling
- [ ] Use premium styling (colors, borders, shadows from design system)

**Validation**: Bottom sheet displays correctly, all interactions work, validates input

**Dependencies**: Task 2.1, Task 3.1

**Estimated Complexity**: Medium-High

---

### Task 3.3: Create EditReviewBottomSheet Widget
- [ ] Create `lib/presentation/widgets/review/edit_review_bottom_sheet.dart`
- [ ] Similar layout to `ReviewSubmissionBottomSheet`
- [ ] Pre-fill existing rating and comment
- [ ] Change button text to "Güncelle"
- [ ] Add "Değerlendirmeyi Sil" button (red/destructive styling)
- [ ] Show confirmation dialog before deleting
- [ ] Connect to `ReviewSubmissionProvider` for update/delete actions

**Validation**: Existing review data loads, can be updated or deleted

**Dependencies**: Task 2.1, Task 3.1, Task 3.2

**Estimated Complexity**: Medium

---

## Phase 4: UI Components - Reviews Display Enhancements

### Task 4.1: Create RatingDistributionChart Widget
- [ ] Create `lib/presentation/widgets/review/rating_distribution_chart.dart`
- [ ] Display 5 rows (one per star rating level)
- [ ] Each row: star icon + horizontal bar + percentage label
- [ ] Calculate percentage based on review counts per rating
- [ ] Use theme colors for bars
- [ ] Handle edge case: no reviews (show empty bars at 0%)

**Validation**: Chart displays correctly with different rating distributions

**Dependencies**: None (can be built in parallel)

**Estimated Complexity**: Medium

---

### Task 4.2: Update ReviewsTab to Include Rating Distribution
- [ ] Update `lib/presentation/widgets/venue/tabs/reviews_tab.dart`
- [ ] Add "Değerlendirme Yap" prominent button at top
- [ ] Integrate `RatingDistributionChart` below average rating summary
- [ ] Check if user already has a review for this venue
- [ ] If user has review, open `EditReviewBottomSheet` instead of new submission
- [ ] Highlight user's own review in the list (different background or "Sizin değerlendirmeniz" label)
- [ ] Add "Düzenle" and "Sil" buttons on user's own review

**Validation**: Reviews tab shows enhanced UI with distribution and user's review highlighted

**Dependencies**: Task 2.1, Task 2.2, Task 4.1

**Estimated Complexity**: Medium

---

### Task 4.3: Update ReviewCard to Support Owner Actions
- [ ] Update `lib/presentation/widgets/venue/components/review_card.dart`
- [ ] Add optional `isOwnReview` parameter
- [ ] If `isOwnReview == true`, show "Sizin değerlendirmeniz" badge
- [ ] Add "Düzenle" button that opens `EditReviewBottomSheet`
- [ ] Style appropriately to distinguish from other reviews

**Validation**: Own review card displays differently with edit option

**Dependencies**: None

**Estimated Complexity**: Low

---

## Phase 5: Integration \u0026 Navigation

### Task 5.1: Integrate Review Submission into Venue Details Screen
- [ ] Update `lib/presentation/screens/venue/venue_details_screen.dart`
- [ ] Add method to open `ReviewSubmissionBottomSheet`
- [ ] Add auth check: if not authenticated, redirect to login
- [ ] After login, return to review submission for that venue
- [ ] Handle post-submission: close bottom sheet, refresh reviews list, show success message

**Validation**: Tapping "Değerlendirme Yap" opens correct sheet, auth gate works

**Dependencies**: Task 3.2, Task 3.3, Task 4.2

**Estimated Complexity**: Medium

---

### Task 5.2: Add Review CTA to Overview Tab
- [ ] Update venue overview to include "Değerlendirme Yap" or "Tüm Değerlendirmeleri Gör" link in reviews section
- [ ] Tapping link navigates to Reviews tab and/or opens submission sheet
- [ ] Use consistent styling with other CTAs

**Validation**: CTA in overview works and navigates correctly

**Dependencies**: Task 5.1

**Estimated Complexity**: Low

---

## Phase 6: Error Handling \u0026 Edge Cases

### Task 6.1: Implement Duplicate Review Check
- [ ] Before opening `ReviewSubmissionBottomSheet`, check if user already has a review
- [ ] If existing review found, open `EditReviewBottomSheet` instead
- [ ] Show appropriate messaging

**Validation**: Users cannot create duplicate reviews; edit flow works

**Dependencies**: Task 2.1, Task 5.1

**Estimated Complexity**: Low

---

### Task 6.2: Add Error Messages \u0026 Validation Feedback
- [ ] Display error message for network failures: "Bağlantı hatası. Lütfen tekrar deneyin."
- [ ] Display character limit warning when approaching 500 chars
- [ ] Handle empty comment gracefully (since it's optional)
- [ ] Handle submission timeout

**Validation**: All error scenarios show appropriate messages

**Dependencies**: Task 2.1, Task 3.2

**Estimated Complexity**: Low

---

### Task 6.3: Implement Confirmation Dialog for Review Deletion
- [ ] Create reusable confirmation dialog widget (or use existing if available)
- [ ] Show dialog with message: "Değerlendirmenizi silmek istediğinizden emin misiniz?"
- [ ] Buttons: "İptal" (cancel) and "Sil" (confirm, destructive style)
- [ ] Only delete if user confirms

**Validation**: Deletion requires confirmation, can be cancelled

**Dependencies**: Task 3.3

**Estimated Complexity**: Low

---

## Phase 7: Testing \u0026 Polish

### Task 7.1: Manual Testing - Happy Paths
- [ ] Test: Submit a new review successfully (rating + comment)
- [ ] Test: Submit a new review with rating only (no comment)
- [ ] Test: Edit an existing review
- [ ] Test: Delete an existing review
- [ ] Test: View rating distribution with various review counts

**Validation**: All core flows work end-to-end

**Dependencies**: All previous tasks

**Estimated Complexity**: Low

---

### Task 7.2: Manual Testing - Edge Cases
- [ ] Test: Attempt to review without authentication (redirects to login)
- [ ] Test: Network error during submission (error message shown)
- [ ] Test: Character limit enforcement (cannot exceed 500 chars)
- [ ] Test: Attempt to submit without selecting rating (button disabled)
- [ ] Test: Cancel review submission (no changes saved)
- [ ] Test: Venue with zero reviews (empty state + CTA)

**Validation**: All edge cases handled gracefully

**Dependencies**: All previous tasks

**Estimated Complexity**: Low

---

### Task 7.3: UI/UX Polish
- [ ] Verify all animations are smooth (star selection, bottom sheet open/close)
- [ ] Verify color scheme matches premium design palette
- [ ] Verify spacing, padding, font sizes are consistent
- [ ] Test keyboard behavior (comment field doesn't get hidden)
- [ ] Add haptic feedback on star selection (optional, nice-to-have)
- [ ] Ensure loading states are clear and not jarring

**Validation**: UI feels polished and professional

**Dependencies**: All previous tasks

**Estimated Complexity**: Low

---

### Task 7.4: Write Unit Tests for ReviewSubmissionProvider
- [ ] Test `setRating()` updates state correctly
- [ ] Test `setComment()` updates state and character count
- [ ] Test `submitReview()` calls repository and handles success
- [ ] Test `submitReview()` handles error from repository
- [ ] Test `updateReview()` and `deleteReview()` methods
- [ ] Mock `VenueRepository` for isolated testing

**Validation**: Provider logic is tested and passes

**Dependencies**: Task 2.1

**Estimated Complexity**: Medium

---

### Task 7.5: Write Widget Tests for Key Components
- [ ] Test `StarRatingSelector` widget (star selection, callback)
- [ ] Test `ReviewSubmissionBottomSheet` form validation
- [ ] Test `RatingDistributionChart` rendering with different data
- [ ] Test `ReviewCard` displays correctly with owner actions

**Validation**: Widget tests pass

**Dependencies**: Task 3.1, Task 3.2, Task 4.1, Task 4.3

**Estimated Complexity**: Medium

---

## Phase 8: Documentation \u0026 Cleanup

### Task 8.1: Add Code Comments \u0026 Documentation
- [ ] Add doc comments to public methods in `ReviewSubmissionProvider`
- [ ] Add doc comments to widget constructors
- [ ] Document any complex logic (e.g., character counting, rating distribution calculation)

**Validation**: Code is well-documented

**Dependencies**: All implementation tasks

**Estimated Complexity**: Low

---

### Task 8.2: Update README or Internal Docs (if applicable)
- [ ] Document the review submission feature for team reference
- [ ] Include screenshots or flow diagrams if helpful

**Validation**: Documentation is clear and helpful

**Dependencies**: Task 8.1

**Estimated Complexity**: Low

---

## Summary

**Total Tasks**: 25
**Estimated Total Effort**: 3-5 days for a single developer

**Parallelizable Work**:
- Phase 1 \u0026 Phase 3 can start in parallel (data layer + UI widgets)
- Task 3.1 (StarRatingSelector) and Task 4.1 (RatingDistributionChart) are independent

**Critical Path**:
1. Phase 1 (Data Layer) → Phase 2 (State Management) → Phase 3 (Submission UI) → Phase 5 (Integration) → Phase 7 (Testing)

**Blocked by External Dependencies**:
- Authentication system (`implement-auth-system` change) must be completed for auth guard to work properly. If not ready, can mock auth check for development.
