# Capability: mock-data

## MODIFIED Requirements

### Requirement: Comprehensive Venue Data
The system SHALL store detailed operational information for each venue.

#### Scenario: Detailed venue profile
- **GIVEN** a venue record
- **THEN** it SHALL include working hours, expert team information, certifications, payment options, and accessibility features.
- **AND** it SHALL now explicitly include user reviews to provide a complete profile.

### Requirement: Initial Test Data
The system SHALL have a set of initial test data for venues and services to facilitate development and testing.

#### Scenario: Seed data is present
- **GIVEN** the database is initialized
- **WHEN** the seed script is applied
- **THEN** at least 3 venues SHALL exist in the `venues` table
- **AND** each venue SHALL have at least 3 categorized services in the `services` table.
- **AND** each venue SHALL have at least 2 reviews in the `reviews` table.
- **AND** each venue SHALL have at least 2 expert team members defined in the `expert_team` field.
