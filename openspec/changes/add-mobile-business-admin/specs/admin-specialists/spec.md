# admin-specialists Specification

## Purpose
This specification defines the requirements for business owners to manage their team members/specialists through the mobile admin panel. It covers adding specialists with photos, names, professions, and gender information, as well as editing and deleting team members.

## ADDED Requirements

### Requirement: Add Specialist
Business owners must be able to add team members/specialists to showcase their expert staff.

#### Scenario: Add specialist with all required fields
**Given** a business owner is on the Specialists Management screen  
**When** they tap "Uzman Ekle"  
**And** they enter name "Ayşe Yılmaz", profession "Estetisyen", select gender "Kadın"  
**And** they upload a photo  
**And** they tap "Kaydet"  
**Then** a new record should be created in the `specialists` table  
**And** the photo should be uploaded to `specialists` storage bucket at path `{venue_id}/{specialist_id}_{timestamp}.jpg`  
**And** the specialist should appear in the specialists list  
**And** the specialist should be displayed on the venue details screen

#### Scenario: Upload specialist photo
**Given** a business owner is adding a specialist  
**When** they tap "Fotoğraf Seç"  
**And** they select an image from camera or gallery  
**Then** the image should be cropped to a circular shape (1:1 aspect ratio)  
**And** the image should be compressed to <2MB  
**And** the image should be uploaded to Supabase Storage  
**And** the public URL should be saved in `specialists.photo_url`

#### Scenario: Select gender from dropdown
**Given** a business owner is adding a specialist  
**When** they tap the gender field  
**Then** a dropdown should appear with options: "Kadın", "Erkek", "Belirtmek İstemiyorum"  
**And** selecting an option should populate the field

---

### Requirement: View Specialists List
Business owners must be able to view all their team members in an organized list.

#### Scenario: Display specialists list
**Given** a business owner has 3 specialists  
**When** they view the Specialists Management screen  
**Then** all 3 specialists should be displayed  
**And** each specialist card should show circular photo, name, and profession  
**And** each card should have edit and delete buttons

#### Scenario: Empty state
**Given** a business owner has no specialists  
**When** they view the Specialists Management screen  
**Then** an empty state should be displayed  
**And** it should show "Henüz uzman eklemediniz"  
**And** it should have a prominent "İlk Uzmanı Ekle" button

#### Scenario: Specialists ordered by creation date
**Given** a business owner has multiple specialists  
**When** they view the list  
**Then** specialists should be ordered by `created_at` descending (newest first)  
**Or** if `sort_order` is implemented, by `sort_order` ascending

---

### Requirement: Edit Specialist
Business owners must be able to update specialist information.

#### Scenario: Edit specialist details
**Given** a business owner taps edit on a specialist  
**When** they change the name to "Ayşe Demir" and profession to "Kuaför"  
**And** they tap "Kaydet"  
**Then** the specialist record should be updated in the database  
**And** the changes should be reflected immediately in the UI  
**And** the changes should appear on the venue details screen

#### Scenario: Replace specialist photo
**Given** a business owner is editing a specialist  
**When** they upload a new photo  
**Then** the old photo should be deleted from Supabase Storage  
**And** the new photo should be uploaded  
**And** `photo_url` should be updated with the new URL

---

### Requirement: Delete Specialist
Business owners must be able to remove team members from their venue.

#### Scenario: Delete specialist
**Given** a business owner taps delete on a specialist  
**When** they confirm the deletion  
**Then** the specialist record should be deleted from `specialists` table  
**And** the specialist's photo should be deleted from Supabase Storage  
**And** the specialist should be removed from the UI  
**And** the specialist should no longer appear on the venue details screen

#### Scenario: Confirm before deletion
**Given** a business owner taps the delete button  
**When** the confirmation dialog appears  
**Then** it should show "Bu uzmanı silmek istediğinize emin misiniz?"  
**And** it should have "İptal" and "Sil" buttons  
**And** only tapping "Sil" should proceed with deletion

---

### Requirement: Validation
The system must validate specialist information before saving.

#### Scenario: Validate name field
**Given** a business owner is adding a specialist  
**When** they enter a name with less than 2 characters  
**Then** an error message should be displayed: "İsim en az 2 karakter olmalıdır"  
**And** the save button should be disabled

#### Scenario: Validate name length
**Given** a business owner enters a name longer than 50 characters  
**When** they attempt to save  
**Then** an error message should be displayed: "İsim en fazla 50 karakter olabilir"

#### Scenario: Validate profession field
**Given** a business owner is adding a specialist  
**When** they enter a profession with less than 2 characters  
**Then** an error message should be displayed: "Meslek en az 2 karakter olmalıdır"

