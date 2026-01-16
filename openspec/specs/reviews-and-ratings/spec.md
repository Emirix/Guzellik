---
status: proposed
created: 2026-01-16
author: AI Assistant
---

# Reviews and Ratings System Specification

## Purpose
Define a comprehensive review and rating system that allows users to share their experiences with venues, helps build trust, and provides valuable feedback to business owners.

## Requirements

### Requirement: Review Submission
The system SHALL allow authenticated users to submit reviews for venues.

#### Scenario: Submit review with rating
- **GIVEN** an authenticated user viewing a venue detail page
- **WHEN** the user taps "Yorum Yaz" and submits a review with rating (1-5 stars) and text
- **THEN** the review SHALL be saved to the `reviews` table
- **AND** the venue's `review_count` SHALL be incremented
- **AND** the venue's `average_rating` SHALL be recalculated
- **AND** the review SHALL appear in the venue's review list
- **AND** a success message SHALL be displayed

#### Scenario: Submit review without text
- **GIVEN** an authenticated user
- **WHEN** the user submits a review with only a rating (no text)
- **THEN** the review SHALL be saved successfully
- **AND** the rating SHALL be included in the venue's average

#### Scenario: Submit review with photos
- **GIVEN** an authenticated user writing a review
- **WHEN** the user attaches photos to the review
- **THEN** the photos SHALL be uploaded to Supabase Storage
- **AND** the photo URLs SHALL be stored in the review's `photos` array
- **AND** the photos SHALL be displayed in the review

#### Scenario: Unauthenticated user attempts to review
- **GIVEN** an unauthenticated user
- **WHEN** the user attempts to write a review
- **THEN** the user SHALL be redirected to the login screen
- **AND** after login, the user SHALL be returned to the review form

---

### Requirement: Review Editing
The system SHALL allow users to edit their own reviews.

#### Scenario: Edit existing review
- **GIVEN** a user has previously submitted a review
- **WHEN** the user edits the review text or rating
- **THEN** the review SHALL be updated in the database
- **AND** the `updated_at` timestamp SHALL be set to the current time
- **AND** the venue's average rating SHALL be recalculated
- **AND** an "Düzenlendi" badge SHALL be displayed on the review

#### Scenario: User attempts to edit another user's review
- **GIVEN** a user viewing another user's review
- **WHEN** the user attempts to edit the review
- **THEN** the edit option SHALL NOT be available
- **AND** only the review owner SHALL see the edit button

---

### Requirement: Review Deletion
The system SHALL allow users to delete their own reviews.

#### Scenario: Delete own review
- **GIVEN** a user has submitted a review
- **WHEN** the user deletes the review
- **THEN** the review SHALL be removed from the database
- **AND** the venue's `review_count` SHALL be decremented
- **AND** the venue's `average_rating` SHALL be recalculated
- **AND** a confirmation message SHALL be displayed

#### Scenario: Confirm before deletion
- **GIVEN** a user taps the delete button
- **WHEN** the delete action is initiated
- **THEN** a confirmation dialog SHALL be displayed
- **AND** the review SHALL only be deleted if the user confirms

---

### Requirement: Rating Calculation
The system SHALL maintain accurate average ratings for all venues.

#### Scenario: Calculate average rating
- **GIVEN** a venue has multiple reviews
- **WHEN** a new review is added, edited, or deleted
- **THEN** the average rating SHALL be recalculated as: SUM(all ratings) / COUNT(reviews)
- **AND** the result SHALL be rounded to 1 decimal place
- **AND** the `average_rating` column SHALL be updated in the `venues` table

#### Scenario: Venue with no reviews
- **GIVEN** a venue has no reviews
- **THEN** the `average_rating` SHALL be NULL or 0
- **AND** the UI SHALL display "Henüz değerlendirilmedi"

---

### Requirement: Review Display
The system SHALL display reviews in a user-friendly format.

