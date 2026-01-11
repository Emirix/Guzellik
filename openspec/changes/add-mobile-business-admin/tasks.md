# Tasks: Mobile Business Admin Panel

## Phase 1: Foundation & Navigation (Days 1-2)

### Task 1.1: Update Business Bottom Navigation
- [x] Modify `BusinessBottomNav` widget to add 4th tab "Yönetim"
- [x] Add appropriate icon (`Icons.dashboard_customize` or `Icons.admin_panel_settings`)
- [x] Update navigation logic to handle 4 tabs instead of 3
- [x] Update `AppStateProvider` if needed for new tab index
- [x] Test navigation between all 4 tabs
- **Validation**: All 4 tabs should be visible and tappable in business mode

### Task 1.2: Create Admin Dashboard Screen
- [x] Create `lib/presentation/screens/business/admin_dashboard_screen.dart`
- [x] Implement grid layout with 4 cards (Services, Gallery, Specialists, Campaigns)
- [x] Each card shows icon, title, count, and quick action button
- [x] Add navigation to detail screens on card tap
- [x] Style with app color palette (nude, pink, gold accents)
- [x] Add route `/business/admin` to GoRouter
- **Validation**: Dashboard displays 4 cards with proper styling and navigation

### Task 1.3: Set Up Admin Routes
- [x] Add routes for all admin screens in GoRouter:
- [x] Test deep linking to each route
- **Validation**: All routes are accessible and properly configured

---

## Phase 2: Database & Storage Setup (Days 3-4)

### Task 2.1: Verify/Create Specialists Table
- [ ] Check if `specialists` table exists in Supabase
- [ ] If not, create migration with schema:
  ```sql
  CREATE TABLE specialists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venue_id UUID REFERENCES venues(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    profession TEXT NOT NULL,
    gender TEXT NOT NULL,
    photo_url TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
  );
  ```
- [ ] Add indexes on `venue_id`
- [ ] Test table creation
- **Validation**: `specialists` table exists with correct schema

### Task 2.2: Update Existing Tables
- [ ] Verify `venue_services` has all required columns:
  - `custom_name`, `custom_description`, `custom_image_url`
  - `price`, `duration_minutes`, `is_active`, `sort_order`
- [ ] Add missing columns if needed
- [ ] Verify `venue_photos` has `is_hero_image` and `sort_order`
- [ ] Verify `campaigns` has all required columns
- **Validation**: All tables have required columns

