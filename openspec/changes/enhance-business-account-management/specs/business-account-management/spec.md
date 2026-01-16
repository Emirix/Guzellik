# Spec: business-account-management

## ADDED Requirements

### Requirement: Subscription Tier Definition
The system SHALL support three distinct subscription tiers for business accounts: Standard, Premium, and Enterprise.

#### Scenario: Standard tier features
- **GIVEN** a business account with Standard subscription
- **WHEN** the subscription is queried
- **THEN** the following features SHALL be available:
  - Up to 3 campaigns per month
  - Basic analytics (views, followers, rating)
  - Email support
  - Basic venue profile management

#### Scenario: Premium tier features
- **GIVEN** a business account with Premium subscription
- **WHEN** the subscription is queried
- **THEN** the following features SHALL be available:
  - All Standard features
  - Unlimited campaigns
  - Advanced analytics (demographics, peak hours)
  - Priority support
  - Featured listing in search results
  - Custom branding options

#### Scenario: Enterprise tier features
- **GIVEN** a business account with Enterprise subscription
- **WHEN** the subscription is queried
- **THEN** the following features SHALL be available:
  - All Premium features
  - Multi-location management
  - API access
  - Dedicated account manager
  - Custom integrations
  - White-label options

---

### Requirement: Credit Package Definition
The system SHALL provide predefined credit packages for purchase.

#### Scenario: Available credit packages
- **GIVEN** the credit store is accessed
- **WHEN** packages are queried from `credit_packages` table
- **THEN** the following packages SHALL be available:
  - 10 credits for ₺99
  - 25 credits for ₺229 (8% bonus)
  - 50 credits for ₺449 (10% bonus)
  - 100 credits for ₺849 (15% bonus)

#### Scenario: Package details
- **GIVEN** a credit package
- **THEN** it SHALL include:
  - `id`: Unique identifier
  - `name`: Package name (e.g., "Başlangıç Paketi")
  - `credits`: Number of credits
  - `price`: Price in TRY
  - `is_active`: Whether package is available for purchase

---

## MODIFIED Requirements

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

#### Scenario: Feature matrix storage
- **GIVEN** a business subscription record
- **WHEN** the subscription is created
- **THEN** the `features` JSONB column SHALL contain:
  ```json
  {
    "unlimited_campaigns": boolean,
    "advanced_analytics": boolean,
    "priority_support": boolean,
    "featured_listing": boolean,
    "custom_branding": boolean,
    "multi_location": boolean,
    "api_access": boolean
  }
  ```

---

### Requirement: Feature Gating
The system SHALL control access to features based on subscription tier.

#### Scenario: Check feature access
- **GIVEN** a business account attempting to use a feature
- **WHEN** the system checks feature access
- **THEN** the subscription's `features` JSONB SHALL be queried
- **AND** if the feature is enabled, access SHALL be granted
- **AND** if the feature is disabled, an upgrade prompt SHALL be shown

#### Scenario: Feature access caching
- **GIVEN** a feature access check was performed
- **WHEN** the same feature is checked again within 5 minutes
- **THEN** the cached result SHALL be returned
- **AND** no database query SHALL be made
- **AND** the response time SHALL be <50ms

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

#### Scenario: Premium analytics access
- **GIVEN** a business owner with Premium or Enterprise subscription
- **WHEN** the user views analytics
- **THEN** additional metrics SHALL be available:
  - Demographic insights
  - Peak hours analysis
  - Competitor comparison
  - Search ranking position

#### Scenario: Analytics data refresh
- **GIVEN** analytics data exists
- **WHEN** the daily refresh job runs
- **THEN** materialized views SHALL be refreshed
- **AND** aggregated metrics SHALL be updated
- **AND** a "Last updated" timestamp SHALL be shown on screen

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

#### Scenario: Credit refund
- **GIVEN** a campaign created less than 24 hours ago
- **WHEN** the user deletes the campaign
- **THEN** a credit transaction SHALL be created with positive amount
- **AND** the user's balance SHALL be increased back
- **AND** the description SHALL reflect the refund
