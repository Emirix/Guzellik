-- Migration: Migrate JSONB Working Hours to Structured Table
-- Description: Parses venues.working_hours JSONB and populates venue_hours table

DO $$
DECLARE
    v_venue RECORD;
    v_day_key TEXT;
    v_day_data JSONB;
    v_day_num INTEGER;
    v_open_time TIME;
    v_close_time TIME;
    v_is_closed BOOLEAN;
    v_migrated_count INTEGER := 0;
    v_error_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Starting working hours migration...';
    
    -- Map day names to day numbers (0=Sunday)
    -- Expected JSONB format: {"monday": {"open": "09:00", "close": "18:00", "closed": false}, ...}
    
    FOR v_venue IN 
        SELECT id, working_hours 
        FROM public.venues 
        WHERE working_hours IS NOT NULL 
        AND working_hours != 'null'::jsonb
        AND working_hours != '{}'::jsonb
    LOOP
        BEGIN
            -- Process each day
            FOR v_day_key IN SELECT jsonb_object_keys(v_venue.working_hours)
            LOOP
                -- Map day name to number
                v_day_num := CASE LOWER(v_day_key)
                    WHEN 'sunday' THEN 0
                    WHEN 'monday' THEN 1
                    WHEN 'tuesday' THEN 2
                    WHEN 'wednesday' THEN 3
                    WHEN 'thursday' THEN 4
                    WHEN 'friday' THEN 5
                    WHEN 'saturday' THEN 6
                    WHEN 'pazar' THEN 0
                    WHEN 'pazartesi' THEN 1
                    WHEN 'salı' THEN 2
                    WHEN 'çarşamba' THEN 3
                    WHEN 'perşembe' THEN 4
                    WHEN 'cuma' THEN 5
                    WHEN 'cumartesi' THEN 6
                    ELSE NULL
                END;
                
                IF v_day_num IS NULL THEN
                    RAISE NOTICE 'Unknown day name: % for venue %', v_day_key, v_venue.id;
                    CONTINUE;
                END IF;
                
                -- Get day data
                v_day_data := v_venue.working_hours -> v_day_key;
                
                -- Extract values with proper null handling
                v_is_closed := COALESCE((v_day_data ->> 'closed')::boolean, 
                                       (v_day_data ->> 'isClosed')::boolean,
                                       false);
                
                -- Only parse times if not closed
                IF NOT v_is_closed THEN
                    BEGIN
                        v_open_time := (v_day_data ->> 'open')::TIME;
                    EXCEPTION WHEN OTHERS THEN
                        v_open_time := NULL;
                    END;
                    
                    BEGIN
                        v_close_time := (v_day_data ->> 'close')::TIME;
                    EXCEPTION WHEN OTHERS THEN
                        v_close_time := NULL;
                    END;
                ELSE
                    v_open_time := NULL;
                    v_close_time := NULL;
                END IF;
                
                -- Insert into venue_hours
                INSERT INTO public.venue_hours (
                    venue_id, 
                    day_of_week, 
                    open_time, 
                    close_time, 
                    is_closed
                )
                VALUES (
                    v_venue.id,
                    v_day_num,
                    v_open_time,
                    v_close_time,
                    v_is_closed
                )
                ON CONFLICT (venue_id, day_of_week) 
                DO UPDATE SET
                    open_time = EXCLUDED.open_time,
                    close_time = EXCLUDED.close_time,
                    is_closed = EXCLUDED.is_closed,
                    updated_at = NOW();
                
            END LOOP;
            
            v_migrated_count := v_migrated_count + 1;
            
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Error migrating venue %: %', v_venue.id, SQLERRM;
                v_error_count := v_error_count + 1;
        END;
    END LOOP;
    
    RAISE NOTICE 'Working hours migration completed!';
    RAISE NOTICE '  - Successfully migrated: % venues', v_migrated_count;
    RAISE NOTICE '  - Errors: % venues', v_error_count;
    
END $$;

-- Verification query
DO $$
DECLARE
    total_hours INTEGER;
    total_venues_with_hours INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_hours FROM public.venue_hours;
    SELECT COUNT(DISTINCT venue_id) INTO total_venues_with_hours FROM public.venue_hours;
    
    RAISE NOTICE 'Migration Summary:';
    RAISE NOTICE '  - Total venue_hours records: %', total_hours;
    RAISE NOTICE '  - Venues with hours: %', total_venues_with_hours;
END $$;

-- Sample query to verify data
-- SELECT v.name, vh.day_of_week, vh.open_time, vh.close_time, vh.is_closed
-- FROM public.venues v
-- JOIN public.venue_hours vh ON v.id = vh.venue_id
-- ORDER BY v.name, vh.day_of_week
-- LIMIT 20;