#### Scenario: Display reviews on venue page
- **GIVEN** a venue detail page
- **WHEN** the "Yorumlar" tab is selected
- **THEN** reviews SHALL be displayed in reverse chronological order (newest first)
- **AND** each review SHALL show: user name, avatar, rating, text, photos, date
- **AND** pagination or infinite scroll SHALL be implemented for many reviews

#### Scenario: Display rating summary
- **GIVEN** a venue with reviews
- **WHEN** the venue detail page loads
- **THEN** a rating summary SHALL be displayed showing:
  - Average rating (e.g., "4.5")
  - Total review count (e.g., "128 değerlendirme")
  - Star distribution chart (5 stars: 60%, 4 stars: 25%, etc.)

---

### Requirement: Review Sorting and Filtering
The system SHALL allow users to sort and filter reviews.

#### Scenario: Sort reviews by date
- **GIVEN** a user viewing reviews
- **WHEN** the user selects "En Yeni" sort option
- **THEN** reviews SHALL be sorted by `created_at` DESC

#### Scenario: Sort reviews by rating
- **GIVEN** a user viewing reviews
- **WHEN** the user selects "En Yüksek Puan" sort option
- **THEN** reviews SHALL be sorted by `rating` DESC

#### Scenario: Filter reviews by rating
- **GIVEN** a user viewing reviews
- **WHEN** the user selects "5 Yıldız" filter
- **THEN** only reviews with 5-star ratings SHALL be displayed

---

### Requirement: Helpful Votes
The system SHALL allow users to mark reviews as helpful or unhelpful.

#### Scenario: Mark review as helpful
- **GIVEN** a user viewing a review
- **WHEN** the user taps the "Faydalı" button
- **THEN** the `helpful_count` SHALL be incremented
- **AND** the user's vote SHALL be recorded to prevent duplicate votes
- **AND** the button SHALL change to "Faydalı Bulundu" state

#### Scenario: Remove helpful vote
- **GIVEN** a user has marked a review as helpful
- **WHEN** the user taps the "Faydalı Bulundu" button again
- **THEN** the `helpful_count` SHALL be decremented
- **AND** the user's vote SHALL be removed
- **AND** the button SHALL return to "Faydalı" state

---

### Requirement: Review Moderation
The system SHALL provide moderation capabilities for inappropriate reviews.

#### Scenario: Report inappropriate review
- **GIVEN** a user viewing a review
- **WHEN** the user taps "Şikayet Et" and selects a reason
- **THEN** a report SHALL be created in the `review_reports` table
- **AND** the review SHALL be flagged for admin review
- **AND** a confirmation message SHALL be displayed

#### Scenario: Admin removes inappropriate review
- **GIVEN** an admin reviewing flagged reviews
- **WHEN** the admin confirms the review violates guidelines
- **THEN** the review SHALL be deleted or hidden
- **AND** the user SHALL be notified (optional)
- **AND** the venue's rating SHALL be recalculated

---

### Requirement: Review Response (Business Owner)
The system SHALL allow business owners to respond to reviews.

#### Scenario: Business owner responds to review
- **GIVEN** a business owner viewing reviews of their venue
- **WHEN** the owner submits a response to a review
- **THEN** the response SHALL be saved in the `review_responses` table
- **AND** the response SHALL be displayed below the review
- **AND** the reviewer SHALL receive a notification (optional)

---

### Requirement: Review Verification
The system SHOULD indicate verified reviews when possible.

#### Scenario: Verified review badge
- **GIVEN** a user has made a verified appointment/purchase
- **WHEN** the user submits a review
- **THEN** the review SHALL be marked as "Doğrulanmış Müşteri"
- **AND** a verification badge SHALL be displayed

---

### Requirement: Review Photos
The system SHALL support photo attachments in reviews.

#### Scenario: Upload review photos
- **GIVEN** a user writing a review
- **WHEN** the user selects photos from their device
- **THEN** the photos SHALL be uploaded to the `review-photos` storage bucket
- **AND** the photo URLs SHALL be stored in the review
- **AND** a maximum of 5 photos SHALL be allowed per review

#### Scenario: View review photos
- **GIVEN** a review with photos
- **WHEN** a user taps on a photo thumbnail
- **THEN** the photo SHALL be displayed in full-screen mode
- **AND** the user SHALL be able to swipe through all photos

