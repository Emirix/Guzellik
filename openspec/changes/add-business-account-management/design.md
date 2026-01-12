# Design: İşletme Hesabı Yönetimi

## Architecture Overview

Bu değişiklik, platformu iki farklı kullanıcı moduna ayırıyor:
1. **Normal Kullanıcı Modu**: Mevcut keşfet, ara, favorile, takip et özellikleri
2. **İşletme Modu**: Mekan yönetimi, kampanya oluşturma, randevu takibi, bildirim gönderme

### High-Level Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        User Login                            │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
         ┌────────────────────┐
         │ is_business_account?│
         └────────┬───────────┘
                  │
         ┌────────┴────────┐
         │                 │
      YES│                 │NO
         │                 │
         ▼                 ▼
┌────────────────┐  ┌──────────────┐
│  Show Popup    │  │ Normal Mode  │
│ "İşletme mi?"  │  │   (Default)  │
└────────┬───────┘  └──────────────┘
         │
    ┌────┴─────┐
    │          │
İşletme    Normal
    │          │
    ▼          ▼
┌─────────┐ ┌─────────┐
│Business │ │ Normal  │
│  Mode   │ │  Mode   │
└─────────┘ └─────────┘
```

## Data Model

### 1. Database Schema

#### profiles Table (MODIFIED)
```sql
ALTER TABLE profiles ADD COLUMN is_business_account BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN business_venue_id UUID REFERENCES venues(id);
```

#### business_subscriptions Table (NEW)
```sql
CREATE TABLE business_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  subscription_type TEXT NOT NULL DEFAULT 'standard', -- 'standard', 'premium', 'enterprise'
  status TEXT NOT NULL DEFAULT 'active', -- 'active', 'expired', 'cancelled'
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE,
  features JSONB DEFAULT '{}'::jsonb, -- Store enabled features
  payment_method TEXT, -- 'google_play', 'credit_card', etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. Flutter Data Models

#### BusinessMode Enum
```dart
enum BusinessMode {
  normal,    // Normal kullanıcı modu
  business   // İşletme modu
}
```

#### BusinessSubscription Model
```dart
class BusinessSubscription {
  final String id;
  final String profileId;
  final String subscriptionType;
  final String status;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> features;
  final String? paymentMethod;
  
  // Computed properties
  bool get isActive => status == 'active';
  int get daysRemaining => expiresAt?.difference(DateTime.now()).inDays ?? 0;
}
```

## Component Architecture

### 1. State Management

#### BusinessProvider
```dart
class BusinessProvider extends ChangeNotifier {
  BusinessMode _currentMode = BusinessMode.normal;
  BusinessSubscription? _subscription;
  Venue? _businessVenue;
  
  // Getters
  BusinessMode get currentMode => _currentMode;
  bool get isBusinessMode => _currentMode == BusinessMode.business;
  BusinessSubscription? get subscription => _subscription;
  Venue? get businessVenue => _businessVenue;
  
  // Methods
  Future<void> switchMode(BusinessMode mode);
  Future<void> loadBusinessData();
  Future<void> loadSubscription();
  Future<bool> checkBusinessAccount();
}
```

### 2. UI Components

#### Mode Selection Popup
```dart
class BusinessModeSelectionDialog extends StatelessWidget {
  // Shows when is_business_account = true after login
  // Options: "İşletme Olarak Devam Et" | "Normal Kullanıcı Olarak Devam Et"
}
```

#### Business Bottom Navigation
```dart
class BusinessBottomNav extends StatelessWidget {
  // 3 tabs: Profilim, Abonelik, Mağaza
  // Replaces normal bottom nav when in business mode
}
```

#### Subscription Screen
```dart
class SubscriptionScreen extends StatelessWidget {
  // Shows subscription details based on design/admin-abonelik/image.png
  // - Subscription type badge
  // - Days remaining progress bar
  // - "Admin Panele Git" button
  // - Quick stats (Raporlar, Ayarlar)
}
```

#### Store Screen
```dart
class StoreScreen extends StatelessWidget {
  // Premium features marketplace
  // - Öne çıkma özelliği
  // - Kampanya ekleme
  // - Bildirim gönderme
  // - Analytics
  // (Initially just design/mockup)
}
```

## Navigation Flow

### Route Structure
```
/profile (Normal Mode)
  ├─ Profile Header
  ├─ Stats
  └─ Menu Items

/profile (Business Mode)
  ├─ Profile Header
  ├─ Stats
  ├─ [Yönetim Paneli] Button → Opens web admin
  ├─ [Normal Hesaba Geç] Button → Switches to normal mode
  └─ Menu Items

/business/subscription
  ├─ Subscription Card
  ├─ Progress Bar
  ├─ Admin Panel Button
  └─ Quick Actions

/business/store
  ├─ Feature Cards
  └─ Coming Soon Placeholders
```

## Web Admin Panel Architecture

