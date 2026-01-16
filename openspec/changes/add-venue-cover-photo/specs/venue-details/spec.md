## MODIFIED Requirements

### Requirement: Premium Hero Experience
The system SHALL provide a high-impact visual header with integrated navigation and actions, prioritizing cover photo over hero images.

#### Scenario: Hero visual elements
- **GIVEN** the venue details screen is open
- **WHEN** the user views the top section
- **THEN** it SHALL display the venue's cover photo if available, otherwise the first hero image
- **AND** it SHALL show "Back", "Favorite", and "Share" buttons with glass-effect styling
- **AND** it SHALL display pagination dots if multiple images exist.

#### Scenario: Cover photo fallback
- **GIVEN** a venue has both cover_photo_url and hero_images
- **WHEN** the venue details screen loads
- **THEN** the cover_photo_url SHALL be displayed as the primary hero image
- **AND** if cover_photo_url is null, the first item from hero_images SHALL be used
- **AND** if both are empty, a placeholder image SHALL be shown

### Requirement: Venue Card Display
Venue cards in discovery and search screens SHALL display the cover photo as the primary image.

#### Scenario: Cover photo in venue cards
- **GIVEN** a venue is displayed in a list (search results, featured, nearby)
- **WHEN** the card is rendered
- **THEN** the cover_photo_url SHALL be used as the card image if available
- **AND** if cover_photo_url is null, the first hero_image SHALL be used as fallback
- **AND** if no images exist, a category-based placeholder SHALL be shown
