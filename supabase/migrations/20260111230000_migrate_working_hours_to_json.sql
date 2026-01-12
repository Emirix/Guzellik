-- Migration: Migrate venue_hours back to venues.working_hours JSON and cleanup
-- Description: Consolidates working hours into venues table and removes the legacy table

DO $$
DECLARE
    v_venue_id UUID;
    v_working_hours JSONB;
BEGIN
    RAISE NOTICE 'Starting migration of venue_hours to venues.working_hours JSON...';

    FOR v_venue_id IN SELECT DISTINCT venue_id FROM public.venue_hours
    LOOP
        -- Build JSONB for each venue
        SELECT 
            jsonb_object_agg(
                CASE day_of_week
                    WHEN 0 THEN 'sunday'
                    WHEN 1 THEN 'monday'
                    WHEN 2 THEN 'tuesday'
                    WHEN 3 THEN 'wednesday'
                    WHEN 4 THEN 'thursday'
                    WHEN 5 THEN 'friday'
                    WHEN 6 THEN 'saturday'
                END,
                jsonb_build_object(
                    'open', NOT is_closed,
                    'start', COALESCE(open_time::text, '09:00'),
                    'end', COALESCE(close_time::text, '20:00')
                )
            ) INTO v_working_hours
        FROM public.venue_hours
        WHERE venue_id = v_venue_id;

        -- Update venues table
        UPDATE public.venues
        SET working_hours = v_working_hours
        WHERE id = v_venue_id;
    END LOOP;

    RAISE NOTICE 'Data migration completed.';
END $$;

-- Update database functions to use JSON column