### Task 2.3: Set Up RLS Policies
- [ ] Create RLS policy for `venue_services` (owners can manage their venue's services)
- [ ] Create RLS policy for `venue_photos` (owners can manage their venue's photos)
- [ ] Create RLS policy for `specialists` (owners can manage their venue's specialists)
- [ ] Create RLS policy for `campaigns` (owners can manage their venue's campaigns)
- [ ] Test policies with authenticated user
- **Validation**: RLS policies allow owners to CRUD their own data, deny others

### Task 2.4: Create Storage Buckets
- [ ] Create `venue-gallery` bucket (if not exists)
- [ ] Create `specialists` bucket
- [ ] Create `campaigns` bucket
- [ ] Set up storage RLS policies for each bucket
- [ ] Configure bucket settings (max file size, allowed types)
- **Validation**: Buckets exist and RLS policies work correctly

---

## Phase 3: Data Models & Providers (Days 5-6)

### Task 3.1: Create Specialist Model
- [x] Create `lib/data/models/specialist.dart`
- [x] Implement `Specialist` class with all fields
- [x] Add `fromJson` and `toJson` methods
- [x] Add `copyWith` method
- [x] Test serialization/deserialization
- **Validation**: Specialist model correctly parses JSON from Supabase

### Task 3.2: Create Campaign Model
- [x] Create `lib/data/models/campaign.dart` (if not exists)
- [x] Implement `Campaign` class with all fields
- [x] Add `fromJson` and `toJson` methods
- [x] Add `copyWith` method
- [x] Add helper methods (e.g., `isActive`, `isExpired`)
- **Validation**: Campaign model correctly parses JSON from Supabase

### Task 3.3: Create VenueService Model
- [ ] Create `lib/data/models/venue_service.dart`
- [ ] Implement `VenueService` class with all fields
- [ ] Add `fromJson` and `toJson` methods
- [ ] Add `copyWith` method
- **Validation**: VenueService model correctly parses JSON from Supabase

### Task 3.4: Create AdminServicesProvider
- [ ] Create `lib/presentation/providers/admin_services_provider.dart`
- [ ] Implement state management for services CRUD
- [ ] Add methods: `fetchVenueServices`, `addService`, `updateService`, `reorderServices`, `toggleServiceActive`, `deleteService`
- [ ] Add loading, error, and success states
- [ ] Test all methods with mock data
- **Validation**: Provider correctly manages services state

### Task 3.5: Create AdminGalleryProvider
- [x] Create `lib/presentation/providers/admin_gallery_provider.dart`
- [x] Implement state management for gallery CRUD
- [x] Add methods: `fetchGalleryPhotos`, `uploadPhoto`, `reorderPhotos`, `setHeroImage`, `deletePhoto`
- [x] Add photo limit check (`canAddMorePhotos`)
- [x] Test all methods
- [x] Create `lib/presentation/providers/admin_specialists_provider.dart`
- [x] Implement state management for specialists CRUD
- [x] Add methods: `fetchSpecialists`, `addSpecialist`, `updateSpecialist`, `deleteSpecialist`
- [x] Test all methods
- [x] Create `lib/presentation/providers/admin_campaigns_provider.dart`
- [x] Implement state management for campaigns CRUD
- [x] Add methods: `fetchCampaigns`, `createCampaign`, `updateCampaign`, `toggleCampaignActive`, `deleteCampaign`
- [x] Test all methods
- [x] Add all 4 admin providers to `MultiProvider` in `main.dart`
- [x] Test provider initialization
- **Validation**: All providers are accessible throughout the app

---

## Phase 4: Services Management (Days 7-9)

### Task 4.1: Create Services Management Screen
- [ ] Create `lib/presentation/screens/business/admin_services_screen.dart`
- [ ] Implement search bar for filtering services
- [ ] Add category chips for filtering
- [ ] Create two sections: "Hizmet Kataloğu" and "Mevcut Hizmetler"
- [ ] Style with app theme
- **Validation**: Screen layout matches design

### Task 4.2: Implement Service Catalog List
- [ ] Fetch all services from `service_categories`
- [ ] Display services in a list with name, image, category
- [ ] Implement search functionality (debounced)
- [ ] Implement category filtering
- [ ] Add "Ekle" button for each service
- **Validation**: Service catalog displays and filters correctly

### Task 4.3: Implement Current Services List
- [ ] Fetch venue's services from `venue_services`
- [ ] Display services with drag handles, edit, toggle, delete buttons
- [ ] Show custom details if available, otherwise defaults
- [ ] Implement drag-and-drop reordering
- [ ] Test reordering updates `sort_order`
- **Validation**: Current services display and can be reordered

### Task 4.4: Implement Add Service
- [ ] Create bottom sheet for service customization
- [ ] Add fields: custom name, description, image, price, duration
- [ ] Implement image picker and upload
- [ ] Validate inputs
- [ ] Call `addService` on provider
- [ ] Show success/error messages
- **Validation**: Services can be added with custom details

### Task 4.5: Implement Edit Service
- [ ] Reuse customization bottom sheet for editing
- [ ] Pre-populate fields with current values
- [ ] Allow updating all fields
- [ ] Handle image replacement
- [ ] Call `updateService` on provider
- **Validation**: Services can be edited successfully

### Task 4.6: Implement Toggle and Delete
- [ ] Add toggle switch for `is_active`
- [ ] Implement delete with confirmation dialog
- [ ] Handle storage cleanup for custom images
- [ ] Update UI optimistically
- **Validation**: Services can be toggled and deleted

### Task 4.7: Integrate with Venue Details
- [ ] Update `VenueDetailsProvider` to fetch services
- [ ] Display services in "Hizmetler" tab
- [ ] Show only active services
- [ ] Test real-time sync
- **Validation**: Services appear on venue details screen

---

## Phase 5: Gallery Management (Days 10-12)

### Task 5.1: Create Gallery Management Screen
- [x] Create `lib/presentation/screens/business/admin_gallery_screen.dart`
- [x] Implement 2-column grid for photos
- [x] Show photo count "Galeri (X/5)"
- [x] Add upload button
- [x] Style with app theme
- **Validation**: Screen layout matches design

### Task 5.2: Implement Photo Upload
- [x] Add `image_picker` package
- [x] Implement camera and gallery selection
- [x] Add image compression using `flutter_image_compress` (Using image_picker quality for now)
- [x] Upload to Supabase Storage
- [x] Save metadata to `venue_photos`
- [x] Enforce 5-photo limit
- **Validation**: Photos can be uploaded and compressed

### Task 5.3: Implement Photo Grid Display
- [x] Display photos in 2-column grid
- [x] Show drag handles and delete buttons
- [x] Show "Ana Görsel" badge on hero image
- [x] Implement empty state
- **Validation**: Photos display correctly in grid

### Task 5.4: Implement Drag-and-Drop Reordering
- [ ] Add `flutter_reorderable_list` or similar package
- [ ] Implement long-press to drag
- [ ] Update `sort_order` on reorder
- [ ] Provide visual feedback during drag
- **Validation**: Photos can be reordered smoothly

### Task 5.5: Implement Hero Image Selection
- [x] Add "Ana Görsel Yap" button on each photo
- [x] Update `is_hero_image` for selected photo
- [x] Set all others to `false`
- [x] Auto-set first photo as hero
- [x] Add delete button on each photo
- [x] Show confirmation dialog
- [x] Delete from storage and database
- [ ] Prevent deleting last photo
- [x] Auto-assign new hero if hero deleted
- **Validation**: Photos can be deleted with proper validation

### Task 5.7: Integrate with Venue Details
- [ ] Update `VenueDetailsProvider` to fetch photos
- [ ] Display photos in hero carousel
- [ ] Use hero image as primary
- [ ] Test real-time sync
- **Validation**: Gallery photos appear in venue details carousel

---

## Phase 6: Specialists Management (Days 13-14)

### Task 6.1: Create Specialists Management Screen
- [x] Create `lib/presentation/screens/business/admin_specialists_screen.dart`
- [x] Implement list view for specialists
- [x] Add FAB for adding specialist
- [x] Style with app theme
- **Validation**: Screen layout matches design

### Task 6.2: Implement Specialists List
- [x] Fetch specialists from database
- [x] Display each specialist with circular photo, name, profession
- [x] Add edit and delete buttons
- [x] Implement empty state
- [x] Create bottom sheet or full screen form
- [x] Add fields: name, profession, gender, photo
- [x] Implement circular image crop
- [x] Add gender selection
- [x] Validate inputs
- [x] Implement camera and gallery selection
- [x] Compress image
- [x] Upload to `specialists` bucket
- [x] Save URL to database
- [x] Reuse form for editing
- [x] Pre-populate fields
- [x] Allow photo replacement
- [x] Implement delete with confirmation
- [x] Clean up storage on delete
- [x] Update `VenueDetailsProvider` to fetch specialists
- [x] Display specialists in "Uzmanlar" section
- [x] Test real-time sync
- **Validation**: Specialists appear on venue details screen

---

## Phase 7: Campaigns Management (Days 15-16)

### Task 7.1: Create Campaigns Management Screen
- [x] Create `lib/presentation/screens/business/admin_campaigns_screen.dart`
- [x] Implement list view for campaigns
- [x] Add FAB for adding campaign
- [x] Style with app theme
- [x] Fetch campaigns from database
- [x] Display each campaign with image, title, description, dates, discount
- [x] Show active/inactive status
- [x] Add edit, toggle, delete buttons
- [x] Implement empty state
- [x] Create full screen form
- [x] Add fields: title, description, discount type, discount value, dates, image
- [x] Implement date pickers
- [x] Add discount type toggle (percentage vs amount)
- [x] Validate inputs
- [x] Implement image picker
- [x] Compress image
- [x] Upload to `campaigns` bucket
- [x] Make image optional
- [x] Reuse form for editing
- [x] Pre-populate fields
- [x] Allow image replacement
- [x] Implement active toggle
- [x] Implement delete with confirmation
- [x] Clean up storage on delete
- [x] Update `VenueDetailsProvider` to fetch campaigns
- [x] Display active campaigns in "Kampanyalar" section
- [x] Filter by date range and active status
- [x] Test real-time sync
- **Validation**: Active campaigns appear on venue details screen

---

## Phase 8: Polish & Testing (Days 17-18)

### Task 8.1: Implement Optimistic UI Updates
- [ ] Add optimistic updates for all CRUD operations
- [ ] Show loading indicators
- [ ] Revert on error
- [ ] Test all scenarios
- **Validation**: UI updates immediately and reverts on error

### Task 8.2: Implement Error Handling
- [ ] Add try-catch blocks for all API calls
- [ ] Show user-friendly error messages
- [ ] Add retry buttons where appropriate
- [ ] Handle network errors gracefully
- **Validation**: All errors are handled and displayed properly

### Task 8.3: Add Loading States
- [ ] Add shimmer loading for lists
- [ ] Add progress indicators for uploads
- [ ] Add skeleton screens where appropriate
- **Validation**: Loading states provide good UX

### Task 8.4: Implement Real-time Sync
- [ ] Set up Supabase realtime subscriptions for all tables
- [ ] Update provider state on changes
- [ ] Refresh `VenueDetailsProvider` on updates
- [ ] Test sync across multiple devices
- **Validation**: Changes sync in real-time

### Task 8.5: Performance Optimization
- [ ] Implement image caching with `cached_network_image`
- [ ] Debounce search inputs
- [ ] Throttle drag-and-drop updates
- [ ] Optimize database queries
- **Validation**: App performs smoothly with no lag

### Task 8.6: Accessibility & UX Polish
- [ ] Add semantic labels for screen readers
- [ ] Ensure proper contrast ratios
- [ ] Add haptic feedback for interactions
- [ ] Polish animations and transitions
- **Validation**: App is accessible and polished

### Task 8.7: Integration Testing
- [ ] Test complete flow for services management
- [ ] Test complete flow for gallery management
- [ ] Test complete flow for specialists management
- [ ] Test complete flow for campaigns management
- [ ] Test cross-feature interactions
- **Validation**: All features work end-to-end

### Task 8.8: User Acceptance Testing
- [ ] Test with real business owner accounts
- [ ] Verify all data displays correctly on venue details
- [ ] Test on multiple devices (iOS, Android)
- [ ] Gather feedback and iterate
- **Validation**: Business owners can successfully manage their venue

---

## Dependencies Between Tasks

- **Phase 1** must complete before Phase 3
- **Phase 2** must complete before Phase 3
- **Phase 3** must complete before Phases 4-7
- **Phases 4-7** can be done in parallel or sequentially
- **Phase 8** should be done after Phases 4-7

## Estimated Timeline

- **Phase 1**: 2 days
- **Phase 2**: 2 days
- **Phase 3**: 2 days
- **Phase 4**: 3 days
- **Phase 5**: 3 days
- **Phase 6**: 2 days
- **Phase 7**: 2 days
- **Phase 8**: 2 days

**Total**: ~18 days (3.5 weeks)

## Success Metrics

- [ ] All 4 admin features are functional
- [ ] Business owners can manage services, gallery, specialists, and campaigns
- [ ] Changes sync in real-time to venue details
- [ ] 5-photo limit is enforced
- [ ] All images are properly compressed and uploaded
- [ ] Drag-and-drop works smoothly
- [ ] Error handling is comprehensive
- [ ] UI matches app design language
- [ ] Performance is smooth on mid-range devices
- [ ] No critical bugs in production
