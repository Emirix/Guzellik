-- Migration: Migrate from business_subscriptions to venues_subscription
-- Description: Creates a new venues_subscription table linked to venue_id and migrates data.

-- 1. Create venues_subscription table
CREATE TABLE IF NOT EXISTS public.venues_subscription (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE NOT NULL,
  subscription_type TEXT NOT NULL DEFAULT 'standard',
  status TEXT NOT NULL DEFAULT 'active',
  started_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  features JSONB DEFAULT '{"campaigns": {"enabled": true}, "notifications": {"enabled": true}, "analytics": {"enabled": false}}'::jsonb,
  payment_method TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Indexes for performance
CREATE INDEX IF NOT EXISTS idx_venues_subscription_venue_id ON public.venues_subscription(venue_id);
CREATE INDEX IF NOT EXISTS idx_venues_subscription_status ON public.venues_subscription(status);

-- 3. RLS Policies
ALTER TABLE public.venues_subscription ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can view subscriptions for venues they own
CREATE POLICY "Users can view their own venue subscriptions."
  ON public.venues_subscription FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.venues v
      WHERE v.id = venue_id AND v.owner_id = auth.uid()
    )
  );

-- 4. Migrate data from business_subscriptions to venues_subscription
-- Since business_subscriptions was linked to profile_id, and venues are linked to owner_id,
-- we map them. Note: If a user has multiple venues, we pick the first one created or just all of them?
-- Usually 1 owner = 1 business in this context, but let's be safe.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'business_subscriptions') THEN
    INSERT INTO public.venues_subscription (venue_id, subscription_type, status, started_at, expires_at, features, created_at, updated_at)
    SELECT v.id, bs.subscription_type, bs.status, bs.started_at, bs.expires_at, bs.features, bs.created_at, bs.updated_at
    FROM public.business_subscriptions bs
    JOIN public.venues v ON v.owner_id = bs.profile_id;
  END IF;
END $$;

-- 5. Update is_venue_subscribed function
CREATE OR REPLACE FUNCTION public.is_venue_subscribed(p_venue_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.venues_subscription vs 
    WHERE vs.venue_id = p_venue_id
      AND vs.status = 'active'
      AND (vs.expires_at IS NULL OR vs.expires_at > timezone('utc'::text, now()))
  );
END;
$function$;

-- 6. Update RPCs
CREATE OR REPLACE FUNCTION get_business_subscription(p_profile_id UUID)
RETURNS SETOF public.venues_subscription AS $$
BEGIN
  RETURN QUERY
  SELECT vs.* 
  FROM public.venues_subscription vs
  JOIN public.venues v ON v.id = vs.venue_id
  WHERE v.owner_id = p_profile_id
  ORDER BY vs.created_at DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION check_business_feature(p_profile_id UUID, p_feature TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  v_features JSONB;
BEGIN
  SELECT vs.features INTO v_features
  FROM public.venues_subscription vs
  JOIN public.venues v ON v.id = vs.venue_id
  WHERE v.owner_id = p_profile_id AND vs.status = 'active'
  ORDER BY vs.created_at DESC
  LIMIT 1;
  
  IF v_features IS NULL THEN
    RETURN FALSE;
  END IF;
  
  RETURN COALESCE((v_features->p_feature->>'enabled')::BOOLEAN, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. View updates (get_nearby_venues and search_venues_advanced already use is_venue_subscribed, so they are fine)

-- 8. Clean up (Optional: Drop old table after verification, but let's keep it for safety in this migration step)
-- DROP TABLE IF EXISTS public.business_subscriptions;
