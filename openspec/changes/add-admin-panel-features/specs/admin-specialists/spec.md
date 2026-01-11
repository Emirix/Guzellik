# Spec: Admin Specialists Management

## ADDED Requirements

### Requirement: Specialist CRUD Operations
Venue owners must be able to add, edit, and remove specialist team members through the admin panel.

#### Scenario: Viewing specialist team
**Given** a venue owner is logged into the admin panel  
**When** they navigate to the Specialists page  
**Then** they should see a list of all current specialists  
**And** each specialist should display: name, profession, photo  
**And** they should see an "Add Specialist" button

#### Scenario: Adding a new specialist
**Given** a venue owner clicks "Add Specialist"  
**When** they fill in the specialist form with: name, profession, gender, and upload a photo  
**Then** a new record should be created in the `specialists` table  
**And** the photo should be uploaded to Supabase Storage bucket `specialists/{venue_id}/`  
**And** the specialist should appear in the team list  
**And** all fields except bio should be required

#### Scenario: Uploading specialist photo
**Given** a venue owner is adding a specialist  
**When** they upload a photo  
**Then** the photo should be stored at `specialists/{venue_id}/{specialist_id}.{extension}`  
**And** the photo URL should be saved in `specialists.photo_url`  
**And** the photo should be publicly readable but only editable by the venue owner

#### Scenario: Editing specialist information
**Given** a venue owner wants to update specialist details  
**When** they edit the specialist form  
**Then** the `specialists` record should be updated  
**And** the `updated_at` timestamp should be refreshed  
**And** if a new photo is uploaded, the old photo should be deleted from storage  
**And** changes should be reflected in the mobile app immediately

#### Scenario: Reordering specialists
**Given** a venue owner has multiple specialists  
**When** they drag and drop to reorder the team  
**Then** the `sort_order` values should be updated  
**And** the mobile app should display specialists in the new order

#### Scenario: Deleting a specialist
**Given** a venue owner wants to remove a specialist  
**When** they delete the specialist and confirm  
**Then** the record should be removed from `specialists` table  
**And** the photo should be deleted from Supabase Storage  
**And** the specialist should no longer appear in the mobile app

#### Scenario: Gender selection
**Given** a venue owner is adding a specialist  
**When** they select a gender  
**Then** options should be: 'Kadın', 'Erkek', 'Belirtilmemiş'  
**And** the value should be stored in `specialists.gender`  
**And** this field should be optional

### Requirement: Database Schema
A dedicated `specialists` table must be created to store team member information.

#### Scenario: Specialists table structure
**Given** the database migration is applied  
**When** the `specialists` table is created  
**Then** it should have columns: id, venue_id, name, profession, gender, photo_url, bio, sort_order, created_at, updated_at  
**And** `venue_id` should be a foreign key to `venues(id)` with CASCADE delete  
**And** `gender` should have a CHECK constraint for valid values  
**And** RLS policies should allow public SELECT and owner-only INSERT/UPDATE/DELETE

#### Scenario: Migrating existing expert_team data
**Given** venues have existing data in `venues.expert_team` JSONB field  
**When** the migration runs  
**Then** existing expert data should be converted to `specialists` records  
**And** the `venues.expert_team` field should be deprecated (but not removed for backwards compatibility)  
**And** the mobile app should read from `specialists` table instead

### Requirement: Mobile App Integration
Specialists must be displayed dynamically in the Flutter mobile app.

#### Scenario: Displaying specialists in venue details
**Given** a venue has specialists configured  
**When** a user views the venue in `VenueDetailsScreen`  
**Then** specialists should be displayed in the About tab  
**And** each specialist should show: photo, name, profession  
**And** specialists should be ordered by `sort_order`  
**And** if no specialists exist, a placeholder message should be shown

#### Scenario: Specialist data model in Flutter
**Given** the Flutter app fetches specialist data  
**When** data is retrieved from Supabase  
**Then** it should be deserialized into a `Specialist` model  
**And** the model should include all fields from the database  
**And** photo URLs should be properly formatted for display

#### Scenario: Specialists data synchronization
**Given** a venue owner updates specialists in the admin panel  
**When** changes are saved  
**Then** the mobile app should reflect changes immediately  
**And** the `VenueDetailsProvider` should refresh specialist data  
**And** cached specialist photos should be invalidated
