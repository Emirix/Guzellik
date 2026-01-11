# Tasks: İşletme Hesabı Yönetimi

## Phase 1: Database Schema & Backend (Priority: HIGH)

### Task 1.1: Create database migration for business accounts
- [x] Create migration file `add_business_account_fields.sql`
- [x] Add `is_business_account` boolean to profiles table
- [x] Add `business_venue_id` UUID to profiles table
- [x] Create foreign key constraint to venues table
- [x] Test migration on local Supabase instance
- [x] **Validation**: Query profiles table and verify new columns exist

### Task 1.2: Create business_subscriptions table
- [x] Create migration file `create_business_subscriptions.sql`
- [x] Define table schema with all required columns
- [x] Add foreign key to profiles table
- [x] Create indexes on profile_id and status
- [x] Add default subscription for existing business accounts
- [x] **Validation**: Insert test subscription and query successfully

### Task 1.3: Implement RLS policies for business data
- [x] Create policy for business owners to access their venue
- [x] Create policy for subscription data access
- [x] Create policy for business feature gating
- [x] Test policies with different user roles
- [x] **Validation**: Verify non-business users cannot access business data

### Task 1.4: Create database functions for business operations
- [x] Create function `get_business_subscription(profile_id UUID)`
- [x] Create function `check_business_feature(profile_id UUID, feature TEXT)`
- [x] Create function `get_business_venue(profile_id UUID)`
- [x] Test functions with sample data
- [x] **Validation**: Functions return correct data for test users

---

## Phase 2: Flutter Data Layer (Priority: HIGH)

### Task 2.1: Create BusinessSubscription model
- [x] Create `lib/data/models/business_subscription.dart`
- [x] Define model class with all fields
- [x] Implement `fromJson` and `toJson` methods
- [x] Add computed properties (isActive, daysRemaining)
- [x] Write unit tests for model
- [x] **Validation**: Model correctly parses JSON from Supabase

### Task 2.2: Create BusinessMode enum and utilities
- [x] Create `lib/core/enums/business_mode.dart`
- [x] Define BusinessMode enum (normal, business)
- [x] Create utility functions for mode management
- [x] **Validation**: Enum values are correctly defined

### Task 2.3: Create BusinessRepository
- [x] Create `lib/data/repositories/business_repository.dart`
- [x] Implement `checkBusinessAccount(userId)` method
- [x] Implement `getBusinessVenue(userId)` method
- [x] Implement `getSubscription(userId)` method
- [x] Implement `updateBusinessMode(userId, mode)` method
- [x] Write unit tests with mocked Supabase client
- [x] **Validation**: Repository methods return expected data

### Task 2.4: Create SubscriptionRepository
- [x] Create `lib/data/repositories/subscription_repository.dart`
- [x] Implement `getSubscription(profileId)` method
- [x] Implement `checkFeatureAccess(profileId, feature)` method
- [x] Implement `getFeatureLimit(profileId, feature)` method
- [x] Write unit tests
- [x] **Validation**: Repository correctly fetches subscription data

---

## Phase 3: Flutter State Management (Priority: HIGH)

### Task 3.1: Create BusinessProvider
- [x] Create `lib/presentation/providers/business_provider.dart`
- [x] Implement mode state management (normal/business)
- [x] Implement business data loading (venue, subscription)
- [x] Implement mode switching logic
- [x] Add loading and error states
- [x] Integrate with BusinessRepository
- [x] Write unit tests
- [x] **Validation**: Provider correctly manages business mode state

### Task 3.2: Create SubscriptionProvider
- [x] Create `lib/presentation/providers/subscription_provider.dart`
- [x] Implement subscription data loading
- [x] Implement feature availability checking
- [x] Implement days remaining calculation
- [x] Add caching for subscription data
- [x] Integrate with SubscriptionRepository
- [x] Write unit tests
- [x] **Validation**: Provider correctly manages subscription state