-- 1. is_venue_open
CREATE OR REPLACE FUNCTION public.is_venue_open(p_venue_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_working_hours JSONB;
    v_day_num INTEGER;
    v_day_key TEXT;
    v_day_data JSONB;
    v_current_time TIME;
    v_open BOOLEAN;
    v_start TIME;
    v_end TIME;
BEGIN
    -- Get current day number (0=Sunday)
    v_day_num := EXTRACT(DOW FROM NOW());
    v_day_key := CASE v_day_num
        WHEN 0 THEN 'sunday'
        WHEN 1 THEN 'monday'
        WHEN 2 THEN 'tuesday'
        WHEN 3 THEN 'wednesday'
        WHEN 4 THEN 'thursday'
        WHEN 5 THEN 'friday'
        WHEN 6 THEN 'saturday'
    END;
    
    v_current_time := NOW()::TIME;
    
    -- Get working hours JSON
    SELECT working_hours INTO v_working_hours
    FROM public.venues
    WHERE id = p_venue_id;
    
    IF v_working_hours IS NULL OR v_working_hours = '{}'::jsonb THEN
        RETURN false;
    END IF;
    
    -- Get data for today
    v_day_data := v_working_hours -> v_day_key;
    
    IF v_day_data IS NULL THEN
        RETURN false;
    END IF;
    
    -- Parse values
    BEGIN
        v_open := (v_day_data ->> 'open')::BOOLEAN;
    EXCEPTION WHEN OTHERS THEN
        v_open := false;
    END;
    
    IF NOT COALESCE(v_open, false) THEN
        RETURN false;
    END IF;
    
    BEGIN
        v_start := (v_day_data ->> 'start')::TIME;
        v_end := (v_day_data ->> 'end')::TIME;
    EXCEPTION WHEN OTHERS THEN
        RETURN false;
    END;
    
    IF v_start IS NULL OR v_end IS NULL THEN
        RETURN false;
    END IF;
    
    -- Check if open
    IF v_end > v_start THEN
        RETURN v_current_time >= v_start AND v_current_time <= v_end;
    ELSE
        RETURN v_current_time >= v_start OR v_current_time <= v_end;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

-- 2. is_venue_open_at
CREATE OR REPLACE FUNCTION public.is_venue_open_at(
    p_venue_id UUID,
    p_datetime TIMESTAMPTZ
)
RETURNS BOOLEAN AS $$
DECLARE
    v_working_hours JSONB;
    v_day_num INTEGER;
    v_day_key TEXT;
    v_day_data JSONB;
    v_time TIME;
    v_open BOOLEAN;
    v_start TIME;
    v_end TIME;
BEGIN
    v_day_num := EXTRACT(DOW FROM p_datetime);
    v_day_key := CASE v_day_num
        WHEN 0 THEN 'sunday'
        WHEN 1 THEN 'monday'
        WHEN 2 THEN 'tuesday'
        WHEN 3 THEN 'wednesday'
        WHEN 4 THEN 'thursday'
        WHEN 5 THEN 'friday'
        WHEN 6 THEN 'saturday'
    END;
    
    v_time := p_datetime::TIME;
    
    SELECT working_hours INTO v_working_hours
    FROM public.venues
    WHERE id = p_venue_id;
    
    IF v_working_hours IS NULL THEN RETURN false; END IF;
    
    v_day_data := v_working_hours -> v_day_key;
    IF v_day_data IS NULL THEN RETURN false; END IF;
    
    BEGIN
        v_open := (v_day_data ->> 'open')::BOOLEAN;
    EXCEPTION WHEN OTHERS THEN
        v_open := false;
    END;
    
    IF NOT COALESCE(v_open, false) THEN RETURN false; END IF;
    
    BEGIN
        v_start := (v_day_data ->> 'start')::TIME;
        v_end := (v_day_data ->> 'end')::TIME;
    EXCEPTION WHEN OTHERS THEN
        RETURN false;
    END;
    
    IF v_start IS NULL OR v_end IS NULL THEN RETURN false; END IF;
    
    IF v_end > v_start THEN
        RETURN v_time >= v_start AND v_time <= v_end;
    ELSE
        RETURN v_time >= v_start OR v_time <= v_end;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

-- 3. get_venue_hours_for_week
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
    v_working_hours JSONB;
    v_current_day INTEGER;
    v_current_time TIME;
BEGIN
    v_current_day := EXTRACT(DOW FROM NOW());
    v_current_time := NOW()::TIME;
    
    SELECT working_hours INTO v_working_hours
    FROM public.venues
    WHERE id = p_venue_id;
    
    RETURN QUERY
    WITH days AS (
        SELECT 0 as d, 'Pazar' as n, 'sunday' as k UNION ALL
        SELECT 1, 'Pazartesi', 'monday' UNION ALL
        SELECT 2, 'Salı', 'tuesday' UNION ALL
        SELECT 3, 'Çarşamba', 'wednesday' UNION ALL
        SELECT 4, 'Perşembe', 'thursday' UNION ALL
        SELECT 5, 'Cuma', 'friday' UNION ALL
        SELECT 6, 'Cumartesi', 'saturday'
    )
    SELECT 
        d.d,
        d.n,
        (v_working_hours -> d.k ->> 'start')::TIME,
        (v_working_hours -> d.k ->> 'end')::TIME,
        NOT COALESCE((v_working_hours -> d.k ->> 'open')::BOOLEAN, false),
        CASE 
            WHEN d.d = v_current_day AND COALESCE((v_working_hours -> d.k ->> 'open')::BOOLEAN, false) THEN
                CASE 
                    WHEN (v_working_hours -> d.k ->> 'end')::TIME > (v_working_hours -> d.k ->> 'start')::TIME THEN
                        v_current_time >= (v_working_hours -> d.k ->> 'start')::TIME AND v_current_time <= (v_working_hours -> d.k ->> 'end')::TIME
                    ELSE
                        v_current_time >= (v_working_hours -> d.k ->> 'start')::TIME OR v_current_time <= (v_working_hours -> d.k ->> 'end')::TIME
                END
            ELSE false
        END AS is_open_now
    FROM days d
    ORDER BY d.d;
END;
$$ LANGUAGE plpgsql STABLE;

-- 4. get_open_venues
CREATE OR REPLACE FUNCTION public.get_open_venues()
RETURNS TABLE (venue_id UUID) AS $$
DECLARE
    v_day_num INTEGER;
    v_day_key TEXT;
    v_current_time TIME;
BEGIN
    v_day_num := EXTRACT(DOW FROM NOW());
    v_day_key := CASE v_day_num
        WHEN 0 THEN 'sunday'
        WHEN 1 THEN 'monday'
        WHEN 2 THEN 'tuesday'
        WHEN 3 THEN 'wednesday'
        WHEN 4 THEN 'thursday'
        WHEN 5 THEN 'friday'
        WHEN 6 THEN 'saturday'
    END;
    v_current_time := NOW()::TIME;
    
    RETURN QUERY
    SELECT id
    FROM public.venues
    WHERE 
        COALESCE((working_hours -> v_day_key ->> 'open')::BOOLEAN, false) = true
        AND (
            CASE 
                WHEN (working_hours -> v_day_key ->> 'end')::TIME > (working_hours -> v_day_key ->> 'start')::TIME THEN
                    v_current_time >= (working_hours -> v_day_key ->> 'start')::TIME AND v_current_time <= (working_hours -> v_day_key ->> 'end')::TIME
                ELSE
                    v_current_time >= (working_hours -> v_day_key ->> 'start')::TIME OR v_current_time <= (working_hours -> v_day_key ->> 'end')::TIME
            END
        );
END;
$$ LANGUAGE plpgsql STABLE;

-- Drop legacy table and related objects
DROP TABLE IF EXISTS public.venue_hours CASCADE;
DROP FUNCTION IF EXISTS public.update_venue_hours_updated_at CASCADE;

COMMENT ON COLUMN public.venues.working_hours IS 'Venue opening hours stored as JSONB. Format: {"monday": {"open": true, "start": "09:00", "end": "20:00"}, ...}';
