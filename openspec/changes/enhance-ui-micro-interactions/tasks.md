# Tasks: Enhance UI Micro-Interactions

## Phase 1: Foundation & Dependencies
- [x] Add `shimmer` package to `pubspec.yaml` (version: ^3.0.0) <!-- id: 0 -->
- [x] Run `flutter pub get` to install dependencies <!-- id: 1 -->
- [x] Create `lib/presentation/widgets/common/empty_state.dart` widget scaffold <!-- id: 2 -->
- [x] Add database migration for `specialists.is_featured` boolean column (default: false) <!-- id: 3 -->

## Phase 2: Animations
- [x] Implement pulsing animation for "Open Now" status dot in `WorkingHoursCardV2` <!-- id: 4 -->
- [x] Add button press animations to Follow button in `VenueIdentityV2` <!-- id: 5 -->
- [x] Add button press animations to Contact button in `BookingBottomBar` <!-- id: 6 -->
- [x] Implement glassmorphic effect on map preview button in `MapPreviewV2` <!-- id: 7 -->

## Phase 3: Loading States (Shimmer)
- [x] Replace image placeholders in `VenueOverviewV2` gallery section <!-- id: 8 -->
- [x] Replace image placeholders in `PhotoGalleryViewer` <!-- id: 9 -->
- [x] Replace avatar placeholders in `ExpertsSectionV2` <!-- id: 10 -->
- [ ] Create shimmer skeleton for venue cards (future use in discovery/search) <!-- id: 11 -->

## Phase 4: Visual Hierarchy
- [ ] Add gradient backgrounds to gender-based avatars in `AvatarUtils` <!-- id: 12 -->
- [x] Implement featured expert glow effect in `ExpertsSectionV2` <!-- id: 13 -->
- [x] Update expert sorting logic to prioritize featured experts <!-- id: 14 -->
- [x] Refine section dividers in `VenueOverviewV2` <!-- id: 15 -->

## Phase 5: Empty States
- [x] Implement `EmptyState` widget in `lib/presentation/widgets/common/empty_state.dart` <!-- id: 16 -->
- [ ] Add empty state to `ReviewsTab` for no reviews <!-- id: 17 -->
- [x] Add empty state to `ExpertsTab` for no experts <!-- id: 18 -->
- [ ] Add empty state to `ServicesTab` for no services <!-- id: 19 -->
- [ ] Add empty state to followed venues screen (if exists) <!-- id: 20 -->

## Phase 6: Testing & Validation
- [ ] Test all animations on iOS device (verify haptic feedback works) <!-- id: 21 -->
- [ ] Test all animations on Android device (verify haptic feedback works) <!-- id: 22 -->
- [ ] Verify animations respect "Reduce Motion" accessibility setting <!-- id: 23 -->
- [ ] Performance test on low-end device <!-- id: 24 -->
- [ ] Visual QA: Compare running app against design <!-- id: 25 -->
- [ ] Screen reader testing <!-- id: 26 -->
- [x] Run `flutter analyze` to check for warnings <!-- id: 27 -->
- [ ] Run existing widget tests (if any) to ensure no regressions <!-- id: 28 -->
