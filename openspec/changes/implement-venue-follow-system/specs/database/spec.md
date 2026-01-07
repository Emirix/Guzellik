# database Specification Delta

## MODIFIED Requirements

### Requirement: User Profile Persistence
The system SHALL provide a persistent storage for user profiles linked to authentication, including FCM token management.

#### Scenario: Profile record exists for every user
- **GIVEN** a new user signs up through Supabase Auth
- **WHEN** the signup process is completed
- **THEN** a corresponding entry SHALL exist in the `profiles` table

#### Scenario: Profile stores FCM token
- **GIVEN** a user profile exists
- **WHEN** the user enables push notifications
- **THEN** the profile SHALL include an `fcm_token` column to store the Firebase Cloud Messaging token
- **AND** the profile SHALL include an `fcm_token_updated_at` timestamp column

### Requirement: Persistent Notification Storage
The system SHALL provide a table named `notifications` to store user-specific messages and alerts with venue association.

#### Scenario: Table has required columns
- **GIVEN** the `notifications` table exists
- **THEN** it SHALL include `id`, `user_id`, `title`, `body`, `type`, `is_read`, `metadata`, and `created_at`
- **AND** it SHALL include `venue_id` to track which venue sent the notification (nullable for system notifications)

## ADDED Requirements

### Requirement: Follow Relationship Indexing
The system SHALL provide optimized indexes on the `follows` table for efficient follow state queries.

#### Scenario: User-venue follow lookup is indexed
- **GIVEN** the `follows` table exists
- **THEN** there SHALL be a composite index on `(user_id, venue_id)` for checking if a user follows a specific venue
- **AND** there SHALL be an index on `venue_id` for querying all followers of a venue

#### Scenario: Follow query performance
- **GIVEN** a user has followed 100 venues
- **WHEN** the system checks if the user follows a specific venue
- **THEN** the query SHALL use the composite index for optimal performance
