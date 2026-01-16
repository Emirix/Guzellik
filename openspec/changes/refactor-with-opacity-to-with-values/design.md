# Design: Refactor `withOpacity` to `withValues(alpha: ...)`

## Architectural Reasoning
In Flutter 3.27 and newer, the `Color.withOpacity` method has been superseded by `Color.withValues`. The primary reason for this change in the Flutter engine is better support for wide-gamut colors and more consistent behavior across different color spaces. 

From a performance standpoint, `withValues` is designed to be more efficient when working with the newer Impeller rendering engine, which is now the default on iOS and being rolled out on Android.

## Implementation Details

### Transformation Rule
The refactor follows a simple direct translation:
-   **Old**: `color.withOpacity(opacity)` where `opacity` is a `double` between 0.0 and 1.0.
-   **New**: `color.withValues(alpha: opacity)` where `alpha` is the same `double` value.

### Scope
The change covers all Dart files in the `lib/` directory.

### Example
```dart
// Before
Container(
  color: Colors.black.withOpacity(0.5),
)

// After
Container(
  color: Colors.black.withValues(alpha: 0.5),
)
```

## Potential Risks & Mitigations
-   **Parameter Name Confusion**: `withValues` can take other parameters (red, green, blue). We must ensure we only target the `alpha` parameter to match `withOpacity` behavior.
-   **Flutter Version Dependency**: This change requires Flutter 3.27 or newer. If the project is on an older version, this will cause build errors. 
    -   *Mitigation*: Check `pubspec.yaml` for the environment SDK version and potentially `flutter --version`.
