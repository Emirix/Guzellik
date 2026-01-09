# Design: Location Selection Bottom Sheet

## Overview
The location selection bottom sheet will provide a centralized interface for users to manage their discovery location. It aligns with the "Clean, minimal, premium aesthetic" of the project.

## UI Components

### 1. Trigger
-   **Location Header:** Located in the top-left of the `ExploreScreen` (and `DiscoveryHomeView`).
-   **Visuals:** Icon (Location pin), "Konum" label, current City/District name, and an `expand_more` icon.
-   **Interactivity:** `InkWell` wrapper to trigger the bottom sheet.

### 2. Bottom Sheet Layout
-   **Header:** Title "Konum Seçin" with a close button.
-   **Current Location Section:**
    -   High-contrast button: "Mevcut Konumumu Kullan".
    -   Icon: `target` or `my_location`.
-   **Manual Selection Section:**
    -   Labeled input fields or searchable dropdowns for "İl" (City) and "İlçe" (District).
    -   Placeholder text: "İl seçiniz", "İlçe seçiniz".
-   **Map Selection (Optional/Phase 2):**
    -   Button: "Haritadan Seç".
    -   Visual: Opens a mini-map or redirects to a map selection view.
-   **Recently Used Locations:**
    -   Horizontal or vertical list of 2-3 recently selected locations for quick access.

## Interaction Flow
1.  User taps the location header.
2.  `LocationSelectionBottomSheet` slides up.
3.  User selects one of three paths:
    -   **GPS:** Taps "Mevcut Konumumu Kullan" -> App requests/uses permission -> Updates provider -> Closes sheet.
    -   **Manual:** Selects City and District -> Taps "Konumu Uygula" -> Updates provider -> Closes sheet.
    -   **Map:** Taps "Haritadan Seç" -> Interface updates to map view -> User picks point -> Confirms -> Updates provider -> Closes sheet.
4.  `DiscoveryProvider.refresh()` is called to update search results based on the new location.

## Technical Details

### State Management
-   `DiscoveryProvider` will hold:
    -   `_manualCity`: String?
    -   `_manualDistrict`: String?
    -   `isUsingManualLocation`: Boolean
-   `DiscoveryProvider.updateManualLocation(String city, String district)`: New method to set location manually.

### Data
-   Need a list of Turkish cities and districts. This can be hardcoded as a static asset or fetched if a large list is needed. For MVP, we can start with a searchable list or common cities.

## Aesthetic Details
-   **Colors:** `AppColors.primary` (Nude/Pink) for buttons, `AppColors.white` for background.
-   **Typography:** Bold headers, medium weight for labels.
-   **Shapes:** Rounded corners (24px or more) for the bottom sheet.
