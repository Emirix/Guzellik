# User Profile Specification Delta

## ADDED Requirements

### Requirement: Profile Information Display
Authenticated users SHALL be able to view their profile information.

#### Scenario: Display user avatar
- **GIVEN** an authenticated user with a profile photo
- **WHEN** the user views the profile screen
- **THEN** the user's avatar is displayed in a circular frame
- **AND** the avatar has a gold gradient border
- **AND** an edit icon badge is shown on the avatar

#### Scenario: Display user name and email
- **GIVEN** an authenticated user with name "Ayşe Yılmaz" and email "ayse.yilmaz@gmail.com"
- **WHEN** the user views the profile screen
- **THEN** the name "Ayşe Yılmaz" is displayed prominently
- **AND** the email "ayse.yilmaz@gmail.com" is displayed below the name

#### Scenario: Display membership badge
- **GIVEN** an authenticated user with "Gold Üye" membership
- **WHEN** the user views the profile screen
- **THEN** a gold membership badge is displayed
- **AND** the badge shows "Gold Üye" text
- **AND** the badge has a gold star icon

### Requirement: Profile Statistics
Users SHALL be able to view their activity statistics.

#### Scenario: Display appointment count
- **GIVEN** an authenticated user with 12 appointments
- **WHEN** the user views the profile screen
- **THEN** "12" is displayed in the appointments stat card
- **AND** the label "Randevu" is shown

#### Scenario: Display favorites count
- **GIVEN** an authenticated user with 5 favorite venues
- **WHEN** the user views the profile screen
- **THEN** "5" is displayed in the favorites stat card
- **AND** the label "Favori" is shown

#### Scenario: Display points
- **GIVEN** an authenticated user with 150 points
- **WHEN** the user views the profile screen
- **THEN** "150" is displayed in the points stat card
- **AND** the label "Puan" is shown
- **AND** the number is displayed in primary color

### Requirement: Profile Menu Navigation
Users SHALL be able to navigate to various profile-related screens.

#### Scenario: Navigate to appointments
- **GIVEN** an authenticated user on the profile screen
- **WHEN** the user taps "Randevularım"
- **THEN** the user is navigated to the appointments screen

#### Scenario: Navigate to favorites
- **GIVEN** an authenticated user on the profile screen
- **WHEN** the user taps "Favorilerim"
- **THEN** the user is navigated to the favorites screen

#### Scenario: Navigate to wallet
- **GIVEN** an authenticated user on the profile screen
- **WHEN** the user taps "Cüzdanım"
- **THEN** the user is navigated to the wallet screen

### Requirement: Profile Editing
Users SHALL be able to edit their profile information.

#### Scenario: Navigate to profile edit
- **GIVEN** an authenticated user on the profile screen
- **WHEN** the user taps "Düzenle" in the top bar
- **THEN** the user is navigated to the profile edit screen

#### Scenario: Edit avatar
- **GIVEN** an authenticated user on the profile screen
- **WHEN** the user taps the avatar edit icon
- **THEN** the user is prompted to select a new photo
- **AND** options for camera and gallery are shown

### Requirement: Logout Functionality
Users SHALL be able to log out from the profile screen.

#### Scenario: Logout confirmation
- **GIVEN** an authenticated user on the profile screen
- **WHEN** the user taps "Çıkış Yap"
- **THEN** the user is logged out
- **AND** the user is redirected to the home screen
- **AND** the session is cleared

### Requirement: Profile Screen Design
The profile screen SHALL match the provided design specifications.

#### Scenario: Profile header design
- **GIVEN** the profile screen is displayed
- **THEN** the header shows a back button on the left
- **AND** "Profilim" title is centered
- **AND** "Düzenle" button is on the right
- **AND** the header has a subtle border at the bottom

#### Scenario: Avatar design
- **GIVEN** the profile screen is displayed
- **THEN** the avatar has a gold-to-primary gradient border
- **AND** the gradient has a blur effect
- **AND** the edit icon is positioned at bottom-right of avatar
- **AND** the edit icon has a primary color background

#### Scenario: Stats cards design
- **GIVEN** the profile screen is displayed
- **THEN** stats are displayed in a 3-column grid
- **AND** each stat card has a white background
- **AND** each stat card has rounded corners
- **AND** each stat card has a subtle shadow

#### Scenario: Menu items design
- **GIVEN** the profile screen is displayed
- **THEN** menu items are grouped in cards
- **AND** each item has an icon on the left
- **AND** each item has a chevron on the right
- **AND** items have hover/press states
- **AND** items are separated by thin dividers

### Requirement: Dark Mode Support
The profile screen SHALL support dark mode.

#### Scenario: Profile screen in dark mode
- **GIVEN** dark mode is enabled
- **WHEN** the user views the profile screen
- **THEN** the background is dark (#211115)
- **AND** text is white
- **AND** cards have dark backgrounds with transparency
- **AND** borders are subtle and light

## MODIFIED Requirements

None - This is a new capability.

## REMOVED Requirements

None - This is a new capability.
