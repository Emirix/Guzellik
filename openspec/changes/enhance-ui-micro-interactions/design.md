# Design: Enhance UI Micro-Interactions

## Architectural Reasoning

### Animation Performance
Flutter's animation system is built on the `Ticker` API, which synchronizes with the device's refresh rate (typically 60 FPS). For micro-interactions to feel smooth and not drain battery:

1. **Use `AnimatedContainer` for simple property changes** (color, size, opacity) - Flutter optimizes these internally
2. **Leverage `RepaintBoundary`** to isolate animated widgets and prevent unnecessary repaints of parent/sibling widgets
3. **Prefer implicit animations** (`AnimatedOpacity`, `AnimatedScale`) over explicit `AnimationController` when possible - less boilerplate, automatic disposal

### Shimmer vs. Skeleton Loading
**Shimmer Effect**: A gradient that sweeps across placeholder content, creating a "shimmering" appearance.

**Why Shimmer?**
- **Perceived Performance**: Studies show shimmer loading reduces perceived wait time by ~30% vs. spinners
- **Content Preview**: Skeleton shapes hint at incoming content structure, reducing cognitive load
- **Modern Standard**: Used by Facebook, LinkedIn, YouTube - users expect it in premium apps

**Implementation Strategy**:
- Use `shimmer` package (pub.dev) for pre-built, performant shimmer widgets
- Create reusable `ShimmerPlaceholder` widgets matching actual content shapes
- Ensure shimmer animation respects system "reduce motion" accessibility setting

### Haptic Feedback
Flutter's `HapticFeedback` class provides platform-specific tactile responses:
- **iOS**: Uses Taptic Engine (nuanced vibrations)
- **Android**: Uses Vibrator API (less refined but functional)

**Usage Guidelines**:
- **Light Impact**: For secondary actions (like/favorite)
- **Medium Impact**: For primary CTAs (Follow, Contact)
- **Heavy Impact**: For critical actions (delete, confirm)
- **Selection Click**: For toggles and switches

**Accessibility**: Haptic feedback can be disabled in system settings; always check `HapticFeedback.selectionClick()` availability.

## Implementation Details

### 1. Pulsing "Open Now" Dot
**Location**: `lib/presentation/widgets/venue/v2/working_hours_card_v2.dart`

**Approach**:
```dart
// Replace static Container with AnimatedBuilder + Tween
AnimatedBuilder(
  animation: _pulseController,
  builder: (context, child) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Color(0xFF22C55E).withOpacity(_pulseAnimation.value),
        shape: BoxShape.circle,
      ),
    );
  },
)
```

**Animation Spec**:
- Duration: 2 seconds
- Curve: `Curves.easeInOut`
- Repeat: Infinite
- Opacity range: 1.0 → 0.5 → 1.0

### 2. Shimmer Loading for Images
**Affected Files**:
- `lib/presentation/widgets/venue/v2/venue_overview_v2.dart` (gallery)
- `lib/presentation/widgets/venue/photo_gallery_viewer.dart`
- `lib/presentation/widgets/venue/components/expert_card.dart`

**Approach**:
Replace `CircularProgressIndicator` placeholder in `CachedNetworkImage` with:
```dart
placeholder: (context, url) => Shimmer.fromColors(
  baseColor: AppColors.gray200,
  highlightColor: AppColors.gray100,
  child: Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.gray200,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### 3. Button Press Animations
**Affected Files**:
- `lib/presentation/widgets/venue/v2/venue_identity_v2.dart` (Follow button)
- `lib/presentation/widgets/venue/components/booking_bottom_bar.dart` (Contact button)

**Approach**:
Wrap buttons with `GestureDetector` and `AnimatedScale`:
```dart
AnimatedScale(
  scale: _isPressed ? 0.95 : 1.0,
  duration: Duration(milliseconds: 100),
  curve: Curves.easeInOut,
  child: ElevatedButton(...),
)
```

Trigger haptic feedback on `onTapDown`:
```dart
onTapDown: (_) {
  setState(() => _isPressed = true);
  HapticFeedback.mediumImpact();
},
onTapUp: (_) => setState(() => _isPressed = false),
onTapCancel: () => setState(() => _isPressed = false),
```

### 4. Featured Expert Glow
**Location**: `lib/presentation/widgets/venue/v2/experts_section_v2.dart`

**Current**: Simple border with `AppColors.primary.withOpacity(0.2)`

**Enhanced**:
```dart
Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: isHighlighted ? [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 12,
        spreadRadius: 2,
      ),
    ] : null,
  ),
  child: CircleAvatar(...),
)
```

### 5. Glassmorphic Map Button
**Location**: `lib/presentation/widgets/venue/v2/map_preview_v2.dart`

**Current**: `rgba(255,255,255,0.9)` solid background

**Enhanced**:
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(...),
    ),
  ),
)
```

### 6. Empty State Component
**New File**: `lib/presentation/widgets/common/empty_state.dart`

**Structure**:
```dart
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  
  // Displays centered icon, title, message, and optional CTA button
  // Uses AppColors and AppTextStyles for consistency
}
```

**Usage Example** (in `ReviewsTab`):
```dart
if (reviews.isEmpty) {
  return EmptyState(
    icon: Icons.rate_review_outlined,
    title: 'Henüz Yorum Yok',
    message: 'Bu mekan hakkında ilk yorumu siz yapın!',
    actionLabel: 'Yorum Yaz',
    onAction: () => _showReviewDialog(),
  );
}
```

## Potential Risks & Mitigations

### Performance Concerns
**Risk**: Too many simultaneous animations could drop frame rate below 60 FPS on older devices.

**Mitigation**:
- Use `RepaintBoundary` to isolate animated widgets
- Test on low-end devices (e.g., iPhone 8, Samsung Galaxy A series)
- Provide option to disable animations in app settings (future enhancement)

### Accessibility
**Risk**: Users with vestibular disorders may experience discomfort from animations.

**Mitigation**:
- Check `MediaQuery.of(context).disableAnimations` (respects system "Reduce Motion" setting)
- Conditionally disable animations when this flag is true
- Ensure all functionality works without animations

### Package Dependencies
**Risk**: Adding `shimmer` package increases app size and introduces external dependency.

**Mitigation**:
- `shimmer` package is lightweight (~10KB)
- Widely used (5000+ pub points) and actively maintained
- Can be replaced with custom implementation if needed (low priority)

### Design Consistency
**Risk**: Over-animation can feel gimmicky and detract from premium aesthetic.

**Mitigation**:
- Follow design prototypes strictly (e.g., pulsing dot is in `design/mekan-detay.html`)
- Use subtle, purposeful animations (200-300ms durations)
- Get design approval before implementation
