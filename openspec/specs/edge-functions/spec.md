# edge-functions Specification

## Purpose
TBD - created by archiving change add-supabase. Update Purpose after archive.
## Requirements
### Requirement: Server-side Notification Dispatch
The system SHALL provide a centralized mechanism to send push notifications via Firebase Cloud Messaging.

#### Scenario: Send FCM notification
- **GIVEN** a notification payload and a target device token
- **WHEN** the `send-notification` edge function is triggered
- **THEN** it SHALL request the FCM API to deliver the message
- **AND** it SHALL return the delivery status.

