# Tasks: Admin Panel Features

## Database & Storage Setup

### 1. Create specialists table and migration
- [ ] Create migration file for `specialists` table
- [ ] Add columns: id, venue_id, name, profession, gender, photo_url, bio, sort_order, created_at, updated_at
- [ ] Add foreign key constraint to venues with CASCADE delete
- [ ] Add CHECK constraint for gender values
- [ ] Add indexes on venue_id and sort_order
- [ ] Enable RLS on specialists table
- [ ] Create RLS policies (public SELECT, owner INSERT/UPDATE/DELETE)
- [ ] Add trigger for updated_at timestamp
- [ ] **Validation**: Query specialists table, verify constraints work

### 2. Add venue_photos limit constraint
- [ ] Create trigger function `check_venue_photos_limit()`
- [ ] Add BEFORE INSERT trigger to enforce 5-photo limit
- [ ] Test trigger by attempting to insert 6th photo
- [ ] **Validation**: Verify database rejects 6th photo insertion

### 3. Create Supabase Storage buckets
- [ ] Create `specialists` bucket (if not exists)
- [ ] Create `campaigns` bucket (if not exists)
- [ ] Verify `venue-gallery` bucket exists
- [ ] Configure public read access for all buckets
- [ ] **Validation**: Test file upload to each bucket

### 4. Configure Storage RLS policies
- [ ] Add SELECT policy (public) for specialists bucket
- [ ] Add INSERT/UPDATE/DELETE policies (owner only) for specialists bucket
- [ ] Add SELECT policy (public) for campaigns bucket
- [ ] Add INSERT/UPDATE/DELETE policies (owner only) for campaigns bucket
- [ ] Verify venue-gallery bucket has correct policies
- [ ] **Validation**: Test upload/delete as owner and non-owner

### 5. Migrate existing expert_team data
- [ ] Create data migration script to convert JSONB to specialists records
- [ ] Run migration on existing venues
- [ ] Verify all expert data is preserved
- [ ] Update Flutter app to read from specialists table
- [ ] **Validation**: Compare old JSONB data with new specialists records

## Admin Panel - Services Management

### 6. Create Services page component
- [ ] Replace placeholder `Services.jsx` with functional component
- [ ] Add page header with "Add Service" button
- [ ] Create layout for services list/grid
- [ ] Add loading and error states
- [ ] **Validation**: Page renders without errors

### 7. Implement service catalog selector
- [ ] Create `ServiceSelector.jsx` component
- [ ] Fetch all `service_categories` from Supabase
- [ ] Display categories grouped by main category
- [ ] Add search/filter functionality
- [ ] Show service details (name, description, duration, icon)
- [ ] **Validation**: All service categories load and are searchable

### 8. Implement add service functionality
- [ ] Create `ServiceForm.jsx` component
- [ ] Add form fields: service selection, custom price, custom duration
- [ ] Add optional fields: custom photo upload, custom description
- [ ] Implement form validation
- [ ] Insert into `venue_services` table on submit
- [ ] If custom photo/description provided, insert into `services` table
- [ ] **Validation**: Service appears in list after adding

### 9. Implement service list display
- [ ] Create `ServiceCard.jsx` component
- [ ] Display service name, category, price, duration
- [ ] Show custom photo if available, else default icon
- [ ] Add enable/disable toggle
- [ ] Add edit and delete buttons
- [ ] **Validation**: All services display correctly with proper data

### 10. Implement service editing
- [ ] Add edit mode to `ServiceForm.jsx`
- [ ] Pre-fill form with existing service data
- [ ] Update `venue_services` and `services` tables on save
- [ ] Handle photo replacement (delete old, upload new)
- [ ] **Validation**: Edits persist and display correctly

### 11. Implement service deletion
- [ ] Add delete confirmation modal
- [ ] Delete from `venue_services` (cascades to `services`)
- [ ] Delete custom photo from storage if exists
- [ ] Refresh services list
- [ ] **Validation**: Service is removed from database and UI

