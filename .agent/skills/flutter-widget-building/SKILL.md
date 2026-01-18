---
name: flutter-widget-building
description: Builds Flutter widgets following the Guzellik project's design system, architecture patterns, and Turkish naming conventions. Use when creating new widgets, screens, or UI components for the beauty services platform.
---

# Flutter Widget Building

## When to use this skill
- Creating new screens or widgets for the Guzellik app
- Building reusable UI components
- Implementing design system components
- User mentions "widget", "ekran", "component", "UI", or specific screen names
- Working with the beauty services platform's visual elements

## Design System Reference

### Color Palette
Always use colors from `lib/core/theme/app_colors.dart`:
- **Primary**: Nude (#E8D5C4), Soft Pink (#FFC9D9), Cream (#FFFBF5)
- **Accent**: Gold (#D4AF37) - Premium feel
- **Base**: White (#FFFFFF) - Cleanliness and trust

### Typography
- **Headings**: Outfit (Google Font)
- **Body**: Inter (Google Font)

### Design Principles
- Clean, minimal, premium aesthetic
- **Always check `design/` folder first** for mockups and references
- Emphasis on trust and professionalism
- Visual hierarchy with gold accents

## Widget Organization Rules

### File Structure
```
lib/presentation/widgets/
├── common/              # Reusable components (Header, Navbar, Buttons)
├── venue/               # Venue-specific widgets
├── service/             # Service-specific widgets
└── business/            # Business account widgets
```

### Naming Conventions
- **Files**: `snake_case.dart` (e.g., `trust_badges_grid_v2.dart`)
- **Classes**: `PascalCase` (e.g., `TrustBadgesGridV2`)
- **Variables/Functions**: `camelCase` (e.g., `onTapVenue`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_ITEMS`)
- **Private members**: Prefix with `_` (e.g., `_buildCard`)

## Workflow

### Pre-Implementation Checklist
- [ ] Check `design/` folder for relevant mockups
- [ ] Identify if widget is common, venue, service, or business-specific
- [ ] Determine if widget should be stateless or stateful
- [ ] Check if similar widget exists to reuse/extend
- [ ] Verify color palette usage from `app_colors.dart`

### Implementation Steps

1. **Create Widget File**
   - Place in correct folder (`common/`, `venue/`, `service/`, `business/`)
   - Use snake_case naming
   - Add proper imports

2. **Define Widget Class**
   ```dart
   class WidgetName extends StatelessWidget {
     const WidgetName({
       super.key,
       required this.parameter,
     });

     final Type parameter;

     @override
     Widget build(BuildContext context) {
       // Implementation
     }
   }
   ```

3. **Apply Design System**
   - Use `AppColors` for all colors
   - Use `GoogleFonts.outfit()` or `GoogleFonts.inter()` for typography
   - Follow spacing conventions (8px grid system)
   - Add gold accents for premium feel

4. **Add Turkish Comments**
   - Document complex logic in Turkish
   - Use Turkish for business domain terms
   - Keep code identifiers in English

5. **Optimize for Performance**
   - Use `const` constructors where possible
   - Implement `ListView.builder` for lists
   - Use `CachedNetworkImage` for images
   - Avoid unnecessary rebuilds

### Validation
- [ ] Widget follows design system colors
- [ ] Typography uses Outfit/Inter fonts
- [ ] File is in correct folder
- [ ] Naming follows conventions
- [ ] No hardcoded colors (use AppColors)
- [ ] Responsive to different screen sizes
- [ ] Includes Turkish comments for business logic

## Common Patterns

### Trust Badges
```dart
// Güven rozetleri için standart widget
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.gold.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.gold),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.verified, size: 16, color: AppColors.gold),
      const SizedBox(width: 4),
      Text(
        badge.title,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
)
```

### Venue Cards
```dart
// Mekan kartları için standart yapı
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Image with CachedNetworkImage
      ClipRRectangle(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: CachedNetworkImage(...),
      ),
      // Content
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(...),
      ),
    ],
  ),
)
```

### Bottom Sheets
```dart
// Alt modal sayfalar için
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: DraggableScrollableSheet(...),
  ),
)
```

## Resources

### Key Files to Reference
- `lib/core/theme/app_colors.dart` - Color definitions
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/config/app_config.dart` - App branding constants
- `design/` folder - Design mockups and references

### Common Imports
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
```

## Error Prevention

### Common Mistakes to Avoid
- ❌ Hardcoding colors instead of using `AppColors`
- ❌ Using default fonts instead of Outfit/Inter
- ❌ Placing widgets in wrong folders
- ❌ Not using `const` constructors
- ❌ Forgetting to check `design/` folder first
- ❌ Not following Turkish naming for business terms

### Quality Checklist
- [ ] Colors from `AppColors` only
- [ ] Fonts from `GoogleFonts.outfit()` or `GoogleFonts.inter()`
- [ ] Proper folder placement
- [ ] Turkish comments for business logic
- [ ] Responsive design
- [ ] Performance optimized (const, builders)
- [ ] Follows design mockups from `design/` folder
