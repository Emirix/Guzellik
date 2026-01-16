# Tasks: Enhance Business Account Management

## Phase 1: Subscription Tier System

### Task 1.1: Create subscription tier database schema
- [ ] Create migration for `business_subscriptions` table updates
- [ ] Add `features` JSONB column
- [ ] Add `subscription_type` enum (standard, premium, enterprise)
- [ ] Create indexes on `profile_id`, `status`, `expires_at`
- [ ] **Validation**: Migration runs successfully without errors

### Task 1.2: Define subscription tier features
- [ ] Create feature matrix for Standard tier
- [ ] Create feature matrix for Premium tier
- [ ] Create feature matrix for Enterprise tier
- [ ] Document feature differences in spec
- [ ] **Validation**: All tiers have clear feature definitions

### Task 1.3: Implement subscription tier RPC functions
- [ ] Create `get_business_subscription(profile_id)` function
- [ ] Create `check_business_feature(profile_id, feature)` function
- [ ] Create `update_subscription_tier(subscription_id, tier)` function
- [ ] Add RLS policies for subscription access
- [ ] **Validation**: RPC functions return correct data

### Task 1.4: Create SubscriptionRepository
- [ ] Implement `getSubscription(userId)` method
- [ ] Implement `checkFeature(userId, feature)` method
- [ ] Implement `updateSubscriptionStatus(subscriptionId, status)` method
- [ ] Implement `renewSubscription(subscriptionId, duration)` method
- [ ] **Validation**: Repository methods work with test data

### Task 1.5: Create SubscriptionProvider
- [ ] Implement subscription state management
- [ ] Add feature access caching (5 min TTL)
- [ ] Implement subscription expiration checks
- [ ] Add subscription renewal logic
- [ ] **Validation**: Provider correctly manages subscription state

---

## Phase 2: Feature Gating Infrastructure

### Task 2.1: Implement feature gating service
- [ ] Create `FeatureGatingService` class
- [ ] Implement `checkAccess(feature)` method with caching
- [ ] Implement `getLockedFeatures()` method
- [ ] Add upgrade prompt logic
- [ ] **Validation**: Feature checks work correctly

### Task 2.2: Add feature gates to campaign creation
- [ ] Check campaign limit based on tier
- [ ] Show upgrade prompt if limit reached
- [ ] Disable "Create Campaign" button when locked
- [ ] **Validation**: Campaign limits are enforced

### Task 2.3: Add feature gates to analytics
- [ ] Check analytics access based on tier
- [ ] Show basic analytics for Standard
- [ ] Show advanced analytics for Premium/Enterprise
- [ ] **Validation**: Analytics features are gated correctly

### Task 2.4: Add feature gates to other premium features
- [ ] Gate featured listing feature
- [ ] Gate custom branding feature
- [ ] Gate priority support feature
- [ ] **Validation**: All premium features are gated

---

## Phase 3: Credit System

### Task 3.1: Create credit system database schema
- [ ] Create `credit_packages` table
- [ ] Create `credit_transactions` table
- [ ] Add indexes on `profile_id`, `created_at`
- [ ] Create RPC function `get_credit_balance(profile_id)`
- [ ] Create RPC function `deduct_credit(profile_id, amount, description)`
- [ ] **Validation**: Tables and functions work correctly

### Task 3.2: Seed credit packages
- [ ] Create seed data for credit packages (10, 25, 50, 100 credits)
- [ ] Set pricing for each package
- [ ] Add bonus credits for larger packages
- [ ] **Validation**: Credit packages are available

### Task 3.3: Create CreditRepository
- [ ] Implement `getCreditBalance(userId)` method
- [ ] Implement `purchaseCredits(userId, packageId)` method
- [ ] Implement `deductCredits(userId, amount, description)` method
- [ ] Implement `getCreditHistory(userId)` method
- [ ] **Validation**: Repository methods work correctly

### Task 3.4: Create CreditProvider
- [ ] Implement credit balance state management
- [ ] Add credit transaction history
- [ ] Implement credit purchase flow
- [ ] Add credit deduction logic
- [ ] **Validation**: Provider manages credits correctly

### Task 3.5: Integrate credits with campaign creation
- [ ] Deduct 1 credit when campaign is created
- [ ] Show insufficient credits error
- [ ] Add "Buy Credits" button in campaign screen
- [ ] **Validation**: Credits are deducted on campaign creation

### Task 3.6: Create Store Screen
- [ ] Design credit package cards
- [ ] Implement package selection
- [ ] Add purchase flow (placeholder for now)
- [ ] Show current balance and history
- [ ] **Validation**: Store screen displays packages correctly

---

## Phase 4: Enhanced Admin Dashboard

### Task 4.1: Enhance venue management UI
- [ ] Create comprehensive venue info edit form
- [ ] Add address and location editing
- [ ] Add working hours editor
- [ ] Add social media links editor
- [ ] **Validation**: All venue fields are editable

### Task 4.2: Implement service management
- [ ] Create service list view
- [ ] Add "Add Service" dialog
- [ ] Implement service editing
- [ ] Implement service deletion with confirmation
- [ ] Add service reordering
- [ ] **Validation**: Services can be managed completely

