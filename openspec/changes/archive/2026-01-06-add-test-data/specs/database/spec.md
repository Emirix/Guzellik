## ADDED Requirements

### Requirement: Initial Test Data
The system SHALL have a set of initial test data for venues and services to facilitate development and testing.

#### Scenario: Seed data is present
- **GIVEN** the database is initialized
- **WHEN** the seed script is applied
- **THEN** at least 3 venues SHALL exist in the `venues` table
- **AND** each venue SHALL have at least 2 services in the `services` table.
