---
status: proposed
created: 2026-01-16
author: AI Assistant
---

# Business Account Management Specification

## Purpose
Define the business account system that enables venue owners to manage their businesses, access premium features, handle subscriptions, and utilize the admin dashboard.

## Requirements

### Requirement: Business Account Detection
The system SHALL identify and differentiate business accounts from regular user accounts.

#### Scenario: Check if user is business owner
- **GIVEN** a logged-in user
- **WHEN** the app checks the user's account type
- **THEN** the system SHALL query the `profiles` table for `is_business_account` flag
- **AND** if true, the system SHALL load business-specific features

#### Scenario: Business account navigation
- **GIVEN** a user with `is_business_account = true`
- **WHEN** the user opens the app
- **THEN** the bottom navigation SHALL display business mode tabs
- **AND** the user SHALL have access to the admin dashboard

---

### Requirement: Business Account Conversion
The system SHALL allow regular users to convert their accounts to business accounts.

#### Scenario: Initiate conversion from settings
- **GIVEN** a regular user in the profile/settings screen
- **WHEN** the user taps "İşletme Hesabına Geç"
- **THEN** the user SHALL be shown an overview of business features
- **AND** the user SHALL be presented with subscription plan options

#### Scenario: Select subscription plan
- **GIVEN** a user viewing subscription plans
- **WHEN** the user selects a plan (Standard, Premium, or Enterprise)
- **THEN** the plan details SHALL be displayed (features, price, duration)
- **AND** the user SHALL be able to proceed to payment/setup

#### Scenario: Complete business account setup
- **GIVEN** a user has selected a subscription plan
- **WHEN** the user completes the setup process
- **THEN** the user's `is_business_account` flag SHALL be set to true
- **AND** a subscription record SHALL be created in `business_subscriptions`
- **AND** the user SHALL be prompted to claim or create a venue
- **AND** the user SHALL be redirected to the business dashboard

---

### Requirement: Venue Claiming
The system SHALL allow business owners to claim existing venues or create new ones.

#### Scenario: Claim existing venue
- **GIVEN** a new business account without a venue
- **WHEN** the user searches for their venue by name
- **THEN** matching venues SHALL be displayed
- **WHEN** the user selects their venue and submits verification documents
- **THEN** a claim request SHALL be created for admin approval
- **AND** the user SHALL be notified when the claim is approved

#### Scenario: Create new venue
- **GIVEN** a business account user who cannot find their venue
- **WHEN** the user chooses to create a new venue
- **THEN** the user SHALL be prompted to enter venue details (name, category, address, etc.)
- **WHEN** the user submits the new venue
- **THEN** the venue SHALL be created in the `venues` table
- **AND** the `business_venue_id` SHALL be set in the user's profile
- **AND** the user SHALL have full admin access to the venue

---

### Requirement: Subscription Management
The system SHALL manage business subscriptions with different tiers and features.

#### Scenario: Active subscription
- **GIVEN** a business account with an active subscription
- **WHEN** the subscription is queried
- **THEN** the system SHALL return the subscription details
- **AND** the `status` SHALL be 'active'
- **AND** the `expires_at` SHALL be in the future

#### Scenario: Subscription expiration
- **GIVEN** a business subscription with `expires_at` in the past
- **WHEN** the system checks subscription status
- **THEN** the subscription `status` SHALL be updated to 'expired'
- **AND** the user SHALL be notified via email and in-app notification
- **AND** premium features SHALL be disabled

#### Scenario: Subscription renewal
- **GIVEN** a business account with an expiring subscription
- **WHEN** the user renews the subscription
- **THEN** a new subscription period SHALL be created
- **AND** the `expires_at` SHALL be extended by the subscription duration
- **AND** the `status` SHALL be set to 'active'

---

### Requirement: Feature Gating
The system SHALL control access to features based on subscription tier.

#### Scenario: Check feature access
- **GIVEN** a business account attempting to use a feature
- **WHEN** the system checks feature access
- **THEN** the subscription's `features` JSONB SHALL be queried
- **AND** if the feature is enabled, access SHALL be granted
- **AND** if the feature is disabled, an upgrade prompt SHALL be shown

#### Scenario: Standard plan features
- **GIVEN** a business account with Standard subscription
- **THEN** the following features SHALL be available:
  - Basic venue profile management
  - Up to 3 campaigns per month
  - Basic analytics
  - Email support

#### Scenario: Premium plan features
- **GIVEN** a business account with Premium subscription
- **THEN** the following features SHALL be available:
  - All Standard features
  - Unlimited campaigns
  - Advanced analytics
  - Priority support
  - Featured listing
  - Custom branding

