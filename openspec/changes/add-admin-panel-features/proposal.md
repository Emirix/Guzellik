# Proposal: Admin Panel Features

## Overview

This change adds comprehensive business management features to the admin panel, enabling venue owners to manage their services, gallery, specialists, and campaigns. All data will be dynamically displayed in the Flutter mobile application wherever venues are shown.

## Why

Venue owners need a self-service admin panel to manage their business presence on the platform. Currently, the admin panel has placeholder pages that prevent owners from:
- Showcasing their service offerings to attract customers
- Displaying their venue through high-quality photos
- Highlighting their expert team to build trust
- Running promotional campaigns to drive bookings

Without these features, venues cannot effectively market themselves, and users cannot make informed decisions when choosing a venue. This creates a poor experience for both business owners and end users.

By implementing these admin features, we enable:
- **Business Growth**: Venues can actively manage and promote their services
- **User Trust**: Detailed information (photos, specialists, services) builds confidence
- **Platform Engagement**: Campaigns and rich content keep users engaged
- **Data Accuracy**: Owners maintain their own data, reducing support burden

This change is critical for platform adoption and retention of business users.

## Problem Statement

Currently, the admin panel has placeholder pages for key business management features. Venue owners need the ability to:
- Manage their service offerings from the service catalog
- Upload and organize venue gallery photos (max 5 photos)
- Add and manage specialist/expert team members
- Create and manage promotional campaigns

All of this data should be immediately reflected in the mobile app wherever venues are displayed (search results, venue details, discovery pages, etc.).

## Proposed Solution

Implement four core admin panel features with full CRUD operations:

### 1. **Services Management**
- Select services from existing `service_categories` catalog
- Add services to `venue_services` table
- Optional custom pricing and duration
- Optional custom photo and description (defaults to service catalog values)
- Reorder, enable/disable, and remove services

### 2. **Gallery Management**
- Upload up to 5 photos to Supabase Storage
- Store metadata in existing `venue_photos` table
- Drag-and-drop reordering (updates `sort_order`)
- Set primary/hero image (`is_hero_image`)
- Delete photos from both storage and database

### 3. **Specialists Management**
- Create new `specialists` table (separate from JSONB in venues)
- Add specialist with: name, profession, gender, photo
- Upload photos to Supabase Storage
- No service association required
- CRUD operations for team members

### 4. **Campaigns Management**
- Use existing `campaigns` table
- Create campaigns with: title, description, discount, dates, image
- Upload campaign images to Supabase Storage
- Enable/disable campaigns
- CRUD operations

## Success Criteria

- [ ] Venue owners can manage all four features from admin panel
- [ ] All changes are immediately reflected in Flutter app
- [ ] Supabase Storage buckets are properly configured with RLS
- [ ] 5-photo limit enforced for gallery
- [ ] All data displays dynamically in mobile app (VenueDetailsScreen, SearchScreen, etc.)
- [ ] Proper error handling and validation
- [ ] Responsive admin panel UI

## Dependencies

- Existing database tables: `venue_services`, `service_categories`, `venue_photos`, `campaigns`
- New database table: `specialists`
- Supabase Storage buckets: `venue-gallery`, `specialists`, `campaigns`
- Admin panel React components
- Flutter data models and providers

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Storage bucket permissions | Implement proper RLS policies for authenticated venue owners |
| Photo upload size limits | Implement client-side validation and image compression |
| Data sync delays | Use Supabase realtime subscriptions in Flutter app |
| Gallery limit enforcement | Add database constraint and UI validation |

## Out of Scope

- Service creation (only selection from catalog)
- Appointment booking integration
- Analytics/reporting features
- Multi-venue management UI
- Bulk operations
