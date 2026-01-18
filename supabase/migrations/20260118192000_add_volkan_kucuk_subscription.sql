-- Add 1 year premium subscription for Kuaför By Volkan Küçük
-- Venue id: 45735d02-1459-48a4-8ca0-c9ae6e94e693
-- Owner id: ec67eff5-3fab-4b2e-a00c-6a7ae18c9e5a

BEGIN;

-- 1. Update Profile
UPDATE profiles 
SET 
    is_business_account = true,
    subscription_start_date = NOW(),
    subscription_end_date = NOW() + INTERVAL '1 year'
WHERE id = 'ec67eff5-3fab-4b2e-a00c-6a7ae18c9e5a';

-- 2. Update Venue
UPDATE venues 
SET 
    is_verified = true,
    is_preferred = true,
    is_hygienic = true,
    appointments_enabled = true,
    is_discover = true,
    is_active = true
WHERE id = '45735d02-1459-48a4-8ca0-c9ae6e94e693';

-- 3. Business Subscription (deprecated but kept for compatibility)
UPDATE business_subscriptions 
SET 
    subscription_type = 'premium',
    status = 'active',
    started_at = NOW(),
    expires_at = NOW() + INTERVAL '1 year',
    features = '{
      "campaigns": {"enabled": true, "monthly_limit": -1},
      "notifications": {"enabled": true, "daily_limit": 20},
      "analytics": {"enabled": true, "type": "advanced"},
      "support": {"type": "priority"},
      "featured_listing": {"enabled": true}
    }'::jsonb,
    updated_at = NOW()
WHERE profile_id = 'ec67eff5-3fab-4b2e-a00c-6a7ae18c9e5a';

-- 4. Venue Subscription (New system)
DELETE FROM venues_subscription WHERE venue_id = '45735d02-1459-48a4-8ca0-c9ae6e94e693';
INSERT INTO venues_subscription (
    venue_id, 
    subscription_type, 
    status, 
    started_at, 
    expires_at, 
    features
) VALUES (
    '45735d02-1459-48a4-8ca0-c9ae6e94e693',
    'premium',
    'active',
    NOW(),
    NOW() + INTERVAL '1 year',
    '{
      "campaigns": {"enabled": true, "monthly_limit": -1},
      "notifications": {"enabled": true, "daily_limit": 20},
      "analytics": {"enabled": true, "type": "advanced"},
      "support": {"type": "priority"},
      "featured_listing": {"enabled": true}
    }'::jsonb
);

-- 5. Venue Credits
INSERT INTO venue_credits (venue_id, balance)
VALUES ('45735d02-1459-48a4-8ca0-c9ae6e94e693', 1000)
ON CONFLICT (venue_id) DO UPDATE SET 
    balance = EXCLUDED.balance,
    updated_at = NOW();

COMMIT;