### Task 4.3: Implement specialist management
- [ ] Create specialist grid view
- [ ] Add "Add Specialist" dialog
- [ ] Implement specialist editing
- [ ] Implement specialist deletion
- [ ] Add specialist photo upload
- [ ] **Validation**: Specialists can be managed completely

### Task 4.4: Implement gallery management
- [ ] Create photo grid view
- [ ] Add photo upload (max 10 photos)
- [ ] Implement photo deletion
- [ ] Add drag-and-drop reordering
- [ ] Add cover photo selection
- [ ] **Validation**: Gallery can be managed completely

### Task 4.5: Enhance campaign management
- [ ] Add campaign scheduling (start/end dates)
- [ ] Add campaign targeting options
- [ ] Implement campaign editing
- [ ] Add campaign deletion with refund logic
- [ ] **Validation**: Campaigns can be fully managed

---

## Phase 5: Venue Claiming Process

### Task 5.1: Create venue claim database schema
- [ ] Create `venue_claim_requests` table
- [ ] Add fields: `profile_id`, `venue_id`, `status`, `documents`
- [ ] Create RLS policies for claim requests
- [ ] **Validation**: Table is created successfully

### Task 5.2: Create Claim Venue Screen
- [ ] Design venue search UI
- [ ] Implement venue search by name
- [ ] Add venue selection
- [ ] Add document upload (verification)
- [ ] Add claim submission
- [ ] **Validation**: Users can search and claim venues

### Task 5.3: Implement claim approval workflow (admin)
- [ ] Create admin claim review screen (future)
- [ ] Add approve/reject actions
- [ ] Link approved venue to business account
- [ ] Send notification to user
- [ ] **Validation**: Claims can be approved/rejected

---

## Phase 6: Analytics & Reporting

### Task 6.1: Create analytics data pipeline
- [ ] Create materialized view for venue views
- [ ] Create materialized view for follower growth
- [ ] Create materialized view for campaign performance
- [ ] Schedule daily refresh of views
- [ ] **Validation**: Analytics data is accurate

### Task 6.2: Create analytics RPC functions
- [ ] Create `get_venue_analytics(venue_id, period)` function
- [ ] Create `get_campaign_analytics(campaign_id)` function
- [ ] Create `get_follower_growth(venue_id, period)` function
- [ ] **Validation**: Functions return correct data

### Task 6.3: Create Analytics Screen
- [ ] Design analytics dashboard layout
- [ ] Add venue views chart (7d, 30d, all-time)
- [ ] Add follower growth chart
- [ ] Add campaign performance metrics
- [ ] Add popular services list
- [ ] **Validation**: Analytics screen displays data

### Task 6.4: Implement tier-based analytics
- [ ] Show basic analytics for Standard tier
- [ ] Show advanced analytics for Premium tier
- [ ] Add demographic insights for Premium
- [ ] Add competitor comparison for Enterprise
- [ ] **Validation**: Analytics features match tier

---

## Phase 7: Notification Management

### Task 7.1: Implement notification rate limiting
- [ ] Add daily notification count tracking
- [ ] Enforce 5 notifications/day limit
- [ ] Show error when limit reached
- [ ] Reset count daily
- [ ] **Validation**: Rate limiting works correctly

### Task 7.2: Add notification preferences
- [ ] Allow users to customize notification settings per venue
- [ ] Add opt-out option for campaign notifications
- [ ] Respect user preferences when sending
- [ ] **Validation**: Preferences are respected

---

## Phase 8: Migration & Testing

### Task 8.1: Create migration script for existing business accounts
- [ ] Identify all existing business accounts
- [ ] Assign Standard tier to all
- [ ] Set expiry date to 1 year from now
- [ ] Create default feature set
- [ ] **Validation**: All accounts migrated successfully

### Task 8.2: Performance testing
- [ ] Test feature check performance (<500ms)
- [ ] Test analytics query performance
- [ ] Test credit transaction performance
- [ ] Optimize slow queries
- [ ] **Validation**: All operations meet performance targets

### Task 8.3: End-to-end testing
- [ ] Test complete business account conversion flow
- [ ] Test subscription tier upgrades
- [ ] Test credit purchase and usage
- [ ] Test campaign creation with limits
- [ ] Test analytics data accuracy
- [ ] **Validation**: All flows work correctly

### Task 8.4: Documentation
- [ ] Update API documentation
- [ ] Create business account user guide
- [ ] Document subscription tiers
- [ ] Document credit system
- [ ] **Validation**: Documentation is complete

---

## Dependencies

- **Requires**: `add-business-account-management` change must be applied first
- **Parallel**: Can work on Phase 1-3 in parallel
- **Sequential**: Phase 4-6 depend on Phase 1-3 completion

## Validation Checkpoints

- [ ] All database migrations run successfully
- [ ] All RPC functions return correct data
- [ ] All repository methods work with test data
- [ ] All providers manage state correctly
- [ ] All UI screens display correctly
- [ ] All feature gates work as expected
- [ ] All analytics data is accurate
- [ ] Performance targets are met
- [ ] Migration script works on staging
- [ ] End-to-end tests pass
