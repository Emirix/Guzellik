# Tasks: Enhance UI Micro-Interactions

## Phase 1: Foundation & Dependencies
- [ ] Add `shimmer` package to `pubspec.yaml` (version: ^3.0.0) <!-- id: 0 -->
- [ ] Run `flutter pub get` to install dependencies <!-- id: 1 -->
- [ ] Create `lib/presentation/widgets/common/empty_state.dart` widget scaffold <!-- id: 2 -->
- [ ] Add database migration for `specialists.is_featured` boolean column (default: false) <!-- id: 3 -->

## Phase 2: Animations
- [ ] Implement pulsing animation for "Open Now" status dot in `WorkingHoursCardV2` <!-- id: 4 -->
  - Add `AnimationController` with 2-second duration
  - Create opacity tween (1.0 → 0.5 → 1.0)
  - Wrap status dot in `AnimatedBuilder`
  - Add accessibility check for `MediaQuery.disableAnimations`
- [ ] Add button press animations to Follow button in `VenueIdentityV2` <!-- id: 5 -->
  - Wrap button with `AnimatedScale` widget
  - Implement `onTapDown`, `onTapUp`, `onTapCancel` handlers
  - Add `HapticFeedback.mediumImpact()` on tap down
  - Test on both iOS and Android devices
- [ ] Add button press animations to Contact button in `BookingBottomBar` <!-- id: 6 -->
  - Same implementation as Follow button
  - Ensure haptic feedback triggers before bottom sheet opens
- [ ] Implement glassmorphic effect on map preview button in `MapPreviewV2` <!-- id: 7 -->
  - Import `dart:ui` for `BackdropFilter`
  - Wrap button with `ClipRRect` and `BackdropFilter`
  - Set blur sigma to 10px
  - Update background color to white with 70% opacity
  - Add white border with 30% opacity

## Phase 3: Loading States (Shimmer)
- [ ] Replace image placeholders in `VenueOverviewV2` gallery section <!-- id: 8 -->
  - Replace `CircularProgressIndicator` with `Shimmer.fromColors`
  - Set base color to `AppColors.gray200`
  - Set highlight color to `AppColors.gray100`
  - Match shimmer shape to image dimensions (160x120, 12px border radius)
- [ ] Replace image placeholders in `PhotoGalleryViewer` <!-- id: 9 -->
  - Same shimmer configuration as gallery
  - Ensure shimmer stops when image loads or errors
- [ ] Replace avatar placeholders in `ExpertsSectionV2` <!-- id: 10 -->
  - Use circular shimmer for avatar shape
  - Diameter: 80px
  - Same color scheme as image shimmer
- [ ] Create shimmer skeleton for venue cards (future use in discovery/search) <!-- id: 11 -->
  - Create `VenueCardShimmer` widget in `lib/presentation/widgets/common/`
  - Match structure: rectangular image, two text lines, circular rating badge
  - Synchronize shimmer animation across multiple skeletons

## Phase 4: Visual Hierarchy
- [ ] Add gradient backgrounds to gender-based avatars in `AvatarUtils` <!-- id: 12 -->
  - Update `getAvatarBackgroundColor()` to return `LinearGradient` instead of `Color`
  - Male: `E3F2FD` → `BBDEFB` (top-left to bottom-right)
  - Female: `FFEAF3` → `FFD6E8`
  - Neutral: `gray100` → `gray200`
  - Update all avatar usages to support gradient backgrounds
- [ ] Implement featured expert glow effect in `ExpertsSectionV2` <!-- id: 13 -->
  - Read `is_featured` flag from `Specialist` model
  - Add `BoxShadow` to avatar container when `is_featured == true`
  - Shadow: `AppColors.primary` with 30% opacity, 12px blur, 2px spread
  - Remove existing border styling for featured experts
- [ ] Update expert sorting logic to prioritize featured experts <!-- id: 14 -->
  - Fetch experts from database with `ORDER BY is_featured DESC, created_at DESC`
  - Update `VenueDetailsProvider.loadSpecialists()` query
- [ ] Refine section dividers in `VenueOverviewV2` <!-- id: 15 -->
  - Replace `Container(height: 8, color: AppColors.nude.withOpacity(0.3))` with chosen style
  - Option A: Add subtle top shadow to nude container
  - Option B: Use dashed border (1px, `AppColors.gray200`, 4px dash/gap)
  - Apply consistently to all 5 divider instances in file

## Phase 5: Empty States
- [ ] Implement `EmptyState` widget in `lib/presentation/widgets/common/empty_state.dart` <!-- id: 16 -->
  - Props: `title`, `message`, `icon`, `actionLabel?`, `onAction?`
  - Layout: centered column with icon, title, message, optional button
  - Spacing: 16px icon-to-title, 8px title-to-message, 24px message-to-button
  - Horizontal padding: 32px
  - Add semantic labels for screen readers
- [ ] Add empty state to `ReviewsTab` for no reviews <!-- id: 17 -->
  - Icon: `Icons.rate_review_outlined`
  - Title: "Henüz Yorum Yok"
  - Message: "Bu mekan hakkında ilk yorumu siz yapın!"
  - Action: "Yorum Yaz" → open review dialog
- [ ] Add empty state to `ExpertsTab` for no experts <!-- id: 18 -->
  - Icon: `Icons.people_outline`
  - Title: "Uzman Kadrosu Henüz Eklenmedi"
  - Message: "Bu mekan henüz uzman bilgilerini paylaşmamış."
  - No action button
- [ ] Add empty state to `ServicesTab` for no services <!-- id: 19 -->
  - Icon: `Icons.spa_outlined`
  - Title: "Hizmet Listesi Henüz Eklenmedi"
  - Message: "Bu mekan henüz hizmet bilgilerini paylaşmamış."
  - No action button
- [ ] Add empty state to followed venues screen (if exists) <!-- id: 20 -->
  - Icon: `Icons.favorite_border`
  - Title: "Henüz Takip Ettiğiniz Mekan Yok"
  - Message: "Favori mekanlarınızı takip ederek kampanyalardan haberdar olun!"
  - Action: "Mekan Keşfet" → navigate to discovery screen

## Phase 6: Testing & Validation
- [ ] Test all animations on iOS device (verify haptic feedback works) <!-- id: 21 -->
- [ ] Test all animations on Android device (verify haptic feedback works) <!-- id: 22 -->
- [ ] Verify animations respect "Reduce Motion" accessibility setting <!-- id: 23 -->
  - Enable "Reduce Motion" in iOS Settings → Accessibility → Motion
  - Enable "Remove animations" in Android Settings → Accessibility
  - Confirm pulsing dot, button scales, and shimmer are disabled
- [ ] Performance test on low-end device (e.g., iPhone 8, Samsung Galaxy A series) <!-- id: 24 -->
  - Monitor frame rate during animations (should maintain 60 FPS)
  - Check for jank or stuttering
- [ ] Visual QA: Compare running app against `design/mekan-detay.html` <!-- id: 25 -->
  - Pulsing dot matches design
  - Glassmorphic map button matches design
  - Section dividers match design
  - Empty states feel on-brand
- [ ] Screen reader testing (iOS VoiceOver, Android TalkBack) <!-- id: 26 -->
  - Empty states announce correctly
  - Action buttons are labeled and focusable
- [ ] Run `flutter analyze` to check for warnings <!-- id: 27 -->
- [ ] Run existing widget tests (if any) to ensure no regressions <!-- id: 28 -->
