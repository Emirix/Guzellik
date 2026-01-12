# structured-availability Specification Delta

## ADDED Requirements

### Requirement: Granular Opening Hour Storage
The system SHALL store venue opening and closing times in a structured table per day of the week.

#### Scenario: Check if venue is open now
- **GIVEN** the current time and day
- **WHEN** the system checks a venue's availability
- **THEN** it SHALL query the `venue_hours` table for that specific day
- **AND** return `true` if the current time is between `open_time` and `close_time` and `is_closed` is false.

#### Scenario: Display weekly schedule
- **GIVEN** a venue profile screen
- **THEN** the system SHALL display the hours for all 7 days retrieved from the `venue_hours` table
- **AND** handle cases where the venue is marked as "Closed" for certain days.
