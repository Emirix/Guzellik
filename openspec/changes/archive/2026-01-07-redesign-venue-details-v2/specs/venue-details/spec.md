# Venue Details Specification (V2)

## Purpose
Defines the user interface and interaction requirements for the comprehensive venue details screen, ensuring a premium "one-stop" information hub for users.

## ADDED Requirements

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

#### Scenario: Booking initiation
- **GIVEN** the venue details screen is open
- **WHEN** the user views the bottom of the screen
- **THEN** a persistent bar SHALL show the starting price (e.g., "₺750/seans")
- **AND** a prominent "Randevu Oluştur" button.