#### Scenario: Validate profession length
**Given** a business owner enters a profession longer than 30 characters  
**When** they attempt to save  
**Then** an error message should be displayed: "Meslek en fazla 30 karakter olabilir"

#### Scenario: Require photo
**Given** a business owner is adding a specialist  
**When** they attempt to save without uploading a photo  
**Then** an error message should be displayed: "Lütfen bir fotoğraf seçin"  
**And** the save button should be disabled

#### Scenario: Require gender
**Given** a business owner is adding a specialist  
**When** they attempt to save without selecting a gender  
**Then** an error message should be displayed: "Lütfen cinsiyet seçin"  
**And** the save button should be disabled

---

### Requirement: Real-time Sync with Venue Display
Specialist changes must be immediately reflected on the venue details screen.

#### Scenario: New specialist appears on venue details
**Given** a business owner adds a new specialist  
**When** a customer views the venue details screen  
**Then** the new specialist should appear in the "Uzmanlar" section  
**And** the specialist should display their photo, name, and profession

#### Scenario: Updated specialist reflects changes
**Given** a business owner updates a specialist's information  
**When** a customer views the venue  
**Then** the updated information should be displayed  
**And** the update should be reflected within seconds

#### Scenario: Deleted specialist removed from venue
**Given** a business owner deletes a specialist  
**When** a customer views the venue  
**Then** the deleted specialist should no longer appear  
**And** the "Uzmanlar" section should update accordingly

---

### Requirement: Photo Handling
Specialist photos must be properly processed and stored.

#### Scenario: Circular crop for specialist photos
**Given** a business owner selects a photo for a specialist  
**When** the image picker opens  
**Then** a circular crop overlay should be shown  
**And** the user should be able to adjust the crop area  
**And** only the circular portion should be uploaded

#### Scenario: Compress specialist photos
**Given** a business owner selects a 5MB photo  
**When** the upload process begins  
**Then** the image should be compressed to <2MB  
**And** the compression should maintain good quality for face recognition  
**And** a progress indicator should be shown

#### Scenario: Support multiple image sources
**Given** a business owner taps "Fotoğraf Seç"  
**When** the picker opens  
**Then** they should have options for "Kamera" and "Galeri"  
**And** both options should work correctly

---

### Requirement: Error Handling
The system must handle errors gracefully.

#### Scenario: Handle photo upload failure
**Given** a business owner uploads a specialist photo  
**When** the Supabase Storage upload fails  
**Then** an error message should be displayed: "Fotoğraf yüklenemedi"  
**And** the specialist should not be saved  
**And** the user should be able to retry

#### Scenario: Handle network error during save
**Given** a business owner attempts to save a specialist  
**When** the network request fails  
**Then** an error message should be displayed: "Bağlantı hatası. Lütfen tekrar deneyin."  
**And** the specialist should not be added to the local list  
**And** a retry button should be available

#### Scenario: Handle deletion failure
**Given** a business owner attempts to delete a specialist  
**When** the deletion fails  
**Then** an error message should be displayed  
**And** the specialist should remain in the list  
**And** a retry option should be available

---

### Requirement: Performance and UX
The specialists management interface must be responsive and user-friendly.

#### Scenario: Optimistic UI updates
**Given** a business owner adds a specialist  
**When** they tap "Kaydet"  
**Then** the specialist should immediately appear in the list with a loading indicator  
**And** if the API call succeeds, the loading indicator should disappear  
**And** if the API call fails, the specialist should be removed and an error shown

#### Scenario: Form validation feedback
**Given** a business owner is filling the add specialist form  
**When** they enter invalid data  
**Then** inline error messages should appear below each invalid field  
**And** the save button should be disabled until all fields are valid

#### Scenario: Smooth photo upload experience
**Given** a business owner is uploading a specialist photo  
**When** the upload is in progress  
**Then** a circular progress indicator should be shown  
**And** the percentage should update in real-time  
**And** the user should be able to cancel the upload

---

### Requirement: Display on Venue Details
Specialists must be properly displayed on the venue details screen for customers.

#### Scenario: Display specialists in grid
**Given** a venue has 4 specialists  
**When** a customer views the "Uzmanlar" section  
**Then** specialists should be displayed in a horizontal scrollable list or grid  
**And** each specialist should show circular photo, name, and profession  
**And** the display should match the app's design language

#### Scenario: Handle empty specialists
**Given** a venue has no specialists  
**When** a customer views the venue details  
**Then** the "Uzmanlar" section should either be hidden  
**Or** show a message like "Bu işletme henüz uzman bilgisi eklemememiş"

#### Scenario: Specialists load efficiently
**Given** a customer views a venue with specialists  
**When** the specialists section loads  
**Then** photos should be cached for fast loading  
**And** a shimmer loading effect should be shown while loading  
**And** the section should not block other content from loading
