-- Migration: Fix search permissions and missing view
-- Description: Adds missing GRANT statements for search functions and ensures venues_with_coords view exists

-- 1. Create venues_with_coords view (used by getVenues and others)
CREATE OR REPLACE VIEW venues_with_coords AS
SELECT 
    v.*,
    COALESCE(v.latitude, ST_Y(v.location::geometry)) as latitude,
    COALESCE(v.longitude, ST_X(v.location::geometry)) as longitude
FROM venues v;

-- Grant permissions for the view
GRANT SELECT ON venues_with_coords TO anon, authenticated;

-- 2. Grant permissions for search_venues_advanced (12 parameters version)
GRANT EXECUTE ON FUNCTION search_venues_advanced(
    TEXT, -- p_query
    TEXT[], -- p_categories
    DOUBLE PRECISION, -- p_lat
    DOUBLE PRECISION, -- p_lng
    DOUBLE PRECISION, -- p_max_dist_meters
    BOOLEAN, -- p_only_verified
    BOOLEAN, -- p_only_preferred
    BOOLEAN, -- p_only_hygienic
    DOUBLE PRECISION, -- p_min_rating
    UUID, -- p_category_id
    TEXT, -- p_sort_by
    UUID[] -- p_service_ids
) TO anon, authenticated;

-- 3. Grant permissions for elastic_search_venues (13 parameters version)
GRANT EXECUTE ON FUNCTION elastic_search_venues(
    TEXT, -- p_query
    DOUBLE PRECISION, -- p_lat
    DOUBLE PRECISION, -- p_lng
    INTEGER, -- p_province_id
    UUID, -- p_district_id
    DOUBLE PRECISION, -- p_max_dist_meters
    BOOLEAN, -- p_only_verified
    BOOLEAN, -- p_only_preferred
    BOOLEAN, -- p_only_hygienic
    DOUBLE PRECISION, -- p_min_rating
    TEXT, -- p_sort_by
    INTEGER, -- p_limit
    UUID[] -- p_service_ids
) TO anon, authenticated;
