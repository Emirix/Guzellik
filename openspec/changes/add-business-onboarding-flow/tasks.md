# Tasks: Business Account Onboarding Flow

## Phase 1: Database & Backend Setup

### 1.1 Database Schema Updates
- [ ] Create migration to add `business_name` and `business_type` columns to `profiles` table
- [ ] Create migration to add 'trial' to `business_subscriptions.subscription_type` constraint
- [ ] Add index on `profiles.business_type` for performance
- [ ] Test migrations on local database
- [ ] Verify foreign key constraints work correctly

**Validation**: Run migrations successfully, query profiles table to confirm new columns exist

---

### 1.2 Repository Layer
- [ ] Create `VenueCategoryRepository` with `getActiveCategories()` method
- [ ] Update `BusinessRepository` with `convertToBusinessAccount()` method
- [ ] Add `canConvertToBusinessAccount()` helper method to `BusinessRepository`
- [ ] Implement proper error handling and rollback logic
- [ ] Add unit tests for repository methods

**Validation**: Unit tests pass, methods return expected data

---

## Phase 2: State Management

### 2.1 Business Onboarding Provider
- [ ] Create `BusinessOnboardingProvider` in `lib/presentation/providers/`
- [ ] Add state variables: `currentStep`, `businessName`, `businessType`, `isLoading`, `errorMessage`
- [ ] Implement `nextStep()`, `previousStep()`, `skipOnboarding()` methods
- [ ] Implement `setBusinessName()`, `setBusinessType()` methods
- [ ] Implement `validateForm()` method
- [ ] Implement `convertToBusinessAccount()` method that calls repository
- [ ] Add proper error handling and loading states
- [ ] Add unit tests for provider logic

**Validation**: Provider state updates correctly, conversion logic works in isolation

---

## Phase 3: UI Components

### 3.1 Onboarding Step Widget
- [ ] Create `OnboardingStep` widget in `lib/presentation/widgets/business/`
- [ ] Add props: `title`, `description`, `iconData`, `gradient`
- [ ] Implement responsive layout with icon, title, and description
- [ ] Apply design system colors and typography
- [ ] Add widget tests

**Validation**: Widget renders correctly with different props

---

### 3.2 Business Onboarding Screen
- [ ] Create `BusinessOnboardingScreen` in `lib/presentation/screens/business/`
- [ ] Implement PageView for carousel with 4 steps
- [ ] Add dot indicators for current step
- [ ] Add "Devam Et" and "Atla" buttons
- [ ] Implement swipe gesture handling
- [ ] Connect to `BusinessOnboardingProvider`
- [ ] Add smooth page transition animations
- [ ] Handle navigation to business info form on completion
- [ ] Add widget tests for carousel navigation

**Validation**: Carousel swipes smoothly, buttons navigate correctly, animations work

---

### 3.3 Business Info Form Screen
- [ ] Create `BusinessInfoFormScreen` in `lib/presentation/screens/business/`
- [ ] Add TextFormField for business name with validation
- [ ] Add DropdownButtonFormField for business type
- [ ] Fetch categories from `VenueCategoryRepository` on init
- [ ] Implement form validation (min/max length, required fields)
- [ ] Add "İşletme Hesabını Oluştur" submit button
- [ ] Disable button when form is invalid or loading
- [ ] Show loading indicator during submission
- [ ] Handle success: show SnackBar, navigate to dashboard
- [ ] Handle error: show SnackBar, re-enable form
- [ ] Add widget tests for form validation

**Validation**: Form validates correctly, submission triggers conversion, error handling works

---

### 3.4 Profile Screen Enhancement
- [ ] Open `ProfileScreen` in `lib/presentation/screens/`
- [ ] Add conditional "İşletme Hesabına Geç" button/card
- [ ] Only show if `!authProvider.isBusinessAccount`
- [ ] Place button after settings group, before logout
- [ ] Style with primary pink gradient and business icon
- [ ] Add tap handler to navigate to `/business-onboarding`
- [ ] Test on both business and non-business accounts

**Validation**: Button appears only for non-business users, navigation works

---

## Phase 4: Navigation & Routing

