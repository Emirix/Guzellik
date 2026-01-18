# Reviews and Ratings System Specification

## MODIFIED Requirements

### Requirement: Review Submission
The system SHALL allow authenticated users to submit reviews for venues. All reviews are subject to approval by the venue owner before being publicly visible.

#### Scenario: Submit review with rating
- **GIVEN** an authenticated user viewing a venue detail page
- **WHEN** the user taps "Yorum Yaz" and submits a review with rating (1-5 stars) and text
- **THEN** the review SHALL be saved to the `reviews` table with `status = 'pending'`
- **AND** the venue's `review_count` SHALL be incremented (only for approved reviews in public view, but stored in backend)
- **AND** a message SHALL be displayed: "Yorumunuz incelendikten sonra yayınlanacaktır."

#### Scenario: Submit review with photos
- **GIVEN** an authenticated user writing a review
- **WHEN** the user attaches photos to the review
- **THEN** the photos SHALL be limited to a maximum of 2
- **AND** the photos SHALL be uploaded to Supabase Storage via `entity_media`
- **AND** the review SHALL be saved with `status = 'pending'`

### Requirement: Review Sorting and Filtering
The system SHALL allow users to sort and filter reviews.

#### Scenario: Sort reviews by date
- **GIVEN** a user viewing reviews
- **WHEN** the user selects "En Yeni" sort option
- **THEN** reviews SHALL be sorted by `created_at` DESC

#### Scenario: Sort reviews by helpfulness
- **GIVEN** a user viewing reviews
- **WHEN** the user selects "En Faydalı" sort option
- **THEN** reviews SHALL be sorted by `helpful_count` DESC

#### Scenario: Filter reviews by photo
- **GIVEN** a user viewing reviews
- **WHEN** the user selects "Fotoğraflı" filter
- **THEN** only approved reviews with at least one photo SHALL be displayed

### Requirement: Review Response (Business Owner)
The system SHALL allow business owners to respond to reviews. Owners can use templates for faster responses and must approve reviews for visibility.

#### Scenario: Business owner approves and responds
- **GIVEN** a business owner viewing a pending review
- **WHEN** the owner selects a template response and taps "Onayla ve Yanıtla"
- **THEN** the review's `status` SHALL be set to 'approved'.
- **AND** the `business_reply` SHALL be updated.
- **AND** the `reply_at` SHALL be set to NOW().

## ADDED Requirements

### Requirement: Helpful Interaction
The system SHALL allow users to mark reviews as helpful.

#### Scenario: Mark review as helpful
- **GIVEN** an authenticated user viewing an approved review
- **WHEN** the user taps the "Faydalı" button
- **THEN** a record SHALL be added to `review_reactions`.
- **AND** the `helpful_count` in `reviews` SHALL be incremented.
