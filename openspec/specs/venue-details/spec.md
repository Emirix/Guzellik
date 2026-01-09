# venue-details Specification

## Purpose
TBD - created by archiving change redesign-venue-details-v2. Update Purpose after archive.
## Requirements
### Requirement: Premium Hero Experience
The system SHALL provide a high-impact visual header with integrated navigation and actions.

#### Scenario: Hero visual elements
- **GIVEN** the venue details screen is open
- **WHEN** the user views the top section
- **THEN** it SHALL display a parallax-ready hero image
- **AND** it SHALL show "Back", "Favorite", and "Share" buttons with glass-effect styling
- **AND** it SHALL display pagination dots if multiple images exist.

### Requirement: Unified Venue Overview
The system SHALL present key information (About, Experts, Hours, Location, Awards) in a single integrated scrollable view.

#### Scenario: Navigating the overview
- **GIVEN** the Overview tab is active
- **WHEN** the user scrolls down
- **THEN** the sections SHALL appear in the following order: Identity, Quick Actions, About, Experts, Hours, Map, Certificates, Features, Reviews.
- **AND** each section SHALL follow the spacing and divider patterns defined in the design.

### Requirement: Social & Contact Actions
The system SHALL provide direct links to communication and social platforms.

#### Scenario: Tapping quick actions
- **GIVEN** the Quick Actions grid is visible
- **WHEN** the user taps "WhatsApp"
- **THEN** it SHALL open the WhatsApp app with the venue's number and a pre-filled message (if available).
- **WHEN** the user taps "Instagram"
- **THEN** it SHALL open the Instagram app to the venue's profile.

### Requirement: Dynamic Status Indicator
The system SHALL visually indicate the current opening status of the venue.

#### Scenario: Status display
- **GIVEN** the current time and venue working hours
- **WHEN** the venue is currently open
- **THEN** a "Şu an Açık" badge with a pulse animation SHALL be displayed.
- **WHEN** the venue is closed
- **THEN** the relevant day in the hours card SHALL be highlighted (e.g., "Kapalı").

### Requirement: Persistent Action Hub
The system SHALL maintain a fixed bottom bar for primary conversion.

#### Scenario: Contact initiation
- **GIVEN** the venue details screen is open
- **WHEN** the user views the bottom of the screen
- **THEN** a persistent bar SHALL show the starting price (e.g., "₺750/seans")
- **AND** a prominent "İletişime Geç" button.
- **AND** tapping the button SHALL show contact options (WhatsApp, Phone).

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