### 12. Implement service reordering
- [ ] Add drag-and-drop library (e.g., dnd-kit)
- [ ] Implement drag handlers
- [ ] Update sort order in database on drop
- [ ] **Validation**: Order persists after page refresh

## Admin Panel - Gallery Management

### 13. Create Gallery page component
- [ ] Replace placeholder `Gallery.jsx` with functional component
- [ ] Add page header with photo count (e.g., "3/5 photos")
- [ ] Create grid layout for photos
- [ ] Add "Upload Photo" button (disabled if at limit)
- [ ] **Validation**: Page renders with current photos

### 14. Implement photo upload
- [ ] Create `PhotoUploader.jsx` component
- [ ] Add file input with image type validation
- [ ] Implement client-side image validation (type, size max 5MB)
- [ ] Upload to `venue-gallery/{venue_id}/` in Supabase Storage
- [ ] Insert record into `venue_photos` table
- [ ] Generate thumbnail (400px width)
- [ ] **Validation**: Photo appears in gallery after upload

### 15. Implement photo limit enforcement
- [ ] Add UI validation to disable upload at 5 photos
- [ ] Show error message if limit reached
- [ ] Verify database trigger prevents 6th photo
- [ ] **Validation**: Cannot upload more than 5 photos

### 16. Implement photo grid display
- [ ] Create `PhotoGrid.jsx` component
- [ ] Display photos in responsive grid
- [ ] Show photo title and category if available
- [ ] Highlight hero image with badge
- [ ] Add hover actions (edit, delete, set as hero)
- [ ] **Validation**: All photos display with correct metadata

### 17. Implement drag-and-drop reordering
- [ ] Create `DragDropReorder.jsx` component
- [ ] Add drag-and-drop functionality
- [ ] Update `sort_order` in database on drop
- [ ] Provide visual feedback during drag
- [ ] **Validation**: Order persists and reflects in mobile app

### 18. Implement set hero image
- [ ] Add "Set as Primary" button to each photo
- [ ] Update `is_hero_image` to true for selected photo
- [ ] Set all other photos' `is_hero_image` to false
- [ ] Show visual indicator for hero image
- [ ] **Validation**: Only one hero image at a time

### 19. Implement photo deletion
- [ ] Add delete confirmation modal
- [ ] Delete photo from Supabase Storage
- [ ] Delete record from `venue_photos` table
- [ ] Update photo count
- [ ] **Validation**: Photo removed from storage and database

### 20. Add photo metadata editing
- [ ] Create edit modal for photo
- [ ] Add fields: title, category
- [ ] Update `venue_photos` record on save
- [ ] **Validation**: Metadata updates persist

## Admin Panel - Specialists Management

### 21. Create Specialists page component
- [ ] Replace placeholder `Specialists.jsx` with functional component
- [ ] Add page header with "Add Specialist" button
- [ ] Create layout for specialists list
- [ ] Add loading and error states
- [ ] **Validation**: Page renders without errors

### 22. Implement add specialist functionality
- [ ] Create `SpecialistForm.jsx` component
- [ ] Add form fields: name, profession, gender, photo upload, bio
- [ ] Implement form validation (name, profession required)
- [ ] Upload photo to `specialists/{venue_id}/` in Supabase Storage
- [ ] Insert record into `specialists` table
- [ ] **Validation**: Specialist appears in list after adding

### 23. Implement specialists list display
- [ ] Create `SpecialistCard.jsx` component
- [ ] Display specialist photo, name, profession
- [ ] Add edit and delete buttons
- [ ] Show specialists ordered by `sort_order`
- [ ] **Validation**: All specialists display correctly

### 24. Implement specialist editing
- [ ] Add edit mode to `SpecialistForm.jsx`
- [ ] Pre-fill form with existing specialist data
- [ ] Handle photo replacement (delete old, upload new)
- [ ] Update `specialists` record on save
- [ ] Update `updated_at` timestamp
- [ ] **Validation**: Edits persist and display correctly

