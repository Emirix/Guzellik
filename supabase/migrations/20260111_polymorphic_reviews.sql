-- Migration: Polymorphic Review System
-- Description: Extends reviews table to support venues, services, and specialists

-- Add polymorphic columns to reviews table
ALTER TABLE public.reviews 
ADD COLUMN IF NOT EXISTS target_type TEXT NOT NULL DEFAULT 'venue',
ADD COLUMN IF NOT EXISTS target_id UUID;

-- Add constraint to ensure target_type is valid
ALTER TABLE public.reviews
ADD CONSTRAINT reviews_target_type_check 
CHECK (target_type IN ('venue', 'service', 'specialist'));

-- Migrate existing reviews to use target_id
UPDATE public.reviews 
SET target_id = venue_id 
WHERE target_type = 'venue' AND target_id IS NULL;

-- Make target_id NOT NULL after migration
ALTER TABLE public.reviews
ALTER COLUMN target_id SET NOT NULL;

-- Create indexes for polymorphic queries
CREATE INDEX IF NOT EXISTS idx_reviews_target ON public.reviews(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_reviews_target_rating ON public.reviews(target_type, target_id, rating);

-- Create a composite index for efficient aggregation
CREATE INDEX IF NOT EXISTS idx_reviews_target_composite ON public.reviews(target_type, target_id, rating, created_at DESC);

-- ========================================
-- Function: get_entity_reviews
-- Get all reviews for a specific entity
-- ========================================
CREATE OR REPLACE FUNCTION public.get_entity_reviews(
    p_target_type TEXT,
    p_target_id UUID,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    user_name TEXT,
    user_avatar TEXT,
    rating INTEGER,
    comment TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
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
        r.created_at,
        r.updated_at
    FROM public.reviews r
    LEFT JOIN public.profiles p ON r.user_id = p.id
    WHERE r.target_type = p_target_type
    AND r.target_id = p_target_id
    ORDER BY r.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- ========================================
-- Function: get_entity_rating_summary
-- Get rating summary for an entity
-- ========================================
CREATE OR REPLACE FUNCTION public.get_entity_rating_summary(
    p_target_type TEXT,
    p_target_id UUID
)
RETURNS TABLE (
    average_rating NUMERIC,
    total_reviews BIGINT,
    rating_distribution JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ROUND(AVG(rating)::NUMERIC, 2) AS average_rating,
        COUNT(*) AS total_reviews,
        jsonb_build_object(
            '5', COUNT(*) FILTER (WHERE rating = 5),
            '4', COUNT(*) FILTER (WHERE rating = 4),
            '3', COUNT(*) FILTER (WHERE rating = 3),
            '2', COUNT(*) FILTER (WHERE rating = 2),
            '1', COUNT(*) FILTER (WHERE rating = 1)
        ) AS rating_distribution
    FROM public.reviews
    WHERE target_type = p_target_type
    AND target_id = p_target_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- ========================================
-- Function: get_venue_comprehensive_rating
-- Get comprehensive rating for a venue including service and specialist ratings
-- ========================================
CREATE OR REPLACE FUNCTION public.get_venue_comprehensive_rating(p_venue_id UUID)
RETURNS TABLE (
    venue_rating NUMERIC,
    venue_review_count BIGINT,
    service_ratings JSONB,
    specialist_ratings JSONB
) AS $$
BEGIN
    RETURN QUERY
    WITH venue_stats AS (
        SELECT 
            ROUND(AVG(rating)::NUMERIC, 2) AS avg_rating,
            COUNT(*) AS review_count
        FROM public.reviews
        WHERE target_type = 'venue' AND target_id = p_venue_id
    ),
    service_stats AS (
        SELECT 
            jsonb_object_agg(
                vs.id::TEXT,
                jsonb_build_object(
                    'service_name', sc.name,
                    'average_rating', ROUND(AVG(r.rating)::NUMERIC, 2),
                    'review_count', COUNT(r.id)
                )
            ) AS ratings
        FROM public.venue_services vs
        JOIN public.service_categories sc ON vs.service_id = sc.id
        LEFT JOIN public.reviews r ON r.target_type = 'service' AND r.target_id = vs.id
        WHERE vs.venue_id = p_venue_id
        GROUP BY vs.id, sc.name
    ),
    specialist_stats AS (
        SELECT 
            jsonb_object_agg(
                s.id::TEXT,
                jsonb_build_object(
                    'specialist_name', s.name,
                    'average_rating', ROUND(AVG(r.rating)::NUMERIC, 2),
                    'review_count', COUNT(r.id)
                )
            ) AS ratings
        FROM public.specialists s
        LEFT JOIN public.reviews r ON r.target_type = 'specialist' AND r.target_id = s.id
        WHERE s.venue_id = p_venue_id
        GROUP BY s.id, s.name
    )
    SELECT 
        v.avg_rating,
        v.review_count,
        COALESCE(srv.ratings, '{}'::jsonb),
        COALESCE(spc.ratings, '{}'::jsonb)
    FROM venue_stats v
    CROSS JOIN service_stats srv
    CROSS JOIN specialist_stats spc;
END;
$$ LANGUAGE plpgsql STABLE;

-- Update RLS policies to support polymorphic reviews
DROP POLICY IF EXISTS "Users can insert their own reviews" ON public.reviews;
CREATE POLICY "Users can insert their own reviews"
    ON public.reviews FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own reviews" ON public.reviews;
CREATE POLICY "Users can update their own reviews"
    ON public.reviews FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own reviews" ON public.reviews;
CREATE POLICY "Users can delete their own reviews"
    ON public.reviews FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_entity_reviews(TEXT, UUID, INTEGER, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_entity_rating_summary(TEXT, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_venue_comprehensive_rating(UUID) TO anon, authenticated;

-- Add helpful comments
COMMENT ON COLUMN public.reviews.target_type IS 'Type of entity being reviewed: venue, service, or specialist';
COMMENT ON COLUMN public.reviews.target_id IS 'ID of the entity being reviewed';
COMMENT ON FUNCTION public.get_entity_reviews(TEXT, UUID, INTEGER, INTEGER) IS 'Get paginated reviews for any entity type';
COMMENT ON FUNCTION public.get_entity_rating_summary(TEXT, UUID) IS 'Get rating summary including average and distribution';
COMMENT ON FUNCTION public.get_venue_comprehensive_rating(UUID) IS 'Get comprehensive rating breakdown for a venue including services and specialists';
