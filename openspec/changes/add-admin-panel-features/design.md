# Design: Admin Panel Features

## Architecture Overview

This change extends the existing admin panel with four new management modules while maintaining clean separation between the admin panel (React) and mobile app (Flutter).

```
┌─────────────────────────────────────────────────────────────┐
│                      Admin Panel (React)                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Services │  │ Gallery  │  │Specialists│  │Campaigns │   │
│  │   Page   │  │   Page   │  │   Page    │  │   Page   │   │
│  └────┬─────┘  └────┬─────┘  └────┬──────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼──────────────┼──────────┘
        │             │             │              │
        └─────────────┴─────────────┴──────────────┘
                          │
                    Supabase Client
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
   ┌────▼────┐                      ┌───────▼────────┐
   │Database │                      │    Storage     │
   │  Tables │                      │    Buckets     │
   └────┬────┘                      └───────┬────────┘
        │                                   │
        └─────────────┬─────────────────────┘
                      │
        ┌─────────────▼─────────────────┐
        │   Flutter App (Mobile)        │
        │  ┌────────────────────────┐   │
        │  │ VenueDetailsScreen     │   │
        │  │ SearchScreen           │   │
        │  │ DiscoveryScreen        │   │
        │  └────────────────────────┘   │
        └───────────────────────────────┘
```

## Database Schema Changes

### New Table: `specialists`

```sql
CREATE TABLE specialists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  profession TEXT NOT NULL,
  gender TEXT CHECK (gender IN ('Kadın', 'Erkek', 'Belirtilmemiş')),
  photo_url TEXT,
  bio TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Modified Tables

**`venue_photos`** - Add constraint for 5-photo limit:
```sql
-- Add check constraint via trigger
CREATE OR REPLACE FUNCTION check_venue_photos_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM venue_photos WHERE venue_id = NEW.venue_id) >= 5 THEN
    RAISE EXCEPTION 'Venue cannot have more than 5 photos';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**`campaigns`** - Already exists, no changes needed

**`venue_services`** - Already exists, no changes needed

## Supabase Storage Structure

### Buckets

1. **`venue-gallery`** (already exists, verify configuration)
   ```
   venue-gallery/
   └── {venue_id}/
       ├── {photo_id_1}.jpg
       ├── {photo_id_2}.jpg
       └── ...
   ```

2. **`specialists`** (new)
   ```
   specialists/
   └── {venue_id}/
       ├── {specialist_id_1}.jpg
       ├── {specialist_id_2}.jpg
       └── ...
   ```

3. **`campaigns`** (new)
   ```
   campaigns/
   └── {venue_id}/
       ├── {campaign_id_1}.jpg
       ├── {campaign_id_2}.jpg
       └── ...
   ```

### Storage RLS Policies

All buckets follow the same pattern:
- **SELECT**: Public (anyone can view)
- **INSERT**: Authenticated users, own venue only
- **UPDATE**: Authenticated users, own venue only
- **DELETE**: Authenticated users, own venue only

## Admin Panel Component Structure

```
admin/src/
├── pages/
│   ├── Services.jsx          (replace placeholder)
│   ├── Gallery.jsx           (replace placeholder)
│   ├── Specialists.jsx       (replace placeholder)
│   └── Campaigns.jsx         (replace placeholder)
├── components/
│   ├── services/
│   │   ├── ServiceSelector.jsx
│   │   ├── ServiceCard.jsx
│   │   └── ServiceForm.jsx
│   ├── gallery/
│   │   ├── PhotoUploader.jsx
│   │   ├── PhotoGrid.jsx
│   │   └── DragDropReorder.jsx
│   ├── specialists/
│   │   ├── SpecialistForm.jsx
│   │   ├── SpecialistCard.jsx
│   │   └── SpecialistList.jsx
│   └── campaigns/
│       ├── CampaignForm.jsx
│       ├── CampaignCard.jsx
│       └── CampaignList.jsx
└── lib/
    └── supabase.js
```

