# credits-system Capability Specification

## ADDED Requirements

### Requirement: Venue Credit Tracking
The system SHALL maintain a real-time credit balance for each venue.

#### Scenario: Venue has a credit balance
- **GIVEN** an existing venue
- **THEN** it SHALL have an associated record in the `venue_credits` table trackings its current balance.

### Requirement: Credit Purchasing
The system SHALL allow business owners to purchase credit packages to increase their balance.

#### Scenario: Business owner buys credits
- **GIVEN** a business owner is on the Credit Store screen
- **WHEN** they select a credit package and click "Buy"
- **THEN** the venue's credit balance SHALL increase by the package amount
- **AND** a transaction record SHALL be created in `credit_transactions`.

### Requirement: Transaction History
The system SHALL provide a history of all credit-related activities for a venue.

#### Scenario: View transaction logs
- **GIVEN** a business owner views their credit history
- **THEN** they SHALL see a list of all purchases and credit usage events.
