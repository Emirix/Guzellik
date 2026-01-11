# Proposal: Mobile Business Admin Panel

## Overview

This change adds comprehensive business management features directly within the Flutter mobile application, enabling venue owners to manage their services, gallery, specialists, and campaigns from their mobile devices. All data will be dynamically displayed throughout the app wherever venues are shown.

## Why

Venue owners need a mobile-first admin panel to manage their business presence on the platform. Currently, business owners must use a separate web admin panel, which creates friction and limits accessibility. By integrating admin features directly into the mobile app:

- **Accessibility**: Owners can manage their business anytime, anywhere from their phones
- **Seamless Experience**: No need to switch between web and mobile platforms
- **Real-time Updates**: Changes are immediately reflected in the app for all users
- **Lower Barrier**: Business owners can update their venue information on-the-go
- **Better Engagement**: Easy access encourages owners to keep their information current

This change is critical for:
- **Business Growth**: Venues can actively manage and promote their services from mobile
- **User Trust**: Up-to-date information (photos, specialists, services) builds confidence
- **Platform Adoption**: Removing friction increases business user retention
- **Data Accuracy**: Owners maintain their own data in real-time

## Problem Statement

Currently, business owners must:
1. Switch to a separate web admin panel to manage their venue
2. Use a desktop/laptop to update their business information
3. Cannot make quick updates while on-the-go

Venue owners need the ability to manage their business directly from the mobile app:
- Manage service offerings from the service catalog
- Upload and organize venue gallery photos (max 5 photos)
- Add and manage specialist/expert team members
- Create and manage promotional campaigns

All of this data should be immediately reflected throughout the mobile app (search results, venue details, discovery pages, etc.).

## Proposed Solution

Implement a mobile business admin panel accessible via the business bottom navigation bar with four core features:

### 1. **Services Management** (`admin-services`)
- Access via new "Yönetim" tab in business bottom nav
- Browse and select services from existing `service_categories` catalog
- Add services to `venue_services` table with venue association
- Optional custom photo and description (defaults to service catalog values)
- Optional pricing and duration fields
- Drag-and-drop reordering of services
- Enable/disable and remove services
- Real-time sync with venue details display

### 2. **Gallery Management** (`admin-gallery`)
- Upload up to 5 photos using image picker (camera + gallery)
- Store photos in Supabase Storage `venue-gallery` bucket
- Store metadata in existing `venue_photos` table
- Drag-and-drop reordering (updates `sort_order`)
- Set primary/hero image (`is_hero_image`)
- Delete photos from both storage and database
- Enforce 5-photo limit with UI validation
- Real-time sync with venue hero carousel

### 3. **Specialists Management** (`admin-specialists`)
- Create and manage team members in `specialists` table
- Add specialist with: name, profession, gender, photo
- Upload photos to Supabase Storage `specialists` bucket
- No service association required (simple team directory)
- CRUD operations for team members
- Real-time sync with venue details "Uzmanlar" section

### 4. **Campaigns Management** (`admin-campaigns`)
- Use existing `campaigns` table
- Create campaigns with: title, description, discount, dates, image
- Upload campaign images to Supabase Storage `campaigns` bucket
- Enable/disable campaigns with toggle
- CRUD operations
- Real-time sync with venue details and discovery pages

### Navigation Structure

Business mode bottom navigation will have 4 tabs:
1. **Profilim** (Profile) - Shows venue details preview
2. **Yönetim** (Management) - NEW: Admin panel with 4 sections
3. **Abonelik** (Subscription) - Existing subscription screen
4. **Mağaza** (Store) - Existing store screen

### Design Principles

- Use existing app color palette (nude, soft pink, primary pink, gold accents)
- Follow Flutter Material Design 3 guidelines
- Maintain consistency with existing app UI/UX
- Premium, clean, minimal aesthetic
- Responsive and touch-friendly interactions
- Drag-and-drop using `reorderable_list` or similar packages

## Success Criteria

- [ ] Business owners can access admin panel from business bottom nav
- [ ] All four management features (Services, Gallery, Specialists, Campaigns) are functional
- [ ] Changes are immediately reflected throughout the app
- [ ] Supabase Storage buckets are properly configured with RLS
- [ ] 5-photo limit enforced for gallery
- [ ] Drag-and-drop reordering works smoothly
- [ ] All data displays dynamically in VenueDetailsScreen, SearchScreen, DiscoveryScreen
- [ ] Proper error handling and validation
- [ ] UI matches existing app design language
- [ ] Image upload and compression works efficiently

## Dependencies

### Existing Database Tables
- `venue_services` - Service associations
- `service_categories` - Service catalog
- `venue_photos` - Gallery photos
- `campaigns` - Promotional campaigns
- `specialists` - Team members (may need to be created if doesn't exist)

### Supabase Storage Buckets
- `venue-gallery` - Venue photos
- `specialists` - Specialist photos
- `campaigns` - Campaign images

### Flutter Packages (Expected)
- `image_picker` - Photo selection
- `image_cropper` - Image editing
- `flutter_image_compress` - Image optimization
- `reorderable_list` or `flutter_reorderable_list` - Drag-and-drop
- `cached_network_image` - Image caching
- Existing: `supabase_flutter`, `provider`, `go_router`

### Existing Providers/Services
- `BusinessProvider` - Business mode state
- `VenueDetailsProvider` - Venue data
- `AuthProvider` - User authentication
- Supabase client

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Storage bucket permissions | Implement proper RLS policies for authenticated venue owners |
| Photo upload size limits | Implement client-side image compression before upload |
| Data sync delays | Use Supabase realtime subscriptions and optimistic UI updates |
| Gallery limit enforcement | Add database constraint and UI validation |
| Mobile performance | Optimize image loading, use pagination for large lists |
| Drag-and-drop UX | Use well-tested packages, provide visual feedback |
| Offline scenarios | Show clear error messages, queue uploads when online |

## Out of Scope

- Service creation (only selection from existing catalog)
- Appointment booking integration
- Analytics/reporting features
- Multi-venue management UI
- Bulk operations
- Advanced image editing (filters, effects)
- Video uploads
- Staff account management (only owner access)
- Web admin panel modifications

## Related Changes

- Depends on existing `add-business-account-management` for business mode
- May inform future `add-appointment-booking` feature
- Complements existing venue details display features
