# Spec: Admin Gallery Management

## ADDED Requirements

### Requirement: Photo Upload and Management
Venue owners must be able to upload and manage up to 5 gallery photos through the admin panel.

#### Scenario: Viewing current gallery
**Given** a venue owner is logged into the admin panel  
**When** they navigate to the Gallery page  
**Then** they should see all currently uploaded photos  
**And** they should see the photo count (e.g., "3/5 photos")  
**And** they should see an "Upload Photo" button if under the limit

#### Scenario: Uploading a new photo
**Given** a venue owner has fewer than 5 photos  
**When** they click "Upload Photo" and select an image file  
**Then** the image should be uploaded to Supabase Storage bucket `venue-gallery/{venue_id}/`  
**And** a new record should be created in `venue_photos` table  
**And** the photo should appear in the gallery grid  
**And** the photo should have a default `sort_order` value

#### Scenario: Enforcing 5-photo limit
**Given** a venue owner already has 5 photos  
**When** they attempt to upload another photo  
**Then** they should see an error message "Maximum 5 photos allowed"  
**And** the upload button should be disabled  
**And** the database trigger should prevent insertion if UI validation is bypassed

#### Scenario: Reordering photos with drag-and-drop
**Given** a venue owner has multiple photos  
**When** they drag a photo to a new position  
**Then** the `sort_order` values should be updated for affected photos  
**And** the new order should be saved to the database  
**And** the mobile app should display photos in the new order

#### Scenario: Setting primary/hero image
**Given** a venue owner wants to set a featured image  
**When** they mark a photo as "Primary Image"  
**Then** `venue_photos.is_hero_image` should be set to `true` for that photo  
**And** any previously set hero image should be set to `false`  
**And** the mobile app should display this photo prominently

#### Scenario: Deleting a photo
**Given** a venue owner wants to remove a photo  
**When** they click delete and confirm  
**Then** the photo should be deleted from Supabase Storage  
**And** the record should be removed from `venue_photos` table  
**And** the photo should no longer appear in the mobile app  
**And** the photo count should be updated

#### Scenario: Adding photo metadata
**Given** a venue owner is uploading a photo  
**When** they optionally add a title and category  
**Then** the `title` and `category` fields should be saved  
**And** categories should be one of: 'interior', 'exterior', 'service_result', 'team', 'equipment'  
**And** this metadata should be available for filtering in the mobile app

### Requirement: Storage Configuration
Gallery photos must be stored securely in Supabase Storage with proper access controls.

#### Scenario: Storage bucket structure
**Given** the `venue-gallery` bucket exists  
**When** a photo is uploaded  
**Then** it should be stored at path `{venue_id}/{photo_id}.{extension}`  
**And** the URL should be publicly accessible for reading  
**And** only the venue owner should be able to upload/delete

#### Scenario: Image optimization
**Given** a venue owner uploads a large image  
**When** the upload is processed  
**Then** the image should be resized to max 1920px width  
**And** a thumbnail should be generated (400px width)  
**And** the thumbnail URL should be stored in `venue_photos.thumbnail_url`  
**And** the mobile app should use thumbnails for grid views

### Requirement: Mobile App Integration
Gallery photos must be displayed dynamically in the Flutter mobile app.

#### Scenario: Displaying gallery in venue details
**Given** a venue has gallery photos  
**When** a user views the venue in `VenueDetailsScreen`  
**Then** photos should be displayed in a carousel or grid  
**And** photos should be ordered by `sort_order`  
**And** the hero image should be displayed first if set  
**And** tapping a photo should open a fullscreen viewer

#### Scenario: Displaying hero image in search results
**Given** a venue has a hero image set  
**When** the venue appears in search results  
**Then** the hero image should be displayed as the venue thumbnail  
**And** if no hero image is set, the first photo by `sort_order` should be used

#### Scenario: Gallery data synchronization
**Given** a venue owner updates gallery in the admin panel  
**When** changes are saved  
**Then** the mobile app should reflect changes immediately  
**And** image caching should be invalidated for updated photos
