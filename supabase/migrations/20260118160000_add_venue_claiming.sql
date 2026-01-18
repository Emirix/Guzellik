-- Migration: Add venue claiming process
-- Description: Creates table for venue claim requests and handles status updates

-- Create venue claim requests table
CREATE TABLE IF NOT EXISTS public.venue_claim_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    documents TEXT[], -- Array of document URLs for verification
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    
    -- Ensure a user can only have one pending request for a specific venue
    CONSTRAINT unique_pending_claim UNIQUE (profile_id, venue_id, status)
);

-- RLS for venue claim requests
ALTER TABLE public.venue_claim_requests ENABLE ROW LEVEL SECURITY;

-- Users can view their own claim requests
CREATE POLICY "Users can view their own claim requests"
ON public.venue_claim_requests FOR SELECT
USING (auth.uid() = profile_id);

-- Users can create claim requests
CREATE POLICY "Users can create claim requests"
ON public.venue_claim_requests FOR INSERT
WITH CHECK (auth.uid() = profile_id);

-- Trigger for updated_at
CREATE TRIGGER set_venue_claim_requests_updated_at
    BEFORE UPDATE ON public.venue_claim_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Documentation:
-- 1. User searches for a venue
-- 2. User submits a claim request with documents
-- 3. Admin reviews and approves the request
-- 4. On approval, update venues table to set owner_id = profile_id
