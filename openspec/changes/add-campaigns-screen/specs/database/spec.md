## ADDED Requirements

### Requirement: Campaigns Table
The system SHALL provide a campaigns table to store promotional offers from venues.

#### Scenario: Table structure
- **WHEN** the campaigns table is created
- **THEN** it SHALL have the following columns:
  - id (UUID, primary key)
  - venue_id (UUID, foreign key to venues.id)
  - title (TEXT, not null)
  - description (TEXT, nullable)
  - discount_percentage (INTEGER, nullable, 0-100)
  - discount_amount (DECIMAL(10,2), nullable, >= 0)
  - start_date (TIMESTAMPTZ, not null, default NOW())
  - end_date (TIMESTAMPTZ, not null)
  - image_url (TEXT, nullable)
  - is_active (BOOLEAN, default true)
  - created_at (TIMESTAMPTZ, default NOW())
  - updated_at (TIMESTAMPTZ, default NOW())

#### Scenario: Table constraints
- **WHEN** the campaigns table is created
- **THEN** it SHALL enforce:
  - Foreign key constraint on venue_id referencing venues(id) with CASCADE delete
  - Check constraint ensuring at least one of discount_percentage or discount_amount is NOT NULL
  - Check constraint ensuring end_date > start_date
  - Check constraint ensuring discount_percentage is between 0 and 100 if present
  - Check constraint ensuring discount_amount >= 0 if present

#### Scenario: Table indexes
- **WHEN** the campaigns table is created
- **THEN** it SHALL have indexes on:
  - venue_id (for filtering by venue)
  - is_active (for filtering active campaigns)
  - (start_date, end_date) composite index (for date range queries)

### Requirement: Campaign RLS Policies
The system SHALL implement Row Level Security policies for the campaigns table.

#### Scenario: Public read access for active campaigns
- **WHEN** RLS is enabled on campaigns table
- **THEN** SELECT policy SHALL allow public access to campaigns where:
  - is_active = true
  - end_date > NOW()
- **AND** venue information SHALL be joinable

#### Scenario: No public write access
- **WHEN** RLS is enabled on campaigns table
- **THEN** INSERT, UPDATE, DELETE operations SHALL be restricted
- **AND** only authenticated venue owners SHALL be able to modify their campaigns (future implementation)

### Requirement: Campaign Migration File
The system SHALL provide a migration file to create the campaigns table and related objects.

#### Scenario: Migration file naming
- **WHEN** migration file is created
- **THEN** it SHALL follow naming convention: `YYYYMMDDHHMMSS_create_campaigns_table.sql`
- **AND** timestamp SHALL be unique and sequential

#### Scenario: Migration file content
- **WHEN** migration is executed
- **THEN** it SHALL:
  - Create campaigns table with all columns and constraints
  - Create all required indexes
  - Enable RLS on campaigns table
  - Create RLS policies for public read access
  - Create updated_at trigger for automatic timestamp updates

#### Scenario: Migration rollback
- **WHEN** migration needs to be rolled back
- **THEN** it SHALL include a comment with rollback command:
  - `DROP TABLE IF EXISTS campaigns CASCADE;`
