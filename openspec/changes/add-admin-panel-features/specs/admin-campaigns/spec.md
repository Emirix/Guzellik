# Spec: Admin Campaigns Management

## ADDED Requirements

### Requirement: Campaign CRUD Operations
Venue owners must be able to create, edit, and manage promotional campaigns through the admin panel.

#### Scenario: Viewing campaigns
**Given** a venue owner is logged into the admin panel  
**When** they navigate to the Campaigns page  
**Then** they should see a list of all campaigns (active and inactive)  
**And** each campaign should display: title, discount, dates, status  
**And** they should see a "Create Campaign" button

#### Scenario: Creating a new campaign
**Given** a venue owner clicks "Create Campaign"  
**When** they fill in the campaign form with: title, description, discount, start_date, end_date  
**Then** a new record should be created in the `campaigns` table  
**And** the campaign should be associated with their `venue_id`  
**And** the campaign should be marked as active by default  
**And** at least one discount type (percentage or amount) must be provided

#### Scenario: Setting campaign discount
**Given** a venue owner is creating a campaign  
**When** they choose a discount type  
**Then** they can set either `discount_percentage` (0-100) or `discount_amount` (TRY)  
**And** only one discount type should be allowed per campaign  
**And** the database constraint should enforce this rule

#### Scenario: Setting campaign dates
**Given** a venue owner is creating a campaign  
**When** they set start and end dates  
**Then** `end_date` must be after `start_date`  
**And** the database constraint should enforce this rule  
**And** the campaign should automatically become inactive after `end_date`

#### Scenario: Uploading campaign image
**Given** a venue owner wants to add a visual to the campaign  
**When** they upload an image  
**Then** the image should be stored in Supabase Storage bucket `campaigns/{venue_id}/`  
**And** the image URL should be saved in `campaigns.image_url`  
**And** the image should be publicly readable

#### Scenario: Editing a campaign
**Given** a venue owner wants to update a campaign  
**When** they edit the campaign details  
**Then** the `campaigns` record should be updated  
**And** the `updated_at` timestamp should be refreshed  
**And** if a new image is uploaded, the old image should be deleted from storage  
**And** changes should be reflected in the mobile app immediately

#### Scenario: Activating/deactivating a campaign
**Given** a venue owner wants to control campaign visibility  
**When** they toggle the campaign status  
**Then** `campaigns.is_active` should be updated  
**And** inactive campaigns should not appear in the mobile app  
**And** the campaign should still be visible in the admin panel with status indicator

#### Scenario: Deleting a campaign
**Given** a venue owner wants to remove a campaign permanently  
**When** they delete the campaign and confirm  
**Then** the record should be removed from `campaigns` table  
**And** the campaign image should be deleted from Supabase Storage  
**And** the campaign should no longer appear anywhere

### Requirement: Campaign Validation
Campaigns must have proper validation to ensure data integrity.

#### Scenario: Required fields validation
**Given** a venue owner is creating a campaign  
**When** they submit the form  
**Then** `title`, `start_date`, and `end_date` must be provided  
**And** at least one discount type must be set  
**And** if validation fails, clear error messages should be shown

#### Scenario: Discount validation
**Given** a venue owner enters a discount percentage  
**When** they submit the form  
**Then** the percentage must be between 0 and 100  
**And** if `discount_amount` is also set, an error should be shown  
**And** the database CHECK constraint should prevent invalid data

#### Scenario: Date validation
**Given** a venue owner sets campaign dates  
**When** they submit the form  
**Then** `end_date` must be after `start_date`  
**And** both dates must be valid timestamps  
**And** the database CHECK constraint should prevent invalid dates

### Requirement: Storage Configuration
Campaign images must be stored securely in Supabase Storage.

#### Scenario: Storage bucket structure
**Given** the `campaigns` bucket exists  
**When** a campaign image is uploaded  
**Then** it should be stored at path `{venue_id}/{campaign_id}.{extension}`  
**And** the URL should be publicly accessible for reading  
**And** only the venue owner should be able to upload/delete

#### Scenario: Image optimization
**Given** a venue owner uploads a campaign image  
**When** the upload is processed  
**Then** the image should be resized to max 1200px width  
**And** the image should be optimized for web display  
**And** the mobile app should load the optimized image

### Requirement: Mobile App Integration
Campaigns must be displayed dynamically in the Flutter mobile app.

#### Scenario: Displaying active campaigns in venue details
**Given** a venue has active campaigns  
**When** a user views the venue in `VenueDetailsScreen`  
**Then** active campaigns should be displayed in a dedicated section  
**And** each campaign should show: image, title, discount, end date  
**And** only campaigns where `is_active = true` and `end_date > NOW()` should be shown

#### Scenario: Displaying campaigns in discovery feed
**Given** multiple venues have active campaigns  
**When** a user browses the discovery feed  
**Then** featured campaigns should be displayed  
**And** campaigns should be sorted by creation date or relevance  
**And** tapping a campaign should navigate to the venue details

#### Scenario: Campaign expiration handling
**Given** a campaign's `end_date` has passed  
**When** the mobile app fetches campaigns  
**Then** expired campaigns should not be returned by the RLS policy  
**And** the admin panel should show expired campaigns with an "Expired" badge  
**And** venue owners should be able to extend the end date

#### Scenario: Campaigns data synchronization
**Given** a venue owner updates campaigns in the admin panel  
**When** changes are saved  
**Then** the mobile app should reflect changes immediately  
**And** the discovery feed should refresh campaign data  
**And** cached campaign images should be invalidated
