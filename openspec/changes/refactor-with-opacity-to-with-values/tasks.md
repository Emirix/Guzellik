# Tasks: Refactor `withOpacity` to `withValues(alpha: ...)`

- [x] **Phase 1: Analysis & Preparation**
    - [x] Run `flutter --version` to confirm Flutter 3.27+ availability (Done: 3.38.5) <!-- id: 0 -->
    - [/] Identify all occurrences of `withOpacity` in `lib/` <!-- id: 1 -->
    - [x] Create a backup or ensure git state is clean <!-- id: 2 -->

- [x] **Phase 2: Execution**
    - [x] Replace `withOpacity` with `withValues(alpha: ...)` in `lib/presentation/widgets/venue/` <!-- id: 3 -->
    - [x] Replace `withOpacity` with `withValues(alpha: ...)` in `lib/presentation/widgets/search/` <!-- id: 4 -->
    - [x] Replace `withOpacity` with `withValues(alpha: ...)` in `lib/presentation/widgets/discovery/` <!-- id: 5 -->
    - [x] Replace `withOpacity` with `withValues(alpha: ...)` in `lib/presentation/widgets/profile/` <!-- id: 6 -->
    - [x] Replace all remaining occurrences in `lib/` <!-- id: 7 -->

- [x] **Phase 3: Validation**
    - [x] Run `flutter analyze` to check for errors <!-- id: 8 -->
    - [x] Run `flutter test` (if applicable) <!-- id: 9 -->
    - [x] Manual visual inspection of key screens <!-- id: 10 -->
    - [x] Perform hot reload/restart to ensure no runtime crashes <!-- id: 11 -->
