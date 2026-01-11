# admin-campaigns Specification

## Purpose
This specification defines the requirements for business owners to create and manage promotional campaigns through the mobile admin panel. It covers campaign creation with titles, descriptions, discounts, date ranges, and optional images, as well as toggling campaign status and deletion.

## ADDED Requirements

### Requirement: Create Campaign
Business owners must be able to create promotional campaigns to attract customers.

#### Scenario: Create campaign with all fields
**Given** a business owner is on the Campaigns Management screen  
**When** they tap "Kampanya Ekle"  
**And** they enter title "Yaz İndirimi", description "Tüm lazer epilasyon hizmetlerinde %30 indirim"  
**And** they select discount type "Yüzde" and enter "30"  
**And** they select start date "2026-06-01" and end date "2026-08-31"  
**And** they upload a campaign image  
**And** they tap "Kaydet"  
**Then** a new record should be created in the `campaigns` table  
**And** the campaign image should be uploaded to `campaigns` storage bucket  
**And** the campaign should appear in the campaigns list  
**And** the campaign should be displayed on the venue details screen

#### Scenario: Create campaign with percentage discount
**Given** a business owner is creating a campaign  
**When** they select discount type "Yüzde" and enter "25"  
**Then** the campaign should be saved with `discount_percentage = 25` and `discount_amount = null`

#### Scenario: Create campaign with amount discount
**Given** a business owner is creating a campaign  
**When** they select discount type "Tutar" and enter "100"  
**Then** the campaign should be saved with `discount_amount = 100` and `discount_percentage = null`

#### Scenario: Create campaign without image
**Given** a business owner is creating a campaign  
**When** they do not upload an image  
**And** they save the campaign  
**Then** the campaign should be saved with `image_url = null`  
**And** a default campaign placeholder image should be displayed

---

### Requirement: View Campaigns List
Business owners must be able to view all their campaigns.

#### Scenario: Display campaigns list
**Given** a business owner has 3 campaigns  
**When** they view the Campaigns Management screen  
**Then** all 3 campaigns should be displayed  
**And** each campaign card should show image, title, description, discount, date range, and active status  
**And** each card should have edit, toggle, and delete buttons

#### Scenario: Display active and inactive campaigns
**Given** a business owner has 2 active and 1 inactive campaign  
**When** they view the campaigns list  
**Then** active campaigns should be displayed normally  
**And** inactive campaigns should be visually dimmed or marked as "Pasif"

#### Scenario: Empty state
**Given** a business owner has no campaigns  
**When** they view the Campaigns Management screen  
**Then** an empty state should be displayed  
**And** it should show "Henüz kampanya eklemediniz"  
**And** it should have a prominent "İlk Kampanyayı Ekle" button

#### Scenario: Campaigns ordered by date
**Given** a business owner has multiple campaigns  
**When** they view the list  
**Then** campaigns should be ordered by `start_date` descending (newest first)  
**And** active campaigns should appear before inactive ones

---

### Requirement: Edit Campaign
Business owners must be able to update campaign information.

#### Scenario: Edit campaign details
**Given** a business owner taps edit on a campaign  
**When** they change the title to "Sonbahar İndirimi" and discount to "40%"  
**And** they tap "Kaydet"  
**Then** the campaign record should be updated in the database  
**And** the changes should be reflected immediately in the UI  
**And** the changes should appear on the venue details screen

#### Scenario: Replace campaign image
**Given** a business owner is editing a campaign  
**When** they upload a new image  
**Then** the old image should be deleted from Supabase Storage  
**And** the new image should be uploaded  
**And** `image_url` should be updated with the new URL

#### Scenario: Extend campaign dates
**Given** a business owner has a campaign ending on "2026-08-31"  
**When** they edit the end date to "2026-09-30"  
**And** they save  
**Then** the campaign should remain active until the new end date  
**And** the updated dates should be displayed

---

### Requirement: Toggle Campaign Active Status
Business owners must be able to activate or deactivate campaigns.

