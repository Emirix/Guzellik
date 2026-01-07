# Design Document: Rating Submission UI

## Architectural Overview

This feature adds user-generated review submission capabilities to the existing venue details screen. The architecture follows the established clean architecture pattern with clear separation between presentation, business logic, and data layers.

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  VenueDetailsScreen                                          │
│    ├─ ReviewsTab (enhanced)                                 │
│    │   ├─ RatingDistributionChart                          │
│    │   ├─ ReviewCard (with owner actions)                  │
│    │   └─ "Değerlendirme Yap" CTA                          │
│    │                                                         │
│    └─ ReviewSubmissionBottomSheet / EditReviewBottomSheet   │
│         ├─ StarRatingSelector                               │
│         ├─ Comment TextField                                 │
│         └─ Submit/Update/Delete Actions                      │
│                                                               │
├─────────────────────────────────────────────────────────────┤
│                    State Management                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ReviewSubmissionProvider (ChangeNotifier)                   │
│    ├─ rating: int?                                          │
│    ├─ comment: String                                        │
│    ├─ characterCount: int                                    │
│    ├─ isLoading: bool                                        │
│    ├─ errorMessage: String?                                  │
│    └─ Methods: submit, update, delete, checkExisting        │
│                                                               │
│  VenueDetailsProvider (existing, enhanced)                   │
│    └─ refreshReviews() after submission/edit/delete          │
│                                                               │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  VenueRepository (extended)                                  │
│    ├─ submitReview(venueId, rating, comment)               │
│    ├─ updateReview(reviewId, rating, comment)              │
│    ├─ deleteReview(reviewId)                                │
│    └─ getUserReviewForVenue(venueId, userId)                │
│                                                               │
│  Supabase Client                                             │
│    └─ public.reviews table (existing)                        │
│         ├─ RLS: users can create own reviews                │
│         ├─ RLS: users can update/delete own reviews         │
│         └─ Trigger: auto-update venue.rating on change      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Key Design Decisions

### 1. Bottom Sheet vs Full Screen Modal

**Decision**: Use Bottom Sheet for review submission

**Rationale**:
- **Context Retention**: Venue information remains visible at the top, providing context
- **Modern UX Pattern**: Bottom sheets are standard in modern mobile apps for quick actions
- **Less Intrusive**: Users can dismiss easily by swiping down
- **Keyboard Handling**: Better support for sliding up when keyboard appears

**Trade-offs**:
- Slightly less space for content (mitigated by making it scrollable)
- May feel cramped on small screens (tested on iPhone SE size - acceptable)

### 2. Edit vs New Review Flow

**Decision**: Detect existing review and open edit mode automatically

**Rationale**:
- **Prevents Duplicates**: Enforces one-review-per-user-per-venue constraint at UI level
- **Seamless UX**: User doesn't see an error message; system intelligently switches to edit mode
- **Database Constraint**: Backed by database-level unique constraint (user_id + venue_id)

**Implementation**:
- Check for existing review when "Değerlendirme Yap" is tapped
- If found, pre-fill `EditReviewBottomSheet` with existing data
- If not found, open empty `ReviewSubmissionBottomSheet`

### 3. State Management: Dedicated Provider vs Extending VenueDetailsProvider

**Decision**: Create dedicated `ReviewSubmissionProvider`

**Rationale**:
- **Separation of Concerns**: Review submission logic is complex enough to warrant its own provider
- **Reusability**: Could potentially be used from other screens in the future
- **Testability**: Easier to unit test in isolation
- **State Lifecycle**: Review submission state should be ephemeral and reset after submission, separate from venue details state

**Integration**: `ReviewSubmissionProvider` will notify `VenueDetailsProvider` to refresh reviews list after successful submission/update/delete.

### 4. Character Limit Enforcement

**Decision**: Prevent typing beyond 500 characters + show counter

**Rationale**:
- **Proactive UX**: Better than allowing typing and showing error on submit
- **Visual Feedback**: Character counter provides clear guidance
- **Database Constraint**: Enforces consistency with database TEXT field expectations

