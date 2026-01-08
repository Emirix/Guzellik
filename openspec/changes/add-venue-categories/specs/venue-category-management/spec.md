# Spec: Venue Category Management

## ADDED Requirements

### Requirement: Venue Classification
Each venue MUST be associated with a specific category to facilitate organized discovery and filtering.

#### Scenario: Categorizing a New Venue
- **WHEN** a new venue is being created
- **WHEN** the user selects a category from the predefined list
- **THEN** the venue MUST be saved with the corresponding `category_id`

### Requirement: Dynamic Category Retrieval
The application MUST fetch the list of available categories from the database at startup or when needed.

#### Scenario: Loading Categories for Filtering
- **WHEN** the application starts
- **THEN** it MUST fetch all active categories from the `venue_categories` table
- **AND** display them as filtering options
