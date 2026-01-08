# Tasks: Automatic Location Onboarding

## Overview
This document outlines the implementation tasks for the automatic location onboarding feature. Tasks are ordered to deliver incremental, testable progress.

---

## Phase 1: Data Layer Foundation

### Task 1.1: Create Province and District Models
**Estimated Time**: 30 minutes

- [ ] Create `lib/data/models/province.dart`
  - Add `Province` model with `id`, `name`, `latitude`, `longitude`
  - Add `fromJson` factory constructor
  - Add `toJson` method
- [ ] Create `lib/data/models/district.dart`
  - Add `District` model with `id`, `provinceId`, `name`
  - Add `fromJson` factory constructor
  - Add `toJson` method
- [ ] Create `lib/data/models/user_location.dart`
  - Add `UserLocation` model with `provinceName`, `districtName`, `provinceId`, `latitude`, `longitude`, `isGPSBased`
  - Add `fromJson` and `toJson` methods

**Validation**: Models compile without errors, JSON serialization works

**Dependencies**: None

---

### Task 1.2: Create LocationRepository
**Estimated Time**: 1 hour

- [ ] Create `lib/data/repositories/location_repository.dart`
- [ ] Implement `fetchProvinces()` method
  - Query `provinces` table from Supabase
  - Order by `name` ASC
  - Return `List<Province>`
- [ ] Implement `fetchDistrictsByProvince(int provinceId)` method
  - Query `districts` table with `province_id = provinceId`
  - Order by `name` ASC
  - Return `List<District>`
- [ ] Add in-memory caching for provinces
- [ ] Add error handling for network failures
- [ ] Add timeout handling (10 seconds)

**Validation**: 
- Can fetch all provinces from Supabase
- Can fetch districts for a specific province
- Cache works correctly
- Errors are handled gracefully

**Dependencies**: Task 1.1

---

### Task 1.3: Create LocationPreferences Service
**Estimated Time**: 45 minutes

- [ ] Create `lib/data/services/location_preferences.dart`
- [ ] Add `shared_preferences` dependency to `pubspec.yaml`
- [ ] Implement `saveLocation(UserLocation location)` method
  - Save as JSON string to SharedPreferences
  - Key: `'user_location'`
- [ ] Implement `getLocation()` method
  - Load from SharedPreferences
  - Parse JSON to `UserLocation`
  - Return `null` if not found
- [ ] Implement `isLocationSet()` method
  - Check if location exists in SharedPreferences
- [ ] Implement `clearLocation()` method
  - Remove location from SharedPreferences

**Validation**:
- Can save and retrieve location
- Returns null when no location is saved
- `isLocationSet()` returns correct boolean

**Dependencies**: Task 1.1

---

## Phase 2: Enhanced Location Service

### Task 2.1: Enhance LocationService
**Estimated Time**: 30 minutes

- [ ] Update `lib/data/services/location_service.dart`
- [ ] Add `extractProvinceAndDistrict(String address)` method
  - Parse address string to extract province and district
  - Handle various address formats
  - Return `Map<String, String>` with `province` and `district` keys
- [ ] Add better error messages for permission scenarios
- [ ] Add logging for debugging

**Validation**:
- Can correctly parse common address formats
- Returns appropriate error messages
- Logs are helpful for debugging

**Dependencies**: None

---

## Phase 3: Presentation Layer

### Task 3.1: Create LocationOnboardingProvider
**Estimated Time**: 1.5 hours

- [ ] Create `lib/presentation/providers/location_onboarding_provider.dart`
- [ ] Define `OnboardingState` enum
  - `initial`, `checkingLocation`, `requestingGPS`, `fetchingGPS`, `showingManual`, `completed`, `error`
- [ ] Implement state management
  - `_state`, `_errorMessage`, `_selectedLocation`
  - Getters for all state variables
- [ ] Implement `checkLocationStatus()` method
  - Check if location is already saved
  - If yes, set state to `completed`
  - If no, call `requestGPSLocation()`
- [ ] Implement `requestGPSLocation()` method
  - Request GPS permission
  - Fetch GPS coordinates
  - Get address from coordinates
  - Extract province and district
  - Save location
  - Handle all error scenarios
- [ ] Implement `saveManualLocation(String province, String district)` method
  - Create `UserLocation` with manual data
  - Save to preferences
  - Set state to `completed`
- [ ] Add `reset()` method to restart onboarding

**Validation**:
- State transitions work correctly
- GPS flow works end-to-end
- Manual selection flow works
- Errors are handled and displayed

**Dependencies**: Tasks 1.1, 1.2, 1.3, 2.1

---

### Task 3.2: Create LocationOnboardingScreen
**Estimated Time**: 1 hour

- [ ] Create `lib/presentation/screens/location_onboarding_screen.dart`
- [ ] Add UI for different states:
  - `checkingLocation`: Show splash with spinner
  - `requestingGPS`: Show dialog explaining location need
  - `fetchingGPS`: Show loading indicator
  - `showingManual`: Show `LocationSelectionBottomSheet`
  - `error`: Show error message with retry button
- [ ] Add navigation logic
  - Navigate to `HomeScreen` when `completed`
- [ ] Add branding elements (logo, colors)
- [ ] Add "Neden konum gerekli?" info button

**Validation**:
- All states display correctly
- Navigation works
- UI matches design guidelines
- Error states show retry button

**Dependencies**: Task 3.1

---

### Task 3.3: Update LocationSelectionBottomSheet
**Estimated Time**: 2 hours

- [ ] Update `lib/presentation/widgets/discovery/location_selection_bottom_sheet.dart`
- [ ] Replace `LocationConstants` with `LocationRepository`
- [ ] Add loading state for provinces
  - Show skeleton loader while fetching
