# Implementation Tasks

## 1. Database & Schema Setup

### 1.1 Create venue_photos table migration
- [x] Create migration file: `supabase/migrations/YYYYMMDDHHMMSS_create_venue_photos_table.sql`
- [x] Define `venue_photos` table schema with all fields (id, venue_id, url, thumbnail_url, title, category, service_id, uploaded_at, sort_order, is_hero_image, likes_count)
- [x] Add foreign key constraints (venue_id → venues, service_id → services)
- [x] Add check constraints (category enum, valid URL format)
- [x] Create indexes (venue_id, category, sort_order)
- [x] Test migration locally with Supabase CLI
- [x] Apply migrations to database via SQL Editor

### 1.2 Update venues table schema
- [x] Create migration file: `supabase/migrations/YYYYMMDDHHMMSS_add_hero_images_to_venues.sql`
- [x] Add `hero_images` JSONB column with default empty array
- [x] Backfill existing `image_url` values into `hero_images[0]`
- [x] Test migration locally
- [x] Verify hero images show up in UI

### 1.3 Verify RLS policies
- [x] Add RLS policies for `venue_photos` table (read: public, write: venue owners only)
- [x] Test policies with different user roles
- [x] Verify RLS is working as expected

## 2. Data Layer Implementation

### 2.1 Create VenuePhoto model
- [x] Create `lib/data/models/venue_photo.dart`
- [x] Define `VenuePhoto` class with all properties
- [x] Implement `PhotoCategory` enum (interior, exterior, service_result, team, equipment)
- [x] Add `fromJson` and `toJson` methods
- [ ] Add unit tests for model serialization

### 2.2 Update Venue model
- [x] Edit `lib/data/models/venue.dart`
- [x] Add `heroImages` field (List<String>)
- [x] Add optional `galleryPhotos` field (List<VenuePhoto>?)
- [x] Update `fromJson` to handle new fields
- [x] Update `toJson` to serialize new fields
- [x] Add backward compatibility for `imageUrl` field
- [ ] Update unit tests

### 2.3 Update VenueRepository
- [x] Edit `lib/data/repositories/venue_repository.dart`
- [x] Add `fetchVenuePhotos(String venueId)` method
- [x] Add `fetchPhotosByCategory(String venueId, PhotoCategory category)` method
- [x] Add `likePhoto(String photoId)` method
- [x] Add `unlikePhoto(String photoId)` method
- [ ] Update `getVenueById` to optionally fetch gallery photos
- [ ] Add integration tests

### 2.4 Update StorageService
- [ ] Edit `lib/data/services/storage_service.dart`
- [ ] Add `uploadVenuePhotos(List<File> photos, String venueId)` for batch upload
- [ ] Add `uploadPhotoWithThumbnail(File photo, String venueId)` helper
- [ ] Add `downloadPhoto(String url, String filename)` for download feature
- [ ] Add unit tests

## 3. Core UI Components

### 3.1 Build VenueHeroCarousel widget
- [x] Create `lib/presentation/widgets/venue/venue_hero_carousel.dart`
- [x] Implement PageView.builder for image carousel
- [x] Add pagination dots indicator
- [x] Add photo count badge (e.g., "1/5")
- [x] Add tap gesture to open full-screen viewer
- [x] Integrate parallax scroll effect (if not already present)
- [x] Add loading and error states
- [ ] Test with single and multiple images

### 3.2 Build PhotoThumbnailGrid widget
- [x] Create `lib/presentation/widgets/venue/components/photo_thumbnail_grid.dart`
- [x] Implement GridView with responsive column count
- [x] Add category filter chips
- [x] Use cached_network_image for thumbnails
- [ ] Add lazy loading with pagination
- [x] Add tap gesture to open full-screen viewer
- [x] Add empty state (no photos)
- [ ] Test with various photo counts and categories

### 3.3 Build PhotoGalleryViewer (full-screen)
- [x] Create `lib/presentation/widgets/venue/photo_gallery_viewer.dart`
- [x] Add `photo_view` package to `pubspec.yaml`
- [x] Implement PhotoViewGallery for swipeable full-screen images
- [x] Add pinch-to-zoom functionality
- [x] Add bottom metadata sheet (title, date, category)
- [x] Add action bar (share, download, like, close)
- [x] Implement auto-hide metadata after 3 seconds
- [x] Add smooth open/close transitions
- [x] Test zoom, swipe, and actions

### 3.4 Build BeforeAfterViewer widget
- [x] Create `lib/presentation/widgets/venue/before_after_viewer.dart`
- [x] Implement custom slider comparison widget (ClipRect + Stack)
- [x] Add draggable divider line with handle
- [x] Add horizontal/vertical orientation toggle
- [x] Add metadata display (service name, date, description)
- [x] Add action bar (share combined image, download, close)
- [x] Add smooth slider animations
- [x] Test with both orientations
- [x] Integrate with ServiceCard tap behavior

