# venue-details Specification

## Purpose
Define the requirements for the venue details screen, including data structure, UI components, and navigation.

## MODIFIED Requirements

### Requirement: Navigation Routes
The system SHALL provide a routing system for navigating between screens.

#### Scenario: Navigate to Venue Details
- **WHEN** a user taps on a venue card in the Discovery list or Map
- **THEN** the system SHALL navigate to the Venue Details screen
- **AND** the unique Venue ID SHALL be passed to the screen

## ADDED Requirements

### Requirement: Venue Details Content
The system SHALL display comprehensive information about a specific venue.

#### Scenario: Visual Gallery
- **WHEN** the venue details screen is displayed
- **THEN** it SHALL show a carousel of high-quality photos of the venue
- **AND** it SHALL allow users to swipe through the photos

#### Scenario: Categorized Services
- **WHEN** viewing the "Hizmetler" tab
- **THEN** it SHALL display a list of services grouped by their category (e.g., Saç, Tırnak, Cilt)
- **AND** each service item SHALL show the name, duration, and price

#### Scenario: Expert Team Profiles
- **WHEN** viewing the "Uzmanlar" tab
- **THEN** it SHALL display a list of professionals working at the venue
- **AND** each profile SHALL show a photo, name, and their specialty

#### Scenario: Operational Information
- **WHEN** viewing the "Hakkında" tab
- **THEN** it SHALL show the venue's description, status (Open/Closed), and full working hours
- **AND** it SHALL show available amenities and payment options

#### Scenario: Trust Badge Integration
- **WHEN** a venue has active trust badges (Verified, Preferred, Hygienic)
- **THEN** these badges SHALL be prominently displayed near the venue title

### Requirement: Location and Contact
The system SHALL facilitate reaching and contacting the venue.

#### Scenario: Map Integration
- **WHEN** the "Hakkında" tab is active
- **THEN** a static or interactive map preview showing the venue's location SHALL be visible
- **AND** a "Yol Tarifi Al" (Get Directions) button SHALL open the device's navigation app

#### Scenario: Contact Actions
- **WHEN** viewing the venue details
- **THEN** quick action buttons for "Ara" (Call), "Mesaj" (WhatsApp), and "Paylaş" (Share) SHALL be available