### 25. Implement specialist deletion
- [ ] Add delete confirmation modal
- [ ] Delete photo from Supabase Storage
- [ ] Delete record from `specialists` table
- [ ] Refresh specialists list
- [ ] **Validation**: Specialist removed from database and storage

### 26. Implement specialist reordering
- [ ] Add drag-and-drop functionality
- [ ] Update `sort_order` in database on drop
- [ ] **Validation**: Order persists after page refresh

## Admin Panel - Campaigns Management

### 27. Create Campaigns page component
- [ ] Replace placeholder `Campaigns.jsx` with functional component
- [ ] Add page header with "Create Campaign" button
- [ ] Create layout for campaigns list
- [ ] Show active and inactive campaigns separately
- [ ] **Validation**: Page renders without errors

### 28. Implement create campaign functionality
- [ ] Create `CampaignForm.jsx` component
- [ ] Add form fields: title, description, discount type, discount value, dates, image upload
- [ ] Implement form validation (required fields, date logic, discount validation)
- [ ] Upload image to `campaigns/{venue_id}/` in Supabase Storage
- [ ] Insert record into `campaigns` table
- [ ] **Validation**: Campaign appears in list after creation

### 29. Implement campaigns list display
- [ ] Create `CampaignCard.jsx` component
- [ ] Display campaign image, title, discount, dates
- [ ] Show active/inactive status badge
- [ ] Show "Expired" badge if past end_date
- [ ] Add edit, delete, and toggle active buttons
- [ ] **Validation**: All campaigns display with correct status

### 30. Implement campaign editing
- [ ] Add edit mode to `CampaignForm.jsx`
- [ ] Pre-fill form with existing campaign data
- [ ] Handle image replacement (delete old, upload new)
- [ ] Update `campaigns` record on save
- [ ] Update `updated_at` timestamp
- [ ] **Validation**: Edits persist and display correctly

### 31. Implement campaign activation toggle
- [ ] Add toggle switch for `is_active` status
- [ ] Update `campaigns.is_active` in database
- [ ] Show visual feedback for status change
- [ ] **Validation**: Status change reflects in mobile app

### 32. Implement campaign deletion
- [ ] Add delete confirmation modal
- [ ] Delete image from Supabase Storage if exists
- [ ] Delete record from `campaigns` table
- [ ] Refresh campaigns list
- [ ] **Validation**: Campaign removed from database and storage

## Flutter App - Data Models

### 33. Create Specialist data model
- [ ] Create `lib/data/models/specialist.dart`
- [ ] Add fields: id, venueId, name, profession, gender, photoUrl, bio, sortOrder
- [ ] Implement `fromJson` factory constructor
- [ ] Implement `toJson` method
- [ ] **Validation**: Model deserializes Supabase data correctly

### 34. Update Service data model
- [ ] Verify `Service` model includes custom photo and description fields
- [ ] Ensure model handles null values for optional fields
- [ ] **Validation**: Model works with new service structure

### 35. Update VenuePhoto data model
- [ ] Verify `VenuePhoto` model includes all fields (sort_order, is_hero_image, etc.)
- [ ] **Validation**: Model deserializes venue_photos data correctly

### 36. Update Campaign data model
- [ ] Verify `Campaign` model exists and includes all fields
- [ ] Add helper methods for checking if campaign is active/expired
- [ ] **Validation**: Model works with campaigns table

## Flutter App - Repositories

### 37. Update VenueRepository for specialists
- [ ] Add `getVenueSpecialists(venueId)` method
- [ ] Query `specialists` table with proper ordering
- [ ] Return List<Specialist>
- [ ] **Validation**: Specialists data loads correctly