#### Scenario: Deactivate active campaign
**Given** a business owner has an active campaign  
**When** they toggle the active switch to off  
**Then** the campaign's `is_active` should be set to `false`  
**And** the campaign should be visually marked as inactive  
**And** the campaign should not appear on the venue details screen for customers

#### Scenario: Activate inactive campaign
**Given** a business owner has an inactive campaign  
**When** they toggle the active switch to on  
**Then** the campaign's `is_active` should be set to `true`  
**And** the campaign should appear active in the UI  
**And** the campaign should be displayed on the venue details screen

---

### Requirement: Delete Campaign
Business owners must be able to remove campaigns.

#### Scenario: Delete campaign
**Given** a business owner taps delete on a campaign  
**When** they confirm the deletion  
**Then** the campaign record should be deleted from `campaigns` table  
**And** if a campaign image was uploaded, it should be deleted from Supabase Storage  
**And** the campaign should be removed from the UI  
**And** the campaign should no longer appear on the venue details screen

#### Scenario: Confirm before deletion
**Given** a business owner taps the delete button  
**When** the confirmation dialog appears  
**Then** it should show "Bu kampanyayı silmek istediğinize emin misiniz?"  
**And** it should have "İptal" and "Sil" buttons  
**And** only tapping "Sil" should proceed with deletion

---

### Requirement: Validation
The system must validate campaign information before saving.

#### Scenario: Validate title length
**Given** a business owner is creating a campaign  
**When** they enter a title with less than 5 characters  
**Then** an error message should be displayed: "Başlık en az 5 karakter olmalıdır"  
**And** the save button should be disabled

#### Scenario: Validate title max length
**Given** a business owner enters a title longer than 100 characters  
**When** they attempt to save  
**Then** an error message should be displayed: "Başlık en fazla 100 karakter olabilir"

#### Scenario: Validate description length
**Given** a business owner is creating a campaign  
**When** they enter a description with less than 10 characters  
**Then** an error message should be displayed: "Açıklama en az 10 karakter olmalıdır"

#### Scenario: Validate description max length
**Given** a business owner enters a description longer than 500 characters  
**When** they attempt to save  
**Then** an error message should be displayed: "Açıklama en fazla 500 karakter olabilir"

#### Scenario: Validate discount percentage range
**Given** a business owner selects percentage discount  
**When** they enter a value less than 1 or greater than 100  
**Then** an error message should be displayed: "İndirim oranı 1-100 arasında olmalıdır"

#### Scenario: Validate discount amount
**Given** a business owner selects amount discount  
**When** they enter a value less than 1  
**Then** an error message should be displayed: "İndirim tutarı 0'dan büyük olmalıdır"

#### Scenario: Validate date range
**Given** a business owner is creating a campaign  
**When** they select an end date before the start date  
**Then** an error message should be displayed: "Bitiş tarihi başlangıç tarihinden sonra olmalıdır"  
**And** the save button should be disabled

#### Scenario: Require discount
**Given** a business owner is creating a campaign  
**When** they do not enter any discount (neither percentage nor amount)  
**Then** an error message should be displayed: "Lütfen bir indirim oranı veya tutarı girin"

---

### Requirement: Campaign Image Upload
Business owners must be able to upload images for campaigns.

#### Scenario: Upload campaign image
**Given** a business owner is creating a campaign  
**When** they tap "Görsel Seç" and select an image  
**Then** the image should be compressed to <5MB  
**And** the image should be uploaded to the `campaigns` storage bucket  
**And** the public URL should be saved in `campaigns.image_url`

#### Scenario: Replace campaign image
**Given** a business owner has a campaign with an image  
**When** they edit the campaign and upload a new image  
**Then** the old image should be deleted from storage  
**And** the new image should be uploaded  
**And** the `image_url` should be updated

#### Scenario: Remove campaign image
**Given** a business owner has a campaign with an image  
**When** they tap "Görseli Kaldır"  
**Then** the image should be deleted from storage  
**And** `image_url` should be set to null  
**And** a default placeholder should be displayed

---

