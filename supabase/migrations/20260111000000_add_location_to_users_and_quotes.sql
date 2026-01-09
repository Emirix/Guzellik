-- Migration: Add Location to Profiles and Quote Requests
-- Description: Adds province and district associations to users and quotes

-- 1. Update profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS province_id INTEGER REFERENCES public.provinces(id),
ADD COLUMN IF NOT EXISTS district_id UUID REFERENCES public.districts(id);

-- 2. Update quote_requests table
ALTER TABLE public.quote_requests
ADD COLUMN IF NOT EXISTS province_id INTEGER REFERENCES public.provinces(id),
ADD COLUMN IF NOT EXISTS district_id UUID REFERENCES public.districts(id);

-- 3. Update create_quote_request function
CREATE OR REPLACE FUNCTION create_quote_request(
  p_preferred_date DATE,
  p_preferred_time_slot TEXT,
  p_notes TEXT,
  p_service_category_ids UUID[],
  p_province_id INTEGER DEFAULT NULL,
  p_district_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_quote_request_id UUID;
  v_service_id UUID;
BEGIN
  -- Insert the quote request
  INSERT INTO public.quote_requests (
    user_id, 
    preferred_date, 
    preferred_time_slot, 
    notes, 
    province_id, 
    district_id
  )
  VALUES (
    auth.uid(), 
    p_preferred_date, 
    p_preferred_time_slot, 
    p_notes, 
    p_province_id, 
    p_district_id
  )
  RETURNING id INTO v_quote_request_id;

  -- Insert the services
  FOREACH v_service_id IN ARRAY p_service_category_ids
  LOOP
    INSERT INTO public.quote_request_services (quote_request_id, service_category_id)
    VALUES (v_quote_request_id, v_service_id);
  END LOOP;

  RETURN v_quote_request_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Re-grant permissions (optional but good practice when replacing functions)
GRANT EXECUTE ON FUNCTION create_quote_request(DATE, TEXT, TEXT, UUID[], INTEGER, UUID) TO authenticated;
