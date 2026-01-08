# Capability: Location Data Management

## ADDED Requirements

### Requirement: Province Data Retrieval

**Priority**: P0 (Critical)

**Description**: The application MUST fetch province data from the Supabase `provinces` table and make it available for location selection.

#### Scenario: Fetch All Provinces

**Given** the user needs to select a location manually  
**When** the location selection bottom sheet is opened  
**Then** the app MUST query the `provinces` table from Supabase  
**And** the app MUST retrieve all provinces with their `id`, `name`, `latitude`, and `longitude`  
**And** the provinces MUST be ordered alphabetically by `name`  
**And** the query MUST complete within 5 seconds  
**And** the results MUST be cached in memory for subsequent requests

**Acceptance Criteria**:
- All 81 Turkish provinces are retrieved
- Provinces are sorted alphabetically
- Query is performant (< 5 seconds)
- Results are cached to avoid redundant queries
- Cache is cleared on app restart

---

#### Scenario: Province Data Caching

**Given** provinces have been fetched once  
**When** the user opens the location selection bottom sheet again  
**Then** the app MUST use the cached province data  
**And** the app MUST NOT make another database query  
**And** the cached data MUST be displayed immediately (< 100ms)

**Acceptance Criteria**:
- Cache is implemented in `LocationRepository`
- No duplicate queries are made
- Cache hit is fast (< 100ms)
- Cache is thread-safe

---

### Requirement: District Data Retrieval

**Priority**: P0 (Critical)

**Description**: The application MUST fetch district data for a selected province from the Supabase `districts` table.

#### Scenario: Fetch Districts for Selected Province

**Given** the user has selected a province  
**When** the province selection is confirmed  
**Then** the app MUST query the `districts` table from Supabase  
**And** the app MUST filter districts where `province_id` matches the selected province's `id`  
**And** the districts MUST be ordered alphabetically by `name`  
**And** the query MUST complete within 3 seconds  
**And** the results SHOULD be cached per province

**Acceptance Criteria**:
- Only districts for the selected province are retrieved
- Districts are sorted alphabetically
- Query is performant (< 3 seconds)
- Results are cached per province
- Cache is invalidated when province changes

---

#### Scenario: District Data for Istanbul

**Given** the user selects "İstanbul" province  
**When** the districts are fetched  
**Then** the app MUST return all 39 districts of Istanbul  
**And** the districts MUST include "Kadıköy", "Beşiktaş", "Üsküdar", etc.  
**And** the districts MUST be ordered alphabetically

**Acceptance Criteria**:
- All Istanbul districts are present
- District names match database exactly
- Alphabetical ordering is correct

---

### Requirement: Location Data Models

**Priority**: P0 (Critical)

**Description**: The application MUST define clear data models for provinces, districts, and user locations.

#### Scenario: Province Model Structure

**Given** province data is fetched from the database  
**Then** the `Province` model MUST have the following fields:
- `id` (int, required): Unique identifier
- `name` (String, required): Province name
- `latitude` (double, optional): Province center latitude
- `longitude` (double, optional): Province center longitude

**And** the model MUST support JSON serialization  
**And** the model MUST support JSON deserialization

**Acceptance Criteria**:
- Model is defined in `lib/data/models/province.dart`
- All fields are correctly typed
- `fromJson` and `toJson` methods work correctly
- Null safety is properly handled

---

#### Scenario: District Model Structure

**Given** district data is fetched from the database  
**Then** the `District` model MUST have the following fields:
- `id` (String, required): Unique identifier (UUID)
- `provinceId` (int, required): Foreign key to province
- `name` (String, required): District name

**And** the model MUST support JSON serialization  
**And** the model MUST support JSON deserialization

**Acceptance Criteria**:
- Model is defined in `lib/data/models/district.dart`
- All fields are correctly typed
- `fromJson` and `toJson` methods work correctly
- Foreign key relationship is clear

---

#### Scenario: UserLocation Model Structure

**Given** a user has selected or obtained a location  
**Then** the `UserLocation` model MUST have the following fields:
- `provinceName` (String, required): Name of the province
- `districtName` (String, required): Name of the district
- `provinceId` (int, optional): ID of the province
- `latitude` (double, optional): GPS latitude
- `longitude` (double, optional): GPS longitude
- `isGPSBased` (bool, required): Whether location was obtained via GPS

**And** the model MUST support JSON serialization for local storage  
**And** the model MUST support JSON deserialization