---

### Requirement: Spam Prevention
The system SHALL implement measures to prevent spam and fake reviews.

#### Scenario: Rate limiting
- **GIVEN** a user has submitted a review
- **WHEN** the user attempts to submit another review for the same venue
- **THEN** the system SHALL prevent duplicate reviews
- **AND** an error message SHALL be displayed: "Bu mekan için zaten yorum yaptınız"

#### Scenario: Suspicious activity detection
- **GIVEN** multiple reviews from the same IP address or device
- **WHEN** the system detects suspicious patterns
- **THEN** the reviews SHALL be flagged for manual review
- **AND** the user MAY be temporarily restricted from reviewing

---

## Non-Functional Requirements

### Performance
- Review submission SHALL complete within 2 seconds
- Review list SHALL load within 1 second
- Photo upload SHALL support up to 5 photos (max 5MB each)
- Rating recalculation SHALL be asynchronous and not block UI

### Security
- Users SHALL only be able to edit/delete their own reviews
- Review content SHALL be sanitized to prevent XSS attacks
- Photo uploads SHALL be validated for file type and size
- Rate limiting SHALL prevent spam (max 1 review per venue per user)

### Reliability
- Failed review submissions SHALL be retryable
- Photo uploads SHALL support retry on failure
- Rating calculations SHALL be eventually consistent

---

## Data Model

### reviews table
```sql
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  photos TEXT[] DEFAULT '{}',
  helpful_count INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  is_flagged BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(venue_id, user_id) -- One review per user per venue
);

CREATE INDEX idx_reviews_venue_id ON reviews(venue_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at DESC);
```

### review_votes table
```sql
CREATE TABLE review_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vote_type TEXT NOT NULL CHECK (vote_type IN ('helpful', 'unhelpful')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(review_id, user_id) -- One vote per user per review
);

CREATE INDEX idx_review_votes_review_id ON review_votes(review_id);
```

### review_responses table
```sql
CREATE TABLE review_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  response_text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(review_id) -- One response per review
);
```

