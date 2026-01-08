# Proposal: Automatic Location Onboarding

## Overview

**Change ID**: `add-automatic-location-onboarding`

**Problem**: Currently, the application attempts to fetch location in the background during initialization, but there's no guarantee that users will have a location set when they first open the app. If location permission is denied or unavailable, users may not see relevant nearby venues, degrading the discovery experience.

**Solution**: Implement a mandatory location onboarding flow that ensures every user has a location (either GPS-based or manually selected) before they can use the app. This will:
- Automatically request GPS location on first launch
- Show a location selection bottom sheet if GPS is unavailable or denied
- Fetch province and district data from the existing Supabase `provinces` and `districts` tables instead of using hardcoded `LocationConstants`
- Ensure the app always has location context for venue discovery

## Goals

1. **Guarantee Location Context**: Ensure every user has a valid location (city + district) before accessing main app features
2. **Seamless GPS Flow**: Automatically request and use GPS location when available
3. **Graceful Fallback**: Provide manual location selection when GPS is unavailable or denied
4. **Database Integration**: Replace hardcoded location data with dynamic data from Supabase tables
5. **User-Friendly**: Make the onboarding process smooth and non-intrusive

## Non-Goals

- Implementing location-based authentication or user profiles
- Adding location history or favorite locations
- Implementing location-based notifications
- Creating a separate onboarding screen (we'll use existing bottom sheet)

## User Impact

### Positive
- **Better Discovery**: Users will always see relevant nearby venues from the start
- **Clear Expectations**: Users understand why location is needed
- **Flexibility**: Users can choose between GPS and manual selection
- **Accurate Data**: Province and district data comes from the database, ensuring consistency

### Negative
- **Extra Step**: Users must select a location before using the app (minimal friction)
- **Permission Request**: Users will see a system permission dialog on first launch

## Technical Approach

### High-Level Flow

```
App Launch
    ↓
Check if location is set
    ↓
    ├─ YES → Continue to main app
    ↓
    └─ NO → Request GPS permission
              ↓
              ├─ GRANTED → Fetch GPS location → Continue to main app
              ↓
              └─ DENIED → Show location selection bottom sheet
                          ↓
                          User selects province + district
                          ↓
                          Continue to main app
```

### Key Components

1. **Location Repository** (new)
   - Fetch provinces from `provinces` table
   - Fetch districts for a given province from `districts` table
   - Cache location data locally for performance

2. **Location Onboarding Provider** (new)
   - Manage onboarding state
   - Handle GPS permission flow
   - Coordinate with LocationService and LocationRepository

3. **Enhanced LocationService**
   - Add methods to check if location is already set
   - Improve error handling for permission scenarios

4. **Updated LocationSelectionBottomSheet**
   - Fetch provinces and districts from database instead of LocationConstants
   - Handle loading and error states
   - Support search/filter for easier selection

5. **App Initialization Logic**
   - Check location status on app start
   - Show onboarding flow if needed
   - Block navigation to main app until location is set

## Implementation Phases

### Phase 1: Database Integration
- Create `LocationRepository` to fetch provinces and districts from Supabase
- Add caching mechanism for location data
- Update `LocationSelectionBottomSheet` to use repository instead of constants

### Phase 2: Onboarding Logic
- Create `LocationOnboardingProvider` to manage onboarding state
- Implement location check on app initialization
- Add logic to show/hide onboarding based on location status

### Phase 3: UI Flow
- Create onboarding wrapper screen/widget
- Integrate location selection bottom sheet into onboarding flow
- Add loading states and error handling

### Phase 4: Testing & Polish
- Test GPS permission scenarios (granted, denied, denied forever)
- Test manual location selection flow
- Ensure smooth transition to main app
- Add analytics events for tracking onboarding completion

## Open Questions

1. **Persistence**: Where should we store the selected location?
   - Option A: Shared Preferences (simple, local only)
   - Option B: Supabase user profile (requires auth, syncs across devices)
   - **Recommendation**: Start with Shared Preferences for simplicity

2. **Re-selection**: Should users be able to change their location later?
   - **Answer**: Yes, through the existing location header in ExploreScreen

3. **Offline Handling**: What happens if the app is offline during onboarding?
   - **Answer**: Cache provinces/districts locally, show cached data if available

4. **Location Accuracy**: Should we store GPS coordinates or just city/district?
   - **Answer**: Store both - GPS coordinates for distance calculations, city/district for display and filtering

## Success Metrics

- 100% of users have a location set after onboarding
- < 5% of users abandon the app during onboarding
- GPS permission grant rate > 60%
- Average onboarding completion time < 30 seconds

## Dependencies

- Existing `provinces` and `districts` tables in Supabase
- Existing `LocationService` and `LocationSelectionBottomSheet`
- Existing `DiscoveryProvider` for location state management

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Users deny GPS and skip manual selection | High | Make manual selection mandatory (no skip button) |
| Database fetch fails during onboarding | Medium | Cache location data, show cached data as fallback |
| Onboarding feels intrusive | Low | Keep UI minimal, explain why location is needed |
| Performance issues with large district lists | Low | Implement search/filter, lazy loading |

## Related Changes

- None (this is a standalone feature)

## Alternatives Considered

1. **Optional Location**: Allow users to skip location selection
   - **Rejected**: Defeats the purpose of ensuring location context

2. **IP-based Location**: Use IP geolocation as fallback
   - **Rejected**: Less accurate, adds external dependency

3. **Separate Onboarding Screen**: Create a dedicated onboarding screen
   - **Rejected**: Reusing existing bottom sheet is simpler and more consistent
