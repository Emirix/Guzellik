# Design: Mobile Business Admin Panel

## Architecture Overview

This design document outlines the technical architecture for implementing a mobile business admin panel within the Flutter application. The solution integrates seamlessly with existing business mode functionality and leverages current database schema.

## System Components

### 1. Navigation Layer

#### Business Bottom Navigation Extension
- **Current State**: 3 tabs (Profilim, Abonelik, Mağaza)
- **Proposed State**: 4 tabs (Profilim, Yönetim, Abonelik, Mağaza)
- **Implementation**: Modify `BusinessBottomNav` widget to include new "Yönetim" tab
- **Icon**: `Icons.dashboard_customize` or `Icons.admin_panel_settings`

#### Route Structure
```
/business/admin (Main admin screen with 4 sections)
  ├── /business/admin/services (Services management)
  ├── /business/admin/gallery (Gallery management)
  ├── /business/admin/specialists (Specialists management)
  └── /business/admin/campaigns (Campaigns management)
```

### 2. Data Layer

#### Database Schema (Existing Tables)

**venue_services**
```sql
- id: uuid (PK)
- venue_id: uuid (FK -> venues)
- service_id: uuid (FK -> service_categories)
- custom_name: text (optional override)
- custom_description: text (optional override)
- custom_image_url: text (optional override)
- price: decimal (optional)
- duration_minutes: integer (optional)
- is_active: boolean (default true)
- sort_order: integer (for drag-and-drop)
- created_at: timestamp
- updated_at: timestamp
```

**venue_photos**
```sql
- id: uuid (PK)
- venue_id: uuid (FK -> venues)
- photo_url: text
- caption: text (optional)
- is_hero_image: boolean (default false)
- sort_order: integer
- created_at: timestamp
```

**specialists** (May need creation)
```sql
- id: uuid (PK)
- venue_id: uuid (FK -> venues)
- name: text
- profession: text
- gender: text (enum: 'male', 'female', 'other')
- photo_url: text
- bio: text (optional, for future)
- sort_order: integer
- created_at: timestamp
- updated_at: timestamp
```

**campaigns**
```sql
- id: uuid (PK)
- venue_id: uuid (FK -> venues)
- title: text
- description: text
- discount_percentage: decimal (optional)
- discount_amount: decimal (optional)
- start_date: date
- end_date: date
- image_url: text (optional)
- is_active: boolean (default true)
- created_at: timestamp
- updated_at: timestamp
```

#### Supabase Storage Buckets

**venue-gallery**
- Path: `{venue_id}/{timestamp}_{filename}`
- Max file size: 5MB
- Allowed types: image/jpeg, image/png, image/webp
- RLS: Authenticated users can upload to their own venue folder

**specialists**
- Path: `{venue_id}/{specialist_id}_{filename}`
- Max file size: 2MB
- Allowed types: image/jpeg, image/png, image/webp
- RLS: Authenticated users can upload to their own venue folder

**campaigns**
- Path: `{venue_id}/{campaign_id}_{filename}`
- Max file size: 5MB
- Allowed types: image/jpeg, image/png, image/webp
- RLS: Authenticated users can upload to their own venue folder

### 3. State Management

#### New Providers

**AdminServicesProvider**
```dart
class AdminServicesProvider extends ChangeNotifier {
  List<VenueService> _services = [];
  bool _isLoading = false;
  String? _error;
  
  // Fetch services for current venue
  Future<void> fetchVenueServices(String venueId);
  
  // Add service from catalog
  Future<void> addService(String venueId, String serviceId, {
    String? customName,
    String? customDescription,
    String? customImageUrl,
    double? price,
    int? durationMinutes,
  });
  
  // Update service
  Future<void> updateService(String serviceId, Map<String, dynamic> updates);
  
  // Reorder services
  Future<void> reorderServices(List<String> serviceIds);
  
  // Toggle active status
  Future<void> toggleServiceActive(String serviceId, bool isActive);
  
  // Delete service
  Future<void> deleteService(String serviceId);
}
```

**AdminGalleryProvider**
```dart
class AdminGalleryProvider extends ChangeNotifier {
  List<VenuePhoto> _photos = [];
  bool _isLoading = false;
  String? _error;
  
  // Fetch gallery photos
  Future<void> fetchGalleryPhotos(String venueId);
  
  // Upload photo
  Future<void> uploadPhoto(String venueId, File imageFile, {String? caption});
  
  // Reorder photos
  Future<void> reorderPhotos(List<String> photoIds);
  
  // Set hero image
  Future<void> setHeroImage(String photoId);
  
  // Delete photo
  Future<void> deletePhoto(String photoId);
  
  // Check photo limit
  bool canAddMorePhotos() => _photos.length < 5;
}
```

