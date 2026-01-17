-- Add 1 year premium subscription for Ebruli Kuaför
-- Owner id: 3cdcc960-5b1c-49b9-adb1-6066b43e9434
-- Venue id: 9369b06a-b714-475d-b0fd-3255db868b4a

BEGIN;

-- 1. Update Profile
UPDATE profiles 
SET 
    is_business_account = true,
    subscription_start_date = NOW(),
    subscription_end_date = NOW() + INTERVAL '1 year'
WHERE id = '3cdcc960-5b1c-49b9-adb1-6066b43e9434';

-- 2. Update Venue
UPDATE venues 
SET 
    is_verified = true,
    is_preferred = true,
    is_hygienic = true,
    appointments_enabled = true,
    is_discover = true,
    is_active = true
WHERE id = '9369b06a-b714-475d-b0fd-3255db868b4a';

-- 3. Business Subscription
UPDATE business_subscriptions 
SET 
    subscription_type = 'premium',
    status = 'active',
    started_at = NOW(),
    expires_at = NOW() + INTERVAL '1 year',
    features = '{"analytics": true, "campaigns": true, "team_management": true, "featured_listing": true, "priority_support": true, "unlimited_campaigns": true, "advanced_analytics": true}'::jsonb,
    updated_at = NOW()
WHERE profile_id = '3cdcc960-5b1c-49b9-adb1-6066b43e9434';

-- 4. Venue Subscription
DELETE FROM venues_subscription WHERE venue_id = '9369b06a-b714-475d-b0fd-3255db868b4a';
INSERT INTO venues_subscription (
    venue_id, 
    subscription_type, 
    status, 
    started_at, 
    expires_at, 
    features
) VALUES (
    '9369b06a-b714-475d-b0fd-3255db868b4a',
    'premium',
    'active',
    NOW(),
    NOW() + INTERVAL '1 year',
    '{"analytics": true, "campaigns": true, "team_management": true, "featured_listing": true, "priority_support": true, "unlimited_campaigns": true, "advanced_analytics": true}'::jsonb
);

-- 5. Venue Credits
INSERT INTO venue_credits (venue_id, balance)
VALUES ('9369b06a-b714-475d-b0fd-3255db868b4a', 10000)
ON CONFLICT (venue_id) DO UPDATE SET 
    balance = EXCLUDED.balance,
    updated_at = NOW();

COMMIT;
