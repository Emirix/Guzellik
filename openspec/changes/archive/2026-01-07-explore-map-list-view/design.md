# Design: Discovery Module Architecture

## Overview

The Discovery module is the core of the application. It provides two primary views: a map-based view for spatial exploration and a list-based view for detailed browsing.

## Architecture

### State Management
- **`DiscoveryProvider`**: Manages the state of the discovery screen, including:
  - Current view mode (`map` vs `list`)
  - List of venues fetched from the backend
  - Current map camera position
  - Active search queries and filters

### Component Breakdown
- **`DiscoveryScreen`**: Main container managing layout and view switching.
- **`MapView`**: Wraps `google_maps_flutter` and displays markers.
- **`ListView`**: Displays venues in a scrollable list (e.g., using `VenueCard`).
- **`DiscoverySearchBar`**: Floating search bar at the top with filtering options.
- **`ViewToggle`**: Floating button to switch between Map and List.

### Data Flow
1. **Fetch**: On initialization, `DiscoveryProvider` fetches venues based on the user's current location or map bounds.
2. **Filter**: User applies a search or filter; `DiscoveryProvider` updates the visible list.
3. **Sync**: Map markers and list items remain in sync with the same underlying data source.

### Location Services
- `LocationService` (from `initialize-flutter-project`) will be used to obtain current coordinates and handle permission prompts.

## Visual Design (Daima Premium Style)
- **Map Style**: Custom silver/gold themed map style to match the "Premium" aesthetic.
- **Markers**: Custom brand-colored markers (Nude/Gold) instead of default red pins.
- **Transitions**: Smooth cross-fades or slide transitions between list and map views.
- **Cards**: Glassmorphism or subtle shadows with gold borders for the discovery cards.
