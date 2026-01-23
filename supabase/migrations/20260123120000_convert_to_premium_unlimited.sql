-- Migration: Convert to Premium Unlimited Subscription
-- Description: Converts all subscriptions to premium tier with unlimited features

-- 1. Upgrade all subscriptions to premium tier
UPDATE public.venues_subscription
SET subscription_type = 'premium',
    updated_at = timezone('utc'::text, now())
WHERE subscription_type IN ('standard', 'enterprise');

-- 2. Update campaigns limit to unlimited
UPDATE public.venues_subscription
SET features = jsonb_set(features, '{campaigns,monthly_limit}', '-1'::jsonb),
    updated_at = timezone('utc'::text, now())
WHERE subscription_type = 'premium';

-- 3. Update notifications limit to unlimited
UPDATE public.venues_subscription
SET features = jsonb_set(features, '{notifications,daily_limit}', '-1'::jsonb),
    updated_at = timezone('utc'::text, now())
WHERE subscription_type = 'premium';

-- 4. Update analytics to enterprise
UPDATE public.venues_subscription
SET features = jsonb_set(features, '{analytics,type}', '"enterprise"'::jsonb),
    updated_at = timezone('utc'::text, now())
WHERE subscription_type = 'premium';

-- 5. Update support to dedicated
UPDATE public.venues_subscription
SET features = jsonb_set(features, '{support,type}', '"dedicated"'::jsonb),
    updated_at = timezone('utc'::text, now())
WHERE subscription_type = 'premium';

-- 6. Enable featured listing
UPDATE public.venues_subscription
SET features = jsonb_set(features, '{featured_listing,enabled}', 'true'::jsonb),
    updated_at = timezone('utc'::text, now())
WHERE subscription_type = 'premium';

-- 7. Enable API access
UPDATE public.venues_subscription
SET features = jsonb_set(features, '{api_access,enabled}', 'true'::jsonb),
    updated_at = timezone('utc'::text, now())
WHERE features->'api_access' IS NULL;

-- 8. Enable multi location
UPDATE public.venues_subscription
SET features = jsonb_set(features, '{multi_location,enabled}', 'true'::jsonb),
    updated_at = timezone('utc'::text, now())
WHERE features->'multi_location' IS NULL;

-- 9. Ensure all feature objects have required fields for subscriptions with NULL or empty features
UPDATE public.venues_subscription
SET features = '{
  "campaigns": {"enabled": true, "monthly_limit": -1},
  "notifications": {"enabled": true, "daily_limit": -1},
  "analytics": {"enabled": true, "type": "enterprise"},
  "support": {"type": "dedicated"},
  "featured_listing": {"enabled": true},
  "api_access": {"enabled": true},
  "multi_location": {"enabled": true}
}'::jsonb,
  updated_at = timezone('utc'::text, now())
WHERE features IS NULL OR features = '{}'::jsonb;
