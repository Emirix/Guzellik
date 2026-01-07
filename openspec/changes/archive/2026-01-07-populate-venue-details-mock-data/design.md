# Design: Venue Details Data Integration

This document outlines the architectural changes for integrating reviews and populating mock data for venues.

## Data Layer

### Database Schema (Supabase)
We will add a `reviews` table:
```sql
CREATE TABLE public.reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  rating NUMERIC NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
```

### Expert Team Data
The `expert_team` field in `venues` is already a JSONB. We will populate it with the following structure:
```json
[
  {
    "id": "exp1",
    "name": "Ayşe Yılmaz",
    "specialty": "Saç Tasarımcı",
    "rating": 4.9,
    "photo_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=Ayse"
  }
]
```

## UI Architecture

### Reviews Tab
The `ReviewsTab` will display:
- An overall rating summary.
- A list of `ReviewCard` widgets.
- Loading and empty states.

### Services Tab
Already implemented but depends on data. We will ensure the seeding provides a categorized list to test the grouping logic.

## Logic Flow
1. `VenueDetailsScreen` calls `provider.loadVenueDetails`.
2. `VenueDetailsProvider` calls repo to fetch:
   - Venue (includes Experts in JSONB).
   - Services.
   - Reviews (New).
3. UI rebuilds with the loaded data.
