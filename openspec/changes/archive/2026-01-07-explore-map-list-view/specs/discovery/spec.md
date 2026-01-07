## ADDED Requirements

### Requirement: Interactive Map Discovery
The system SHALL provide a Google Maps based interface showing venue locations using custom markers.

#### Scenario: User navigates to map view
- **GIVEN** the user is on the Discovery screen
- **WHEN** the Map view mode is active
- **THEN** a Google Map SHALL be rendered
- **AND** it SHALL display markers representing venues within the current viewport.

### Requirement: UI View Toggle
The system SHALL allow users to switch between a map view and a list view seamlessly.

#### Scenario: User toggles from Map to List
- **GIVEN** the user is in Map view
- **WHEN** the user taps the view toggle button
- **THEN** the Map view SHALL be replaced by a scrollable List view of venues
- **AND** the toggle UI SHALL update to reflect the new state.

### Requirement: Category Filtering and Search
The system SHALL provide a search bar to filter venues by name or category.

#### Scenario: User searches for a category
- **GIVEN** the Discovery screen is open
- **WHEN** the user enters a category name in the search bar
- **THEN** both the Map markers and List items SHALL be filtered to show only matching venues.

### Requirement: User Geolocation
The system SHALL center the map on the user's current location upon request if permissions are granted.

#### Scenario: User centers on current location
- **GIVEN** location permissions are granted
- **WHEN** the user taps the location centering button
- **THEN** the map camera SHALL animate to the user's current GPS coordinates.