#### Scenario: Enterprise plan features
- **GIVEN** a business account with Enterprise subscription
- **THEN** the following features SHALL be available:
  - All Premium features
  - Multi-location management
  - API access
  - Dedicated account manager
  - Custom integrations

---

### Requirement: Admin Dashboard Access
The system SHALL provide business owners with an admin dashboard to manage their venue.

#### Scenario: Access admin dashboard
- **GIVEN** a business account with a claimed venue
- **WHEN** the user navigates to the admin dashboard
- **THEN** the dashboard SHALL display:
  - Venue overview (views, followers, rating)
  - Quick actions (edit profile, manage services, create campaign)
  - Recent activity
  - Subscription status

#### Scenario: Manage venue information
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user taps "Mekan Bilgileri"
- **THEN** the user SHALL be able to edit:
  - Basic info (name, description, phone, email)
  - Address and location
  - Working hours
  - Social media links
  - Payment options
  - Accessibility features

#### Scenario: Manage services
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user taps "Hizmetler"
- **THEN** the user SHALL be able to:
  - Add new services
  - Edit existing services (name, price, duration)
  - Delete services
  - Reorder services

#### Scenario: Manage specialists
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user taps "Uzmanlar"
- **THEN** the user SHALL be able to:
  - Add new specialists (name, photo, bio, specialization)
  - Edit specialist information
  - Delete specialists
  - Assign services to specialists

#### Scenario: Manage gallery
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user taps "Galeri"
- **THEN** the user SHALL be able to:
  - Upload new photos
  - Delete photos
  - Reorder photos
  - Set cover photo
  - Add photo descriptions

---

### Requirement: Campaign Management
The system SHALL allow business owners to create and manage promotional campaigns.

#### Scenario: Create campaign
- **GIVEN** a business owner with available campaign credits
- **WHEN** the user creates a new campaign
- **THEN** the campaign SHALL be saved to the `campaigns` table
- **AND** the campaign credit SHALL be deducted
- **AND** followers SHALL receive a push notification
- **AND** the campaign SHALL appear in the campaigns feed

#### Scenario: Campaign credit limit
- **GIVEN** a business owner with Standard subscription (3 campaigns/month)
- **WHEN** the user has already created 3 campaigns this month
- **THEN** the "Create Campaign" button SHALL be disabled
- **AND** an upgrade prompt SHALL be displayed

#### Scenario: Edit campaign
- **GIVEN** a business owner viewing their campaigns
- **WHEN** the user edits an active campaign
- **THEN** the campaign details SHALL be updated
- **AND** the `updated_at` timestamp SHALL be set

#### Scenario: Delete campaign
- **GIVEN** a business owner viewing their campaigns
- **WHEN** the user deletes a campaign
- **THEN** the campaign SHALL be removed from the database
- **AND** the campaign credit SHALL be refunded (if within 24 hours)

---

### Requirement: Credit System
The system SHALL manage credits for campaigns and premium features.

#### Scenario: View credit balance
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user views their credit balance
- **THEN** the current credit balance SHALL be displayed
- **AND** the credit usage history SHALL be shown

#### Scenario: Purchase credit packages
- **GIVEN** a business owner with low credits
- **WHEN** the user navigates to the store
- **THEN** credit packages SHALL be displayed (e.g., 10 credits for ₺99)
- **WHEN** the user purchases a package
- **THEN** the credits SHALL be added to the user's balance
- **AND** a transaction record SHALL be created

#### Scenario: Deduct credits for campaign
- **GIVEN** a business owner creating a campaign
- **WHEN** the campaign is published
- **THEN** 1 credit SHALL be deducted from the user's balance
- **AND** a transaction record SHALL be created

---

### Requirement: Analytics and Insights
The system SHALL provide business owners with analytics about their venue performance.

#### Scenario: View venue analytics
- **GIVEN** a business owner in the admin dashboard
- **WHEN** the user taps "Analitik"
- **THEN** the following metrics SHALL be displayed:
  - Total views (last 7 days, 30 days, all time)
  - Follower count and growth
  - Average rating and review count
  - Campaign performance
  - Popular services

#### Scenario: Premium analytics
- **GIVEN** a business owner with Premium or Enterprise subscription
- **WHEN** the user views analytics
- **THEN** additional metrics SHALL be available:
  - Demographic insights
  - Peak hours analysis
  - Competitor comparison
  - Search ranking position

---

### Requirement: Notification Management
The system SHALL allow business owners to send notifications to their followers.

#### Scenario: Send notification to followers
- **GIVEN** a business owner with an active subscription
- **WHEN** the user creates a campaign
- **THEN** a push notification SHALL be sent to all followers
- **AND** the notification SHALL include the campaign details

#### Scenario: Notification rate limiting
- **GIVEN** a business owner attempting to send notifications
- **WHEN** the user has already sent 5 notifications today
- **THEN** further notifications SHALL be blocked
- **AND** an error message SHALL be displayed

