# Business Account Management Specification

## MODIFIED Requirements

### Requirement: Admin Dashboard Access
The system SHALL provide business owners with an admin dashboard to manage their venue.

#### Scenario: Access admin dashboard
- **GIVEN** a business account with a claimed venue
- **WHEN** the user navigates to the admin dashboard
- **THEN** the dashboard SHALL display:
  - Venue overview (views, followers, rating)
  - Quick actions (edit profile, manage services, create campaign, manage reviews)
  - Recent activity
  - Subscription status

#### Scenario: Manage venue information
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user taps "Mekan Bilgileri"
- **THEN** the user SHALL be able to edit:
  - Basic info (name, description, phone, email)
  - Address and location
  - Working hours
  - Social media links
  - Payment options
  - Accessibility features

#### Scenario: Manage services
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user taps "Hizmetler"
- **THEN** the user SHALL be able to:
  - Add new services
  - Edit existing services (name, price, duration)
  - Delete services
  - Reorder services

#### Scenario: Manage specialists
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user taps "Uzmanlar"
- **THEN** the user SHALL be able to:
  - Add new specialists (name, photo, bio, specialization)
  - Edit specialist information
  - Delete specialists
  - Assign services to specialists

#### Scenario: Manage gallery
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user taps "Galeri"
- **THEN** the user SHALL be able to:
  - Upload new photos
  - Delete photos
  - Reorder photos
  - Set cover photo
  - Add photo descriptions

#### Scenario: Access review management
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user navigates to the "Yorum Yönetimi" section
- **THEN** the system SHALL display tabs for "Onay Bekleyenler" and "Onaylananlar".
- **AND** for each pending review, "Onayla", "Yanıtla" and "Reddet" options SHALL be visible.

## ADDED Requirements

### Requirement: Review Response Templates
The system SHALL provide response templates for business owners.

#### Scenario: Use template for reply
- **GIVEN** a business owner responding to a review
- **WHEN** the owner clicks on a pre-defined template (e.g., "Nezaketiniz için teşekkürler")
- **THEN** the template text SHALL be populated into the reply text field.
- **AND** the owner SHALL be able to edit the text before sending.
