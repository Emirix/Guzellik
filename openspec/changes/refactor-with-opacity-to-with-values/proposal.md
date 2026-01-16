# Proposal: Refactor `withOpacity` to `withValues(alpha: ...)`

## Overview
Flutter 3.x introduced `withValues` on the `Color` class as a more performant alternative to `withOpacity`. `withOpacity` is now discouraged (and will likely be deprecated or handled less efficiently in future versions) because it creates a new `Color` object in a way that can be less optimized for the engine. Using `withValues(alpha: ...)` is the modern standard for adjusting color transparency in Flutter.

## Problem Statement
The current codebase extensively uses `withOpacity` for transparency. While functional, it doesn't align with modern Flutter best practices and missing out on potential performance optimizations provided by the newer API.

## Proposed Changes
1.  **Global Refactor**: Replace all occurrences of `color.withOpacity(0.x)` with `color.withValues(alpha: 0.x)`.
2.  **Linting/Static Analysis**: Ensure that future additions use the correct API (if possible via custom lint rules, though a simple one-time refactor is the primary goal here).

## Expected Impact
-   **Performance**: Improved rendering performance, especially in complex UI trees with many transparent elements.
-   **Maintainability**: Codebase stays up-to-date with Flutter's latest stable APIs.
-   **Consistency**: Unified way of handling color transparency across the app.

## Verification Plan
1.  **Automated Tests**: Run existing widget and integration tests to ensure no UI regressions.
2.  **Manual Verification**: Visual check of key screens (Venue detail, Search, Discovery) where transparency is heavily used.
3.  **Static Analysis**: Run `flutter analyze` to ensure no new warnings or errors are introduced.
