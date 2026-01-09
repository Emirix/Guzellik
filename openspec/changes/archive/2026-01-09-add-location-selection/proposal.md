# Change: Implement Location Selection Bottom Sheet

## Why
Currently, the application only supports location updates via GPS. Users cannot manually change their location to explore services in other cities or districts. This limits discovery in other regions.

## What Changes
- Implement a `LocationSelectionBottomSheet` triggered by tapping the top-left location info.
- Add manual selection for City and District.
- Add "Map Selection" capability for choosing location visually.
- Add "Use Current Location" button for GPS initialization.

## Impact
- Affected specs: `discovery`
- Affected code: `lib/presentation/providers/discovery_provider.dart`, `lib/presentation/screens/explore_screen.dart`, `lib/presentation/widgets/discovery/home_view.dart`.
