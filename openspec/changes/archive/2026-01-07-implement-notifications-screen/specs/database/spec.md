# database Specification

## ADDED Requirements

### Requirement: Persistent Notification Storage
The system SHALL provide a table named `notifications` to store user-specific messages and alerts.

#### Scenario: Table has required columns
- **GIVEN** the `notifications` table exists
- **THEN** it SHALL include `id`, `user_id`, `title`, `body`, `type`, `is_read`, `metadata`, and `created_at`.
