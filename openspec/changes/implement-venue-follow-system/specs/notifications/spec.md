# notifications Specification Delta

## MODIFIED Requirements

### Requirement: Database Storage for Notifications
The system SHALL store notifications in a persistent database table with venue association.

#### Scenario: Notification is saved
- **GIVEN** a new event occurs (e.g., a venue starts a sale)
- **WHEN** a notification record is inserted into the `notifications` table
- **THEN** it SHALL be associated with a specific `user_id`
- **AND** it SHALL have a type (opportunity or system)
- **AND** it MAY include a `venue_id` if the notification originates from a venue

#### Scenario: Venue-sent notification is saved
- **GIVEN** a venue sends a notification to its followers
- **WHEN** the notification record is created
- **THEN** it SHALL include the `venue_id` of the sending venue
- **AND** it SHALL be inserted for each follower of that venue

## ADDED Requirements

### Requirement: FCM Token Management
The system SHALL manage Firebase Cloud Messaging tokens for push notification delivery.

#### Scenario: FCM token is saved on first follow
- **GIVEN** a user follows their first venue
- **WHEN** the follow action completes successfully
- **THEN** the app SHALL request FCM permissions if not already granted
- **AND** the FCM token SHALL be retrieved and stored in the user's profile
- **AND** the `fcm_token_updated_at` timestamp SHALL be recorded

#### Scenario: FCM token is refreshed
- **GIVEN** Firebase triggers a token refresh event
- **WHEN** the app receives the new token
- **THEN** the token SHALL be updated in the user's profile
- **AND** the `fcm_token_updated_at` timestamp SHALL be updated

#### Scenario: FCM token is deleted on logout
- **GIVEN** a user logs out of the app
- **WHEN** the logout process completes
- **THEN** the FCM token SHALL be removed from the user's profile
- **AND** the device SHALL no longer receive push notifications for that account

### Requirement: Push Notification Delivery to Followers
The system SHALL enable venues to send push notifications to their followers.

#### Scenario: Venue sends notification to followers
- **GIVEN** a venue wants to notify its followers about a campaign
- **WHEN** a notification is created with the venue's ID
- **THEN** the system SHALL query all users following that venue
- **AND** for each follower with a valid FCM token, a push notification SHALL be sent
- **AND** an in-app notification record SHALL be created in the `notifications` table

#### Scenario: Push notification is received while app is open
- **GIVEN** the app is in the foreground
- **WHEN** a push notification is received
- **THEN** a local notification SHALL be displayed to the user
- **AND** an in-app notification record SHALL be created or updated

#### Scenario: Push notification is received while app is backgrounded
- **GIVEN** the app is in the background or terminated
- **WHEN** a push notification is received
- **THEN** the system notification SHALL appear in the device's notification tray
- **AND** an in-app notification record SHALL be created when the app next opens

### Requirement: Notification Tap Navigation
The system SHALL navigate users to the relevant venue when they tap a venue notification.

#### Scenario: User taps venue notification
- **GIVEN** a notification with a `venue_id` is displayed
- **WHEN** the user taps the notification
- **THEN** the app SHALL open (or come to foreground)
- **AND** the app SHALL navigate to the venue details screen for that venue

#### Scenario: User taps system notification
- **GIVEN** a notification without a `venue_id` (system notification)
- **WHEN** the user taps the notification
- **THEN** the app SHALL open to the notifications screen

### Requirement: Firebase Configuration Documentation
The system SHALL provide clear documentation for Firebase Cloud Messaging setup.

#### Scenario: Developer reviews Firebase setup steps
- **GIVEN** a developer needs to configure FCM for the app
- **WHEN** they access the Firebase setup documentation
- **THEN** it SHALL include step-by-step instructions for Firebase Console configuration
- **AND** it SHALL specify where to place `google-services.json` (Android)
- **AND** it SHALL specify where to place `GoogleService-Info.plist` (iOS)
- **AND** it SHALL explain how to retrieve the FCM server key for backend usage

### Requirement: Notification Permission Request
The system SHALL request notification permissions at the appropriate time.

#### Scenario: Permission requested after first follow
- **GIVEN** a user has just followed their first venue
- **WHEN** the follow action completes
- **THEN** the system SHALL request notification permissions from the OS
- **AND** the request SHALL explain the purpose (receiving campaign updates)

#### Scenario: Permission denied by user
- **GIVEN** the system requests notification permissions
- **WHEN** the user denies the permission
- **THEN** the follow action SHALL still complete successfully
- **AND** the user SHALL only receive in-app notifications (no push notifications)
- **AND** no error message SHALL be shown

#### Scenario: Permission granted by user
- **GIVEN** the system requests notification permissions
- **WHEN** the user grants the permission
- **THEN** the FCM token SHALL be retrieved and stored
- **AND** the user SHALL receive both in-app and push notifications
