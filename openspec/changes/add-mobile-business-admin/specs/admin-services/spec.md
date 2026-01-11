# admin-services Specification

## Purpose
This specification defines the requirements for business owners to manage their venue's service offerings through the mobile admin panel. It covers browsing the service catalog, adding services with optional customization, and managing existing services with drag-and-drop reordering.

## ADDED Requirements

### Requirement: Service Catalog Browsing
Business owners must be able to browse and search the service catalog to add services to their venue.

#### Scenario: Browse service categories
**Given** a business owner is on the Services Management screen  
**When** they view the available services section  
**Then** they should see services organized by category (Saç, Cilt Bakımı, Tırnak, Estetik, Vücut, Kaş-Kirpik)  
**And** each service should display its name, default image, and category

#### Scenario: Search for specific service
**Given** a business owner is on the Services Management screen  
**When** they enter "Botoks" in the search field  
**Then** the service list should filter to show only matching services  
**And** the search should be case-insensitive and support partial matches

#### Scenario: Filter by category
**Given** a business owner is viewing the service catalog  
**When** they tap on the "Estetik" category chip  
**Then** only services from the Estetik category should be displayed  
**And** the category chip should appear selected

---

### Requirement: Add Service to Venue
Business owners must be able to add services from the catalog to their venue's service list.

#### Scenario: Add service with defaults
**Given** a business owner has selected a service from the catalog  
**When** they tap the "Ekle" button without customization  
**Then** the service should be added to their venue with default name, description, and image  
**And** the service should appear in the "Mevcut Hizmetler" list  
**And** a success message should be displayed

#### Scenario: Add service with custom details
**Given** a business owner has selected a service from the catalog  
**When** they tap "Özelleştir" and provide custom name, description, and image  
**And** they tap "Kaydet"  
**Then** the service should be added with the custom details  
**And** the custom image should be uploaded to Supabase Storage  
**And** the service should display the custom details in the venue

#### Scenario: Add service with pricing
**Given** a business owner is customizing a service  
**When** they enter a price of "500" and duration of "60" minutes  
**Then** the service should be saved with price ₺500 and duration 60 minutes  
**And** these details should be displayed on the venue details screen

#### Scenario: Prevent duplicate services
**Given** a business owner has already added "Botoks" to their venue  
**When** they attempt to add "Botoks" again  
**Then** an error message should be displayed: "Bu hizmet zaten eklenmiş"  
**And** the service should not be added

---

### Requirement: Manage Existing Services
Business owners must be able to view, edit, reorder, and remove their venue's services.

#### Scenario: View current services
**Given** a business owner is on the Services Management screen  
**When** they scroll to the "Mevcut Hizmetler" section  
**Then** they should see all active and inactive services  
**And** each service should show its name, image, price (if set), and active status  
**And** services should be ordered by `sort_order`

#### Scenario: Edit service details
**Given** a business owner taps the edit icon on a service  
**When** they modify the custom description and price  
**And** they tap "Kaydet"  
**Then** the service should be updated with the new details  
**And** the changes should be reflected immediately in the UI  
**And** the changes should sync to the database

#### Scenario: Reorder services via drag-and-drop
**Given** a business owner has multiple services  
**When** they long-press on a service and drag it to a new position  
**Then** the service should visually move to the new position  
**And** the `sort_order` should be updated in the database  
**And** the new order should be reflected on the venue details screen

#### Scenario: Toggle service active status
**Given** a business owner has an active service  
**When** they tap the toggle switch to disable it  
**Then** the service should be marked as inactive (`is_active = false`)  
**And** the service should be visually dimmed or marked as inactive  
**And** the service should not appear on the venue details screen for customers

#### Scenario: Delete service
**Given** a business owner taps the delete icon on a service  
**When** they confirm the deletion in the dialog  
**Then** the service should be removed from `venue_services`  
**And** if a custom image was uploaded, it should be deleted from Supabase Storage  
**And** the service should be removed from the UI  
**And** the service should no longer appear on the venue details screen

---

### Requirement: Image Upload for Custom Services
Business owners must be able to upload custom images for services.

#### Scenario: Upload custom service image
**Given** a business owner is customizing a service  
**When** they tap "Fotoğraf Seç"  
**And** they select an image from their gallery or camera  
**Then** the image should be compressed to <2MB  
**And** the image should be uploaded to the `venue-services` storage bucket  
**And** the public URL should be saved in `venue_services.custom_image_url`

#### Scenario: Replace custom service image
**Given** a business owner has a service with a custom image  
**When** they edit the service and upload a new image  
**Then** the old image should be deleted from storage  
**And** the new image should be uploaded  
**And** the `custom_image_url` should be updated

#### Scenario: Remove custom image
**Given** a business owner has a service with a custom image  
**When** they tap "Varsayılan Fotoğrafı Kullan"  
**Then** the custom image should be deleted from storage  
**And** `custom_image_url` should be set to null  
**And** the service should display the default catalog image

---

### Requirement: Real-time Sync with Venue Display
Service changes must be immediately reflected wherever venues are displayed in the app.

#### Scenario: Service appears on venue details
**Given** a business owner adds a new service  
**When** a customer views the venue details screen  
**Then** the new service should appear in the "Hizmetler" tab  
**And** the service should display the correct name, image, price, and duration

#### Scenario: Service appears in search results
**Given** a business owner adds "Lazer Epilasyon" to their venue  
**When** a customer searches for venues offering "Lazer Epilasyon"  
**Then** the venue should appear in the search results  
**And** the service chip should be displayed on the venue card

#### Scenario: Inactive services are hidden
**Given** a business owner disables a service  
**When** a customer views the venue  
**Then** the disabled service should not appear in the services list  
**And** the venue should not appear in searches for that specific service

---

### Requirement: Validation and Error Handling
The system must validate inputs and handle errors gracefully.

#### Scenario: Validate price input
**Given** a business owner is entering a price  
**When** they enter a negative number or non-numeric value  
**Then** an error message should be displayed: "Geçerli bir fiyat girin"  
**And** the save button should be disabled

#### Scenario: Validate duration input
**Given** a business owner is entering a duration  
**When** they enter a value less than 1 or greater than 480 minutes  
**Then** an error message should be displayed: "Süre 1-480 dakika arasında olmalıdır"

#### Scenario: Handle network error during add
**Given** a business owner attempts to add a service  
**When** the network request fails  
**Then** an error message should be displayed: "Bağlantı hatası. Lütfen tekrar deneyin."  
**And** the service should not be added to the local list  
**And** a retry button should be available

#### Scenario: Handle storage upload failure
**Given** a business owner uploads a custom image  
**When** the Supabase Storage upload fails  
**Then** an error message should be displayed: "Fotoğraf yüklenemedi"  
**And** the service should not be saved  
**And** the user should be able to retry

---

### Requirement: Performance and UX
The services management interface must be responsive and provide good user experience.

#### Scenario: Optimistic UI updates
**Given** a business owner adds a service  
**When** they tap "Ekle"  
**Then** the service should immediately appear in the list with a loading indicator  
**And** if the API call succeeds, the loading indicator should disappear  
**And** if the API call fails, the service should be removed and an error shown

#### Scenario: Debounced search
**Given** a business owner is typing in the search field  
**When** they type "Bot"  
**Then** the search should wait 300ms after the last keystroke before filtering  
**And** this should prevent excessive re-renders

#### Scenario: Image compression
**Given** a business owner selects a 10MB image  
**When** the image is being uploaded  
**Then** it should be compressed to <2MB before upload  
**And** the compression should maintain reasonable quality  
**And** a progress indicator should be shown during compression and upload
