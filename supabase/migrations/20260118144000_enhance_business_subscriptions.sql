-- Migration: Enhance venue subscriptions with tiers and feature gating
-- Description: Adds subscription_tier enum and updates venues_subscription table

-- Create subscription tier enum
DO $$ BEGIN
    CREATE TYPE public.subscription_tier AS ENUM ('standard', 'premium', 'enterprise');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Update venues_subscription table
-- First, ensure the columns exist and have correct types
ALTER TABLE public.venues_subscription 
  ALTER COLUMN subscription_type TYPE TEXT; -- Temporarily ensure it's text for migration if needed

-- Set default features for standard if not set
UPDATE public.venues_subscription
SET features = '{
  "campaigns": {"enabled": true, "monthly_limit": 3},
  "notifications": {"enabled": true, "daily_limit": 5},
  "analytics": {"enabled": true, "type": "basic"},
  "support": {"type": "email"},
  "featured_listing": {"enabled": false}
}'::jsonb
WHERE subscription_type = 'standard' AND (features IS NULL OR features = '{}'::jsonb);

-- Set default features for premium
UPDATE public.venues_subscription
SET features = '{
  "campaigns": {"enabled": true, "monthly_limit": -1},
  "notifications": {"enabled": true, "daily_limit": 20},
  "analytics": {"enabled": true, "type": "advanced"},
  "support": {"type": "priority"},
  "featured_listing": {"enabled": true}
}'::jsonb
WHERE subscription_type = 'premium';

-- Set default features for enterprise
UPDATE public.venues_subscription
SET features = '{
  "campaigns": {"enabled": true, "monthly_limit": -1},
  "notifications": {"enabled": true, "daily_limit": -1},
  "analytics": {"enabled": true, "type": "enterprise"},
  "support": {"type": "dedicated"},
  "featured_listing": {"enabled": true},
  "api_access": {"enabled": true},
  "multi_location": {"enabled": true}
}'::jsonb
WHERE subscription_type = 'enterprise';

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_venues_subscription_expires_at ON public.venues_subscription(expires_at);
CREATE INDEX IF NOT EXISTS idx_venues_subscription_subscription_type ON public.venues_subscription(subscription_type);
