## ADDED Requirements

### Requirement: Multi-Photo Hero Carousel
The system SHALL support multiple hero images in a swipeable carousel at the top of the venue details screen.

#### Scenario: Carousel navigation
- **GIVEN** a venue has multiple hero images
- **WHEN** the user is on the venue details screen
- **THEN** the hero area SHALL display a PageView carousel with all hero images
- **AND** pagination dots SHALL indicate the current image and total count
- **AND** the user SHALL be able to swipe left/right to navigate between images

#### Scenario: Single image fallback
- **GIVEN** a venue has only one hero image
- **WHEN** the user views the venue details
- **THEN** the single image SHALL be displayed without carousel controls
- **AND** no pagination dots SHALL be shown

#### Scenario: Full-screen expansion
- **GIVEN** the hero carousel is visible
- **WHEN** the user taps on the current hero image
- **THEN** the system SHALL open the full-screen photo gallery viewer starting at the tapped image

### Requirement: Photo Gallery Thumbnail Grid
The system SHALL display a thumbnail grid of venue photos in the Services tab.

#### Scenario: Grid display
- **GIVEN** the Services tab is active and the venue has gallery photos
- **WHEN** the user scrolls to the gallery section
- **THEN** a grid of photo thumbnails SHALL be displayed (2-3 columns based on screen width)
- **AND** each thumbnail SHALL show a preview of the photo
- **AND** photos SHALL be lazy-loaded as the user scrolls

#### Scenario: Category filtering
- **GIVEN** the photo gallery grid is visible
- **WHEN** the user selects a category filter (e.g., "İç Mekan", "Hizmet Sonuçları")
- **THEN** only photos matching the selected category SHALL be displayed
- **AND** the filter selection SHALL be visually highlighted

#### Scenario: Opening full viewer
- **GIVEN** a thumbnail grid is displayed
- **WHEN** the user taps a thumbnail
- **THEN** the full-screen photo gallery viewer SHALL open at the selected photo
- **AND** the viewer SHALL be filtered to the current category if a filter is active

### Requirement: Full-Screen Photo Gallery Viewer
The system SHALL provide a full-screen photo viewer with zoom, swipe, and interaction capabilities.

#### Scenario: Viewer navigation
- **GIVEN** the full-screen viewer is open
- **WHEN** the user swipes left or right
- **THEN** the viewer SHALL navigate to the previous or next photo in the gallery
- **AND** a smooth transition animation SHALL be displayed

#### Scenario: Pinch-to-zoom
- **GIVEN** a photo is displayed in the full-screen viewer
- **WHEN** the user performs a pinch gesture
- **THEN** the photo SHALL zoom in or out accordingly
- **AND** the user SHALL be able to pan the zoomed photo by dragging

#### Scenario: Photo metadata display
- **GIVEN** the full-screen viewer is open
- **WHEN** the user views a photo
- **THEN** metadata (title, upload date, category) SHALL be displayed in a bottom sheet
- **AND** the metadata SHALL auto-hide after 3 seconds unless the user interacts with it

#### Scenario: Share photo
- **GIVEN** the full-screen viewer is open
- **WHEN** the user taps the "Share" button
- **THEN** the system SHALL open the native share dialog with the photo URL
- **AND** the share data SHALL include the venue name and photo title

#### Scenario: Download photo
- **GIVEN** the full-screen viewer is open
- **WHEN** the user taps the "Download" button
- **THEN** the photo SHALL be saved to the device's gallery
- **AND** a success notification SHALL be displayed

#### Scenario: Like photo
- **GIVEN** the full-screen viewer is open
- **WHEN** the user taps the "Like" button
- **THEN** the like count SHALL increment
- **AND** the button state SHALL change to indicate the photo is liked
- **AND** the like SHALL be persisted to the backend

#### Scenario: Close viewer
- **GIVEN** the full-screen viewer is open
- **WHEN** the user taps the close button or swipes down
- **THEN** the viewer SHALL close with a smooth transition
- **AND** the user SHALL return to the previous screen at the same scroll position

