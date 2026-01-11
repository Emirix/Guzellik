# Spec Delta: Business Subscriptions

## ADDED Requirements

### Requirement: Subscription Data Model
**GIVEN** a business account exists  
**WHEN** subscription information is needed  
**THEN** the system SHALL provide a subscription model with:
- Subscription ID
- Profile ID (owner)
- Subscription type (standard, premium, enterprise)
- Status (active, expired, cancelled)
- Start date
- Expiration date (nullable for lifetime)
- Enabled features (JSONB)
- Payment method

#### Scenario: Standard subscription
- New business accounts get `subscription_type = 'standard'`
- Status is `active` by default
- Expiration date is null (no expiry for now)
- Standard features are enabled

#### Scenario: Subscription with expiry
- Subscription has `expires_at` set to future date
- System calculates days remaining
- Warning shown when < 7 days remaining
- Features disabled when expired

---

### Requirement: Subscription Status Check
**GIVEN** a user attempts to access business features  
**WHEN** the feature requires an active subscription  
**THEN** the system SHALL verify:
- Subscription exists for the user
- Subscription status is 'active'
- Subscription has not expired (if expiry date exists)

#### Scenario: Active subscription access
- User has active subscription
- All business features are accessible
- No restrictions or warnings

#### Scenario: Expired subscription access
- User has expired subscription
- Business features are restricted
- Renewal prompt is displayed
- User can view but not modify data

---

### Requirement: Subscription Display
**GIVEN** a user is viewing the subscription screen  
**WHEN** the screen loads  
**THEN** it SHALL display:
- Subscription type with visual badge
- Subscription name (e.g., "Premium Üyelik")
- Days remaining (if applicable)
- Progress bar showing time remaining
- Renewal date
- "Admin Panele Git" call-to-action button

#### Scenario: Subscription with time limit
- Screen shows "15 Gün Kaldı"
- Progress bar is 50% filled (15 of 30 days)
- Renewal date: "Yenilenme Tarihi: 12 Eylül"
- Badge shows "AKTİF ABONELİK"

#### Scenario: Lifetime subscription
- Screen shows "Sınırsız"
- Progress bar is full
- No renewal date displayed
- Badge shows "AKTİF ABONELİK"

---

### Requirement: Subscription Features Configuration
**GIVEN** a subscription type  
**WHEN** features need to be checked  
**THEN** the system SHALL use the `features` JSONB field to determine:
- Which features are enabled
- Feature limits (e.g., max campaigns, max notifications)
- Feature quotas (e.g., monthly notification count)

#### Scenario: Standard subscription features
```json
{
  "campaigns": { "enabled": true, "max": 5 },
  "notifications": { "enabled": true, "monthly_limit": 100 },
  "analytics": { "enabled": false },
  "priority_support": { "enabled": false }
}
```

#### Scenario: Premium subscription features
```json
{
  "campaigns": { "enabled": true, "max": -1 },
  "notifications": { "enabled": true, "monthly_limit": -1 },
  "analytics": { "enabled": true },
  "priority_support": { "enabled": true }
}
```

---

### Requirement: Subscription Provider
**GIVEN** the app needs to manage subscription state  
**WHEN** business mode is active  
**THEN** a SubscriptionProvider SHALL:
- Load subscription data from database
- Cache subscription in memory
- Provide subscription status
- Calculate days remaining
- Check feature availability

#### Scenario: Subscription data loading
- Provider fetches subscription on business mode entry
- Data is cached for session
- Provider notifies listeners on data change
- UI updates automatically

#### Scenario: Feature availability check
```dart
final canCreateCampaign = subscriptionProvider.hasFeature('campaigns');
final campaignLimit = subscriptionProvider.getFeatureLimit('campaigns', 'max');
```

---

### Requirement: Subscription Quick Actions
**GIVEN** a user is viewing the subscription screen  
**WHEN** quick action cards are displayed  
**THEN** the following actions SHALL be available:
- **Raporlar** (Reports) - View business statistics
- **Ayarlar** (Settings) - Manage subscription settings

#### Scenario: Tapping Raporlar
- User taps "Raporlar" card
- App navigates to business reports screen (future feature)
- Or shows "Yakında" message if not implemented

#### Scenario: Tapping Ayarlar
- User taps "Ayarlar" card
- App navigates to subscription settings
- User can view subscription details
- User can manage payment method (future)

---

### Requirement: Subscription Bottom Tabs
**GIVEN** a user is viewing the subscription screen  
**WHEN** the bottom tabs are displayed  
**THEN** the following tabs SHALL be available:
- **YARDIM** (Help) - Opens help documentation
- **DESTEK** (Support) - Opens support contact
- **ÇIKIŞ YAP** (Logout) - Logs out the user

#### Scenario: Tapping Yardım
- User taps "YARDIM" tab
- Help documentation is displayed
- Or external help URL is opened

#### Scenario: Tapping Çıkış Yap
- User taps "ÇIKIŞ YAP" tab
- Confirmation dialog is shown
- User confirms and is logged out
- App returns to login screen

---

## ADDED Requirements (Future - Google Play Integration)

### Requirement: Google Play Billing Integration (Placeholder)
**GIVEN** subscription system is in place  
**WHEN** Google Play billing is integrated (future)  
**THEN** the system SHALL support:
- In-app subscription purchases
- Subscription renewal via Google Play
- Receipt validation
- Subscription status sync

#### Scenario: Future implementation note
- Current implementation uses manual subscription management
- Database structure supports future Google Play integration
- `payment_method` field will store 'google_play'
- Receipt data will be stored in `features` JSONB
