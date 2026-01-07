# venue-following Specification Delta

## ADDED Requirements

### Requirement: Follow State Display
The system SHALL display the current follow state for a venue to authenticated users.

#### Scenario: User is not following venue
- **GIVEN** an authenticated user views a venue they are not following
- **WHEN** the venue details screen loads
- **THEN** the follow button SHALL display "Takip Et" text
- **AND** the button SHALL have an outlined style with primary color
- **AND** a notification bell icon (outlined) SHALL appear next to the text

#### Scenario: User is already following venue
- **GIVEN** an authenticated user views a venue they are following
- **WHEN** the venue details screen loads
- **THEN** the follow button SHALL display "Takip Ediliyor" text
- **AND** the button SHALL have a filled style with primary background
- **AND** a notification bell icon (filled) SHALL appear next to the text

### Requirement: Follow Action
The system SHALL allow authenticated users to follow a venue and receive confirmation.

#### Scenario: First-time follow with education
- **GIVEN** an authenticated user taps "Takip Et" for the first time in the app
- **WHEN** the follow action is initiated
- **THEN** an informational bottom sheet SHALL appear explaining notification permissions
- **AND** after the user dismisses the bottom sheet, the venue SHALL be added to the user's follows
- **AND** the follow button state SHALL update to "Takip Ediliyor"
- **AND** a success message SHALL be displayed

#### Scenario: Subsequent follows
- **GIVEN** an authenticated user has already seen the follow information
- **WHEN** the user taps "Takip Et" on any venue
- **THEN** the venue SHALL be immediately added to the user's follows without showing the bottom sheet
- **AND** the follow button state SHALL update to "Takip Ediliyor"
- **AND** a success message SHALL be displayed

#### Scenario: Unauthenticated user attempts to follow
- **GIVEN** an unauthenticated user (guest)
- **WHEN** the user taps "Takip Et"
- **THEN** the user SHALL be redirected to the login screen
- **OR** an authentication prompt SHALL appear

### Requirement: Unfollow Action with Confirmation
The system SHALL require user confirmation before unfollowing a venue.

#### Scenario: User confirms unfollow
- **GIVEN** an authenticated user is following a venue
- **WHEN** the user taps "Takip Ediliyor" button
- **THEN** a confirmation dialog SHALL appear with the message "Takipten Çık?"
- **AND** the dialog SHALL explain "Bu mekanı takipten çıkarsanız, kampanya ve bildirimlerini artık almayacaksınız."
- **WHEN** the user confirms the action
- **THEN** the venue SHALL be removed from the user's follows
- **AND** the follow button state SHALL update to "Takip Et"
- **AND** a success message SHALL be displayed

#### Scenario: User cancels unfollow
- **GIVEN** the unfollow confirmation dialog is displayed
- **WHEN** the user taps "Vazgeç" (cancel)
- **THEN** the dialog SHALL close without any changes
- **AND** the user SHALL remain following the venue

### Requirement: Follow Information Bottom Sheet
The system SHALL provide a one-time educational bottom sheet explaining follow and notification features.

#### Scenario: Bottom sheet content
- **GIVEN** the follow information bottom sheet is displayed
- **THEN** it SHALL contain a title explaining the follow feature
- **AND** it SHALL explain that followed venues can send campaign and notification updates
- **AND** it SHALL have a visual indicator icon (notification bell)
- **AND** it SHALL have a dismissal button or tap-outside-to-close functionality

#### Scenario: One-time display tracking
- **GIVEN** a user has seen and dismissed the follow information bottom sheet
- **WHEN** the user follows another venue
- **THEN** the bottom sheet SHALL NOT appear again
- **AND** the preference SHALL persist across app restarts

### Requirement: Follow State Persistence
The system SHALL persist follow relationships in the database and maintain state across sessions.

#### Scenario: Follow state survives app restart
- **GIVEN** a user has followed a venue
- **WHEN** the user closes and reopens the app
- **AND** navigates to the same venue details screen
- **THEN** the follow button SHALL still display "Takip Ediliyor"

#### Scenario: Follow state syncs across devices
- **GIVEN** a user follows a venue on device A
- **WHEN** the user logs in on device B
- **AND** navigates to the same venue
- **THEN** the follow button SHALL display "Takip Ediliyor"

### Requirement: Loading and Error States
The system SHALL provide appropriate feedback during follow/unfollow operations.

#### Scenario: Loading state during follow action
- **GIVEN** a user initiates a follow or unfollow action
- **WHEN** the API request is in progress
- **THEN** the follow button SHALL display a loading indicator
- **AND** the button SHALL be disabled to prevent duplicate actions

#### Scenario: Network error during follow
- **GIVEN** a user attempts to follow a venue
- **WHEN** the network request fails
- **THEN** an error message SHALL be displayed
- **AND** the follow button state SHALL remain unchanged (still "Takip Et")

#### Scenario: Network error during unfollow
- **GIVEN** a user confirms unfollowing a venue
- **WHEN** the network request fails
- **THEN** an error message SHALL be displayed
- **AND** the follow button state SHALL remain "Takip Ediliyor"