## Flutter Integration Points

### Data Models

```dart
// lib/data/models/specialist.dart
class Specialist {
  final String id;
  final String venueId;
  final String name;
  final String profession;
  final String? gender;
  final String? photoUrl;
  final String? bio;
  final int sortOrder;
}
```

### Providers to Update

- **VenueDetailsProvider**: Add specialists, ensure gallery and campaigns load
- **SearchProvider**: Include service chips from venue_services
- **DiscoveryProvider**: Show campaigns in discovery feed

### Screens to Update

- **VenueDetailsScreen**: Display specialists, gallery carousel, active campaigns
- **SearchScreen**: Show service filters from venue_services
- **DiscoveryScreen**: Feature active campaigns

## Data Flow

### Services Management Flow
```
Admin Panel → Select Service → venue_services.insert() → 
Optional: Add custom photo/description → services.insert() →
Flutter: VenueDetailsProvider.refresh() → Display in ServicesTab
```

### Gallery Management Flow
```
Admin Panel → Upload Photo → Supabase Storage.upload() →
venue_photos.insert() → Set sort_order →
Flutter: VenueDetailsProvider.refresh() → Display in PhotosTab
```

### Specialists Management Flow
```
Admin Panel → Add Specialist → Upload Photo → Supabase Storage.upload() →
specialists.insert() →
Flutter: VenueDetailsProvider.refresh() → Display in AboutTab
```

### Campaigns Management Flow
```
Admin Panel → Create Campaign → Upload Image → Supabase Storage.upload() →
campaigns.insert() →
Flutter: DiscoveryProvider.refresh() → Display in DiscoveryScreen
```

## Technical Decisions

### Why Separate `specialists` Table?

**Decision**: Create a dedicated `specialists` table instead of using JSONB in `venues.expert_team`.

**Rationale**:
- Better data integrity with proper foreign keys
- Easier to query and filter
- Supports photo uploads with proper references
- Enables future features (specialist ratings, bookings)
- Cleaner admin panel CRUD operations

**Trade-offs**:
- Migration needed to move existing JSONB data
- Additional join in queries
- ✅ Better: Structured, scalable, maintainable

### Why 5-Photo Limit?

**Decision**: Enforce 5-photo limit at database level with trigger.

**Rationale**:
- Prevents storage abuse
- Ensures consistent mobile app performance
- Forces curation of best photos
- Clear UX expectation

**Implementation**: Database trigger + UI validation for better UX

### Why No Service Creation in Admin Panel?

**Decision**: Only allow selection from `service_categories` catalog.

**Rationale**:
- Maintains standardized service taxonomy
- Enables accurate filtering and search
- Prevents duplicate/misspelled services
- Custom descriptions still allowed per venue

## Security Considerations

1. **Storage Access**: RLS policies ensure users can only access their own venue's files
2. **Photo Limit**: Database trigger prevents exceeding 5 photos
3. **File Types**: Client-side validation for image types (jpg, png, webp)
4. **File Size**: Max 5MB per image, enforced client-side
5. **Venue Ownership**: All operations verify `venues.owner_id = auth.uid()`

## Performance Considerations

1. **Image Optimization**: 
   - Resize images on upload (max 1920px width)
   - Generate thumbnails for gallery grid
   - Use WebP format when possible

2. **Lazy Loading**:
   - Flutter app loads images progressively
   - Admin panel uses pagination for large lists

3. **Caching**:
   - Flutter: CachedNetworkImage for all photos
   - Admin: Browser cache for uploaded images

## Migration Strategy

1. **Database**: Create `specialists` table, add triggers
2. **Storage**: Create new buckets with RLS policies
3. **Data Migration**: Move `venues.expert_team` JSONB to `specialists` table
4. **Admin Panel**: Replace placeholder pages with functional components
5. **Flutter**: Update providers and screens to fetch new data
6. **Testing**: Verify data sync between admin panel and mobile app
