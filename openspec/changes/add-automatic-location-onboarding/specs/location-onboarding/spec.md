# Capability: Location Onboarding

## ADDED Requirements

### Requirement: Mandatory Location Selection on First Launch

**Priority**: P0 (Critical)

**Description**: The application MUST ensure that every user has a valid location (province + district) set before they can access the main application features. This location can be obtained either through GPS or manual selection.

#### Scenario: New User with GPS Permission Granted

**Given** a new user launches the app for the first time  
**And** the user has not previously set a location  
**When** the app requests GPS permission  
**And** the user grants GPS permission  
**Then** the app MUST fetch the user's current GPS coordinates  
**And** the app MUST convert coordinates to a readable address  
**And** the app MUST extract the province and district from the address  
**And** the app MUST save the location to local storage  
**And** the app MUST navigate the user to the main home screen  
**And** the entire process MUST complete within 10 seconds (excluding user interaction time)

**Acceptance Criteria**:
- GPS permission dialog is shown
- Location is fetched and saved automatically
- User sees a brief loading indicator
- User is taken to home screen without manual intervention
- Location persists across app restarts

---

#### Scenario: New User with GPS Permission Denied

**Given** a new user launches the app for the first time  
**And** the user has not previously set a location  
**When** the app requests GPS permission  
**And** the user denies GPS permission  
**Then** the app MUST show the location selection bottom sheet  
**And** the bottom sheet MUST display a list of all Turkish provinces  
**And** the user MUST be able to select a province  
**And** after selecting a province, the user MUST be able to select a district  
**And** the user MUST be able to confirm the selection  
**And** the app MUST save the manually selected location  
**And** the app MUST navigate the user to the main home screen

**Acceptance Criteria**:
- Bottom sheet appears automatically after permission denial
- Province and district dropdowns are functional
- User cannot proceed without selecting both province and district
- "Konumu Uygula" button is disabled until both are selected
- Location is saved and persists across app restarts

---

#### Scenario: New User with GPS Permission Denied Forever

**Given** a new user launches the app for the first time  
**And** the user has previously denied GPS permission permanently  
**When** the app checks GPS permission status  
**Then** the app MUST NOT request GPS permission again  
**And** the app MUST immediately show the location selection bottom sheet  
**And** the bottom sheet SHOULD display a message explaining that GPS is disabled  
**And** the bottom sheet SHOULD provide a button to open app settings  
**And** the user MUST be able to select location manually

**Acceptance Criteria**:
- No permission dialog is shown
- Bottom sheet appears immediately
- Settings button opens device settings
- Manual selection works as expected

---

#### Scenario: Existing User with Saved Location

**Given** a user has previously set a location  
**When** the user launches the app  
**Then** the app MUST load the saved location from local storage  
**And** the app MUST NOT show the onboarding flow  
**And** the app MUST navigate directly to the main home screen  
**And** the app MUST use the saved location for venue discovery

**Acceptance Criteria**:
- No onboarding screen is shown
- App launches directly to home
- Saved location is used for filtering venues
- Location display shows correct province and district

---

### Requirement: GPS Location Extraction

**Priority**: P0 (Critical)

**Description**: When GPS coordinates are obtained, the application MUST accurately extract the province and district information from the address.

#### Scenario: GPS Coordinates to Province and District

**Given** the app has obtained GPS coordinates  
**When** the app converts coordinates to an address  
**Then** the app MUST parse the address string  
**And** the app MUST identify the province name  
**And** the app MUST identify the district name  
**And** the extracted names MUST match entries in the `provinces` and `districts` tables  
**And** if no exact match is found, the app SHOULD use fuzzy matching  
**And** if fuzzy matching fails, the app MUST fall back to manual selection

**Acceptance Criteria**:
- Province and district are correctly extracted for major cities (Istanbul, Ankara, Izmir)
- Extraction works for at least 90% of locations in Turkey
- Fuzzy matching handles minor spelling variations
- Fallback to manual selection works smoothly

---

### Requirement: Location Persistence

**Priority**: P0 (Critical)

**Description**: The selected location MUST be persisted locally and survive app restarts, updates, and device reboots.

#### Scenario: Location Persists Across App Restarts

**Given** a user has set a location  
**When** the user closes the app  
**And** the user reopens the app  
**Then** the app MUST load the previously saved location  
**And** the app MUST NOT show the onboarding flow again  
**And** the location display MUST show the correct province and district