### 38. Update VenueRepository for gallery
- [ ] Add `getVenuePhotos(venueId)` method
- [ ] Query `venue_photos` table ordered by sort_order
- [ ] Return List<VenuePhoto>
- [ ] **Validation**: Photos load in correct order

### 39. Update VenueRepository for campaigns
- [ ] Add `getVenueCampaigns(venueId)` method
- [ ] Query `campaigns` table with active/date filters
- [ ] Return List<Campaign>
- [ ] **Validation**: Only active, non-expired campaigns load

### 40. Update VenueRepository for services
- [ ] Verify `getVenueServices(venueId)` uses correct RPC or query
- [ ] Ensure custom photos and descriptions are included
- [ ] **Validation**: Services load with all custom data

## Flutter App - Providers

### 41. Update VenueDetailsProvider for specialists
- [ ] Add `specialists` state variable
- [ ] Fetch specialists in `loadVenueDetails()`
- [ ] Add `refreshSpecialists()` method
- [ ] **Validation**: Specialists data available in provider

### 42. Update VenueDetailsProvider for gallery
- [ ] Add `photos` state variable
- [ ] Fetch photos in `loadVenueDetails()`
- [ ] Add `refreshPhotos()` method
- [ ] Identify hero image
- [ ] **Validation**: Photos data available in provider

### 43. Update VenueDetailsProvider for campaigns
- [ ] Add `campaigns` state variable
- [ ] Fetch campaigns in `loadVenueDetails()`
- [ ] Add `refreshCampaigns()` method
- [ ] **Validation**: Campaigns data available in provider

### 44. Update VenueDetailsProvider for services
- [ ] Verify services are loaded with custom data
- [ ] Ensure custom photos display correctly
- [ ] **Validation**: Services display with custom info

### 45. Add realtime subscriptions
- [ ] Subscribe to specialists table changes
- [ ] Subscribe to venue_photos table changes
- [ ] Subscribe to campaigns table changes
- [ ] Subscribe to venue_services table changes
- [ ] Auto-refresh provider data on changes
- [ ] **Validation**: Changes in admin panel reflect immediately in app

## Flutter App - UI Updates

### 46. Update VenueDetailsScreen - About Tab
- [ ] Add specialists section to About tab
- [ ] Create `SpecialistCard` widget
- [ ] Display specialists in grid or list
- [ ] Show photo, name, profession
- [ ] Order by sort_order
- [ ] **Validation**: Specialists display correctly

### 47. Update VenueDetailsScreen - Photos Tab
- [ ] Update photos carousel/grid
- [ ] Ensure photos ordered by sort_order
- [ ] Display hero image first
- [ ] Add fullscreen photo viewer
- [ ] **Validation**: Gallery displays correctly

### 48. Update VenueDetailsScreen - Services Tab
- [ ] Update services list
- [ ] Display custom photos when available
- [ ] Show custom descriptions
- [ ] Display custom pricing and duration
- [ ] **Validation**: Services display with custom data

### 49. Add Campaigns section to VenueDetailsScreen
- [ ] Create `CampaignCard` widget
- [ ] Display active campaigns
- [ ] Show campaign image, title, discount, end date
- [ ] Add section header "Aktif Kampanyalar"
- [ ] **Validation**: Campaigns display in venue details

### 50. Update SearchScreen for service filters
- [ ] Ensure service chips load from venue_services
- [ ] Filter venues by selected services
- [ ] **Validation**: Service filtering works correctly

### 51. Update DiscoveryScreen for campaigns
- [ ] Add campaigns section to discovery feed
- [ ] Display featured campaigns
- [ ] Make campaigns tappable (navigate to venue)
- [ ] **Validation**: Campaigns appear in discovery

### 52. Add image caching
- [ ] Use `CachedNetworkImage` for all photos
- [ ] Implement cache invalidation on updates
- [ ] **Validation**: Images load quickly and cache properly

## Testing & Validation