### Task 3.3: Update AuthProvider for business account detection
- [x] Modify `lib/presentation/providers/auth_provider.dart`
- [x] Add business account check after login
- [x] Trigger business mode selection if needed
- [x] Integrate with BusinessProvider
- [x] **Validation**: Business accounts are detected on login

---

## Phase 4: Flutter UI - Authentication & Mode Selection (Priority: HIGH)

### Task 4.1: Create BusinessModeSelectionDialog
- [x] Create `lib/presentation/widgets/business/business_mode_dialog.dart`
- [x] Design dialog UI with two options
- [x] Implement "İşletme Olarak Devam Et" button
- [x] Implement "Normal Kullanıcı Olarak Devam Et" button
- [x] Add animations and transitions
- [x] **Validation**: Dialog shows after business account login

### Task 4.2: Integrate mode selection into login flow
- [x] Update `lib/presentation/screens/auth/login_screen.dart`
- [x] Show mode selection dialog after successful login
- [x] Navigate to appropriate home based on selection
- [x] Handle dialog dismissal
- [x] **Validation**: Login flow works for both business and normal users

### Task 4.3: Implement session-based mode persistence
- [x] Use SharedPreferences to store current mode
- [x] Load mode preference on app start
- [x] Clear mode preference on logout
- [x] **Validation**: Mode persists during session and resets on logout

---

## Phase 5: Flutter UI - Business Navigation (Priority: HIGH)

### Task 5.1: Create BusinessBottomNav widget
- [x] Create `lib/presentation/widgets/common/business_bottom_nav.dart`
- [x] Implement 3-tab navigation (Profilim, Abonelik, Mağaza)
- [x] Design tab icons and labels
- [x] Implement tab selection logic
- [x] Match design aesthetic with app theme
- [x] **Validation**: Business nav shows in business mode

### Task 5.2: Update CustomBottomNav to support mode switching
- [x] Modify `lib/presentation/widgets/common/custom_bottom_nav.dart`
- [x] Add conditional rendering based on BusinessProvider
- [x] Show BusinessBottomNav when in business mode
- [x] Show normal nav when in normal mode
- [x] **Validation**: Navigation switches correctly between modes

### Task 5.3: Update app router with business routes
- [x] Modify `lib/core/utils/app_router.dart`
- [x] Add `/business/subscription` route
- [x] Add `/business/store` route
- [x] Add `/business/profile` route (if needed)
- [x] Implement route guards for business mode
- [x] **Validation**: Business routes are accessible only in business mode

---

## Phase 6: Flutter UI - Subscription Screen (Priority: MEDIUM)

### Task 6.1: Create SubscriptionScreen
- [ ] Create `lib/presentation/screens/business/subscription_screen.dart`
- [ ] Implement screen layout based on design/admin-abonelik/image.png
- [ ] Add business logo/branding section
- [ ] Add welcome message
- [ ] **Validation**: Screen renders correctly

### Task 6.2: Create SubscriptionCard widget
- [ ] Create `lib/presentation/widgets/business/subscription_card.dart`
- [ ] Implement subscription type badge
- [ ] Add subscription name display
- [ ] Add days remaining display
- [ ] Implement progress bar with gradient
- [ ] Add renewal date display
- [ ] **Validation**: Card displays subscription data correctly

### Task 6.3: Implement "Admin Panele Git" button
- [ ] Add button to SubscriptionScreen
- [ ] Implement URL opening logic using url_launcher
- [ ] Get admin URL from AdminConfig
- [ ] Append venue ID as query parameter
- [ ] **Validation**: Button opens admin panel in browser

### Task 6.4: Create quick action cards
- [ ] Create "Raporlar" card
- [ ] Create "Ayarlar" card
- [ ] Implement tap handlers (placeholder for now)
- [ ] **Validation**: Cards are tappable and show appropriate feedback

### Task 6.5: Implement bottom tabs
- [ ] Create bottom tab bar with YARDIM, DESTEK, ÇIKIŞ YAP
- [ ] Implement tab tap handlers
- [ ] Add logout confirmation dialog
- [ ] **Validation**: Tabs are functional

