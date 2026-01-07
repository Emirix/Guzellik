# User Reviews Specification Delta

## ADDED Requirements

### Requirement: Review Submission
Users SHALL be able to submit a rating and optional comment for venues they want to review.

#### Scenario: Submit a new review successfully
- **GIVEN** an authenticated user viewing a venue they have not reviewed
- **WHEN** the user taps "Değerlendirme Yap" button
- **AND** selects a rating from 1 to 5 stars
- **AND** optionally enters a comment (max 500 characters)
- **AND** taps "Gönder"
- **THEN** the review is saved to the database
- **AND** the venue's average rating is automatically updated via database trigger
- **AND** the user is returned to the venue details screen
- **AND** the new review appears in the reviews list

#### Scenario: Attempt to submit without rating
- **GIVEN** an authenticated user on the review submission screen
- **WHEN** the user has not selected a star rating
- **THEN** the "Gönder" button SHALL be disabled
- **AND** the user cannot submit the review

#### Scenario: Submit review with maximum character comment
- **GIVEN** an authenticated user writing a review
- **WHEN** the user enters exactly 500 characters in the comment field
- **THEN** the character counter displays "500/500"
- **AND** the user can submit the review successfully

#### Scenario: Attempt to submit review exceeding character limit
- **GIVEN** an authenticated user writing a review
- **WHEN** the user attempts to type more than 500 characters
- **THEN** the text field prevents additional input
- **AND** the character counter displays "500/500"

#### Scenario: Network error during submission
- **GIVEN** an authenticated user submitting a review
- **WHEN** a network error occurs during submission
- **THEN** an error message "Bağlantı hatası. Lütfen tekrar deneyin." is displayed
- **AND** the review is not saved
- **AND** the user's input is preserved for retry

### Requirement: Duplicate Review Prevention
The system SHALL prevent users from submitting multiple reviews for the same venue.

#### Scenario: Attempt to review already-reviewed venue
- **GIVEN** an authenticated user who has already submitted a review for venue "Rose Beauty"
- **WHEN** the user taps "Değerlendirme Yap" on the same venue
- **THEN** the system detects an existing review
- **AND** opens the edit review screen instead of new review screen
- **AND** pre-fills the existing rating and comment

### Requirement: Review Editing
Users SHALL be able to edit their previously submitted reviews.

#### Scenario: Edit existing review
- **GIVEN** an authenticated user who has previously reviewed a venue
- **WHEN** the user opens the edit review screen
- **AND** changes the rating from 4 stars to 5 stars
- **AND** updates the comment text
- **AND** taps "Güncelle"
- **THEN** the review is updated in the database
- **AND** the venue's average rating is recalculated automatically
- **AND** the updated review appears in the reviews list
- **AND** the user is returned to the venue details screen

#### Scenario: Cancel editing a review
- **GIVEN** an authenticated user editing their review
- **WHEN** the user makes changes
- **AND** taps "İptal" or the close button
- **THEN** the changes are discarded
- **AND** the user is returned to the venue details screen
- **AND** the original review remains unchanged

### Requirement: Review Deletion
Users SHALL be able to delete their previously submitted reviews.

#### Scenario: Delete own review
- **GIVEN** an authenticated user who has previously reviewed a venue
- **WHEN** the user opens the edit review screen
- **AND** taps "Değerlendirmeyi Sil"
- **AND** confirms the deletion in the confirmation dialog
- **THEN** the review is permanently deleted from the database
- **AND** the venue's average rating and review count are recalculated
- **AND** the user is returned to the venue details screen
- **AND** the deleted review no longer appears in the reviews list

#### Scenario: Cancel review deletion
- **GIVEN** an authenticated user on the edit review screen
- **WHEN** the user taps "Değerlendirmeyi Sil"
- **AND** taps "İptal" in the confirmation dialog
- **THEN** the review is not deleted
- **AND** the edit review screen remains open

### Requirement: Authentication Guard
Review submission SHALL require user authentication.

#### Scenario: Unauthenticated user attempts to review
- **GIVEN** an unauthenticated user viewing a venue details screen
- **WHEN** the user taps "Değerlendirme Yap"
- **THEN** the user is redirected to the login screen
- **AND** after successful login, the user is returned to the review submission screen for that venue

### Requirement: Review Submission UI
The system SHALL provide an intuitive, premium-styled interface for submitting reviews.

#### Scenario: Review submission screen elements
- **GIVEN** the review submission bottom sheet is open
- **THEN** it SHALL display the venue name in the header
- **AND** it SHALL display 5 interactive star icons for rating selection
- **AND** it SHALL display a multi-line text input for comments with placeholder "Deneyiminizi anlatın..."
- **AND** it SHALL display a character counter showing current/maximum characters (e.g., "250/500")
- **AND** it SHALL display a "Gönder" button (disabled if no rating selected)
- **AND** it SHALL display a close/cancel button

#### Scenario: Star rating interaction
- **GIVEN** the review submission screen is open
- **WHEN** the user taps on the 4th star
- **THEN** stars 1 through 4 are visually filled/highlighted
- **AND** the 5th star remains unfilled
- **AND** the "Gönder" button becomes enabled

#### Scenario: Character counter updates
- **GIVEN** the review submission screen with an empty comment field
- **WHEN** the user types "Great service!"
- **THEN** the character counter updates to show "14/500"

### Requirement: Loading and Success States
The system SHALL provide clear feedback during review submission process.

#### Scenario: Loading state during submission
- **GIVEN** an authenticated user submitting a review
- **WHEN** the user taps "Gönder"
- **THEN** the "Gönder" button displays a loading indicator
- **AND** the button is disabled to prevent duplicate submissions
- **AND** the user cannot interact with other form fields

#### Scenario: Success feedback after submission
- **GIVEN** a review is successfully submitted
- **THEN** a subtle success message or toast is displayed
- **AND** the bottom sheet closes automatically
- **AND** the venue details screen shows the updated reviews list with the new review