**Implementation**:
- `TextField` with `maxLength: 500`
- Character counter updates on every keystroke
- Counter turns red when approaching limit (e.g., \u003e 480 chars) - optional polish

### 5. Rating Distribution Chart Design

**Decision**: Horizontal bars with percentages (not absolute counts)

**Rationale**:
- **Scalability**: Percentages are meaningful whether there are 10 or 10,000 reviews
- **Visual Clarity**: Bars provide quick visual comparison between rating levels
- **Standard Pattern**: Matches UX patterns used by Google Reviews, Amazon, etc.

**Implementation**:
```
5 ★ ████████████████████ 45%
4 ★ ████████████         30%
3 ★ ████                 10%
2 ★ ████                 10%
1 ★ ██                    5%
```

### 6. User's Own Review Highlighting

**Decision**: Show user's review at the top with visual distinction

**Rationale**:
- **Discoverability**: Users can easily find and edit their review
- **Ownership**: Clear visual indication that this review belongs to them
- **Quick Actions**: Edit and delete buttons are immediately accessible

**Implementation**:
- Light background color (e.g., primary color at 5% opacity)
- Small badge/label: "Sizin değerlendirmeniz"
- Edit and delete icon buttons in top-right corner

### 7. Deletion Confirmation

**Decision**: Require explicit confirmation before deleting review

**Rationale**:
- **Prevent Accidents**: Deletion is irreversible
- **User Trust**: Shows we care about not losing user data accidentally
- **Standard Pattern**: Matches user expectations for destructive actions

**Implementation**:
- AlertDialog with clear message
- Two buttons: "İptal" (default) and "Sil" (destructive, red)

### 8. Authentication Guard

**Decision**: Redirect to login when unauthenticated, then return to review submission

**Rationale**:
- **Seamless Flow**: User intent (review submission) is preserved after login
- **Encourages Engagement**: Removing friction increases likelihood of review completion
- **Consistent Pattern**: Matches other auth-required actions in the app

**Implementation**:
- Store intended action (review for venue X) before redirecting to login
- After successful auth, navigate to review submission with venue context

### 9. Loading States

**Decision**: Disable form and show loading indicator during submission

**Rationale**:
- **Prevent Duplicate Submissions**: Disabling button prevents double-tap issues
- **User Feedback**: Loading indicator confirms action is processing
- **Error Recovery**: If submission fails, form remains available for retry

**Implementation**:
- Button text changes to loading spinner
- Form fields become read-only (or grayed out)
- Error message replaces loading state if submission fails

## Data Flow Diagrams

### Submit New Review Flow

```
User taps "Değerlendirme Yap"
  ↓
[VenueDetailsScreen] checks auth
  ↓
[ReviewSubmissionProvider] checkExistingReview(venueId)
  ↓
[VenueRepository] getUserReviewForVenue(venueId, userId)
  ↓
[Supabase] SELECT from reviews WHERE user_id = X AND venue_id = Y
  ↓
No existing review found
  ↓
[ReviewSubmissionBottomSheet] opens (empty)
  ↓
User selects rating (e.g., 4 stars) + types comment
  ↓
User taps "Gönder"
  ↓
[ReviewSubmissionProvider] submitReview(venueId, rating, comment)
  ↓
[VenueRepository] INSERT INTO reviews (venue_id, user_id, rating, comment)
  ↓
[Supabase] Trigger auto-updates venue.rating and venue.rating_count
  ↓
Success
  ↓
[ReviewSubmissionProvider] sets success state
  ↓
[VenueDetailsProvider] refreshReviews()
  ↓
[VenueDetailsScreen] closes bottom sheet, shows success message
```

### Edit Existing Review Flow