---

### Requirement: Multi-User Access (Future)
The system SHOULD support multiple users managing the same business account.

#### Scenario: Add team member
- **GIVEN** a business owner with Enterprise subscription
- **WHEN** the owner invites a team member
- **THEN** the team member SHALL receive an invitation
- **AND** upon acceptance, the team member SHALL have limited admin access

---

## Non-Functional Requirements

### Performance
- Subscription check SHALL complete within 500ms
- Feature access check SHALL be cached for 5 minutes
- Admin dashboard SHALL load within 2 seconds
- Analytics data SHALL be cached and updated daily

### Security
- Only the venue owner SHALL have full admin access
- Subscription status SHALL be verified server-side
- Feature gating SHALL be enforced at the API level
- Payment transactions SHALL be encrypted and secure

### Reliability
- Subscription expiration checks SHALL run daily
- Failed payment notifications SHALL be sent immediately
- Credit transactions SHALL be atomic and consistent

---

## Data Model

### profiles table (updates)
```sql
ALTER TABLE profiles
ADD COLUMN is_business_account BOOLEAN DEFAULT false,
ADD COLUMN business_venue_id UUID REFERENCES venues(id);

CREATE INDEX idx_profiles_business_account ON profiles(is_business_account);
CREATE INDEX idx_profiles_business_venue_id ON profiles(business_venue_id);
```

### business_subscriptions table
```sql
CREATE TABLE business_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  subscription_type TEXT NOT NULL CHECK (subscription_type IN ('standard', 'premium', 'enterprise')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'expired', 'cancelled')),
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  features JSONB NOT NULL DEFAULT '{}',
  payment_method TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(profile_id, started_at)
);

CREATE INDEX idx_business_subscriptions_profile_id ON business_subscriptions(profile_id);
CREATE INDEX idx_business_subscriptions_status ON business_subscriptions(status);
CREATE INDEX idx_business_subscriptions_expires_at ON business_subscriptions(expires_at);
```

### credit_transactions table
```sql
CREATE TABLE credit_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'deduction', 'refund')),
  description TEXT,
  balance_after INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_credit_transactions_profile_id ON credit_transactions(profile_id);
```

### credit_packages table
```sql
CREATE TABLE credit_packages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  credits INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## RPC Functions

### get_business_subscription()
```sql
CREATE OR REPLACE FUNCTION get_business_subscription(p_profile_id UUID)
RETURNS business_subscriptions AS $$
DECLARE
  v_subscription business_subscriptions;
BEGIN
  SELECT * INTO v_subscription
  FROM business_subscriptions
  WHERE profile_id = p_profile_id
    AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1;
  
  RETURN v_subscription;
