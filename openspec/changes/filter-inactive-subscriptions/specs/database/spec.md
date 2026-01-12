## ADDED Requirements

### Requirement: Subscription-Based Visibility Filter
The system SHALL restrict venue visibility only to those with an active subscription for regular users.

#### Scenario: Regular user searches for venues
- **WHEN** a regular user searches for venues
- **THEN** only venues with an active subscription are returned

#### Scenario: Venue owner views own venue
- **WHEN** a venue owner views their own venue
- **THEN** it is always visible to the owner regardless of subscription status

#### Scenario: Admin views all venues
- **WHEN** an admin fetches the venue list
- **THEN** all venues are visible regardless of subscription status

#### Scenario: Unauthenticated user browses venues
- **WHEN** an unauthenticated user browses venues
- **THEN** only venues with active subscriptions are visible

### Requirement: RPC Functions Respect Subscription Status
The system SHALL ensure all venue search and discovery RPC functions filter by subscription status.

#### Scenario: Nearby venues search
- **WHEN** a user calls `get_nearby_venues` with location coordinates
- **THEN** only venues with active subscriptions within the radius are returned

#### Scenario: Advanced search
- **WHEN** a user calls `search_venues_advanced` with search criteria
- **THEN** only venues with active subscriptions matching the criteria are returned

#### Scenario: Elastic search
- **WHEN** a user calls `elastic_search_venues` with a search query
- **THEN** only venues with active subscriptions matching the query are returned

#### Scenario: Service-based search
- **WHEN** a user calls `search_venues_by_service` with a service category ID
- **THEN** only venues with active subscriptions offering that service are returned

### Requirement: Related Data Visibility
The system SHALL hide all venue-related data when the venue's subscription is inactive.

#### Scenario: Venue services for inactive subscription
- **WHEN** a venue's subscription is inactive
- **THEN** the venue's services SHALL NOT be visible to regular users

#### Scenario: Campaigns for inactive subscription
- **WHEN** a venue's subscription is inactive
- **THEN** the venue's campaigns SHALL NOT be visible to regular users

#### Scenario: Specialists for inactive subscription
- **WHEN** a venue's subscription is inactive
- **THEN** the venue's specialists SHALL NOT be visible to regular users

#### Scenario: Photos for inactive subscription
- **WHEN** a venue's subscription is inactive
- **THEN** the venue's photos SHALL NOT be visible to regular users

