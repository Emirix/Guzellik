-- Add status and reply columns to reviews
ALTER TABLE public.reviews
ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
ADD COLUMN IF NOT EXISTS business_reply TEXT,
ADD COLUMN IF NOT EXISTS reply_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS helpful_count INTEGER DEFAULT 0;

-- Create review reactions table for helpful votes
CREATE TABLE IF NOT EXISTS public.review_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
    reaction_type TEXT NOT NULL DEFAULT 'helpful', -- extensible for future reactions
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, review_id)
);

-- Enable RLS on review_reactions
ALTER TABLE public.review_reactions ENABLE ROW LEVEL SECURITY;

-- RLS for review_reactions
CREATE POLICY "Users can add reactions" ON public.review_reactions FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can remove their own reactions" ON public.review_reactions FOR DELETE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Anyone can view reactions" ON public.review_reactions FOR SELECT TO authenticated USING (true); -- or PUBLIC if needed

-- Update RLS for reviews to handle visibility
-- Existing policies might be "Public can view reviews". We need to restrict to 'approved' for general public.
-- Owners can see all reviews for their venues.
-- Users can see their own reviews regardless of status.

DROP POLICY IF EXISTS "Public reviews are viewable by everyone." ON public.reviews;
DROP POLICY IF EXISTS "Users can create reviews." ON public.reviews; -- Might need update
DROP POLICY IF EXISTS "Users can update own reviews." ON public.reviews;
DROP POLICY IF EXISTS "Users can delete own reviews." ON public.reviews;

-- New Policies
CREATE POLICY "Public APPROVED reviews are viewable by everyone" 
ON public.reviews FOR SELECT 
USING (status = 'approved');

CREATE POLICY "Users can view their OWN reviews" 
ON public.reviews FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);

CREATE POLICY "Venue owners can view ALL reviews for their venue" 
ON public.reviews FOR SELECT 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM public.venues v
    WHERE v.id = reviews.venue_id AND v.owner_id = auth.uid()
  )
);

-- Basic CRUD for users (unchanged mostly, but explicit)
CREATE POLICY "Users can create reviews" 
ON public.reviews FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id); -- Default status will be pending

CREATE POLICY "Users can update own reviews" 
ON public.reviews FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews" 
ON public.reviews FOR DELETE 
TO authenticated 
USING (auth.uid() = user_id);

-- Venue owners can update reviews (to approve/reply)
CREATE POLICY "Venue owners can update reviews" 
ON public.reviews FOR UPDATE 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM public.venues v
    WHERE v.id = reviews.venue_id AND v.owner_id = auth.uid()
  )
);

-- RPC: Toggle Helpful
CREATE OR REPLACE FUNCTION public.toggle_review_helpful(p_review_id UUID)
RETURNS void AS $$
DECLARE
  v_user_id UUID;
  v_exists BOOLEAN;
BEGIN
  v_user_id := auth.uid();
  
  -- Check if reaction exists
  SELECT EXISTS (
    SELECT 1 FROM public.review_reactions 
    WHERE user_id = v_user_id AND review_id = p_review_id
  ) INTO v_exists;

  IF v_exists THEN
    -- Remove reaction
    DELETE FROM public.review_reactions 
    WHERE user_id = v_user_id AND review_id = p_review_id;
    
    -- Decrement count
    UPDATE public.reviews 
    SET helpful_count = helpful_count - 1
    WHERE id = p_review_id;
  ELSE
    -- Add reaction
    INSERT INTO public.review_reactions (user_id, review_id)
    VALUES (v_user_id, p_review_id);
    
    -- Increment count
    UPDATE public.reviews 
    SET helpful_count = helpful_count + 1
    WHERE id = p_review_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Approve Review (and optional Reply)
CREATE OR REPLACE FUNCTION public.approve_review(
  p_review_id UUID,
  p_reply_text TEXT DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  v_venue_id UUID;
  v_owner_id UUID;
BEGIN
  -- Get review details to verify ownership
  SELECT venue_id INTO v_venue_id FROM public.reviews WHERE id = p_review_id;
  
  -- Check if caller is owner of the venue
  SELECT owner_id INTO v_owner_id FROM public.venues WHERE id = v_venue_id;
  
  IF v_owner_id != auth.uid() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  -- Update review
  UPDATE public.reviews
  SET 
    status = 'approved',
    business_reply = COALESCE(p_reply_text, business_reply),
    reply_at = CASE WHEN p_reply_text IS NOT NULL THEN NOW() ELSE reply_at END
  WHERE id = p_review_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC: Get Venue Reviews (Advanced Filtering)
CREATE OR REPLACE FUNCTION public.get_venue_reviews_advanced(
  p_venue_id UUID,
  p_sort_by TEXT DEFAULT 'newest', -- 'newest', 'oldest', 'highest_rated', 'lowest_rated', 'most_helpful'
  p_filter_rating INTEGER DEFAULT NULL,
  p_filter_has_photos BOOLEAN DEFAULT FALSE,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  user_name TEXT,
  user_avatar TEXT,
  rating NUMERIC,
  comment TEXT,
  photos TEXT[], -- Assuming photos are stored in reviews.photos or need to join entity_media?
                 -- Wait, reviews table doesn't have photos column in the definition I saw? 
                 -- It uses entity_media now!
  created_at TIMESTAMPTZ,
  helpful_count INTEGER,
  business_reply TEXT,
  reply_at TIMESTAMPTZ,
  is_verified BOOLEAN -- Assuming logic for verification exists or just false for now
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.user_id,
    p.full_name AS user_name,
    p.avatar_url AS user_avatar,
    r.rating,
    r.comment,
    ARRAY(
      SELECT m.storage_path 
      FROM public.entity_media em
      JOIN public.media m ON em.media_id = m.id
      WHERE em.entity_id = r.id AND em.entity_type = 'review_photo'
    ) AS photos,
    r.created_at,
    r.helpful_count,
    r.business_reply,
    r.reply_at,
    FALSE AS is_verified -- Placeholder until verification logic is finalized
  FROM public.reviews r
  JOIN public.profiles p ON r.user_id = p.id
  WHERE r.venue_id = p_venue_id
    AND r.status = 'approved'
    AND (p_filter_rating IS NULL OR r.rating = p_filter_rating)
    AND (
      NOT p_filter_has_photos OR EXISTS (
        SELECT 1 FROM public.entity_media em
        WHERE em.entity_id = r.id AND em.entity_type = 'review_photo'
      )
    )
  ORDER BY
    CASE WHEN p_sort_by = 'newest' THEN r.created_at END DESC,
    CASE WHEN p_sort_by = 'oldest' THEN r.created_at END ASC,
    CASE WHEN p_sort_by = 'highest_rated' THEN r.rating END DESC,
    CASE WHEN p_sort_by = 'lowest_rated' THEN r.rating END ASC,
    CASE WHEN p_sort_by = 'most_helpful' THEN r.helpful_count END DESC,
    r.created_at DESC -- Default tie breaker
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;
