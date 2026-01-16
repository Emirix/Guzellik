# Capability: Venue Data Synchronization

## MODIFIED Requirements

### Requirement: Unified Venue Data Fetching
`VenueRepository` MUST provide a consistent way to fetch a venue with its specialists and features, regardless of whether they are stored in JSONB or separate tables.

#### Scenario: Fetching a venue with joined data
- **Given** a venue with specialists and selected features in their respective tables
- **When** `getVenueById` is called
- **Then** the repository should use a single join query to retrieve all related data
- **And** the returned `Venue` object should contain the latest specialists and features

### Requirement: Robust JSONB Deserialization
`Venue.fromJson` MUST prioritize data from joined relations while maintaining compatibility with legacy JSONB columns.

#### Scenario: Prioritizing joined specialists over JSONB
- **Given** a JSON response containing both `specialists` (joined list) and `expert_team` (JSONB column)
- **When** `Venue.fromJson` is executed
- **Then** the `expertTeam` property should be populated from the `specialists` list
- **And** it should be converted to the expected format if necessary

#### Scenario: Flattening joined features into category-specific fields
- **Given** a JSON response with joined `venue_selected_features`
- **When** `Venue.fromJson` is executed
- **Then** `features` should contain all feature names/slugs
- **And** `paymentOptions` should contain features marked with the 'payment' category
- **And** `accessibility` should be updated if relevant transport/access features are present

### Requirement: Automated Database Denormalization
The database MUST automatically keep the legacy JSONB columns in sync with the primary normalized tables.

#### Scenario: Syncing specialists to expert_team
- **Given** a specialist is added or updated in the `specialists` table
- **When** the change is committed
- **Then** the `expert_team` column in the corresponding `venues` row must be automatically updated with the new specialist data

#### Scenario: Syncing features to multiple columns
- **Given** a feature selection is changed in `venue_selected_features`
- **When** the change is committed
- **Then** the `features`, `payment_options`, and `accessibility` columns in `venues` must be updated according to the categories of the selected features
