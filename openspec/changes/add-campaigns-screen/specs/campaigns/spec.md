## ADDED Requirements

### Requirement: Campaign Data Model
The system SHALL provide a Campaign model to represent promotional offers from venues.

#### Scenario: Campaign has required fields
- **WHEN** a campaign is created
- **THEN** it SHALL include:
  - Unique identifier (id)
  - Associated venue (venue_id)
  - Campaign title
  - Start and end dates
  - At least one discount type (percentage OR amount)
  - Active status flag

#### Scenario: Campaign has optional fields
- **WHEN** a campaign is created
- **THEN** it MAY include:
  - Description text
  - Image URL
  - Both discount types (percentage AND amount)

#### Scenario: Campaign validation
- **WHEN** a campaign is validated
- **THEN** end_date SHALL be after start_date
- **AND** at least one of discount_percentage or discount_amount SHALL be present
- **AND** discount_percentage SHALL be between 0 and 100 if present
- **AND** discount_amount SHALL be non-negative if present

### Requirement: Campaign Display
The system SHALL display active campaigns to users in a dedicated screen.

#### Scenario: Active campaigns are shown
- **WHEN** user navigates to campaigns screen
- **THEN** only campaigns where is_active = true AND end_date > NOW() SHALL be displayed
- **AND** campaigns SHALL show venue name, logo, title, discount, and validity dates

#### Scenario: Campaign card interaction
- **WHEN** user taps a campaign card
- **THEN** a bottom sheet SHALL open with full campaign details
- **AND** bottom sheet SHALL include a button to navigate to venue detail page

#### Scenario: Empty state
- **WHEN** no active campaigns exist
- **THEN** an empty state message SHALL be displayed
- **AND** message SHALL indicate "Henüz kampanya yok"

### Requirement: Campaign Sorting
The system SHALL allow users to sort campaigns by different criteria.

#### Scenario: Sort by discount
- **WHEN** user selects "İndirim Oranına Göre" sort option
- **THEN** campaigns SHALL be ordered by discount value descending
- **AND** percentage discounts SHALL be compared by percentage value
- **AND** amount discounts SHALL be compared by amount value

#### Scenario: Sort by date
- **WHEN** user selects "Tarihe Göre" sort option
- **THEN** campaigns SHALL be ordered by start_date descending (newest first)

#### Scenario: Expiring soon indicator
- **WHEN** a campaign's end_date is within 3 days
- **THEN** a "Yakında Sona Eriyor" badge SHALL be displayed on the campaign card

### Requirement: Campaign Detail View
The system SHALL provide detailed information about a campaign in a bottom sheet.

#### Scenario: Detail bottom sheet content
- **WHEN** campaign detail bottom sheet is opened
- **THEN** it SHALL display:
  - Campaign image (if available) or fallback icon
  - Venue name and logo
  - Campaign title and description
  - Discount details (percentage or amount)
  - Validity period (start and end dates)
  - "İşletmeye Git" button

#### Scenario: Navigate to venue from campaign
- **WHEN** user taps "İşletmeye Git" button in campaign detail
- **THEN** app SHALL navigate to the venue detail screen
- **AND** venue_id from campaign SHALL be used for navigation

### Requirement: Campaign Repository
The system SHALL provide a repository for fetching campaign data from Supabase.

#### Scenario: Fetch all active campaigns
- **WHEN** getAllCampaigns() is called
- **THEN** all campaigns where is_active = true AND end_date > NOW() SHALL be returned
- **AND** campaigns SHALL include associated venue information

#### Scenario: Fetch campaigns by venue
- **WHEN** getCampaignsByVenue(venueId) is called
- **THEN** only active campaigns for the specified venue SHALL be returned
- **AND** results SHALL be ordered by start_date descending

#### Scenario: Fetch single campaign
- **WHEN** getCampaignById(id) is called
- **THEN** the campaign with matching id SHALL be returned
- **AND** associated venue information SHALL be included

### Requirement: Campaign State Management
The system SHALL manage campaign data state using a provider pattern.

#### Scenario: Campaign provider initialization
- **WHEN** CampaignProvider is initialized
- **THEN** it SHALL have loading, error, and data states
- **AND** it SHALL expose fetchCampaigns() method
- **AND** it SHALL expose applySorting(sortType) method

#### Scenario: Loading state
- **WHEN** campaigns are being fetched
- **THEN** loading state SHALL be true
- **AND** UI SHALL display loading indicator (shimmer/skeleton)

#### Scenario: Error state
- **WHEN** campaign fetch fails
- **THEN** error state SHALL be set
- **AND** error message SHALL be displayed to user
- **AND** retry option SHALL be available

### Requirement: Venue Integration
The system SHALL integrate campaigns into venue detail pages.

#### Scenario: Display venue campaigns
- **WHEN** a venue has active campaigns
- **THEN** a "Kampanyalar" section SHALL appear on venue detail page
- **AND** section SHALL show up to 3 campaign cards
- **AND** "Tüm Kampanyaları Gör" button SHALL be displayed if venue has more than 3 campaigns

#### Scenario: Navigate to campaigns from venue
- **WHEN** user taps "Tüm Kampanyaları Gör" on venue detail
- **THEN** app SHALL navigate to campaigns screen
- **AND** campaigns SHALL be filtered to show only that venue's campaigns
