## ADDED Requirements

### Requirement: Cover Photo Storage
The system SHALL store a cover photo URL for each venue to enable customized profile presentation.

#### Scenario: Cover photo column exists
- **GIVEN** the `venues` table exists
- **THEN** a `cover_photo_url` column SHALL exist as TEXT type and nullable
- **AND** this column SHALL store FTP photo URLs

#### Scenario: Cover photo update
- **GIVEN** a venue record exists
- **WHEN** the venue owner selects or uploads a cover photo
- **THEN** the `cover_photo_url` column SHALL be updated with the new URL
- **AND** the update operation SHALL succeed