---

## Phase 7: Flutter UI - Store Screen (Priority: LOW)

### Task 7.1: Create StoreScreen (mockup)
- [ ] Create `lib/presentation/screens/business/store_screen.dart`
- [ ] Implement grid layout for feature cards
- [ ] Create feature card widget
- [ ] Add "Yakında" badges to all features
- [ ] **Validation**: Screen displays mockup correctly

### Task 7.2: Design feature cards
- [ ] Create cards for: Öne Çıkma, Kampanya Ekleme, Bildirim Gönderme
- [ ] Add feature icons and descriptions
- [ ] Add placeholder pricing
- [ ] **Validation**: Cards look premium and match app design

---

## Phase 8: Flutter UI - Profile Screen Updates (Priority: MEDIUM)

### Task 8.1: Add business mode buttons to ProfileScreen
- [ ] Modify `lib/presentation/screens/profile_screen.dart`
- [ ] Add "Yönetim Paneli" button (business mode only)
- [ ] Add "Normal Hesaba Geç" button (business mode only)
- [ ] Implement button tap handlers
- [ ] **Validation**: Buttons show only in business mode

### Task 8.2: Implement "Yönetim Paneli" button action
- [ ] Get admin URL from AdminConfig
- [ ] Get venue ID from BusinessProvider
- [ ] Open URL in external browser
- [ ] **Validation**: Button opens admin panel correctly

### Task 8.3: Implement "Normal Hesaba Geç" button action
- [ ] Call BusinessProvider.switchMode(BusinessMode.normal)
- [ ] Navigate to explore screen
- [ ] Update bottom navigation
- [ ] **Validation**: Mode switches correctly

### Task 8.4: Add "İşletme Moduna Geç" button for normal mode
- [ ] Show button in normal mode if is_business_account = true
- [ ] Implement tap handler to switch to business mode
- [ ] **Validation**: Users can switch back to business mode

---

## Phase 9: Configuration & Admin Panel Setup (Priority: MEDIUM)

### Task 9.1: Create AdminConfig file
- [x] Create `lib/config/admin_config.dart`
- [x] Define adminPanelUrl constant
- [x] Create getAdminUrl(venueId) helper function
- [x] Add comments for environment-specific URLs
- [x] **Validation**: Config file is accessible from app

### Task 9.2: Initialize React project for admin panel
- [ ] Create `admin/` directory
- [ ] Run `npx create-vite@latest admin --template react` or similar
- [ ] Install dependencies (react, react-router, @supabase/supabase-js)
- [ ] Set up project structure
- [ ] **Validation**: Admin project runs with `npm run dev`

### Task 9.3: Set up Supabase client in admin panel
- [ ] Create `admin/src/services/supabase.ts`
- [ ] Initialize Supabase client with project URL and anon key
- [ ] Implement auth helpers
- [ ] **Validation**: Admin panel can authenticate with Supabase

### Task 9.4: Create admin panel layout components
- [ ] Create `admin/src/components/layout/Sidebar.tsx`
- [ ] Create `admin/src/components/layout/Header.tsx`
- [ ] Create `admin/src/components/layout/Layout.tsx`
- [ ] Implement responsive design
- [ ] **Validation**: Layout renders correctly on different screen sizes

---

## Phase 10: Admin Panel - Core Pages (Priority: LOW)

### Task 10.1: Create Dashboard page
- [ ] Create `admin/src/pages/Dashboard.tsx`
- [ ] Add placeholder stats cards
- [ ] Add recent appointments section
- [ ] Add recent reviews section
- [ ] **Validation**: Dashboard page renders

### Task 10.2: Create Campaigns page (placeholder)
- [ ] Create `admin/src/pages/Campaigns.tsx`
- [ ] Add "Yakında" message
- [ ] Add basic layout structure
- [ ] **Validation**: Page is accessible from sidebar

