# API Documentation - Business Account Management

## Database Tables

### `profiles`
Kullanıcı profil bilgilerini saklar.

**Yeni Kolonlar:**
| Kolon | Tip | Açıklama |
|-------|-----|----------|
| `is_business_account` | BOOLEAN | İşletme hesabı bayrağı (default: false) |
| `business_venue_id` | UUID | İşletmenin venue ID'si (FK: venues.id) |

**Örnek:**
```sql
SELECT id, full_name, is_business_account, business_venue_id 
FROM profiles 
WHERE id = 'user-uuid';
```

---

### `business_subscriptions`
İşletme abonelik bilgilerini saklar.

**Şema:**
| Kolon | Tip | Açıklama |
|-------|-----|----------|
| `id` | UUID | Primary key |
| `profile_id` | UUID | Kullanıcı ID (FK: profiles.id) |
| `subscription_type` | TEXT | Abonelik tipi (standard, premium, enterprise) |
| `status` | TEXT | Durum (active, inactive, expired, cancelled) |
| `started_at` | TIMESTAMPTZ | Başlangıç tarihi |
| `expires_at` | TIMESTAMPTZ | Bitiş tarihi |
| `features` | JSONB | Özellikler listesi |
| `payment_method` | TEXT | Ödeme yöntemi |
| `created_at` | TIMESTAMPTZ | Oluşturulma tarihi |
| `updated_at` | TIMESTAMPTZ | Güncellenme tarihi |

**Features JSONB Formatı:**
```json
{
  "unlimited_campaigns": true,
  "priority_support": true,
  "analytics": true,
  "custom_branding": false
}
```

**Örnek:**
```sql
SELECT * FROM business_subscriptions 
WHERE profile_id = 'user-uuid' 
AND status = 'active';
```

---

## RPC Functions

### `get_business_subscription(p_profile_id UUID)`
Kullanıcının en son aktif aboneliğini getirir.

**Parametreler:**
- `p_profile_id` (UUID): Kullanıcı ID

**Dönüş:** `business_subscriptions` row

**Örnek:**
```sql
SELECT * FROM get_business_subscription('user-uuid');
```

**Response:**
```json
{
  "id": "sub-uuid",
  "profile_id": "user-uuid",
  "subscription_type": "premium",
  "status": "active",
  "started_at": "2026-01-01T00:00:00Z",
  "expires_at": "2026-02-01T00:00:00Z",
  "features": {
    "unlimited_campaigns": true,
    "priority_support": true
  }
}
```

---

### `check_business_feature(p_profile_id UUID, p_feature TEXT)`
Kullanıcının belirli bir özelliğe erişimi olup olmadığını kontrol eder.

**Parametreler:**
- `p_profile_id` (UUID): Kullanıcı ID
- `p_feature` (TEXT): Özellik adı

**Dönüş:** BOOLEAN

**Örnek:**
```sql
SELECT check_business_feature('user-uuid', 'unlimited_campaigns');
```

**Response:**
```json
true
```

---

### `get_business_venue(p_profile_id UUID)`
Kullanıcının sahip olduğu mekanı getirir.

**Parametreler:**
- `p_profile_id` (UUID): Kullanıcı ID

**Dönüş:** `venues` row

**Örnek:**
```sql
SELECT * FROM get_business_venue('user-uuid');
```

**Response:**
```json
{
  "id": "venue-uuid",
  "name": "Güzellik Salonu",
  "owner_id": "user-uuid",
  "address": "İstanbul, Türkiye",
  "phone": "+90 555 123 4567"
}
```

---

## Row Level Security (RLS) Policies

### `business_subscriptions`

**SELECT Policy:**
```sql
CREATE POLICY "Users can view own subscriptions"
ON business_subscriptions FOR SELECT
USING (auth.uid() = profile_id);
```

**INSERT Policy:**
```sql
CREATE POLICY "Users can insert own subscriptions"
ON business_subscriptions FOR INSERT
WITH CHECK (auth.uid() = profile_id);
```

**UPDATE Policy:**
```sql
CREATE POLICY "Users can update own subscriptions"
ON business_subscriptions FOR UPDATE
USING (auth.uid() = profile_id);
```

---

## Flutter Integration

### BusinessRepository

**Check Business Account:**
```dart
final repository = BusinessRepository();
final isBusinessAccount = await repository.checkBusinessAccount(userId);
```

**Get Business Venue:**
```dart
final venue = await repository.getBusinessVenue(userId);
```

**Get Subscription:**
```dart
final subscription = await repository.getBusinessSubscription(userId);
```

**Check Feature Access:**
```dart
final hasFeature = await repository.checkFeatureAccess(
  userId, 
  'unlimited_campaigns'
);
```

---

### SubscriptionRepository

**Get Subscription:**
```dart
final repository = SubscriptionRepository();
final subscription = await repository.getSubscription(userId);
```

**Check Feature:**
```dart
final hasFeature = await repository.checkFeature(userId, 'analytics');
```

**Update Status:**
```dart
await repository.updateSubscriptionStatus(subscriptionId, 'active');
```

**Update Expiry:**
```dart
await repository.updateExpiryDate(
  subscriptionId, 
  DateTime.now().add(Duration(days: 30))
);
```

---

## Error Handling

### Common Errors

**No Subscription Found:**
```dart
try {
  final subscription = await repository.getSubscription(userId);
} catch (e) {
  // Handle: User has no active subscription
}
```

**Feature Not Available:**
```dart
final hasFeature = await repository.checkFeature(userId, 'premium_feature');
if (!hasFeature) {
  // Show upgrade prompt
}
```

**Venue Not Found:**
```dart
final venue = await repository.getBusinessVenue(userId);
if (venue == null) {
  // User is not a business owner
}
```

---

## Migration History

### `20260111132200_add_business_management.sql`
- Added `is_business_account` to profiles
- Added `business_venue_id` to profiles
- Created `business_subscriptions` table
- Created RLS policies
- Created RPC functions

---

## Testing

### Test Data Setup

**Create Business Account:**
```sql
UPDATE profiles 
SET is_business_account = true,
    business_venue_id = 'venue-uuid'
WHERE id = 'user-uuid';
```

**Create Subscription:**
```sql
INSERT INTO business_subscriptions (
  id, profile_id, subscription_type, status, 
  started_at, expires_at, features
) VALUES (
  gen_random_uuid(),
  'user-uuid',
  'premium',
  'active',
  NOW(),
  NOW() + INTERVAL '30 days',
  '{"unlimited_campaigns": true, "analytics": true}'::jsonb
);
```

---

## Rate Limits
- RPC calls: 100 requests/minute per user
- Subscription checks: Cached for 5 minutes
- Feature checks: Cached for 1 minute

---

## Changelog

### v1.0.0 (2026-01-11)
- Initial release
- Business account detection
- Subscription management
- Feature access control
- RPC functions for business operations
