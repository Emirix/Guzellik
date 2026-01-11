# media-system Specification Delta

## MODIFIED Requirements

### Requirement: Centralized Asset Management
The system SHALL manage all visual assets through a centralized media table and associations.

#### Scenario: Venue has multiple gallery images
- **GIVEN** a venue
- **WHEN** we query for its media items
- **THEN** it SHALL return a list of media records from the `media` table via the `entity_media` join table
- **AND** it SHALL include metadata like `is_primary` and `sort_order`.

#### Scenario: Specialist has a profile photo via media system
- **GIVEN** a specialist record
- **THEN** it SHALL be associated with a `media` record of type `specialist_photo`
- **AND** the system SHALL provide the correct storage path for the photo.