### Task 10.3: Create Appointments page (placeholder)
- [ ] Create `admin/src/pages/Appointments.tsx`
- [ ] Add "Yakında" message
- [ ] Add basic layout structure
- [ ] **Validation**: Page is accessible from sidebar

### Task 10.4: Create Specialists page (placeholder)
- [ ] Create `admin/src/pages/Specialists.tsx`
- [ ] Add "Yakında" message
- [ ] Add basic layout structure
- [ ] **Validation**: Page is accessible from sidebar

### Task 10.5: Create Gallery page (placeholder)
- [ ] Create `admin/src/pages/Gallery.tsx`
- [ ] Add "Yakında" message
- [ ] Add basic layout structure
- [ ] **Validation**: Page is accessible from sidebar

### Task 10.6: Create Notifications page (placeholder)
- [ ] Create `admin/src/pages/Notifications.tsx`
- [ ] Add "Yakında" message
- [ ] Add basic layout structure
- [ ] **Validation**: Page is accessible from sidebar

### Task 10.7: Create Settings page (placeholder)
- [ ] Create `admin/src/pages/Settings.tsx`
- [ ] Add "Yakında" message
- [ ] Add basic layout structure
- [ ] **Validation**: Page is accessible from sidebar

---

## Phase 11: Testing & Validation (Priority: MEDIUM)

### Task 11.1: Write integration tests for business mode flow
- [ ] Test login with business account
- [ ] Test mode selection dialog
- [ ] Test mode switching
- [ ] Test navigation in business mode
- [ ] **Validation**: All tests pass

### Task 11.2: Write widget tests for business components
- [ ] Test BusinessModeSelectionDialog
- [ ] Test BusinessBottomNav
- [ ] Test SubscriptionCard
- [ ] Test StoreScreen
- [ ] **Validation**: All widget tests pass

### Task 11.3: Manual testing on different devices
- [ ] Test on Android phone
- [ ] Test on iOS phone (if available)
- [ ] Test on tablet
- [ ] Test admin panel on desktop browser
- [ ] Test admin panel on mobile browser
- [ ] **Validation**: App works correctly on all devices

### Task 11.4: Test with real business account data
- [ ] Create test business account in Supabase
- [ ] Create test venue and subscription
- [ ] Test complete flow from login to admin panel
- [ ] **Validation**: Real data flows correctly through the system

---

## Phase 12: Documentation & Deployment (Priority: LOW)

### Task 12.1: Update README with business account info
- [ ] Document business account setup process
- [ ] Document admin panel setup and deployment
- [ ] Add screenshots of business mode
- [ ] **Validation**: Documentation is clear and complete

### Task 12.2: Create admin panel deployment guide
- [ ] Document deployment to Vercel/Netlify
- [ ] Document environment variables setup
- [ ] Document custom domain configuration
- [ ] **Validation**: Admin panel can be deployed following guide

### Task 12.3: Update API documentation
- [ ] Document new database tables
- [ ] Document new RPC functions
- [ ] Document RLS policies
- [ ] **Validation**: API docs are up to date

---

## Dependencies & Sequencing

- **Phase 1** must complete before Phase 2
- **Phase 2** must complete before Phase 3
- **Phase 3** must complete before Phase 4
- **Phase 4** and Phase 5 can run in parallel
- **Phase 6, 7, 8** can run in parallel after Phase 5
- **Phase 9** can start after Phase 1
- **Phase 10** can start after Phase 9.3
- **Phase 11** should run after all implementation phases
- **Phase 12** is final and can run anytime

## Estimated Effort

- **Phase 1-3**: 2-3 days (Backend & Data Layer)
- **Phase 4-5**: 2-3 days (Auth & Navigation)
- **Phase 6-8**: 3-4 days (UI Screens)
- **Phase 9-10**: 3-4 days (Admin Panel)
- **Phase 11**: 1-2 days (Testing)
- **Phase 12**: 1 day (Documentation)

**Total**: ~12-17 days for complete implementation
