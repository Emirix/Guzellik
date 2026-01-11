-- Migration: Venue Availability Helper Functions
-- Description: High-performance functions to check if a venue is currently open

-- ========================================
-- Function: is_venue_open
-- Check if a venue is currently open
-- ========================================
CREATE OR REPLACE FUNCTION public.is_venue_open(p_venue_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_day INTEGER;
    v_current_time TIME;
    v_hours RECORD;
BEGIN
    -- Get current day of week (0=Sunday)
    v_current_day := EXTRACT(DOW FROM NOW());
    
    -- Get current time
    v_current_time := NOW()::TIME;
    
    -- Get venue hours for current day
    SELECT * INTO v_hours
    FROM public.venue_hours
    WHERE venue_id = p_venue_id
    AND day_of_week = v_current_day;
    
    -- If no hours defined, assume closed
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- If marked as closed, return false
    IF v_hours.is_closed THEN
        RETURN false;
    END IF;
    
    -- If no times defined, assume closed
    IF v_hours.open_time IS NULL OR v_hours.close_time IS NULL THEN
        RETURN false;
    END IF;
    
    -- Check if current time is within opening hours
    -- Handle cases where close_time is before open_time (crosses midnight)
    IF v_hours.close_time > v_hours.open_time THEN
        -- Normal case: 09:00 - 18:00
        RETURN v_current_time >= v_hours.open_time AND v_current_time <= v_hours.close_time;
    ELSE
        -- Crosses midnight: 22:00 - 02:00
        RETURN v_current_time >= v_hours.open_time OR v_current_time <= v_hours.close_time;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

-- ========================================
-- Function: is_venue_open_at
-- Check if a venue is open at a specific date/time
-- ========================================
CREATE OR REPLACE FUNCTION public.is_venue_open_at(
    p_venue_id UUID,
    p_datetime TIMESTAMPTZ
)
RETURNS BOOLEAN AS $$
DECLARE
    v_day INTEGER;
    v_time TIME;
    v_hours RECORD;
BEGIN
    v_day := EXTRACT(DOW FROM p_datetime);
    v_time := p_datetime::TIME;
    
    SELECT * INTO v_hours
    FROM public.venue_hours
    WHERE venue_id = p_venue_id
    AND day_of_week = v_day;
    
    IF NOT FOUND OR v_hours.is_closed THEN
        RETURN false;
    END IF;
    
    IF v_hours.open_time IS NULL OR v_hours.close_time IS NULL THEN
        RETURN false;
    END IF;
    
    IF v_hours.close_time > v_hours.open_time THEN
        RETURN v_time >= v_hours.open_time AND v_time <= v_hours.close_time;
    ELSE
        RETURN v_time >= v_hours.open_time OR v_time <= v_hours.close_time;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

-- ========================================
-- Function: get_venue_hours_for_week
-- Get all hours for a venue for the entire week
-- ========================================
CREATE OR REPLACE FUNCTION public.get_venue_hours_for_week(p_venue_id UUID)
RETURNS TABLE (
    day_of_week INTEGER,
    day_name TEXT,
    open_time TIME,
    close_time TIME,
    is_closed BOOLEAN,
    is_open_now BOOLEAN
) AS $$
DECLARE
    v_current_day INTEGER;
    v_current_time TIME;
BEGIN
    v_current_day := EXTRACT(DOW FROM NOW());
    v_current_time := NOW()::TIME;
    
    RETURN QUERY
    WITH days AS (
        SELECT 
            generate_series(0, 6) AS day_num,
            CASE generate_series(0, 6)
                WHEN 0 THEN 'Pazar'
                WHEN 1 THEN 'Pazartesi'
                WHEN 2 THEN 'Salı'
                WHEN 3 THEN 'Çarşamba'
                WHEN 4 THEN 'Perşembe'
                WHEN 5 THEN 'Cuma'
                WHEN 6 THEN 'Cumartesi'
            END AS day_name_tr
    )
    SELECT 
        d.day_num,
        d.day_name_tr,
        vh.open_time,
        vh.close_time,
        COALESCE(vh.is_closed, true) AS is_closed,
        CASE 
            WHEN d.day_num = v_current_day AND NOT COALESCE(vh.is_closed, true) THEN
                CASE 
                    WHEN vh.close_time > vh.open_time THEN
                        v_current_time >= vh.open_time AND v_current_time <= vh.close_time
                    ELSE
                        v_current_time >= vh.open_time OR v_current_time <= vh.close_time
                END
            ELSE false
        END AS is_open_now
    FROM days d
    LEFT JOIN public.venue_hours vh ON vh.venue_id = p_venue_id AND vh.day_of_week = d.day_num
    ORDER BY d.day_num;
END;
$$ LANGUAGE plpgsql STABLE;

-- ========================================
-- Function: get_open_venues
-- Get all currently open venues (for filtering)
-- ========================================
CREATE OR REPLACE FUNCTION public.get_open_venues()
RETURNS TABLE (venue_id UUID) AS $$
DECLARE
    v_current_day INTEGER;
    v_current_time TIME;
BEGIN
    v_current_day := EXTRACT(DOW FROM NOW());
    v_current_time := NOW()::TIME;
    
    RETURN QUERY
    SELECT DISTINCT vh.venue_id
    FROM public.venue_hours vh
    WHERE vh.day_of_week = v_current_day
    AND vh.is_closed = false
    AND vh.open_time IS NOT NULL
    AND vh.close_time IS NOT NULL
    AND (
        -- Normal hours
        (vh.close_time > vh.open_time AND v_current_time >= vh.open_time AND v_current_time <= vh.close_time)
        OR
        -- Crosses midnight
        (vh.close_time < vh.open_time AND (v_current_time >= vh.open_time OR v_current_time <= vh.close_time))
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- Create indexes to optimize these functions
CREATE INDEX IF NOT EXISTS idx_venue_hours_current_day ON public.venue_hours(day_of_week, is_closed) 
    WHERE is_closed = false;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.is_venue_open(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_venue_open_at(UUID, TIMESTAMPTZ) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_venue_hours_for_week(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_open_venues() TO anon, authenticated;

-- Add helpful comments
COMMENT ON FUNCTION public.is_venue_open(UUID) IS 'Check if a venue is currently open based on current day and time';
COMMENT ON FUNCTION public.is_venue_open_at(UUID, TIMESTAMPTZ) IS 'Check if a venue is open at a specific date/time';
COMMENT ON FUNCTION public.get_venue_hours_for_week(UUID) IS 'Get all hours for a venue for the entire week with Turkish day names';
COMMENT ON FUNCTION public.get_open_venues() IS 'Get all currently open venue IDs for filtering';
