## MODIFIED Requirements

### Requirement: Floating Action Button Navigation
The system SHALL use the floating action button (FAB) to navigate to the campaigns screen.

#### Scenario: FAB displays campaign icon
- **WHEN** the home screen is displayed
- **THEN** the FAB SHALL show a campaign/offer icon (Icons.local_offer or Icons.campaign)
- **AND** FAB SHALL be positioned in the center of the bottom navigation bar

#### Scenario: FAB navigates to campaigns
- **WHEN** user taps the FAB
- **THEN** app SHALL navigate to the campaigns screen
- **AND** no authentication check SHALL be required (campaigns are public)

#### Scenario: FAB styling
- **WHEN** FAB is rendered
- **THEN** it SHALL use primary theme color as background
- **AND** icon SHALL be white
- **AND** elevation SHALL be 4

## REMOVED Requirements

### Requirement: Quote Request Navigation
**Reason**: Quote request feature is being removed from the application.

**Migration**: 
- FAB now navigates to campaigns screen instead
- Quote-related screens, providers, and models will be deleted
- Database quote tables will remain for historical data but won't be accessed from UI

#### Scenario: FAB quote request check
- **REMOVED**: User authentication check before showing quote request
- **REMOVED**: Navigation to quote request or my quotes screen
- **REMOVED**: QuoteProvider dependency in home screen
