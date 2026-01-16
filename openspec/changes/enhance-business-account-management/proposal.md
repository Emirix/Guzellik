# Change: Enhance Business Account Management

## Why

Mevcut business account sistemi temel özellikleri sağlıyor ancak kapsamlı bir işletme yönetim platformu için gerekli detaylı spesifikasyonlar eksik. Bu change, business account management sistemini tam olarak tanımlayarak:

- **Subscription management** sistemini detaylandırıyor (Standard, Premium, Enterprise tiers)
- **Feature gating** mekanizmasını spesifiye ediyor
- **Credit system** ve campaign limits'i tanımlıyor
- **Admin dashboard** yeteneklerini genişletiyor
- **Venue claiming** sürecini netleştiriyor
- **Analytics ve reporting** gereksinimlerini ekliyor
- **Multi-user access** için altyapı hazırlıyor

Mevcut `add-business-account-management` change'i temel altyapıyı kurdu. Bu change, o altyapı üzerine enterprise-grade bir business management sistemi inşa ediyor.

## What Changes

### 1. Subscription Tier System
- **Standard Plan**: 3 campaigns/month, basic analytics, email support
- **Premium Plan**: Unlimited campaigns, advanced analytics, priority support, featured listing
- **Enterprise Plan**: Multi-location, API access, dedicated account manager

### 2. Feature Gating Infrastructure
- JSONB-based feature flags in `business_subscriptions` table
- Server-side feature access validation
- Client-side feature checks with caching
- Upgrade prompts for locked features

### 3. Credit System
- Credit packages for campaign creation
- Credit balance tracking
- Transaction history
- Refund logic for cancelled campaigns

### 4. Enhanced Admin Dashboard
- **Venue Management**: Complete profile editing
- **Service Management**: Add/edit/delete services
- **Specialist Management**: Team member profiles
- **Gallery Management**: Photo upload/reorder/delete
- **Campaign Management**: Create/edit/schedule campaigns
- **Analytics Dashboard**: Views, followers, ratings, campaign performance

### 5. Venue Claiming Process
- Search existing venues
- Submit verification documents
- Admin approval workflow
- Auto-link approved venue to business account

### 6. Analytics & Reporting
- Venue view analytics (7d, 30d, all-time)
- Follower growth tracking
- Campaign performance metrics
- Popular services insights
- Premium analytics for higher tiers

### 7. Notification Management
- Campaign-based notifications to followers
- Rate limiting (5 notifications/day)
- Notification preferences per venue

## Impact

### Affected Specs

#### MODIFIED Specs
- `business-account-management` (from `add-business-account-management` change)
  - Adds detailed subscription tier requirements
  - Adds feature gating scenarios
  - Adds credit system requirements
  - Adds analytics requirements

#### NEW Spec Capabilities
- `subscription-tiers`: Detailed tier definitions and feature matrices
- `feature-gating`: Feature access control mechanisms
- `credit-system`: Credit management and transactions
- `venue-claiming`: Venue ownership verification process
- `business-analytics`: Analytics and reporting for business owners

### Affected Code

#### New Files
- `lib/data/models/credit_package.dart`
- `lib/data/models/credit_transaction.dart`
- `lib/data/repositories/credit_repository.dart`
- `lib/presentation/providers/credit_provider.dart`
- `lib/presentation/screens/business/store_screen.dart` (enhanced)
- `lib/presentation/screens/business/analytics_screen.dart` (new)
- `lib/presentation/screens/business/claim_venue_screen.dart` (new)

#### Modified Files
- `lib/data/models/business_subscription.dart` (add features JSONB)
- `lib/data/repositories/business_repository.dart` (add feature checks)
- `lib/presentation/providers/business_provider.dart` (add credit management)
- `lib/presentation/screens/business/admin_dashboard_screen.dart` (add analytics)

#### Database Migrations
- `create_credit_packages_table.sql`
- `create_credit_transactions_table.sql`
- `add_features_to_business_subscriptions.sql`
- `create_venue_claim_requests_table.sql`

### Breaking Changes
- **NONE**: This is an enhancement, not a breaking change
- Existing business accounts will be migrated to Standard tier
- All existing features remain accessible

### Dependencies
- Depends on: `add-business-account-management` (must be applied first)
- Blocks: None
- Enables: Future payment integration, multi-location management

## Risks & Considerations

### 1. Migration Complexity
**Risk**: Existing business accounts need to be migrated to new subscription system
**Mitigation**: 
- Create migration script to assign Standard tier to all existing business accounts
- Set generous expiry dates (1 year) for initial migration
- Test migration on staging database first

### 2. Feature Gating Performance
**Risk**: Checking feature access on every action could slow down the app
**Mitigation**:
- Cache feature access checks for 5 minutes
- Use optimistic UI updates
- Implement server-side validation as final check

### 3. Credit System Abuse
**Risk**: Users might try to exploit credit system
**Mitigation**:
- Implement rate limiting on credit purchases
- Add fraud detection for suspicious patterns
- Require payment verification for large credit purchases

### 4. Analytics Data Volume
**Risk**: Analytics queries could become slow with large datasets
**Mitigation**:
- Pre-aggregate analytics data daily
- Use materialized views for common queries
- Implement pagination for analytics results

### 5. Subscription Expiration Handling
**Risk**: Users might lose access to features mid-campaign
**Mitigation**:
- Send expiration warnings 7 days before
- Grace period of 3 days after expiration
- Auto-pause campaigns instead of deleting

## Success Criteria

### Must Have
- [ ] All 3 subscription tiers are defined and functional
- [ ] Feature gating works correctly for all features
- [ ] Credit system allows purchase and deduction
- [ ] Admin dashboard shows all venue management options
- [ ] Analytics dashboard displays key metrics
- [ ] Venue claiming process is functional

### Should Have
- [ ] Migration script successfully upgrades existing business accounts
- [ ] Performance tests show <500ms for feature checks
- [ ] Analytics data updates within 24 hours
- [ ] Campaign creation respects credit limits

### Nice to Have
- [ ] A/B testing for subscription pricing
- [ ] Automated fraud detection
- [ ] Real-time analytics updates
- [ ] Multi-language support for business features

## Rollout Plan

### Phase 1: Foundation (Week 1-2)
- Implement subscription tier system
- Add feature gating infrastructure
- Create credit system tables and logic

### Phase 2: Admin Dashboard (Week 3-4)
- Enhance venue management UI
- Add service and specialist management
- Implement gallery management

### Phase 3: Analytics (Week 5-6)
- Build analytics data pipeline
- Create analytics dashboard UI
- Add campaign performance tracking

### Phase 4: Polish & Testing (Week 7-8)
- Migrate existing business accounts
- Performance optimization
- End-to-end testing
- Documentation

### Phase 5: Launch (Week 9)
- Gradual rollout to business accounts
- Monitor metrics and errors
- Gather feedback
- Iterate based on feedback
