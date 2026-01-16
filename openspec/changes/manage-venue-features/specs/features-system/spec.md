# Capability: Dynamic Venue Features

## ADDED Requirements

### Requirement: Dynamic Feature Management
The system SHALL provide a centralized management system for venue features that allows businesses to select from a dynamic master list.

#### Scenario: Business selects features in Admin Panel
- **Given** I am in the Admin Features screen
- **When** I select "VIP Oda" and "Bahçe/Teras" and save
- **Then** the database SHALL update the `venue_selected_features` junction table
- **And** the system SHALL synchronize these features to the `venues.features` JSONB column for search performance.

#### Scenario: Display features on About Tab
- **Given** a venue has multiple selected features in the new system
- **When** a user views the "About" tab of the venue
- **Then** the system SHALL display a section titled "İşletme Özellikleri"
- **And** all selected features SHALL be displayed as clean, text-only chips (no icons)
- **And** the old hardcoded "Accessibility" (Özellikler) and "Payment Options" sections SHALL be replaced by this unified display.

### Requirement: Admin Navigation for Features
Businesses MUST have an easily accessible route to manage their features from the dashboard.

#### Scenario: Accessing features management
- **Given** I am on the Admin Dashboard
- **When** I look at the management menu
- **Then** I SHALL see an "İşletme Özellikleri" item
- **When** I tap on it
- **Then** it SHALL navigate me to the Feature Selection screen.

### Requirement: Feature-Based Discovery
Users SHALL be able to filter venues based on the dynamically selected features.

#### Scenario: Filter by dynamic feature
- **Given** I am on the Explore screen
- **When** I apply a filter for a specific feature (e.g., "Kadınlara Özel")
- **Then** only venues that have this feature selected in the dynamic system SHALL appear in the results.
