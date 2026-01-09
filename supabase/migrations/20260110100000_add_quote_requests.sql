-- Migration: Add Quote Request System
-- Description: Adds tables and functions for the quote request feature

-- 1. Create quote_requests table
CREATE TABLE IF NOT EXISTS public.quote_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  preferred_date DATE NOT NULL,
  preferred_time_slot TEXT, -- 'Sabah', 'Öğle', 'Akşam' or specific time
  notes TEXT,
  status TEXT DEFAULT 'active' NOT NULL, -- 'active', 'closed'
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (now() + INTERVAL '7 days') NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create quote_request_services table (for multiple services)
CREATE TABLE IF NOT EXISTS public.quote_request_services (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quote_request_id UUID REFERENCES public.quote_requests(id) ON DELETE CASCADE NOT NULL,
  service_category_id UUID REFERENCES public.service_categories(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create quote_responses table (for venue replies)
CREATE TABLE IF NOT EXISTS public.quote_responses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quote_request_id UUID REFERENCES public.quote_requests(id) ON DELETE CASCADE NOT NULL,
  venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE NOT NULL,
  price NUMERIC NOT NULL,
  message TEXT,
  status TEXT DEFAULT 'pending' NOT NULL, -- 'pending', 'accepted', 'rejected'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Enable RLS
ALTER TABLE public.quote_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quote_request_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quote_responses ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies
-- Users can manage their own quote requests
CREATE POLICY "Users can manage their own quote requests."
  ON public.quote_requests FOR ALL
  USING (auth.uid() = user_id);

-- Users can view their own quote request services
CREATE POLICY "Users can view their own quote request services."
  ON public.quote_request_services FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.quote_requests
    WHERE quote_requests.id = quote_request_services.quote_request_id
    AND quote_requests.user_id = auth.uid()
  ));

-- Users can view responses to their quote requests
CREATE POLICY "Users can view responses to their quote requests."
  ON public.quote_responses FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.quote_requests
    WHERE quote_requests.id = quote_responses.quote_request_id
    AND quote_requests.user_id = auth.uid()
  ));

-- 6. Helper function to create a quote request with services in a single transaction
CREATE OR REPLACE FUNCTION create_quote_request(
  p_preferred_date DATE,
  p_preferred_time_slot TEXT,
  p_notes TEXT,
  p_service_category_ids UUID[]
)
RETURNS UUID AS $$
DECLARE
  v_quote_request_id UUID;
  v_service_id UUID;
BEGIN
  -- Insert the quote request
  INSERT INTO public.quote_requests (user_id, preferred_date, preferred_time_slot, notes)
  VALUES (auth.uid(), p_preferred_date, p_preferred_time_slot, p_notes)
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

-- 7. Grant permissions
GRANT EXECUTE ON FUNCTION create_quote_request(DATE, TEXT, TEXT, UUID[]) TO authenticated;