**Acceptance Criteria**:
- Model is defined in `lib/data/models/user_location.dart`
- All fields are correctly typed
- `fromJson` and `toJson` methods work correctly
- Model can be saved to and loaded from SharedPreferences

---

### Requirement: Location Repository

**Priority**: P0 (Critical)

**Description**: The application MUST provide a repository layer for accessing location data from Supabase.

#### Scenario: LocationRepository Interface

**Given** the app needs to fetch location data  
**Then** the `LocationRepository` MUST provide the following methods:
- `Future<List<Province>> fetchProvinces()`: Fetch all provinces
- `Future<List<District>> fetchDistrictsByProvince(int provinceId)`: Fetch districts for a province

**And** each method MUST handle errors gracefully  
**And** each method MUST support timeout (10 seconds)  
**And** each method MUST return empty list on error (not throw)

**Acceptance Criteria**:
- Repository is defined in `lib/data/repositories/location_repository.dart`
- Methods are well-documented
- Error handling is comprehensive
- Timeouts are implemented

---

#### Scenario: Repository Error Handling

**Given** a network error occurs during data fetch  
**When** `fetchProvinces()` or `fetchDistrictsByProvince()` is called  
**Then** the method MUST catch the error  
**And** the method MUST log the error for debugging  
**And** the method MUST return an empty list  
**And** the method MUST NOT throw an exception

**Acceptance Criteria**:
- Errors are caught and logged
- Empty list is returned on error
- No unhandled exceptions
- Error details are logged for debugging

---

### Requirement: Local Storage

**Priority**: P0 (Critical)

**Description**: The application MUST persist the user's selected location locally using SharedPreferences.

#### Scenario: Save Location to Local Storage

**Given** a user has selected or obtained a location  
**When** the location is saved  
**Then** the app MUST serialize the `UserLocation` to JSON  
**And** the app MUST save the JSON string to SharedPreferences with key `'user_location'`  
**And** the save operation MUST complete within 1 second  
**And** the save operation MUST NOT fail silently

**Acceptance Criteria**:
- Location is saved as JSON string
- Key is `'user_location'`
- Save is fast (< 1 second)
- Errors are logged

---

#### Scenario: Load Location from Local Storage

**Given** a location has been previously saved  
**When** the app starts  
**Then** the app MUST load the JSON string from SharedPreferences  
**And** the app MUST deserialize the JSON to a `UserLocation` object  
**And** the load operation MUST complete within 500ms  
**And** if no location is saved, the method MUST return `null`

**Acceptance Criteria**:
- Location is loaded correctly
- Deserialization works
- Load is fast (< 500ms)
- Returns null when no location is saved

---

#### Scenario: Check if Location is Set

**Given** the app needs to determine if a location is already saved  
**When** `isLocationSet()` is called  
**Then** the method MUST check if the `'user_location'` key exists in SharedPreferences  
**And** the method MUST return `true` if the key exists  
**And** the method MUST return `false` if the key does not exist  
**And** the check MUST complete within 100ms

**Acceptance Criteria**:
- Method is fast (< 100ms)
- Returns correct boolean
- No exceptions are thrown

---

### Requirement: Search and Filter

**Priority**: P2 (Medium)

**Description**: The location selection UI SHOULD support search and filter functionality to help users quickly find their province and district.

#### Scenario: Search Provinces

**Given** the user is selecting a province  
**When** the user types in the search field  
**Then** the province list MUST be filtered to show only provinces whose names contain the search query  
**And** the search MUST be case-insensitive  
**And** the search MUST support Turkish characters (ı, ğ, ü, ş, ö, ç)  
**And** the search results MUST update in real-time as the user types

**Acceptance Criteria**:
- Search field is present in province dropdown
- Filtering works correctly
- Turkish characters are handled
- Real-time updates work smoothly

---

#### Scenario: Search Districts

**Given** the user has selected a province and is selecting a district  
**When** the user types in the search field  
**Then** the district list MUST be filtered to show only districts whose names contain the search query  
**And** the search MUST be case-insensitive  
**And** the search MUST support Turkish characters  
**And** the search results MUST update in real-time

**Acceptance Criteria**:
- Search field is present in district dropdown
- Filtering works correctly
- Turkish characters are handled
- Real-time updates work smoothly

---

## MODIFIED Requirements

### Requirement: Location Display in Discovery

**Priority**: P1 (High)

**Description**: The discovery screen's location display MUST use the saved location from local storage instead of relying solely on GPS.

#### Scenario: Display Saved Location

