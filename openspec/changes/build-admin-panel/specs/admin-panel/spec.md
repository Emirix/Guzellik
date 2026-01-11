## ADDED Requirements

### Requirement: Admin panel application structure
The system SHALL provide a standalone React application built with Vite in the `panel/` directory for managing venue data.

**Priority**: High  
**Status**: Proposed

#### Scenario: Initialize admin panel project
- **GIVEN** the project root directory
- **WHEN** an administrator sets up the admin panel
- **THEN** a new Vite + React project is created in `panel/` directory
- **AND** the project is configured with Tailwind CSS
- **AND** Supabase client is configured to connect to the existing database

#### Scenario: Access admin panel interface
- **GIVEN** the admin panel is running
- **WHEN** a user navigates to the admin panel URL
- **THEN** the main layout is displayed with sidebar navigation
- **AND** the venue list page is shown by default

### Requirement: Venue management interface
The system SHALL provide a comprehensive interface for creating and editing venues with all associated data.

**Priority**: High  
**Status**: Proposed

#### Scenario: Create new venue
- **GIVEN** the admin is on the venue creation page
- **WHEN** the admin fills in all required venue information
- **AND** submits the form
- **THEN** a new venue record is created in the `venues` table
- **AND** related records are created for services, specialists, and photos
- **AND** a success notification is displayed

#### Scenario: Edit existing venue
- **GIVEN** the admin is on the venue edit page
- **WHEN** the page loads
- **THEN** all existing venue data is fetched and displayed in the form
- **AND** the admin can modify any field
- **AND** changes are saved to the database when submitted

### Requirement: Photo gallery management
The system SHALL provide comprehensive photo upload and management capabilities with drag-and-drop support.

**Priority**: High  
**Status**: Proposed

#### Scenario: Upload venue photos
- **GIVEN** the admin is creating or editing a venue
- **WHEN** the admin drags and drops photos onto the upload zone
- **THEN** photos are validated for type and size
- **AND** photos are uploaded to Supabase Storage bucket `venue-photos`
- **AND** photo metadata is saved to `venue_photos` table

#### Scenario: Reorder venue photos
- **GIVEN** the admin has uploaded multiple photos
- **WHEN** the admin drags a photo to a new position
- **THEN** the photo order is updated in the UI immediately
- **AND** the `order_index` field is updated in the `venue_photos` table

#### Scenario: Delete venue photo
- **GIVEN** the admin has uploaded photos
- **WHEN** the admin deletes a photo
- **THEN** a confirmation dialog is displayed
- **AND** upon confirmation the photo is deleted from Supabase Storage
- **AND** the photo record is removed from the `venue_photos` table

### Requirement: Form validation and error handling
The system SHALL provide comprehensive validation and error handling for all user inputs.

**Priority**: High  
**Status**: Proposed

#### Scenario: Validate required fields
- **GIVEN** the admin is creating or editing a venue
- **WHEN** the admin attempts to submit the form
- **THEN** all required fields are validated
- **AND** missing required fields are highlighted with error messages
- **AND** the form submission is prevented until all errors are resolved

#### Scenario: Handle Supabase errors
- **GIVEN** the admin is performing a database operation
- **WHEN** a Supabase error occurs
- **THEN** the error is caught and logged
- **AND** a user-friendly error message is displayed in a toast notification

### Requirement: Design consistency
The system SHALL maintain visual consistency with the existing admin design system.

**Priority**: Medium  
**Status**: Proposed

#### Scenario: Apply design system
- **GIVEN** the admin panel is being developed
- **WHEN** UI components are created
- **THEN** the primary color #ec3c68 is used for primary actions
- **AND** the Manrope font family is used for all text
- **AND** glass-card styling is applied to containers
