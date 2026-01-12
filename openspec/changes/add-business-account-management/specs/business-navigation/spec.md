# Spec Delta: Business Navigation

## ADDED Requirements

### Requirement: Business Bottom Navigation Bar
**GIVEN** a user is in business mode  
**WHEN** the main app screen is displayed  
**THEN** a business-specific bottom navigation bar SHALL be shown with three tabs:
- **Profilim** (Profile)
- **Abonelik** (Subscription)
- **Mağaza** (Store)

#### Scenario: Business mode navigation
- User is in business mode
- Bottom navigation shows 3 tabs instead of 4
- No FAB (floating action button) is displayed
- Tapping each tab navigates to respective screen

#### Scenario: Normal mode navigation
- User is in normal mode
- Bottom navigation shows 4 tabs (Keşfet, Ara, Bildirimler, Profil)
- FAB is displayed for campaigns
- Standard navigation behavior

---

### Requirement: Profile Screen in Business Mode
**GIVEN** a user is in business mode  
**WHEN** they navigate to the Profile tab  
**THEN** the profile screen SHALL display additional business-specific buttons:
- **Yönetim Paneli** button (opens web admin panel)
- **Normal Hesaba Geç** button (switches to normal mode)

#### Scenario: Opening admin panel
- User taps "Yönetim Paneli" button
- System opens web admin panel URL in external browser
- URL includes venue ID as query parameter
- User remains logged in via Supabase session

#### Scenario: Switching to normal mode
- User taps "Normal Hesaba Geç" button
- App switches to normal mode
- Normal bottom navigation is displayed
- User is navigated to explore screen

---

### Requirement: Subscription Screen
**GIVEN** a user is in business mode  
**WHEN** they navigate to the Abonelik tab  
**THEN** a subscription screen SHALL be displayed showing:
- Business logo/branding
- Welcome message
- Current subscription card with:
  - Subscription type badge
  - Subscription name
  - Days remaining
  - Progress bar
  - Renewal date
- "Admin Panele Git" button
- Quick action cards (Raporlar, Ayarlar)
- Bottom tabs (Yardım, Destek, Çıkış Yap)

#### Scenario: Active subscription display
- User has active subscription
- Card shows "AKTİF ABONELİK" badge
- Progress bar shows days remaining
- All features are accessible

#### Scenario: Expired subscription display
- User has expired subscription
- Card shows "SÜRESİ DOLMUŞ" badge
- Renewal prompt is displayed
- Limited features are accessible

---

### Requirement: Store Screen (Mockup)
**GIVEN** a user is in business mode  
**WHEN** they navigate to the Mağaza tab  
**THEN** a store screen SHALL be displayed showing:
- Feature cards for premium services
- "Yakında" (Coming Soon) badges
- Feature descriptions
- Placeholder pricing

#### Scenario: Store screen mockup
- Screen displays feature cards in grid layout
- Each card shows feature icon, name, description
- "Yakında" badge on all features
- No actual purchase functionality yet

---

### Requirement: Business Route Configuration
**GIVEN** the app router configuration  
**WHEN** business mode routes are needed  
**THEN** the following routes SHALL be added:
- `/business/subscription` - Subscription screen
- `/business/store` - Store screen
- `/business/profile` - Profile screen (business mode variant)

#### Scenario: Route navigation in business mode
- User taps Abonelik tab
- App navigates to `/business/subscription`
- Subscription screen is displayed
- Back button returns to previous screen

---

### Requirement: Admin Panel URL Configuration
**GIVEN** the admin panel needs to be accessed  
**WHEN** the "Yönetim Paneli" button is tapped  
**THEN** the system SHALL:
- Read admin panel URL from configuration file
- Append venue ID as query parameter
- Open URL in external browser
- Maintain Supabase auth session

#### Scenario: Admin panel URL from config
- Admin URL is stored in `lib/config/admin_config.dart`
- URL can be easily changed without code modification
- Development and production URLs can be different
- URL format: `{baseUrl}/dashboard?venue={venueId}`

---

## MODIFIED Requirements

### Requirement: Bottom Navigation Behavior
**GIVEN** the existing bottom navigation system  
**WHEN** business mode is active  
**THEN** the navigation SHALL:
- Replace normal navigation with business navigation
- Update tab count from 4 to 3
- Remove FAB
- Update navigation icons and labels

#### Scenario: Dynamic navigation switching
- User switches between modes
- Navigation bar updates automatically
- No app restart required
- State is preserved where appropriate