**AdminSpecialistsProvider**
```dart
class AdminSpecialistsProvider extends ChangeNotifier {
  List<Specialist> _specialists = [];
  bool _isLoading = false;
  String? _error;
  
  // Fetch specialists
  Future<void> fetchSpecialists(String venueId);
  
  // Add specialist
  Future<void> addSpecialist(String venueId, {
    required String name,
    required String profession,
    required String gender,
    required File photoFile,
  });
  
  // Update specialist
  Future<void> updateSpecialist(String specialistId, Map<String, dynamic> updates);
  
  // Delete specialist
  Future<void> deleteSpecialist(String specialistId);
}
```

**AdminCampaignsProvider**
```dart
class AdminCampaignsProvider extends ChangeNotifier {
  List<Campaign> _campaigns = [];
  bool _isLoading = false;
  String? _error;
  
  // Fetch campaigns
  Future<void> fetchCampaigns(String venueId);
  
  // Create campaign
  Future<void> createCampaign(String venueId, {
    required String title,
    required String description,
    double? discountPercentage,
    double? discountAmount,
    required DateTime startDate,
    required DateTime endDate,
    File? imageFile,
  });
  
  // Update campaign
  Future<void> updateCampaign(String campaignId, Map<String, dynamic> updates);
  
  // Toggle active status
  Future<void> toggleCampaignActive(String campaignId, bool isActive);
  
  // Delete campaign
  Future<void> deleteCampaign(String campaignId);
}
```

### 4. UI Components

#### Admin Dashboard Screen
- Grid layout with 4 cards (Services, Gallery, Specialists, Campaigns)
- Each card shows count and quick action button
- Tappable cards navigate to detail screens
- Uses app color palette (nude, pink, gold accents)

#### Services Management Screen
- Search bar to filter service catalog
- Category chips for filtering
- List of available services with add button
- List of added services with:
  - Drag handle for reordering
  - Edit button for customization
  - Toggle for active/inactive
  - Delete button
- Bottom sheet for service customization (photo, description, price, duration)

#### Gallery Management Screen
- Grid view of current photos (2 columns)
- Upload button (max 5 photos)
- Each photo card shows:
  - Drag handle for reordering
  - Hero badge if primary image
  - Delete button
- Long-press to reorder
- Tap to set as hero image
- Image picker with compression

#### Specialists Management Screen
- List of specialists with photo, name, profession
- Add button (FAB)
- Each specialist card shows:
  - Circular photo
  - Name and profession
  - Edit and delete buttons
- Add/Edit form:
  - Photo picker (circular crop)
  - Name field
  - Profession field
  - Gender dropdown

#### Campaigns Management Screen
- List of campaigns with image, title, dates
- Add button (FAB)
- Each campaign card shows:
  - Campaign image
  - Title and description
  - Discount info
  - Date range
  - Active toggle
  - Edit and delete buttons
- Add/Edit form:
  - Image picker
  - Title and description fields
  - Discount type (percentage or amount)
  - Date pickers
  - Active toggle

### 5. Image Handling

#### Upload Flow
1. User selects image (camera or gallery)
2. Optional cropping (for specialists: circular, for gallery: 16:9)
3. Compress image (target: <1MB for specialists, <2MB for gallery)
4. Generate unique filename: `{timestamp}_{uuid}.jpg`
5. Upload to Supabase Storage
6. Get public URL
7. Save metadata to database
8. Update UI optimistically

#### Compression Strategy
```dart
Future<File> compressImage(File file, {int maxWidth = 1920, int quality = 85}) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    '${file.parent.path}/compressed_${file.path.split('/').last}',
    quality: quality,
    minWidth: maxWidth,
    minHeight: (maxWidth * 0.75).toInt(),
  );
  return result!;
}
```

### 6. Real-time Sync

#### Supabase Realtime Subscriptions
- Subscribe to changes in `venue_services`, `venue_photos`, `specialists`, `campaigns`
- Update provider state when changes detected
- Refresh VenueDetailsProvider to update venue display
- Use optimistic updates for better UX

#### Optimistic Updates
1. Update local state immediately
2. Show loading indicator
3. Perform API call
4. On success: confirm update
5. On error: revert state and show error