### 53. Test admin panel services flow
- [ ] Add service from catalog
- [ ] Customize price and duration
- [ ] Upload custom photo
- [ ] Verify in mobile app
- [ ] Edit service
- [ ] Delete service
- [ ] **Validation**: Full CRUD cycle works

### 54. Test admin panel gallery flow
- [ ] Upload 5 photos
- [ ] Verify 6th photo is rejected
- [ ] Reorder photos
- [ ] Set hero image
- [ ] Delete photo
- [ ] Verify in mobile app
- [ ] **Validation**: Full gallery management works

### 55. Test admin panel specialists flow
- [ ] Add specialist with photo
- [ ] Edit specialist
- [ ] Reorder specialists
- [ ] Delete specialist
- [ ] Verify in mobile app
- [ ] **Validation**: Full specialists management works

### 56. Test admin panel campaigns flow
- [ ] Create campaign with image
- [ ] Verify validation (dates, discount)
- [ ] Toggle active status
- [ ] Edit campaign
- [ ] Delete campaign
- [ ] Verify in mobile app
- [ ] **Validation**: Full campaigns management works

### 57. Test realtime synchronization
- [ ] Make change in admin panel
- [ ] Verify mobile app updates without refresh
- [ ] Test for all four features
- [ ] **Validation**: Realtime updates work

### 58. Test storage permissions
- [ ] Verify venue owner can upload to their buckets
- [ ] Verify non-owner cannot upload to other's buckets
- [ ] Verify public can read all images
- [ ] **Validation**: RLS policies work correctly

### 59. Test mobile app display across screens
- [ ] Verify data shows in VenueDetailsScreen
- [ ] Verify data shows in SearchScreen
- [ ] Verify data shows in DiscoveryScreen
- [ ] **Validation**: All screens display dynamic data

### 60. Performance testing
- [ ] Test with venue having max data (5 photos, 10 specialists, 10 services, 5 campaigns)
- [ ] Verify load times are acceptable
- [ ] Check image loading performance
- [ ] **Validation**: App performs well with full data

## Documentation

### 61. Update API documentation
- [ ] Document new specialists table schema
- [ ] Document storage bucket structure
- [ ] Document RLS policies
- [ ] **Validation**: Documentation is complete

### 62. Create admin panel user guide
- [ ] Write guide for services management
- [ ] Write guide for gallery management
- [ ] Write guide for specialists management
- [ ] Write guide for campaigns management
- [ ] **Validation**: Guides are clear and helpful

### 63. Update project README
- [ ] Add admin panel features to feature list
- [ ] Update setup instructions if needed
- [ ] **Validation**: README is up to date

## Deployment

### 64. Run database migrations
- [ ] Apply specialists table migration to production
- [ ] Apply venue_photos trigger migration
- [ ] Run data migration for expert_team
- [ ] **Validation**: Migrations complete without errors

### 65. Create storage buckets in production
- [ ] Create specialists bucket
- [ ] Create campaigns bucket
- [ ] Configure RLS policies
- [ ] **Validation**: Buckets are accessible

### 66. Deploy admin panel updates
- [ ] Build admin panel
- [ ] Deploy to hosting
- [ ] **Validation**: Admin panel is accessible

### 67. Deploy Flutter app updates
- [ ] Build Flutter app
- [ ] Test on iOS and Android
- [ ] Deploy to app stores (if applicable)
- [ ] **Validation**: App works on both platforms

## Dependencies

- Tasks 1-5 must complete before any other tasks (database foundation)
- Tasks 6-12 can run in parallel (admin services)
- Tasks 13-20 can run in parallel (admin gallery)
- Tasks 21-26 can run in parallel (admin specialists)
- Tasks 27-32 can run in parallel (admin campaigns)
- Tasks 33-40 must complete before 41-45 (models before providers)
- Tasks 41-45 must complete before 46-52 (providers before UI)
- Tasks 53-60 require all implementation tasks complete
- Tasks 64-67 are final deployment steps