**Acceptance Criteria**:
- Location is saved to SharedPreferences
- Location is loaded on app startup
- No data loss occurs

---

#### Scenario: Location Persists After App Update

**Given** a user has set a location in version X of the app  
**When** the user updates to version Y  
**And** the user opens the app  
**Then** the app MUST load the previously saved location  
**And** the app MUST NOT require re-onboarding

**Acceptance Criteria**:
- SharedPreferences data survives app updates
- No migration is needed for location data

---

### Requirement: Onboarding State Management

**Priority**: P1 (High)

**Description**: The onboarding flow MUST have clear, well-defined states with appropriate UI feedback for each state.

#### Scenario: Onboarding State Transitions

**Given** the onboarding flow has started  
**Then** the app MUST transition through the following states in order:
1. `initial` - App just started
2. `checkingLocation` - Checking if location is already saved
3. `requestingGPS` - Requesting GPS permission (if not saved)
4. `fetchingGPS` - Fetching GPS coordinates (if permission granted)
5. `showingManual` - Showing manual selection (if GPS fails)
6. `completed` - Location is set, ready to proceed

**And** each state MUST have appropriate UI feedback:
- `checkingLocation`: Splash screen with spinner
- `requestingGPS`: Dialog explaining why location is needed
- `fetchingGPS`: Loading indicator
- `showingManual`: Location selection bottom sheet
- `completed`: Navigate to home screen

**Acceptance Criteria**:
- State transitions are predictable and logical
- UI updates correctly for each state
- No state is skipped or repeated unnecessarily
- User can always see what's happening

---

### Requirement: Error Handling

**Priority**: P1 (High)

**Description**: The onboarding flow MUST gracefully handle all error scenarios and provide clear feedback to users.

#### Scenario: GPS Timeout

**Given** the app is fetching GPS coordinates  
**When** the GPS request times out after 10 seconds  
**Then** the app MUST show an error message  
**And** the app MUST fall back to manual location selection  
**And** the error message SHOULD explain what happened

**Acceptance Criteria**:
- Timeout is set to 10 seconds
- Error message is user-friendly
- Manual selection is shown automatically

---

#### Scenario: Network Error During Province Fetch

**Given** the app is fetching provinces from the database  
**When** a network error occurs  
**Then** the app MUST show an error message  
**And** the app SHOULD show cached provinces if available  
**And** the app MUST provide a retry button  
**And** the retry button MUST re-attempt the fetch

**Acceptance Criteria**:
- Error message is clear and actionable
- Cached data is used when available
- Retry button works correctly

---

#### Scenario: Invalid Address Parsing

**Given** the app has obtained GPS coordinates  
**When** the address cannot be parsed to extract province and district  
**Then** the app MUST log the error for debugging  
**And** the app MUST fall back to manual location selection  
**And** the app SHOULD show a message explaining the issue

**Acceptance Criteria**:
- Error is logged with full address details
- Fallback to manual selection is automatic
- User is informed of the issue

---

### Requirement: User Experience

**Priority**: P1 (High)

**Description**: The onboarding flow MUST be quick, intuitive, and non-intrusive.

#### Scenario: Onboarding Completion Time

**Given** a new user starts the onboarding flow  
**When** the user completes all steps  
**Then** the total time from app launch to home screen SHOULD be less than 30 seconds  
**And** the GPS flow (if successful) SHOULD complete in less than 10 seconds  
**And** the manual selection flow SHOULD be completable in less than 20 seconds

**Acceptance Criteria**:
- Performance metrics are tracked
- No unnecessary delays are introduced
- Loading indicators are shown during waits

---

#### Scenario: Clear Call-to-Action

**Given** the user is on the manual location selection screen  
**Then** the UI MUST clearly indicate what the user needs to do  
**And** the "Konumu Uygula" button MUST be prominently displayed  
**And** the button MUST be disabled until both province and district are selected  
**And** the button MUST show a loading state while saving

**Acceptance Criteria**:
- UI is intuitive and self-explanatory
- Button states are clear (enabled/disabled/loading)
- User knows what to do at each step

---

## MODIFIED Requirements

None - This is a new capability with no modifications to existing requirements.

---

## REMOVED Requirements

None - This is a new capability with no removals.
