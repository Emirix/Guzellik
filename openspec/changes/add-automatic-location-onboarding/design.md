# Design: Automatic Location Onboarding

## Architecture Overview

This feature introduces a location onboarding flow that ensures users always have a valid location context before accessing the main application. The design follows a layered architecture with clear separation of concerns.

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        App Layer                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  main.dart - App Initialization                       │   │
│  │  - Check location status                              │   │
│  │  - Show onboarding if needed                          │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  LocationOnboardingProvider                           │   │
│  │  - Manage onboarding state                            │   │
│  │  - Coordinate GPS and manual flows                    │   │
│  │  - Persist location selection                         │   │
│  └──────────────────────────────────────────────────────┘   │
│                            ↓                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  LocationOnboardingScreen (new)                       │   │
│  │  - Wrapper for onboarding flow                        │   │
│  │  - Shows loading/GPS request states                   │   │
│  │  - Triggers bottom sheet when needed                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                            ↓                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  LocationSelectionBottomSheet (enhanced)              │   │
│  │  - Fetch provinces/districts from repository          │   │
│  │  - Show loading and error states                      │   │
│  │  - Support search/filter                              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  LocationRepository (new)                             │   │
│  │  - fetchProvinces()                                   │   │
│  │  - fetchDistrictsByProvince(provinceId)               │   │
│  │  - Cache location data                                │   │
│  └──────────────────────────────────────────────────────┘   │
│                            ↓                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  LocationService (enhanced)                           │   │
│  │  - getCurrentPosition()                               │   │
│  │  - checkPermission()                                  │   │
│  │  - requestPermission()                                │   │
│  │  - getAddressFromCoordinates()                        │   │
│  └──────────────────────────────────────────────────────┘   │
│                            ↓                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  LocationPreferences (new)                            │   │
│  │  - Save/load selected location                        │   │
│  │  - Check if location is set                           │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   External Services                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Supabase (provinces, districts tables)               │   │
│  │  Geolocator (GPS permissions and location)            │   │
│  │  Shared Preferences (local storage)                   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. App Launch Flow

```
User opens app
    ↓
main.dart initializes
    ↓
LocationOnboardingProvider.checkLocationStatus()
    ↓
LocationPreferences.isLocationSet()
    ↓
    ├─ true → Navigate to HomeScreen
    ↓
    └─ false → Show LocationOnboardingScreen
                ↓
                Attempt GPS location
                ↓
                ├─ Success → Save location → Navigate to HomeScreen
                ↓
                └─ Failure → Show LocationSelectionBottomSheet
                             ↓
                             User selects province + district
                             ↓
                             Save location → Navigate to HomeScreen
```

### 2. GPS Location Flow

```
LocationOnboardingProvider.requestGPSLocation()
    ↓
LocationService.checkPermission()
    ↓
    ├─ granted → LocationService.getCurrentPosition()
    │            ↓
    │            LocationService.getAddressFromCoordinates()
    │            ↓
    │            Extract province + district
    │            ↓
    │            LocationPreferences.saveLocation()
    │            ↓
    │            Success
    ↓
    ├─ denied → LocationService.requestPermission()
    │           ↓
    │           ├─ granted → (same as above)
    │           └─ denied → Show manual selection
    ↓
    └─ deniedForever → Show manual selection
```

### 3. Manual Location Selection Flow

```
User opens LocationSelectionBottomSheet
    ↓
LocationRepository.fetchProvinces()
    ↓
Display provinces in dropdown
    ↓
User selects province
    ↓
LocationRepository.fetchDistrictsByProvince(provinceId)
    ↓
Display districts in dropdown
    ↓
User selects district
    ↓
User taps "Konumu Uygula"
    ↓
LocationPreferences.saveLocation(province, district)
    ↓
Close bottom sheet
    ↓
Navigate to HomeScreen
```

## Data Models

### Province Model

```dart
class Province {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;

  Province({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }
}
```

### District Model

```dart
class District {
  final String id;
  final int provinceId;
  final String name;

  District({
    required this.id,
    required this.provinceId,
    required this.name,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as String,
      provinceId: json['province_id'] as int,
      name: json['name'] as String,
    );
  }
}
```

### UserLocation Model

```dart
class UserLocation {
  final String provinceName;
  final String districtName;
  final int? provinceId;
  final double? latitude;
  final double? longitude;
  final bool isGPSBased;

  UserLocation({
    required this.provinceName,
    required this.districtName,
    this.provinceId,
    this.latitude,
    this.longitude,
    required this.isGPSBased,
  });

  Map<String, dynamic> toJson() {
    return {
      'provinceName': provinceName,
      'districtName': districtName,
      'provinceId': provinceId,
      'latitude': latitude,
      'longitude': longitude,
      'isGPSBased': isGPSBased,
    };
  }

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      provinceName: json['provinceName'] as String,
      districtName: json['districtName'] as String,
      provinceId: json['provinceId'] as int?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      isGPSBased: json['isGPSBased'] as bool,
    );
  }
}
```

## State Management

### LocationOnboardingProvider States

```dart
enum OnboardingState {
  initial,           // Just started
  checkingLocation,  // Checking if location is already set
  requestingGPS,     // Requesting GPS permission
  fetchingGPS,       // Fetching GPS coordinates
  showingManual,     // Showing manual selection
  completed,         // Location is set, ready to proceed
  error,             // Error occurred
}
```

### LocationOnboardingProvider

