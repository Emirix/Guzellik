# admin-gallery Specification

## Purpose
This specification defines the requirements for business owners to manage their venue's photo gallery through the mobile admin panel. It covers photo upload with a 5-photo limit, drag-and-drop reordering, hero image selection, and photo deletion with proper storage cleanup.

## ADDED Requirements

### Requirement: Photo Upload
Business owners must be able to upload photos to their venue gallery with a maximum limit of 5 photos.

#### Scenario: Upload first photo
**Given** a business owner has no photos in their gallery  
**When** they tap "Fotoğraf Ekle" and select an image  
**Then** the image should be compressed to <2MB  
**And** the image should be uploaded to the `venue-gallery` storage bucket at path `{venue_id}/{timestamp}_{uuid}.jpg`  
**And** a record should be created in `venue_photos` with `is_hero_image = true` and `sort_order = 0`  
**And** the photo should appear in the gallery grid

#### Scenario: Upload additional photos
**Given** a business owner has 2 photos in their gallery  
**When** they upload a third photo  
**Then** the photo should be added with `is_hero_image = false` and `sort_order = 2`  
**And** the total photo count should be 3

#### Scenario: Enforce 5-photo limit
**Given** a business owner has 5 photos in their gallery  
**When** they attempt to upload another photo  
**Then** an error message should be displayed: "Maksimum 5 fotoğraf yükleyebilirsiniz"  
**And** the upload button should be disabled  
**And** the photo should not be uploaded

#### Scenario: Select photo from camera
**Given** a business owner taps "Fotoğraf Ekle"  
**When** they select "Kamera" option  
**Then** the camera should open  
**And** after taking a photo, it should be processed and uploaded

#### Scenario: Select photo from gallery
**Given** a business owner taps "Fotoğraf Ekle"  
**When** they select "Galeri" option  
**Then** the photo picker should open  
**And** after selecting a photo, it should be processed and uploaded

---

### Requirement: Photo Reordering
Business owners must be able to reorder photos using drag-and-drop to control the display order.

#### Scenario: Reorder photos via drag-and-drop
**Given** a business owner has 4 photos in their gallery  
**When** they long-press on the 3rd photo and drag it to the 1st position  
**Then** the photo should visually move to the 1st position  
**And** the `sort_order` values should be updated: [2,0,1,3] → [0,1,2,3]  
**And** the new order should be saved to the database  
**And** the new order should be reflected on the venue details hero carousel

#### Scenario: Reorder updates hero carousel
**Given** a business owner reorders photos  
**When** a customer views the venue details screen  
**Then** the hero carousel should display photos in the new order  
**And** the first photo should be the one with `sort_order = 0`

---

### Requirement: Hero Image Management
Business owners must be able to designate one photo as the primary/hero image.

#### Scenario: Set hero image
**Given** a business owner has multiple photos  
**When** they tap the "Ana Görsel Yap" button on the 3rd photo  
**Then** the 3rd photo's `is_hero_image` should be set to `true`  
**And** all other photos' `is_hero_image` should be set to `false`  
**And** the photo should display a "Ana Görsel" badge  
**And** this photo should be the primary image on venue cards and search results

#### Scenario: First photo is auto-hero
**Given** a business owner uploads their first photo  
**When** the upload completes  
**Then** `is_hero_image` should automatically be set to `true`  
**And** the photo should display the "Ana Görsel" badge

#### Scenario: Hero image in venue display
**Given** a business owner has set a hero image  
**When** the venue appears in search results or on the map  
**Then** the hero image should be displayed as the venue's primary image  
**And** the venue's `image_url` or `hero_images[0]` should reference this photo

---

### Requirement: Photo Deletion
Business owners must be able to delete photos from their gallery.

#### Scenario: Delete non-hero photo
**Given** a business owner has 4 photos, with the 1st as hero  
**When** they tap delete on the 3rd photo and confirm  
**Then** the photo should be deleted from Supabase Storage  
**And** the record should be deleted from `venue_photos`  
**And** the photo should be removed from the gallery grid  
**And** the `sort_order` of remaining photos should be recalculated

#### Scenario: Delete hero photo
**Given** a business owner deletes the current hero image  
**When** the deletion completes  
**Then** the next photo (by `sort_order`) should automatically become the hero image  
**And** its `is_hero_image` should be set to `true`

#### Scenario: Delete last photo
**Given** a business owner has only 1 photo  
**When** they attempt to delete it  
**Then** a warning should be displayed: "En az 1 fotoğraf bulundurmalısınız"  
**And** the deletion should be prevented

#### Scenario: Confirm before deletion
**Given** a business owner taps the delete button  
**When** the confirmation dialog appears  
**Then** it should show "Bu fotoğrafı silmek istediğinize emin misiniz?"  
**And** it should have "İptal" and "Sil" buttons  
**And** only tapping "Sil" should proceed with deletion

