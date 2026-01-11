-- Migration: Add business account management
-- Description: Adds business account flags, subscription tracking, and related functions

-- Task 1.1: Update profiles table
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_business_account BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS business_venue_id UUID REFERENCES public.venues(id);

-- Task 1.2: Create business_subscriptions table
CREATE TABLE IF NOT EXISTS public.business_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  subscription_type TEXT NOT NULL DEFAULT 'standard',
  status TEXT NOT NULL DEFAULT 'active',
  started_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  features JSONB DEFAULT '{"campaigns": {"enabled": true}, "notifications": {"enabled": true}, "analytics": {"enabled": false}}'::jsonb,
  payment_method TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_business_subscriptions_profile_id ON public.business_subscriptions(profile_id);
CREATE INDEX IF NOT EXISTS idx_business_subscriptions_status ON public.business_subscriptions(status);

-- Task 1.3: RLS Policies
ALTER TABLE public.business_subscriptions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can see their own subscriptions
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'business_subscriptions' 
        AND policyname = 'Users can view their own subscriptions.'
    ) THEN
        CREATE POLICY "Users can view their own subscriptions."
          ON public.business_subscriptions FOR SELECT
          USING (auth.uid() = profile_id);
    END IF;
END $$;

-- Task 1.4: Database Functions (RPCs)
CREATE OR REPLACE FUNCTION get_business_subscription(p_profile_id UUID)
RETURNS SETOF public.business_subscriptions AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM public.business_subscriptions
  WHERE profile_id = p_profile_id
  ORDER BY created_at DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION check_business_feature(p_profile_id UUID, p_feature TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  v_features JSONB;
BEGIN
  SELECT features INTO v_features
  FROM public.business_subscriptions
  WHERE profile_id = p_profile_id AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1;
  
  IF v_features IS NULL THEN
    RETURN FALSE;
  END IF;
  
  RETURN COALESCE((v_features->p_feature->>'enabled')::BOOLEAN, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_business_venue(p_profile_id UUID)
RETURNS SETOF public.venues AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM public.venues
  WHERE owner_id = p_profile_id
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