### Technology Stack
- **Framework**: React (Vite or Next.js)
- **Styling**: CSS (consistent with Flutter app design)
- **Auth**: Supabase Auth (same as Flutter app)
- **State**: React Context or Zustand
- **Routing**: React Router

### Project Structure
```
admin/
├── src/
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Header.tsx
│   │   │   └── Layout.tsx
│   │   ├── campaigns/
│   │   ├── appointments/
│   │   ├── specialists/
│   │   └── gallery/
│   ├── pages/
│   │   ├── Dashboard.tsx
│   │   ├── Campaigns.tsx
│   │   ├── Appointments.tsx
│   │   ├── Specialists.tsx
│   │   ├── Gallery.tsx
│   │   ├── Notifications.tsx
│   │   └── Settings.tsx
│   ├── services/
│   │   └── supabase.ts
│   ├── config/
│   │   └── constants.ts  // ADMIN_PANEL_URL stored here
│   └── App.tsx
├── public/
└── package.json
```

### Admin Panel Features (Phase 1)
1. **Dashboard**: İstatistikler, son randevular, son yorumlar
2. **Kampanyalar**: Kampanya ekleme, düzenleme, silme
3. **Randevular**: Randevu listesi, durum güncelleme
4. **Uzmanlar**: Uzman ekleme, düzenleme, fotoğraf yükleme
5. **Galeri**: İşletme fotoğrafları yönetimi
6. **Bildirimler**: Takipçilere bildirim gönderme
7. **Ayarlar**: İşletme bilgileri düzenleme

## Configuration Management

### Admin Panel URL Configuration
```dart
// lib/config/admin_config.dart
class AdminConfig {
  static const String adminPanelUrl = 'https://admin.guzellikharitam.com';
  // or for development: 'http://localhost:5173'
  
  static String getAdminUrl(String venueId) {
    return '$adminPanelUrl/dashboard?venue=$venueId';
  }
}
```

## Security Considerations

### RLS Policies
```sql
-- Only business account owners can access their venue data
CREATE POLICY "Business owners can manage their venue"
ON venues FOR ALL
USING (
  auth.uid() IN (
    SELECT id FROM profiles 
    WHERE is_business_account = true 
    AND business_venue_id = venues.id
  )
);

-- Only active subscribers can access business features
CREATE POLICY "Active subscribers can access business features"
ON business_subscriptions FOR SELECT
USING (
  auth.uid() = profile_id 
  AND status = 'active'
);
```

### Session Management
- Business mode selection stored in `SharedPreferences` (Flutter)
- Mode preference cleared on logout
- Web admin panel uses same Supabase session

## UI/UX Design Principles

### Business Mode Indicators
- **Color**: Use gold/premium accent for business mode elements
- **Icons**: Business-specific icons (dashboard, analytics, etc.)
- **Badge**: "İşletme" badge on profile header when in business mode

### Subscription Screen Design
Based on `design/admin-abonelik/image.png`:
- **Header**: "LUXE BUSINESS" logo
- **Welcome**: "Hoş Geldiniz" with personalized message
- **Subscription Card**:
  - Badge: "AKTİF ABONELİK" (pink)
  - Title: "Premium Üyelik"
  - Days remaining: "15 Gün Kaldı"
  - Progress bar with gradient
  - Renewal date
- **CTA Button**: "Admin Panele Git" (gradient pink)
- **Quick Actions**: "Raporlar" and "Ayarlar" cards
- **Bottom Tabs**: "YARDIM", "DESTEK", "ÇIKIŞ YAP"

### Store Screen Design (Mockup)
- **Feature Cards**: Grid layout
  - Öne Çıkma Özelliği
  - Kampanya Ekleme
  - Bildirim Gönderme
  - Analytics Dashboard
  - Premium Support
- **Coming Soon Badge**: For features not yet implemented
- **Pricing**: "Yakında" placeholder

## Implementation Phases

### Phase 1: Core Infrastructure (This Change)
- Database schema updates
- Business mode detection and switching
- Business bottom navigation
- Subscription screen (design only)
- Store screen (mockup only)
- Profile screen buttons

### Phase 2: Web Admin Panel Scaffold
- React project setup
- Basic layout (sidebar, header)
- Authentication flow
- Dashboard page (stats only)

### Phase 3: Admin Panel Features
- Campaign management
- Appointment management
- Specialist management
- Gallery management
- Notification sending

### Phase 4: Subscription Integration
- Google Play billing integration
- Subscription validation
- Feature gating based on subscription

## Testing Strategy

### Unit Tests
- BusinessProvider state management
- Subscription model validation
- Mode switching logic

### Integration Tests
- Login flow with business account
- Mode selection popup
- Navigation between modes
- Admin panel URL opening

### E2E Tests
- Complete business onboarding flow
- Switching between normal and business mode
- Accessing admin panel from Flutter app
