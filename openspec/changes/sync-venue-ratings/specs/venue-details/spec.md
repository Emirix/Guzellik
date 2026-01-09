# venue-details Spec Delta

## MODIFIED Requirements

### Requirement: Real-Time Rating Display
The system SHALL display accurate rating and review counts derived from actual user reviews.

#### Scenario: Venue list cards show correct ratings
- **GIVEN** a venue has reviews in the database
- **WHEN** the venue is displayed in a list (search results, featured, nearby)
- **THEN** the rating SHALL equal the average of all review ratings for that venue
- **AND** the review count SHALL equal the total number of reviews for that venue.

#### Scenario: Venue detail page shows correct ratings
- **GIVEN** a user opens a venue detail page
- **WHEN** the page loads
- **THEN** the displayed rating SHALL match the venue's average review rating
- **AND** the displayed review count SHALL match the actual number of reviews
- **AND** the reviews list SHALL contain the same number of items as the review count.

#### Scenario: Rating updates on new review
- **GIVEN** a user submits a new review for a venue
- **WHEN** the review is saved to the database
- **THEN** the venue's rating SHALL be recalculated to include the new review
- **AND** the venue's review count SHALL be incremented by one.