**Given** a user has a saved location  
**When** the user opens the discovery screen  
**Then** the location header MUST display the saved province and district  
**And** the format MUST be "{district}, {province}"  
**Example**: "Kadıköy, İstanbul"

**Acceptance Criteria**:
- Location is loaded from SharedPreferences
- Display format is correct
- Location is shown immediately on screen load

**Changes from Previous Behavior**:
- **Before**: Location was only fetched via GPS on each app launch
- **After**: Location is loaded from local storage first, GPS is optional

---

## REMOVED Requirements

### Requirement: Hardcoded Location Constants

**Priority**: P2 (Medium)

**Description**: The `LocationConstants` class with hardcoded province and district data SHOULD be deprecated and eventually removed.

#### Scenario: Deprecate LocationConstants

**Given** the app now fetches location data from the database  
**Then** the `LocationConstants` class SHOULD be marked as deprecated  
**And** all usages SHOULD be replaced with `LocationRepository`  
**And** the class MAY be removed in a future release after confirming database stability

**Acceptance Criteria**:
- `LocationConstants` is marked with `@deprecated` annotation
- All references are updated to use `LocationRepository`
- Class can be safely removed in future

**Rationale**: Hardcoded data is difficult to maintain and can become outdated. Database-driven data is more flexible and accurate.

---

## Database Schema Requirements

### Requirement: Provinces Table Structure

**Priority**: P0 (Critical)

**Description**: The `provinces` table MUST exist in Supabase with the correct structure and data.

#### Scenario: Provinces Table Schema

**Given** the app queries the `provinces` table  
**Then** the table MUST have the following columns:
- `id` (INTEGER, PRIMARY KEY): Unique province ID (1-81)
- `name` (TEXT, NOT NULL, UNIQUE): Province name
- `latitude` (DOUBLE PRECISION, NULLABLE): Province center latitude
- `longitude` (DOUBLE PRECISION, NULLABLE): Province center longitude

**And** the table MUST have Row Level Security (RLS) enabled  
**And** the table MUST have a policy allowing public read access  
**And** the table MUST contain all 81 Turkish provinces

**Acceptance Criteria**:
- Table exists with correct schema
- RLS is enabled
- Public read policy exists
- All 81 provinces are present

---

### Requirement: Districts Table Structure

**Priority**: P0 (Critical)

**Description**: The `districts` table MUST exist in Supabase with the correct structure and data.

#### Scenario: Districts Table Schema

**Given** the app queries the `districts` table  
**Then** the table MUST have the following columns:
- `id` (UUID, PRIMARY KEY, DEFAULT gen_random_uuid()): Unique district ID
- `province_id` (INTEGER, FOREIGN KEY to provinces.id, ON DELETE CASCADE): Province reference
- `name` (TEXT, NOT NULL): District name
- UNIQUE constraint on (province_id, name)

**And** the table MUST have Row Level Security (RLS) enabled  
**And** the table MUST have a policy allowing public read access  
**And** the table MUST contain all districts for all 81 provinces

**Acceptance Criteria**:
- Table exists with correct schema
- Foreign key constraint is enforced
- RLS is enabled
- Public read policy exists
- All districts are present

---

## Performance Requirements

### Requirement: Query Performance

**Priority**: P1 (High)

**Description**: Location data queries MUST be performant to ensure a smooth user experience.

#### Scenario: Province Query Performance

**Given** the app queries all provinces  
**When** the query is executed  
**Then** the query MUST complete within 5 seconds  
**And** the query SHOULD complete within 2 seconds under normal network conditions

**Acceptance Criteria**:
- Query time is measured
- Performance meets requirements
- Timeout is set to 10 seconds

---

#### Scenario: District Query Performance

**Given** the app queries districts for a province  
**When** the query is executed  
**Then** the query MUST complete within 3 seconds  
**And** the query SHOULD complete within 1 second under normal network conditions

**Acceptance Criteria**:
- Query time is measured
- Performance meets requirements
- Timeout is set to 10 seconds

---

### Requirement: Cache Performance

**Priority**: P1 (High)

**Description**: Cached location data MUST be retrieved quickly to avoid UI delays.

#### Scenario: Cache Hit Performance

**Given** location data has been cached  
**When** the data is requested again  
**Then** the cached data MUST be returned within 100ms  
**And** no database query MUST be made

**Acceptance Criteria**:
- Cache hit is fast (< 100ms)
- No redundant queries
- Cache is reliable