---

### Requirement: Photo Display
Photos must be displayed in a user-friendly grid with proper visual indicators.

#### Scenario: Display gallery grid
**Given** a business owner is on the Gallery Management screen  
**When** they view their photos  
**Then** photos should be displayed in a 2-column grid  
**And** each photo should show a thumbnail  
**And** the hero image should have a visible badge  
**And** each photo should have a drag handle and delete button

#### Scenario: Show photo count
**Given** a business owner has 3 photos  
**When** they view the gallery screen  
**Then** the header should display "Galeri (3/5)"  
**And** this should indicate 3 photos out of maximum 5

#### Scenario: Empty state
**Given** a business owner has no photos  
**When** they view the gallery screen  
**Then** an empty state should be displayed  
**And** it should show "Henüz fotoğraf eklemediniz"  
**And** it should have a prominent "İlk Fotoğrafı Ekle" button

---

### Requirement: Image Optimization
Photos must be optimized for performance and storage efficiency.

#### Scenario: Compress large images
**Given** a business owner selects a 10MB photo  
**When** the upload process begins  
**Then** the image should be compressed to <2MB  
**And** the compression should target 85% quality  
**And** the aspect ratio should be maintained  
**And** a progress indicator should be shown

#### Scenario: Generate thumbnails
**Given** a photo is being uploaded  
**When** the upload completes  
**Then** a thumbnail version should be generated (if supported)  
**And** the thumbnail should be used in the gallery grid for faster loading

#### Scenario: Support multiple formats
**Given** a business owner selects an image  
**When** the image format is JPEG, PNG, or WebP  
**Then** the upload should proceed  
**And** the image should be converted to JPEG if necessary

---

### Requirement: Real-time Sync with Venue Display
Gallery changes must be immediately reflected in venue displays throughout the app.

#### Scenario: New photo appears in hero carousel
**Given** a business owner uploads a new photo  
**When** a customer views the venue details screen  
**Then** the new photo should appear in the hero carousel  
**And** it should be in the correct position based on `sort_order`

#### Scenario: Deleted photo removed from carousel
**Given** a business owner deletes a photo  
**When** a customer views the venue  
**Then** the deleted photo should no longer appear in the hero carousel  
**And** the carousel should adjust to show remaining photos

#### Scenario: Hero image updates venue card
**Given** a business owner changes the hero image  
**When** the venue appears in search results or on the map  
**Then** the new hero image should be displayed  
**And** the update should be reflected within seconds

---

### Requirement: Error Handling and Validation
The system must handle errors gracefully and validate inputs.

#### Scenario: Handle upload failure
**Given** a business owner attempts to upload a photo  
**When** the Supabase Storage upload fails due to network error  
**Then** an error message should be displayed: "Fotoğraf yüklenemedi. Lütfen tekrar deneyin."  
**And** the photo should not be added to the gallery  
**And** a retry button should be available

#### Scenario: Handle storage quota exceeded
**Given** a business owner's storage quota is exceeded  
**When** they attempt to upload a photo  
**Then** an error message should be displayed: "Depolama alanınız dolmuş. Lütfen bazı fotoğrafları silin."  
**And** the upload should be cancelled

#### Scenario: Validate file size
**Given** a business owner selects a photo larger than 10MB  
**When** compression fails to reduce it below 5MB  
**Then** an error message should be displayed: "Fotoğraf çok büyük. Lütfen daha küçük bir fotoğraf seçin."

#### Scenario: Handle deletion failure
**Given** a business owner attempts to delete a photo  
**When** the deletion fails due to network error  
**Then** an error message should be displayed  
**And** the photo should remain in the gallery  
**And** a retry option should be available

---

### Requirement: Performance and UX
The gallery management interface must be responsive and provide smooth interactions.

#### Scenario: Optimistic UI for uploads
**Given** a business owner uploads a photo  
**When** the upload begins  
**Then** a placeholder should immediately appear in the gallery grid  
**And** a progress indicator should show upload progress  
**And** if the upload succeeds, the placeholder should be replaced with the actual photo  
**And** if the upload fails, the placeholder should be removed and an error shown

#### Scenario: Smooth drag-and-drop
**Given** a business owner is reordering photos  
**When** they drag a photo  
**Then** the photo should have elevated shadow and move smoothly  
**And** other photos should animate to make space  
**And** the drag should feel responsive with no lag

#### Scenario: Cached image loading
**Given** a business owner views their gallery  
**When** photos are loaded  
**Then** previously viewed photos should load from cache  
**And** new photos should show a loading shimmer  
**And** all photos should load progressively