END;
$$ LANGUAGE plpgsql;
```

### check_business_feature()
```sql
CREATE OR REPLACE FUNCTION check_business_feature(
  p_profile_id UUID,
  p_feature TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  v_subscription business_subscriptions;
BEGIN
  v_subscription := get_business_subscription(p_profile_id);
  
  IF v_subscription IS NULL THEN
    RETURN false;
  END IF;
  
  RETURN (v_subscription.features->p_feature)::boolean;
END;
$$ LANGUAGE plpgsql;
```

### get_business_venue()
```sql
CREATE OR REPLACE FUNCTION get_business_venue(p_profile_id UUID)
RETURNS venues AS $$
DECLARE
  v_venue venues;
BEGIN
  SELECT v.* INTO v_venue
  FROM venues v
  JOIN profiles p ON p.business_venue_id = v.id
  WHERE p.id = p_profile_id;
  
  RETURN v_venue;
END;
$$ LANGUAGE plpgsql;
```

### deduct_credit()
```sql
CREATE OR REPLACE FUNCTION deduct_credit(
  p_profile_id UUID,
  p_amount INTEGER,
  p_description TEXT
)
RETURNS INTEGER AS $$
DECLARE
  v_current_balance INTEGER;
  v_new_balance INTEGER;
BEGIN
  -- Get current balance
  SELECT COALESCE(SUM(amount), 0) INTO v_current_balance
  FROM credit_transactions
  WHERE profile_id = p_profile_id;
  
  -- Check if sufficient balance
  IF v_current_balance < p_amount THEN
    RAISE EXCEPTION 'Insufficient credits';
  END IF;
  
  -- Deduct credits
  v_new_balance := v_current_balance - p_amount;
  
  INSERT INTO credit_transactions (profile_id, amount, transaction_type, description, balance_after)
  VALUES (p_profile_id, -p_amount, 'deduction', p_description, v_new_balance);
  
  RETURN v_new_balance;
END;
$$ LANGUAGE plpgsql;
```

---

## API Integration

### BusinessRepository Methods

```dart
// Check if user is business account
Future<bool> checkBusinessAccount(String userId);

// Get business venue
Future<Venue?> getBusinessVenue(String userId);

// Get subscription
Future<BusinessSubscription?> getBusinessSubscription(String userId);

// Check feature access
Future<bool> checkFeatureAccess(String userId, String feature);

// Convert to business account
Future<void> convertToBusinessAccount({
  required String userId,
  required String subscriptionType,
});

// Claim venue
Future<void> claimVenue({
  required String userId,
  required String venueId,
  required List<String> verificationDocs,
});

// Create new venue
Future<Venue> createVenue({
  required String userId,
  required Map<String, dynamic> venueData,
});
```

### SubscriptionRepository Methods

```dart
// Get subscription
Future<BusinessSubscription?> getSubscription(String userId);

// Create subscription
Future<BusinessSubscription> createSubscription({
  required String userId,
  required String subscriptionType,
  required DateTime expiresAt,
});

// Update subscription status
Future<void> updateSubscriptionStatus(String subscriptionId, String status);

// Check feature
Future<bool> checkFeature(String userId, String feature);

// Renew subscription
Future<void> renewSubscription(String subscriptionId, Duration duration);
```

### CreditRepository Methods

```dart
// Get credit balance
Future<int> getCreditBalance(String userId);

// Purchase credits
Future<void> purchaseCredits({
  required String userId,
  required String packageId,
});

// Deduct credits
Future<int> deductCredits({
  required String userId,
  required int amount,
  required String description,
});

// Get credit history
Future<List<CreditTransaction>> getCreditHistory(String userId);
```

---

## UI/UX Requirements

### Business Dashboard Screen
- Display venue overview card (photo, name, rating, followers)
- Show subscription status badge
- Display credit balance prominently
- Provide quick action buttons: "Kampanya Oluştur", "Profili Düzenle", "Analitik"
- Show recent activity feed
- Display subscription expiration warning if < 7 days

### Subscription Plans Screen
- Display 3 plan cards: Standard, Premium, Enterprise
- Highlight recommended plan
- Show feature comparison table
- Display pricing clearly
- Provide "Seç" button for each plan
- Show current plan badge if applicable

### Admin Sections
- **Mekan Bilgileri**: Form with all venue details
- **Hizmetler**: List of services with add/edit/delete
- **Uzmanlar**: Grid of specialists with add/edit/delete
- **Galeri**: Photo grid with upload/delete/reorder
- **Çalışma Saatleri**: Weekly schedule editor
- **Kampanyalar**: List of campaigns with create/edit/delete
- **Analitik**: Charts and metrics dashboard

### Credit Store Screen
- Display credit packages as cards
- Show package details (credits, price, bonus)
- Highlight best value package
- Provide "Satın Al" button
- Show current balance at top
- Display purchase history

---

## Testing Requirements

### Unit Tests
- Test subscription status calculation
- Test feature access logic
- Test credit balance calculation
- Test credit deduction logic

### Integration Tests
- Test business account conversion flow
- Test venue claiming process
- Test subscription creation and renewal
- Test credit purchase and deduction
- Test feature gating

### E2E Tests
- Test complete business account setup journey
- Test admin dashboard navigation
- Test campaign creation with credit deduction
- Test subscription expiration and renewal

---

## Error Handling

### Common Errors

| Error Code | Message | User Action |
|------------|---------|-------------|
| `no-subscription` | "Aktif aboneliğiniz bulunmuyor" | Subscribe to a plan |
| `subscription-expired` | "Aboneliğiniz sona erdi" | Renew subscription |
| `feature-not-available` | "Bu özellik planınızda mevcut değil" | Upgrade plan |
| `insufficient-credits` | "Yetersiz kredi bakiyesi" | Purchase credits |
| `venue-not-found` | "İşletme bulunamadı" | Claim or create venue |
| `venue-already-claimed` | "Bu işletme zaten başka bir kullanıcı tarafından talep edilmiş" | Contact support |
| `campaign-limit-reached` | "Aylık kampanya limitinize ulaştınız" | Upgrade or wait |

---

## Dependencies
- Supabase Database
- `BusinessRepository`
- `SubscriptionRepository`
- `CreditRepository`
- `BusinessProvider`
- `SubscriptionProvider`
- `CreditProvider`
- Payment gateway (Iyzico/Stripe)

---

## Future Enhancements
- Multi-location management for chains
- Team member access control
- Advanced analytics with AI insights
- Automated campaign scheduling
- A/B testing for campaigns
- Integration with booking systems
- White-label solutions for enterprises
- API access for third-party integrations
- Loyalty program management
- Customer relationship management (CRM)
