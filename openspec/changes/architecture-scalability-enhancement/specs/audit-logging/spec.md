# audit-logging Specification Delta

## ADDED Requirements

### Requirement: Administrative Audit Trail
The system SHALL record sensitive data changes to an audit table for security and troubleshooting.

#### Scenario: Administrative subscription update
- **GIVEN** an admin updates a venue's subscription via the admin panel
- **WHEN** the record is updated in the database
- **THEN** a row SHALL be automatically inserted into the `audit_logs` table
- **AND** it SHALL contain the `actor_id`, `table_name`, `record_id`, and a JSON diff of the change.

#### Scenario: Venue verification audit
- **GIVEN** a venue's `is_verified` status is changed
- **THEN** an audit log SHALL be generated to track who performed the verification and when.
    
