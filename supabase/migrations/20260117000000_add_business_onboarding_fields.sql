-- Add business onboarding fields to profiles table
-- These fields store temporary business information before venue creation

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS business_name TEXT,
ADD COLUMN IF NOT EXISTS business_type UUID REFERENCES venue_categories(id);

-- Add index for business type lookups
CREATE INDEX IF NOT EXISTS idx_profiles_business_type ON profiles(business_type);

-- Add 'trial' subscription type to business_subscriptions
ALTER TABLE business_subscriptions
DROP CONSTRAINT IF EXISTS business_subscriptions_subscription_type_check;

ALTER TABLE business_subscriptions
ADD CONSTRAINT business_subscriptions_subscription_type_check
CHECK (subscription_type IN ('trial', 'standard', 'premium', 'enterprise'));

-- Add comment for documentation
COMMENT ON COLUMN profiles.business_name IS 'Temporary storage for business name during onboarding, used to pre-fill venue creation form';
COMMENT ON COLUMN profiles.business_type IS 'Temporary storage for business category during onboarding, references venue_categories';
