# Tasks: Enhance Business Account Management

## Phase 1: Subscription Tier System

### Task 1.1: Create subscription tier database schema
- [x] Create migration for `venues_subscription` table updates
- [x] Add default features JSONB definitions
- [x] Create `subscription_tier` enum
- [x] Create indexes on `venue_id`, `status`, `expires_at`
- [x] **Validation**: Migration file `20260118144000_enhance_business_subscriptions.sql` created
- [x] **Status**: Completed

### Task 1.2: Define subscription tier features
- [x] Create feature matrix for Standard tier (3 campaigns, email support)
- [x] Create feature matrix for Premium tier (Unlimited, advanced analytics)
- [x] Create feature matrix for Enterprise tier (Multi-location, API)
- [x] Document feature differences in `BusinessSubscription` model
- [x] **Validation**: `SubscriptionTier` enum added to model
- [x] **Status**: Completed

### Task 1.3: Implement subscription tier RPC functions
- [x] Update `check_business_feature` to handle new JSONB structure
- [x] Update `get_business_subscription` to use `venues_subscription`
- [x] **Validation**: RPC functions in `20260111210000_migrate_to_venue_subscriptions.sql` are compatible
- [x] **Status**: Completed

### Task 1.4: Create SubscriptionRepository
- [x] Implement `getSubscription(profileId)` method
- [x] Implement `checkFeatureAccess(profileId, feature)` method
- [x] Implement `updateSubscriptionStatus(id, status)` method
- [x] **Validation**: `SubscriptionRepository` class exists and is functional
- [x] **Status**: Completed

### Task 1.5: Create SubscriptionProvider
- [x] Implement subscription state management with logic
- [x] Implement subscription expiration checks
- [x] **Validation**: `SubscriptionProvider` class exists and is functional
- [x] **Status**: Completed

---

## Phase 2: Feature Gating Infrastructure

### Task 2.1: Implement feature gating service
- [x] Create `FeatureGatingService` class
- [x] Implement `hasAccess(feature)` and `getLimit(feature, key)`
- [x] Add upgrade prompt logic with `checkAndPrompt`
- **Validation**: `FeatureGatingService` is functional and provides clean API
- **Status**: Completed

### Task 2.2: Add feature gates to campaign creation
- [x] Check campaign limit based on tier in `CampaignEditScreen`
- [x] Show upgrade prompt if limit reached
- **Validation**: Campaign limits are enforced correctly
- **Status**: Completed

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
- [x] Create `credit_packages` table
- [x] Create `credit_transactions` table
- [x] Add indexes on `venue_id`, `created_at`
- [x] Create RPC function `increment_venue_credits`
- **Validation**: Schema implemented in `20260118150000_add_credit_system.sql`
- **Status**: Completed

### Task 3.2: Seed credit packages
- [x] Create seed data for credit packages (100, 500, 1500 credits)
- [x] Set pricing for each package
- **Validation**: Packages are available in database
- **Status**: Completed

### Task 3.3: Create CreditRepository
- [x] Implement `getBalance(venueId)` method
- [x] Implement `purchasePackage(venueId, package)` method
- [x] Implement `useCredits(venueId, amount, feature)` method
- [x] Implement `getTransactionHistory(venueId)` method
- **Validation**: Repository is functional
- **Status**: Completed

### Task 3.4: Create CreditProvider
- [x] Implement credit balance state management
- [x] Add credit transaction history
- [x] Implement credit purchase flow
- **Validation**: Provider manages credits correctly
- **Status**: Completed

### Task 3.5: Integrate credits with campaign creation
- [ ] Deduct credit when campaign is created (optional for now, currently using tier limit)
- [ ] Show insufficient credits error
- [ ] Add "Buy Credits" button in campaign screen
- **Status**: In Progress

### Task 3.6: Create Store Screen
- [x] Design credit package cards
- [x] Implement package selection
- [x] Add purchase flow (functional call)
- [x] Show current balance and history
- **Validation**: Store screen is fully functional
- **Status**: Completed

---

## Phase 4: Enhanced Admin Dashboard

### Task 4.1: Enhance venue management UI
- [x] Create comprehensive venue info edit form (`AdminBasicInfoScreen`)
- [x] Add address and location editing (`AdminLocationScreen`)
- [x] Add working hours editor (`AdminWorkingHoursScreen`)
- [x] Add social media links editor (`AdminBasicInfoScreen`)
- **Validation**: All venue fields are editable with a premium UI
- **Status**: Completed

### Task 4.2: Implement service management
- [x] Create service list view
- [x] Add "Add Service" dialog
- [x] Implement service editing
- [x] Implement service deletion with confirmation
- [x] Add service reordering
- **Validation**: Services can be managed completely
- **Status**: Completed

### Task 4.3: Implement specialist management
- [x] Create specialist grid view
- [x] Add "Add Specialist" dialog
- [x] Implement specialist editing
- [x] Implement specialist deletion
- [x] Add specialist photo upload
- **Validation**: Specialists can be managed completely
- **Status**: Completed

### Task 4.4: Implement gallery management
- [x] Create photo grid view
- [x] Add photo upload (max 10 photos)
- [x] Implement photo deletion
- [x] Add cover photo selection
- **Validation**: Gallery can be managed completely
- **Status**: Completed

### Task 4.5: Enhance campaign management
- [x] Add campaign scheduling (implemented in `CampaignEditScreen`)
- [x] Add campaign targeting options (basic tier checking implemented)
- [x] Implement campaign editing
- [x] Add campaign deletion
- **Validation**: Campaigns can be fully managed
- **Status**: Completed

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