```
User taps "Değerlendirme Yap" (already has review)
  ↓
[ReviewSubmissionProvider] checkExistingReview(venueId)
  ↓
Existing review found
  ↓
[EditReviewBottomSheet] opens (pre-filled with existing data)
  ↓
User changes rating from 4 to 5, updates comment
  ↓
User taps "Güncelle"
  ↓
[ReviewSubmissionProvider] updateReview(reviewId, rating, comment)
  ↓
[VenueRepository] UPDATE reviews SET rating = X, comment = Y WHERE id = Z
  ↓
[Supabase] Trigger recalculates venue.rating
  ↓
Success
  ↓
[VenueDetailsProvider] refreshReviews()
  ↓
[VenueDetailsScreen] closes bottom sheet, updated review appears
```

## Performance Considerations

### 1. Real-time Updates

**Not Implemented in MVP**: Supabase Realtime subscription for reviews
**Rationale**: Adds complexity; not critical for MVP since reviews don't change frequently
**Future Enhancement**: Subscribe to review changes so users see new reviews without refreshing

### 2. Review List Pagination

**Not Implemented in MVP**: Paginated loading of reviews
**Rationale**: Most venues won't have \u003e100 reviews initially; premature optimization
**Trigger for Implementation**: If average reviews per venue \u003e 50, implement pagination

### 3. Optimistic UI Updates

**Not Implemented in MVP**: Show new review immediately before API confirmation
**Rationale**: Adds complexity with rollback logic; loading state is acceptable for MVP
**Future Enhancement**: Optimistically add review to list, rollback if submission fails

## Error Handling Strategy

| Error Type | User-Facing Message | Recovery Action |
|-----------|---------------------|----------------|
| Network failure | "Bağlantı hatası. Lütfen tekrar deneyin." | Preserve form data, allow retry |
| Duplicate review (edge case) | Auto-switch to edit mode | Show edit screen instead |
| Character limit exceeded | Prevent typing \u003e 500 chars | TextField enforces maxLength |
| Missing rating | Disable submit button | Enable when rating selected |
| Auth failure | Redirect to login | Return to review submission after auth |
| RLS policy violation | "Bu işlemi yapmaya yetkiniz yok." | Log error, show generic message |

## Security Considerations

1. **Row-Level Security (RLS)**:
   - Already configured on `reviews` table
   - Users can only INSERT with their own `user_id`
   - Users can only UPDATE/DELETE reviews where `user_id = auth.uid()`

2. **Input Validation**:
   - Frontend: Character limit (500), rating range (1-5)
   - Backend: Supabase enforces rating CHECK constraint (1-5)

3. **SQL Injection**: Not applicable (using Supabase client, parameterized queries)

4. **XSS Prevention**: Flutter renders text safely; no HTML injection risk

## Accessibility

- **Screen Reader Support**: Star rating has semantic labels (e.g., "4 out of 5 stars")
- **Keyboard Navigation**: All interactive elements are focusable
- **Color Contrast**: Primary text and backgrounds meet WCAG AA standards
- **Touch Targets**: Buttons and stars meet minimum size (48x48 logical pixels)

## Testing Strategy

### Unit Tests
- `ReviewSubmissionProvider` state logic
- Character counting
- Rating validation

### Widget Tests
- `StarRatingSelector` interaction
- `ReviewSubmissionBottomSheet` form validation
- `RatingDistributionChart` rendering

### Integration Tests
- End-to-end review submission flow
- Edit and delete flows
- Auth guard behavior

### Manual Testing Checklist
- Test on small screens (iPhone SE) and large screens (iPad)
- Test with slow network (loading states)
- Test with offline mode (error messages)
- Test with keyboard open (layout doesn't break)

## Open Questions \u0026 Future Enhancements

### Answered in Proposal
✅ Photo uploads → Not in MVP
✅ Venue responses → Not in MVP
✅ Moderation → Not in MVP (auto-publish)

### Future Considerations
- **Helpful Reviews**: Like/dislike on reviews to surface quality content
- **Verified Visits**: Mark reviews from users who actually booked/visited
- **Review Filters**: Filter by rating, date, verified visits
- **Photo Attachments**: Allow users to upload photos with reviews
- **Moderation Dashboard**: Admin tool to review/remove inappropriate content
- **Review Notifications**: Notify venue owners of new reviews (separate feature)