### 4.1 Router Configuration
- [ ] Open `app_router.dart`
- [ ] Add route for `/business-onboarding` → `BusinessOnboardingScreen`
- [ ] Add route for `/business-info-form` → `BusinessInfoFormScreen`
- [ ] Test navigation flow: profile → onboarding → form → dashboard
- [ ] Ensure back button behavior is correct

**Validation**: All routes work, navigation flow is smooth

---

## Phase 5: Integration & Testing

### 5.1 End-to-End Flow
- [ ] Test complete flow: profile button → carousel → form → conversion
- [ ] Verify database records are created correctly
- [ ] Verify subscription has correct expiration date (1 year)
- [ ] Verify business info is stored in profile
- [ ] Test with different business types
- [ ] Test error scenarios (network failure, invalid data)

**Validation**: Complete flow works from start to finish, database is updated correctly

---

### 5.2 Edge Cases & Error Handling
- [ ] Test conversion attempt by existing business account (should fail gracefully)
- [ ] Test form submission with empty fields (should show validation errors)
- [ ] Test form submission with very long business name (should truncate or reject)
- [ ] Test category dropdown when API fails (should show error message)
- [ ] Test conversion when network is offline (should show error, allow retry)
- [ ] Test rapid button taps (should prevent duplicate submissions)

**Validation**: All edge cases handled gracefully with user-friendly messages

---

### 5.3 Visual Polish
- [ ] Review all screens for design consistency
- [ ] Ensure colors match design system (primary pink, gold accents)
- [ ] Verify spacing and padding are consistent (20px, 24px)
- [ ] Test animations are smooth (300ms transitions)
- [ ] Test on different screen sizes (small phones, tablets)
- [ ] Test in both light and dark mode (if applicable)
- [ ] Ensure accessibility: touch targets, labels, contrast

**Validation**: UI looks polished and professional, matches design mockups

---

### 5.4 Performance Optimization
- [ ] Ensure category fetch is cached (avoid repeated API calls)
- [ ] Optimize carousel animations (no jank)
- [ ] Test on low-end devices for performance
- [ ] Profile provider state updates efficiently

**Validation**: No performance issues, smooth on all devices

---

## Phase 6: Documentation & Cleanup

### 6.1 Code Documentation
- [ ] Add doc comments to all public methods
- [ ] Document provider state variables
- [ ] Add inline comments for complex logic
- [ ] Update README if needed

**Validation**: Code is well-documented and easy to understand

---

### 6.2 Testing Coverage
- [ ] Ensure unit tests cover all repository methods
- [ ] Ensure widget tests cover all UI components
- [ ] Ensure integration tests cover the complete flow
- [ ] Run `flutter test` and verify all tests pass
- [ ] Aim for >80% code coverage on new code

**Validation**: All tests pass, coverage is sufficient

---

### 6.3 Final Review
- [ ] Review all code for best practices
- [ ] Check for any TODO comments or debug code
- [ ] Verify no hardcoded strings (use localization if available)
- [ ] Run `flutter analyze` and fix any issues
- [ ] Run `dart format` on all new files
- [ ] Test on both iOS and Android (if applicable)

**Validation**: Code is clean, no linting errors, works on all platforms

---

## Dependencies Between Tasks
- Phase 1 (Database) must complete before Phase 2 (State Management)
- Phase 2 must complete before Phase 3 (UI Components)
- Phase 3 must complete before Phase 4 (Navigation)
- Phase 5 (Integration) requires all previous phases

## Parallelizable Work
- Within Phase 3, all UI components can be built in parallel
- Widget tests can be written alongside component development
- Documentation can be written as code is developed

## Estimated Timeline
- Phase 1: 0.5 day
- Phase 2: 0.5 day
- Phase 3: 1.5 days
- Phase 4: 0.5 day
- Phase 5: 1 day
- Phase 6: 0.5 day
- **Total**: ~4.5 days

## Success Criteria
- [ ] Non-business users can discover and access business onboarding from profile
- [ ] Onboarding carousel educates users about business benefits
- [ ] Form collects business name and type with proper validation
- [ ] Account conversion creates database records correctly
- [ ] 1-year trial subscription is activated
- [ ] User is navigated to appropriate next step (dashboard/venue setup)
- [ ] All error cases are handled gracefully
- [ ] UI is polished and matches design system
- [ ] Code is well-tested and documented