### Requirement: Real-time Sync with Venue Display
Campaign changes must be immediately reflected on the venue details screen.

#### Scenario: New campaign appears on venue details
**Given** a business owner creates a new active campaign  
**When** a customer views the venue details screen  
**Then** the new campaign should appear in the "Kampanyalar" section  
**And** the campaign should display image, title, description, and discount

#### Scenario: Updated campaign reflects changes
**Given** a business owner updates a campaign  
**When** a customer views the venue  
**Then** the updated information should be displayed  
**And** the update should be reflected within seconds

#### Scenario: Inactive campaigns hidden from customers
**Given** a business owner deactivates a campaign  
**When** a customer views the venue  
**Then** the deactivated campaign should not appear  
**And** only active campaigns should be visible

#### Scenario: Expired campaigns auto-hide
**Given** a campaign's end date has passed  
**When** a customer views the venue  
**Then** the expired campaign should not be displayed  
**And** only current campaigns (within date range) should be shown

---

### Requirement: Date Picker Integration
Business owners must be able to easily select campaign dates.

#### Scenario: Select start date
**Given** a business owner taps the start date field  
**When** the date picker opens  
**Then** the current date should be pre-selected  
**And** past dates should be disabled  
**And** selecting a date should populate the field

#### Scenario: Select end date
**Given** a business owner has selected a start date  
**When** they tap the end date field  
**Then** the date picker should open with the start date as minimum  
**And** dates before the start date should be disabled  
**And** selecting a date should populate the field

---

### Requirement: Error Handling
The system must handle errors gracefully.

#### Scenario: Handle image upload failure
**Given** a business owner uploads a campaign image  
**When** the Supabase Storage upload fails  
**Then** an error message should be displayed: "Görsel yüklenemedi"  
**And** the campaign should not be saved  
**And** the user should be able to retry

#### Scenario: Handle network error during save
**Given** a business owner attempts to save a campaign  
**When** the network request fails  
**Then** an error message should be displayed: "Bağlantı hatası. Lütfen tekrar deneyin."  
**And** the campaign should not be added to the local list  
**And** a retry button should be available

#### Scenario: Handle deletion failure
**Given** a business owner attempts to delete a campaign  
**When** the deletion fails  
**Then** an error message should be displayed  
**And** the campaign should remain in the list  
**And** a retry option should be available

---

### Requirement: Performance and UX
The campaigns management interface must be responsive and user-friendly.

#### Scenario: Optimistic UI updates
**Given** a business owner creates a campaign  
**When** they tap "Kaydet"  
**Then** the campaign should immediately appear in the list with a loading indicator  
**And** if the API call succeeds, the loading indicator should disappear  
**And** if the API call fails, the campaign should be removed and an error shown

#### Scenario: Form validation feedback
**Given** a business owner is filling the campaign form  
**When** they enter invalid data  
**Then** inline error messages should appear below each invalid field  
**And** the save button should be disabled until all fields are valid

#### Scenario: Smooth image upload experience
**Given** a business owner is uploading a campaign image  
**When** the upload is in progress  
**Then** a progress indicator should be shown  
**And** the percentage should update in real-time  
**And** the user should be able to cancel the upload

---

### Requirement: Display on Venue Details
Campaigns must be properly displayed on the venue details screen for customers.

#### Scenario: Display active campaigns
**Given** a venue has 2 active campaigns within date range  
**When** a customer views the "Kampanyalar" section  
**Then** both campaigns should be displayed  
**And** each campaign should show image, title, description, and discount  
**And** the display should match the app's design language

#### Scenario: Handle no active campaigns
**Given** a venue has no active campaigns  
**When** a customer views the venue details  
**Then** the "Kampanyalar" section should either be hidden  
**Or** show a message like "Şu anda aktif kampanya bulunmamaktadır"

#### Scenario: Campaigns load efficiently
**Given** a customer views a venue with campaigns  
**When** the campaigns section loads  
**Then** images should be cached for fast loading  
**And** a shimmer loading effect should be shown while loading  
**And** the section should not block other content from loading
