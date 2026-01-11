# Design: Architecture Scalability & Logical Optimization

## Database Schema Enhancements

### 1. Centralized Media System
Instead of simple URLs, we use a structured table and a join table for maximum flexibility.

```sql
CREATE TABLE public.media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    storage_path TEXT NOT NULL, -- Path in Supabase storage
    mime_type TEXT,
    size_bytes BIGINT,
    metadata JSONB DEFAULT '{}'::jsonb, -- width, height, blurhash
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Join table for polymorphic associations
CREATE TABLE public.entity_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    media_id UUID REFERENCES public.media(id) ON DELETE CASCADE,
    entity_id UUID NOT NULL, -- venue_id, specialist_id, etc.
    entity_type TEXT NOT NULL, -- 'venue_hero', 'venue_gallery', 'specialist_photo', 'profile_avatar'
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. Structured Venue Hours
Allows for efficient "Open Now" queries.

```sql
CREATE TABLE public.venue_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE,
    day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Sunday
    open_time TIME,
    close_time TIME,
    is_closed BOOLEAN DEFAULT false,
    UNIQUE(venue_id, day_of_week)
);
```

### 3. Polymorphic Reviews
Extending the existing review system.

```sql
ALTER TABLE public.reviews 
ADD COLUMN target_type TEXT NOT NULL DEFAULT 'venue', -- 'venue', 'service', 'specialist'
ADD COLUMN target_id UUID NOT NULL;

-- Migrate existing reviews
UPDATE public.reviews SET target_id = venue_id WHERE target_type = 'venue';
```

### 4. Audit Logging
Automated tracking via triggers.

```sql
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action TEXT NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    old_data JSONB,
    new_data JSONB,
    actor_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Migration Strategy

### Step 1: Media Migration
1. Create `media` and `entity_media` tables.
2. Script a migration that reads existing `photo_url`, `avatar_url`, and `hero_image` values.
3. For each unique URL, create a `media` record.
4. Create corresponding `entity_media` entries.
5. Verification: Ensure all entities still have their images via the new system.
6. Cleanup: Remove old URL columns in a later phase.

### Step 2: Hours Migration
1. Create `venue_hours` table.
2. Use a PL/pgSQL loop or script to parse existing `working_hours` JSONB.
3. Insert structured rows.
4. Verification: Query for "Open Now" venues and compare results.

### Step 3: Review Refactor
1. Add columns to `reviews`.
2. Update foreign keys (keep `venue_id` as a denormalized shortcut or remove it if `target_id` is reliable).
3. Update App UI to allow selecting "What are you reviewing?" if applicable.

## Scalability Considerations
- **Indexes**: Added B-tree indexes on `entity_id` and `entity_type` for media and reviews.
- **Triggers**: Automated data integrity for `updated_at` and `audit_logs`.
- **Querying**: Use PostgreSQL `VIEW`s to simplify frontend access to the new complex media structure (e.g., `venues_with_hero`).
