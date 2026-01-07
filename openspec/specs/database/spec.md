# database Specification

## Purpose
TBD - created by archiving change add-supabase. Update Purpose after archive.
## Requirements
### Requirement: User Profile Persistence
The system SHALL provide a persistent storage for user profiles linked to authentication.

#### Scenario: Profile record exists for every user
- **GIVEN** a new user signs up through Supabase Auth
- **WHEN** the signup process is completed
- **THEN** a corresponding entry SHALL exist in the `profiles` table.

### Requirement: Venue Location Storage
The system SHALL store venue addresses and geographic coordinates to enable spatial discovery.

#### Scenario: Venue has coordinates
- **GIVEN** a venue profile exists
- **THEN** it SHALL include latitude and longitude coordinates
- **AND** it SHALL be searchable via geographic queries.

### Requirement: Service Classification
The system SHALL allow services to be organized by predefined categories.

#### Scenario: Service has a category
- **GIVEN** a service is defined in the database
- **THEN** it SHALL be assigned to one of: Saç, Cilt Bakımı, Kaş-Kirpik, etc.

### Requirement: Venue Following
The system SHALL track user-venue interest to facilitate targetted notifications.

#### Scenario: User follows a venue
- **GIVEN** an authenticated user
- **WHEN** the user follows a venue
- **THEN** a relationship SHALL be recorded in the `follows` table.

### Requirement: Trust and Verification System
The system SHALL support verification badges for venues to build user trust.

#### Scenario: Venue has trust badges
- **GIVEN** a venue record
- **THEN** it SHALL support flags for `is_verified` (Onaylı Mekan), `is_preferred` (En Çok Tercih Edilen), and `is_hygienic` (Hijyen Onaylı).

### Requirement: Comprehensive Venue Data
The system SHALL store detailed operational information for each venue.

#### Scenario: Detailed venue profile
- **GIVEN** a venue record
- **THEN** it SHALL include working hours, expert team information, certifications, payment options, and accessibility features.

### Requirement: Initial Test Data
The system SHALL have a set of initial test data for venues and services to facilitate development and testing.

#### Scenario: Seed data is present
- **GIVEN** the database is initialized
- **WHEN** the seed script is applied
- **THEN** at least 3 venues SHALL exist in the `venues` table
- **AND** each venue SHALL have at least 2 services in the `services` table.

### Requirement: Advanced Search RPC Function
The system SHALL provide an RPC function for advanced venue search with multiple filter criteria.

#### Scenario: Search with service names
- **GIVEN** a user searches for "Botoks"
- **WHEN** the `search_venues_advanced` RPC is called with search_query="Botoks"
- **THEN** venues offering services matching "Botoks" SHALL be returned
- **AND** results SHALL be ordered by distance from user location

#### Scenario: Combined filters
- **GIVEN** a user applies multiple filters
- **WHEN** the RPC is called with category, rating, and distance filters
- **THEN** only venues matching ALL criteria SHALL be returned
- **AND** results SHALL be ordered by relevance and distance

### Requirement: Persistent Notification Storage
The system SHALL provide a table named `notifications` to store user-specific messages and alerts.

#### Scenario: Table has required columns
- **GIVEN** the `notifications` table exists
- **THEN** it SHALL include `id`, `user_id`, `title`, `body`, `type`, `is_read`, `metadata`, and `created_at`.