## 4. Integration into Venue Details Screen

### 4.1 Update venue details hero section
- [x] Edit venue details screen to replace single image with `VenueHeroCarousel`
- [x] Pass `venue.heroImages` to carousel
- [x] Handle loading state while hero images fetch
- [x] Test navigation to full-screen viewer

### 4.2 Add gallery to Services tab
- [x] Create separate `GalleryTab` for all photos
- [x] Add `GallerySectionV2` to overview tab
- [x] Implement category filtering UI
- [x] Test thumbnail grid display and filtering

### 4.3 Integrate before/after previews
- [x] Add before/after preview thumbnails to service cards (if service has photos)
- [x] Add tap gesture to open `BeforeAfterViewer`
- [x] Pass service before/after URLs to viewer
- [x] Test viewer opening and interaction

## 5. Photo Actions Implementation

### 5.1 Implement share functionality
- [x] Add `share_plus` package to `pubspec.yaml`
- [x] Create `PhotoActionsService` in `lib/core/services/photo_actions_service.dart`
- [x] Implement `sharePhoto` method
- [x] Test share dialog on iOS and Android
- [x] Implement `downloadPhoto` method in `PhotoActionsService`
- [x] Handle storage permissions
- [x] Show success/error notifications
- [x] Connect `VenueDetailsProvider.likePhoto` and `unlikePhoto`
- [x] Update UI state optimistically
- [x] Test like/unlike toggle

## 6. Performance Optimization

### 6.1 Image caching strategy
- [ ] Configure `cached_network_image` cache duration (24 hours from app_config)
- [ ] Add memory cache limits
- [ ] Implement cache clearing utility (optional)
- [ ] Test cache behavior on slow networks

### 6.2 Progressive image loading
- [ ] Add blur hash placeholders (using `blurhash_dart` or similar)
- [ ] Implement three-tier loading: placeholder → thumbnail → full
- [ ] Test loading states

### 6.3 Lazy loading for gallery
- [ ] Implement pagination for photo grid (load 20 photos at a time)
- [ ] Add "Load More" button or infinite scroll
- [ ] Test with large photo galleries (50+ photos)

## 7. Testing

### 7.1 Unit tests
- [ ] Test `VenuePhoto` model serialization
- [ ] Test `Venue` model with new fields
- [ ] Test repository methods (fetch, like, unlike)
- [ ] Test `PhotoActionService` methods

### 7.2 Widget tests
- [ ] Test `VenueHeroCarousel` with single and multiple images
- [ ] Test `PhotoThumbnailGrid` with filtering
- [ ] Test `PhotoGalleryViewer` navigation and actions
- [ ] Test `BeforeAfterViewer` slider interaction

### 7.3 Integration tests
- [ ] Test full flow: venue details → hero carousel → full-screen viewer → actions
- [ ] Test full flow: services tab → thumbnail grid → gallery viewer
- [ ] Test full flow: service card → before/after viewer
- [ ] Test on different screen sizes (phone, tablet)

## 8. Documentation & Polish

### 8.1 Code documentation
- [ ] Add dartdoc comments to all new classes and methods
- [ ] Update README if needed (new features section)

### 8.2 Analytics integration
- [ ] Add analytics events: `photo_gallery_opened`, `before_after_viewed`, `photo_shared`, `photo_downloaded`, `photo_liked`
- [ ] Test analytics tracking

### 8.3 Accessibility
- [ ] Add semantic labels to image widgets
- [ ] Add hero tags for smooth transitions
- [ ] Test with screen readers (TalkBack, VoiceOver)

### 8.4 Edge cases and error handling
- [ ] Handle network errors (display error state, retry button)
- [ ] Handle missing thumbnails (fallback to full URL)
- [ ] Handle empty galleries (show placeholder message)
- [ ] Handle permission denials (storage, network)
- [ ] Test offline behavior

## 9. Deployment Preparation

### 9.1 Database migration deployment
- [ ] Review and approve migration files
- [ ] Run migrations on staging environment
- [ ] Verify data integrity
- [ ] Run migrations on production

### 9.2 Feature flag (optional)
- [ ] Add `ENABLE_VENUE_GALLERY` feature flag in `app_config.dart`
- [ ] Wrap new features with flag checks
- [ ] Test both enabled and disabled states

### 9.3 Monitoring and rollback plan
- [ ] Monitor error rates post-deployment
- [ ] Monitor image loading performance
- [ ] Prepare rollback plan (disable feature flag if needed)

## 10. Final Review

- [ ] Code review with team
- [ ] QA testing on staging
- [ ] Performance benchmarking (image load times, memory usage)
- [ ] Update all task checkboxes to `[x]` upon completion
- [ ] Mark change as ready for archive after successful deployment