- [ ] Add loading state for districts
  - Show skeleton loader while fetching
- [ ] Add error handling
  - Show error message with retry button
  - Show cached data if available
- [ ] Add search functionality for provinces
  - Add search TextField
  - Filter provinces as user types
- [ ] Add search functionality for districts
  - Filter districts as user types
- [ ] Update "Konumu Uygula" button
  - Call `LocationOnboardingProvider.saveManualLocation()`
  - Close bottom sheet on success
- [ ] Remove "Haritadan Seç" button (out of scope for now)
- [ ] Remove "Mevcut Konumumu Kullan" button (handled by onboarding screen)

**Validation**:
- Provinces load from database
- Districts load when province is selected
- Search works for both provinces and districts
- Loading and error states display correctly
- Manual selection saves correctly

**Dependencies**: Tasks 1.2, 3.1

---

## Phase 4: App Integration

### Task 4.1: Update App Initialization
**Estimated Time**: 1 hour

- [ ] Update `lib/main.dart`
- [ ] Add `LocationOnboardingProvider` to `MultiProvider`
- [ ] Update `AppRouter` to handle onboarding
  - Add `/onboarding` route
  - Set initial route based on location status
- [ ] Add location check in app initialization
  - If location not set, navigate to onboarding
  - If location set, navigate to home

**Validation**:
- New users see onboarding screen
- Users with location go directly to home
- Provider is accessible throughout app

**Dependencies**: Tasks 3.1, 3.2

---

### Task 4.2: Update DiscoveryProvider Integration
**Estimated Time**: 45 minutes

- [ ] Update `lib/presentation/providers/discovery_provider.dart`
- [ ] Modify `_initialize()` method
  - Check if location is set before attempting GPS
  - Use saved location from `LocationPreferences`
- [ ] Update `updateLocation()` method
  - Save new location to `LocationPreferences`
- [ ] Update `updateManualLocation()` method
  - Save to `LocationPreferences`

**Validation**:
- DiscoveryProvider uses saved location
- Location updates are persisted
- No duplicate location requests

**Dependencies**: Task 1.3

---

## Phase 5: Testing & Polish

### Task 5.1: Add Unit Tests
**Estimated Time**: 2 hours

- [ ] Create `test/data/repositories/location_repository_test.dart`
  - Test `fetchProvinces()`
  - Test `fetchDistrictsByProvince()`
  - Test caching
  - Test error handling
- [ ] Create `test/data/services/location_preferences_test.dart`
  - Test save/load/clear operations
  - Test `isLocationSet()`
- [ ] Create `test/presentation/providers/location_onboarding_provider_test.dart`
  - Test state transitions
  - Test GPS flow
  - Test manual selection flow
  - Test error scenarios

**Validation**:
- All tests pass
- Code coverage > 80% for new code

**Dependencies**: All previous tasks

---

### Task 5.2: Manual Testing
**Estimated Time**: 1.5 hours

- [ ] Test GPS permission scenarios
  - First launch with permission granted
  - First launch with permission denied
  - First launch with permission denied forever
- [ ] Test manual selection
  - Select different provinces and districts
  - Test search functionality
  - Test error scenarios (network off)
- [ ] Test app restart
  - Verify location persists
  - Verify no re-onboarding for existing users
- [ ] Test location change
  - Change location from ExploreScreen
  - Verify new location is saved
- [ ] Test offline scenarios
  - Start app offline with saved location
  - Start app offline without saved location

**Validation**:
- All scenarios work as expected
- No crashes or unexpected behavior
- User experience is smooth

**Dependencies**: All previous tasks

---

### Task 5.3: Performance Optimization
**Estimated Time**: 1 hour

- [ ] Profile app startup time
  - Measure time to show onboarding
  - Measure time to complete onboarding
- [ ] Optimize database queries
  - Add indexes if needed
  - Reduce query size if needed
- [ ] Optimize caching
  - Ensure cache hits are fast
  - Prevent memory leaks
- [ ] Optimize UI rendering
  - Reduce unnecessary rebuilds
  - Lazy load district lists

**Validation**:
- App startup time < 2 seconds
- Onboarding completion time < 30 seconds
- No memory leaks
- Smooth UI performance

**Dependencies**: Task 5.2

---

### Task 5.4: Documentation & Cleanup
**Estimated Time**: 30 minutes

- [ ] Add code documentation
  - Document all public methods
  - Add usage examples
- [ ] Update README if needed
- [ ] Remove deprecated `LocationConstants` (if safe)
- [ ] Clean up debug logs
- [ ] Add analytics events
  - `onboarding_started`
  - `onboarding_gps_granted`
  - `onboarding_gps_denied`
  - `onboarding_manual_selected`
  - `onboarding_completed`

**Validation**:
- Code is well-documented
- No unused code
- Analytics events fire correctly

**Dependencies**: All previous tasks

---

## Summary

**Total Estimated Time**: ~13 hours

**Critical Path**:
1. Data models and repository (Tasks 1.1, 1.2, 1.3)
2. Location service enhancement (Task 2.1)
3. Provider and screens (Tasks 3.1, 3.2, 3.3)
4. App integration (Tasks 4.1, 4.2)
5. Testing and polish (Tasks 5.1, 5.2, 5.3, 5.4)

**Parallelizable Work**:
- Tasks 1.1, 1.2, 1.3 can be done in parallel
- Tasks 3.2 and 3.3 can be done in parallel after 3.1
- Tasks 5.1 and 5.2 can be done in parallel

**Risk Areas**:
- GPS permission handling on different Android/iOS versions
- Address parsing from GPS coordinates (may need refinement)
- Database query performance with large district lists
- Offline handling and caching strategy