```dart
class LocationOnboardingProvider extends ChangeNotifier {
  final LocationService _locationService;
  final LocationRepository _locationRepository;
  final LocationPreferences _locationPreferences;

  OnboardingState _state = OnboardingState.initial;
  String? _errorMessage;
  UserLocation? _selectedLocation;

  OnboardingState get state => _state;
  String? get errorMessage => _errorMessage;
  UserLocation? get selectedLocation => _selectedLocation;
  bool get isCompleted => _state == OnboardingState.completed;

  Future<void> checkLocationStatus() async {
    _state = OnboardingState.checkingLocation;
    notifyListeners();

    final location = await _locationPreferences.getLocation();
    if (location != null) {
      _selectedLocation = location;
      _state = OnboardingState.completed;
    } else {
      await requestGPSLocation();
    }
    notifyListeners();
  }

  Future<void> requestGPSLocation() async {
    _state = OnboardingState.requestingGPS;
    notifyListeners();

    try {
      final permission = await _locationService.checkPermission();
      
      if (permission == LocationPermission.denied) {
        final newPermission = await _locationService.requestPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          _showManualSelection();
          return;
        }
      } else if (permission == LocationPermission.deniedForever) {
        _showManualSelection();
        return;
      }

      _state = OnboardingState.fetchingGPS;
      notifyListeners();

      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        _showManualSelection();
        return;
      }

      final address = await _locationService.getAddressFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Extract province and district from address
      // This is a simplified version - actual implementation needs parsing
      final location = UserLocation(
        provinceName: 'Extracted Province',
        districtName: 'Extracted District',
        latitude: position.latitude,
        longitude: position.longitude,
        isGPSBased: true,
      );

      await _locationPreferences.saveLocation(location);
      _selectedLocation = location;
      _state = OnboardingState.completed;
      notifyListeners();

    } catch (e) {
      _errorMessage = e.toString();
      _showManualSelection();
    }
  }

  void _showManualSelection() {
    _state = OnboardingState.showingManual;
    notifyListeners();
  }

  Future<void> saveManualLocation(String province, String district) async {
    final location = UserLocation(
      provinceName: province,
      districtName: district,
      isGPSBased: false,
    );

    await _locationPreferences.saveLocation(location);
    _selectedLocation = location;
    _state = OnboardingState.completed;
    notifyListeners();
  }
}
```

## Database Schema

The feature uses existing Supabase tables:

### provinces table
```sql
CREATE TABLE provinces (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION
);
```

### districts table
```sql
CREATE TABLE districts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    province_id INTEGER REFERENCES provinces(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    UNIQUE(province_id, name)
);
```

## Local Storage Schema

Using Shared Preferences:

```
Key: 'user_location'
Value: JSON string of UserLocation model
Example:
{
  "provinceName": "İstanbul",
  "districtName": "Kadıköy",
  "provinceId": 34,
  "latitude": 40.9833,
  "longitude": 29.0333,
  "isGPSBased": true
}
```

## Performance Considerations

### Caching Strategy

1. **Province List**: Cache in memory after first fetch, refresh on app restart
2. **District Lists**: Cache per province, clear when switching provinces
3. **User Location**: Persist in SharedPreferences, load on app start

### Optimization Techniques

1. **Lazy Loading**: Only fetch districts when a province is selected
2. **Debouncing**: Debounce search input to reduce queries
3. **Pagination**: If district list is very large (> 100), implement pagination
4. **Offline Support**: Cache location data locally, show cached data when offline

## Error Handling

### GPS Errors

| Error | User Message | Action |
|-------|--------------|--------|
| Permission denied | "Konum izni reddedildi. Manuel olarak seçebilirsiniz." | Show manual selection |
| Permission denied forever | "Konum izni kalıcı olarak reddedildi. Ayarlardan izin verebilir veya manuel seçim yapabilirsiniz." | Show manual selection with settings button |
| Location service disabled | "Konum servisleri kapalı. Lütfen açın veya manuel seçim yapın." | Show manual selection |
| Timeout | "Konum alınamadı. Manuel olarak seçebilirsiniz." | Show manual selection |

### Database Errors

| Error | User Message | Action |
|-------|--------------|--------|
| Failed to fetch provinces | "İl listesi yüklenemedi. Lütfen tekrar deneyin." | Show retry button |
| Failed to fetch districts | "İlçe listesi yüklenemedi. Lütfen tekrar deneyin." | Show retry button |
| Network error | "İnternet bağlantınızı kontrol edin." | Show cached data if available |

## UI/UX Considerations

### Loading States

1. **Checking Location**: Show splash screen with spinner
2. **Requesting GPS**: Show dialog explaining why location is needed
3. **Fetching GPS**: Show loading indicator
4. **Loading Provinces/Districts**: Show skeleton loaders in dropdowns

### Empty States

1. **No Cached Provinces**: Show message to connect to internet
2. **No Districts for Province**: Show "İlçe bulunamadı" message

### Success States

1. **GPS Success**: Brief success message, auto-navigate to main app
2. **Manual Selection Success**: Close bottom sheet, navigate to main app

## Security Considerations

1. **Location Privacy**: Never send GPS coordinates to server without user consent
2. **Data Validation**: Validate province and district selections before saving
3. **Permission Handling**: Respect user's permission choices, don't spam requests

## Accessibility

1. **Screen Reader Support**: Add semantic labels to all interactive elements
2. **Keyboard Navigation**: Ensure dropdowns are keyboard-accessible
3. **Color Contrast**: Ensure text meets WCAG AA standards
4. **Touch Targets**: Minimum 44x44 points for all interactive elements

## Migration Strategy

### Existing Users

Users who already have the app installed will go through onboarding on next app launch if they don't have a location set. This is acceptable since:
1. Most users likely already have location from `DiscoveryProvider` initialization
2. The flow is quick and non-intrusive
3. It ensures data consistency going forward

### LocationConstants Deprecation

1. Keep `LocationConstants` for now as fallback
2. Update `LocationSelectionBottomSheet` to use database first, fallback to constants
3. Remove `LocationConstants` in future release after confirming database stability
