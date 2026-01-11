## ADDED Requirements

### Requirement: Index Route Presentation
The system SHALL host a public landing page at the root URL to introduce the application to visitors.

#### Scenario: Unauthorized visitor lands on root
- **WHEN** a user navigates to the root URL
- **THEN** the LandingPage component SHALL be rendered
- **AND** the layout SHALL NOT include the administrative sidebar

### Requirement: Responsive Branding
The system SHALL maintain visual consistency with the mobile application's premium aesthetic across all device sizes.

#### Scenario: Viewing on mobile devices
- **WHEN** screen width is less than 768px
- **THEN** the hero section SHALL stack vertically
- **AND** the navigation menu SHALL collapse into a mobile-friendly menu

### Requirement: App Showcase
The system SHALL clearly showcase the core features of the Güzellik platform.

#### Scenario: Highlighting key features
- **WHEN** the features section is visible
- **THEN** it SHALL include cards for Location Discovery, Verified Venues, and Business Communication
- **AND** each card SHALL use the primary pink/gold color palette correctly
