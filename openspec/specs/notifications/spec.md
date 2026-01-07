# notifications Specification

## Purpose
TBD - created by archiving change implement-notifications-screen. Update Purpose after archive.
## Requirements
### Requirement: Database Storage for Notifications
The system SHALL store notifications in a persistent database table.

#### Scenario: Notification is saved
- **GIVEN** a new event occurs (e.g., a venue starts a sale)
- **WHEN** a notification record is inserted into the `notifications` table
- **THEN** it SHALL be associated with a specific `user_id`
- **AND** it SHALL have a type (opportunity or system).

### Requirement: Filtering by Category
The system SHALL allow users to filter notifications by their primary category.

#### Scenario: Filter by Fırsatlar
- **GIVEN** the notifications screen is open
- **WHEN** the user selects the "Fırsatlar" tab
- **THEN** only notifications of type `opportunity` SHALL be displayed.

### Requirement: Chronological Grouping
The system SHALL group notifications by the date they were received.

#### Scenario: Visual grouping
- **GIVEN** a list of notifications from multiple days
- **THEN** they SHALL be displayed under headers: "Bugün", "Dün", or "Geçen Hafta".

### Requirement: Mark All as Read
The system SHALL provide a way to mark all unread notifications as read with a single action.

#### Scenario: Mark all as read
- **GIVEN** the user has multiple unread notifications (is_read = false)
- **WHEN** the user taps "Tümünü Oku"
- **THEN** all notifications for that user SHALL have `is_read` set to true
- **AND** the UI unread indicators SHALL disappear.

### Requirement: Swipe to Delete
The system SHALL allow users to remove individual notifications from their list.

#### Scenario: Delete notification
- **GIVEN** a notification item in the list
- **WHEN** the user swipes left on the item
- **THEN** the notification SHALL be removed from the UI
- **AND** the record SHALL be deleted from the database.

