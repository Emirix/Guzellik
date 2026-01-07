# Capability: reviews

Infrastructure and UI for venue reviews.

## ADDED Requirements

### Requirement: Venue Reviews Storage
The system SHALL store and retrieve user reviews for each venue, including rating and optional comments.

#### Scenario: Fetching Reviews for a Venue
- **Given** a venue with ID `V1` has 3 reviews in the database.
- **When** the application requests reviews for `V1`.
- **Then** the system returns a list of 3 review objects with details (user, rating, comment, date).

### Requirement: Venue Reviews UI
The application SHALL display a list of reviews in the "Yorumlar" tab of the venue details screen.

#### Scenario: Displaying Reviews Tab
- **Given** the user is on the venue details screen and selects the "Yorumlar" tab.
- **When** the reviews are loaded.
- **Then** the screen displays a list of reviews with user avatars, names, ratings (stars), and comments.