### review_reports table
```sql
CREATE TABLE review_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### venues table (updates)
```sql
ALTER TABLE venues
ADD COLUMN average_rating DECIMAL(2,1),
ADD COLUMN review_count INTEGER DEFAULT 0;
```

---

## RPC Functions

### update_venue_rating()
```sql
CREATE OR REPLACE FUNCTION update_venue_rating(p_venue_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE venues
  SET 
    average_rating = (
      SELECT ROUND(AVG(rating)::numeric, 1)
      FROM reviews
      WHERE venue_id = p_venue_id
    ),
    review_count = (
      SELECT COUNT(*)
      FROM reviews
      WHERE venue_id = p_venue_id
    )
  WHERE id = p_venue_id;
END;
$$ LANGUAGE plpgsql;
```

### get_venue_reviews()
```sql
CREATE OR REPLACE FUNCTION get_venue_reviews(
  p_venue_id UUID,
  p_sort_by TEXT DEFAULT 'newest',
  p_rating_filter INTEGER DEFAULT NULL,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  user_name TEXT,
  user_avatar TEXT,
  rating INTEGER,
  comment TEXT,
  photos TEXT[],
  helpful_count INTEGER,
  is_verified BOOLEAN,
  created_at TIMESTAMPTZ,
  response TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    p.full_name,
    p.avatar_url,
    r.rating,
    r.comment,
    r.photos,
    r.helpful_count,
    r.is_verified,
    r.created_at,
    rr.response_text
  FROM reviews r
  JOIN profiles p ON r.user_id = p.id
  LEFT JOIN review_responses rr ON r.id = rr.review_id
  WHERE r.venue_id = p_venue_id
    AND (p_rating_filter IS NULL OR r.rating = p_rating_filter)
  ORDER BY
    CASE WHEN p_sort_by = 'newest' THEN r.created_at END DESC,
    CASE WHEN p_sort_by = 'highest' THEN r.rating END DESC,
    CASE WHEN p_sort_by = 'helpful' THEN r.helpful_count END DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;
```

---

## API Integration

### ReviewRepository Methods

```dart
// Submit review
Future<Review> submitReview({
  required String venueId,
  required int rating,
  String? comment,
  List<String>? photoUrls,
});

// Edit review
Future<Review> editReview({
  required String reviewId,
  required int rating,
  String? comment,
  List<String>? photoUrls,
});

// Delete review
Future<void> deleteReview(String reviewId);

// Get venue reviews
Future<List<Review>> getVenueReviews({
  required String venueId,
  String sortBy = 'newest',
  int? ratingFilter,
  int limit = 20,
  int offset = 0,
});

// Vote on review
Future<void> voteReview({
  required String reviewId,
  required String voteType,
});

// Report review
Future<void> reportReview({
  required String reviewId,
  required String reason,
  String? description,
});

// Business owner response
Future<void> respondToReview({
  required String reviewId,
  required String responseText,
});

// Upload review photos
Future<List<String>> uploadReviewPhotos(List<File> photos);
```

---

## UI/UX Requirements

### Review List Screen
- Display average rating and review count at top
- Show star distribution chart
- Provide sort options: "En Yeni", "En Yüksek Puan", "En Faydalı"
- Provide filter options: "Tüm Yorumlar", "5 Yıldız", "4 Yıldız", etc.
- Display each review with: avatar, name, rating, date, text, photos
- Show "Faydalı" button with count
- Show "Şikayet Et" option
- Implement infinite scroll or pagination

### Write Review Screen
- Display venue name and photo at top
- 5-star rating selector (required)
- Text input for comment (optional, max 500 characters)
- Photo upload button (max 5 photos)
- Character counter for comment
- "Gönder" button (disabled until rating selected)
- Loading indicator during submission

### Review Item Widget
- User avatar (circular)
- User name
- Rating stars (filled based on rating)
- Review date (relative: "2 gün önce")
- Review text (with "Daha Fazla" expand option if long)
- Review photos (horizontal scrollable thumbnails)
- "Faydalı" button with count
- "Şikayet Et" option (three-dot menu)
- Edit/Delete options (only for own reviews)
- Business response (if exists, indented below review)

---

## Testing Requirements

### Unit Tests
- Test rating calculation logic
- Test review validation
- Test photo URL generation
- Test helpful vote logic

### Integration Tests
- Test complete review submission flow
- Test review editing and deletion
- Test rating recalculation on review changes
- Test review sorting and filtering
- Test helpful voting

### E2E Tests
- Test user journey from viewing venue to submitting review
- Test editing and deleting own review
- Test viewing and sorting reviews
- Test photo upload in review

---

## Error Handling

### Common Errors

| Error Code | Message | User Action |
|------------|---------|-------------|
| `duplicate-review` | "Bu mekan için zaten yorum yaptınız" | Edit existing review |
| `invalid-rating` | "Lütfen 1-5 arası puan verin" | Select valid rating |
| `comment-too-long` | "Yorum 500 karakterden uzun olamaz" | Shorten comment |
| `photo-upload-failed` | "Fotoğraf yüklenemedi" | Retry upload |
| `photo-size-exceeded` | "Fotoğraf boyutu 5MB'dan büyük olamaz" | Select smaller photo |
| `too-many-photos` | "En fazla 5 fotoğraf ekleyebilirsiniz" | Remove some photos |
| `unauthorized` | "Yorum yapmak için giriş yapmalısınız" | Login |
| `network-error` | "Bağlantı hatası" | Check connection and retry |

---

## Dependencies
- Supabase Database (reviews table)
- Supabase Storage (review photos)
- `ReviewRepository`
- `ReviewSubmissionProvider`
- `image_picker` package (photo selection)
- `cached_network_image` (photo display)

---

## Future Enhancements
- Video reviews
- Review templates for common feedback
- AI-powered review summarization
- Sentiment analysis
- Review rewards/badges
- Review translation
- Review search
- Verified purchase reviews
- Review analytics for business owners
