## ADDED Requirements

### Requirement: Cover Photo Management
Venue owners SHALL be able to select category-based template cover photos or upload custom cover photos to enhance their profile presentation.

#### Scenario: Display category template photos
- **GIVEN** a venue owner is logged into the admin panel
- **WHEN** they click on the "Cover Photo" menu item
- **THEN** template cover photos for their venue's category SHALL be displayed in a grid view
- **AND** each photo SHALL be shown as a preview

#### Scenario: Select template photo
- **GIVEN** category template photos are listed
- **WHEN** the venue owner clicks on a photo
- **THEN** the selected photo SHALL be visually highlighted
- **AND** the "Save" button SHALL become active

#### Scenario: Upload custom photo
- **GIVEN** the cover photo screen is open
- **WHEN** the venue owner clicks the "Upload Custom Photo" button
- **THEN** the device photo picker SHALL open
- **AND** the selected photo SHALL be uploaded to FTP
- **AND** a loading indicator SHALL be displayed during upload

#### Scenario: Save cover photo
- **GIVEN** a photo is selected (template or custom)
- **WHEN** the "Save" button is clicked
- **THEN** the selected photo URL SHALL be saved to `venues.cover_photo_url`
- **AND** a success message SHALL be displayed
- **AND** the screen SHALL close

#### Scenario: Error handling
- **GIVEN** a cover photo upload or save operation is initiated
- **WHEN** an error occurs (FTP connection error, network error, etc.)
- **THEN** a clear error message SHALL be displayed to the user
- **AND** the operation SHALL be rolled back

### Requirement: Admin Dashboard Integration
Cover photo management SHALL be easily accessible from the venue admin panel.

#### Scenario: Cover photo menu option
- **GIVEN** a venue owner is logged into the admin dashboard
- **WHEN** they view the admin menu
- **THEN** a "Cover Photo" menu item SHALL be visible
- **AND** clicking this item SHALL open the `AdminCoverPhotoScreen`

