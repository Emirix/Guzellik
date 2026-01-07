## ADDED Requirements

### Requirement: Advanced Search RPC Function
The system SHALL provide an RPC function for advanced venue search with multiple filter criteria.

#### Scenario: Search with service names
- **GIVEN** a user searches for "Botoks"
- **WHEN** the `search_venues_advanced` RPC is called with search_query="Botoks"
- **THEN** venues offering services matching "Botoks" SHALL be returned
- **AND** results SHALL be ordered by distance from user location

#### Scenario: Combined filters
- **GIVEN** a user applies multiple filters
- **WHEN** the RPC is called with category, rating, and distance filters
- **THEN** only venues matching ALL criteria SHALL be returned
- **AND** results SHALL be ordered by relevance and distance
