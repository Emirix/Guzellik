-- Fix RLS policies to allow review photo uploads

-- 1. Drop existing restricted policy
DROP POLICY IF EXISTS "Authenticated users can insert entity_media" ON public.entity_media;

-- 2. Create updated policy including review_photo
CREATE POLICY "Authenticated users can insert entity_media"
    ON public.entity_media FOR INSERT
    TO authenticated
    WITH CHECK (
        -- Profile avatar
        (entity_type = 'profile_avatar' AND entity_id = auth.uid())
        OR
        -- Venue media (owner check)
        (entity_type IN ('venue_hero', 'venue_gallery') AND EXISTS (
            SELECT 1 FROM public.venues v WHERE v.id = entity_id AND v.owner_id = auth.uid()
        ))
        OR
        -- Specialist media (owner check via venue)
        (entity_type IN ('specialist_photo', 'specialist_certificate') AND EXISTS (
            SELECT 1 FROM public.specialists s
            JOIN public.venues v ON s.venue_id = v.id
            WHERE s.id = entity_id AND v.owner_id = auth.uid()
        ))
        OR
        -- Review media (Review owner check)
        (entity_type = 'review_photo' AND EXISTS (
            SELECT 1 FROM public.reviews r WHERE r.id = entity_id AND r.user_id = auth.uid()
        ))
    );