### Requirement: Before/After Comparison Viewer
The system SHALL provide an interactive slider-based viewer for before/after service photos.

#### Scenario: Opening before/after viewer
- **GIVEN** a service has both before and after photos
- **WHEN** the user taps the before/after preview in the Services tab
- **THEN** the before/after comparison viewer SHALL open in full-screen mode
- **AND** both photos SHALL be loaded and aligned for comparison

#### Scenario: Slider interaction
- **GIVEN** the before/after viewer is open
- **WHEN** the user drags the slider left or right
- **THEN** the dividing line SHALL move accordingly
- **AND** the before photo SHALL be revealed on one side and the after photo on the other
- **AND** the slider movement SHALL be smooth and responsive

#### Scenario: Horizontal vs vertical comparison
- **GIVEN** the before/after viewer is open
- **WHEN** the user taps the orientation toggle button
- **THEN** the comparison SHALL switch between horizontal and vertical slider modes
- **AND** the slider position SHALL reset to center

#### Scenario: Metadata and actions
- **GIVEN** the before/after viewer is open
- **WHEN** the user views the comparison
- **THEN** service name, treatment date, and description SHALL be displayed
- **AND** share and download actions SHALL be available
- **AND** the actions SHALL share/download a combined comparison image

### Requirement: Photo Data Management
The system SHALL store and retrieve venue photos with associated metadata.

#### Scenario: Fetching venue photos
- **GIVEN** a venue ID
- **WHEN** the venue details screen loads
- **THEN** hero images SHALL be fetched immediately
- **AND** gallery photos SHALL be lazy-loaded when the Services tab is accessed
- **AND** photos SHALL be sorted by `sort_order` ascending

#### Scenario: Photo categorization
- **GIVEN** venue photos are being displayed
- **WHEN** photos are retrieved from the database
- **THEN** each photo SHALL have a category (interior, exterior, service_result, team, equipment)
- **AND** photos SHALL be filterable by category in the UI

#### Scenario: Thumbnail optimization
- **GIVEN** a photo is being displayed in a thumbnail grid
- **WHEN** the photo is loaded
- **THEN** the system SHALL load the thumbnail URL if available
- **AND** SHALL fall back to the full URL if no thumbnail exists
- **AND** SHALL use cached_network_image for caching

### Requirement: Image Performance Optimization
The system SHALL optimize image loading and rendering for performance.

#### Scenario: Progressive loading
- **GIVEN** a photo is being loaded in any viewer
- **WHEN** the image is fetched from the network
- **THEN** a blur placeholder SHALL be displayed first
- **AND** the thumbnail SHALL load next (if available)
- **AND** the full-resolution image SHALL load last

#### Scenario: Caching strategy
- **GIVEN** photos have been previously loaded
- **WHEN** the user returns to the venue details or gallery
- **THEN** cached images SHALL be displayed immediately
- **AND** the cache SHALL be valid for 24 hours (configurable)
- **AND** network requests SHALL only be made for cache misses

#### Scenario: Bandwidth optimization
- **GIVEN** the user is on a slow network connection
- **WHEN** loading gallery photos
- **THEN** only thumbnails SHALL be loaded initially
- **AND** full-resolution images SHALL only load when opened in the full-screen viewer

## MODIFIED Requirements

### Requirement: Premium Hero Experience
The system SHALL provide a high-impact visual header with integrated navigation and actions, supporting multiple hero images.

#### Scenario: Hero visual elements
- **GIVEN** the venue details screen is open
- **WHEN** the user views the top section
- **THEN** it SHALL display a carousel of hero images with parallax-ready scrolling
- **AND** it SHALL show "Back", "Favorite", and "Share" buttons with glass-effect styling
- **AND** it SHALL display pagination dots if multiple images exist
- **AND** tapping a hero image SHALL open the full-screen gallery viewer

#### Scenario: Hero image count indicator
- **GIVEN** multiple hero images exist
- **WHEN** the user views the hero carousel
- **THEN** a photo count badge (e.g., "1/5") SHALL be displayed in the top-right corner
- **AND** the badge SHALL update as the user swipes through images