### 7. Validation & Constraints

#### Gallery Constraints
- Maximum 5 photos per venue
- Minimum 1 hero image required
- File size: <5MB per photo
- Formats: JPEG, PNG, WebP

#### Services Constraints
- Must select from existing catalog
- Cannot add duplicate services
- Custom fields are optional
- Price and duration validation (positive numbers)

#### Specialists Constraints
- Name: 2-50 characters
- Profession: 2-30 characters
- Photo required
- Gender required

#### Campaigns Constraints
- Title: 5-100 characters
- Description: 10-500 characters
- Discount: Either percentage (0-100) OR amount (>0)
- End date must be after start date
- Image optional

### 8. Error Handling

#### Network Errors
- Show retry button
- Cache failed uploads for retry
- Offline indicator

#### Validation Errors
- Inline field validation
- Form-level validation before submit
- Clear error messages

#### Storage Errors
- File size exceeded
- Upload failed
- Quota exceeded

### 9. Performance Considerations

#### Image Loading
- Use `cached_network_image` for all images
- Thumbnail generation for gallery grid
- Lazy loading for long lists

#### Database Queries
- Index on `venue_id` for all tables
- Pagination for large datasets
- Efficient RLS policies

#### State Management
- Dispose providers when not needed
- Debounce search inputs
- Throttle reorder operations

## UI/UX Design Patterns

### Color Palette
- Primary: `AppColors.primary` (#EE2B5B)
- Background: `AppColors.backgroundLight` (#FFF9FA)
- Cards: `AppColors.white` with subtle shadow
- Accents: `AppColors.gold` for premium elements
- Text: `AppColors.black` / `AppColors.gray700`

### Typography
- Headers: Bold, 20-24px
- Subheaders: SemiBold, 16-18px
- Body: Regular, 14-16px
- Captions: Regular, 12-14px

### Spacing
- Card padding: 16px
- Section spacing: 24px
- Element spacing: 8-12px

### Interactions
- Tap feedback: Ripple effect
- Drag feedback: Elevation + shadow
- Loading: Shimmer or circular progress
- Success: Snackbar with checkmark
- Error: Snackbar with error icon

## Security Considerations

### Row Level Security (RLS)
```sql
-- venue_services
CREATE POLICY "Owners can manage their venue services"
ON venue_services
FOR ALL
USING (venue_id IN (
  SELECT id FROM venues WHERE owner_id = auth.uid()
));

-- venue_photos
CREATE POLICY "Owners can manage their venue photos"
ON venue_photos
FOR ALL
USING (venue_id IN (
  SELECT id FROM venues WHERE owner_id = auth.uid()
));

-- specialists
CREATE POLICY "Owners can manage their specialists"
ON specialists
FOR ALL
USING (venue_id IN (
  SELECT id FROM venues WHERE owner_id = auth.uid()
));

-- campaigns
CREATE POLICY "Owners can manage their campaigns"
ON campaigns
FOR ALL
USING (venue_id IN (
  SELECT id FROM venues WHERE owner_id = auth.uid()
));
```

### Storage Security
```sql
-- Bucket policies for venue-gallery, specialists, campaigns
CREATE POLICY "Owners can upload to their venue folder"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'venue-gallery' AND
  (storage.foldername(name))[1] IN (
    SELECT id::text FROM venues WHERE owner_id = auth.uid()
  )
);
```

## Testing Strategy

### Unit Tests
- Provider logic (CRUD operations)
- Validation functions
- Image compression
- Data model serialization

### Widget Tests
- Admin dashboard layout
- Form validation
- Drag-and-drop interactions
- Image picker integration

### Integration Tests
- End-to-end service management flow
- Gallery upload and reorder flow
- Specialist creation flow
- Campaign creation flow
- Real-time sync verification

## Migration Path

### Phase 1: Database Setup
1. Verify/create `specialists` table
2. Add missing columns to existing tables
3. Set up RLS policies
4. Create storage buckets

### Phase 2: Core Features
1. Implement admin dashboard
2. Services management
3. Gallery management

### Phase 3: Extended Features
1. Specialists management
2. Campaigns management

### Phase 4: Polish
1. Drag-and-drop refinement
2. Image optimization
3. Real-time sync
4. Error handling

## Future Enhancements

- Bulk operations (multi-select delete)
- Service analytics (most booked services)
- Campaign performance metrics
- Specialist scheduling integration
- Advanced image editing (filters, cropping)
- Video support for gallery
- Multi-language support for services
