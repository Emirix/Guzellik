# Agent Instructions for Güzellik Haritam

This document provides essential guidelines for AI coding agents working on the Güzellik Haritam Flutter project.

## Project Overview

- **Name**: Güzellik Haritam (Beauty Services Platform)
- **Type**: Flutter mobile application (iOS/Android)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Real-time)
- **State Management**: Provider
- **Navigation**: go_router
- **Language**: Dart 3.10.4+, Flutter 3.10.4+

## Build, Lint, and Test Commands

### Development
```bash
# Run the app
flutter run

# Run with specific flavor/environment
flutter run --debug
flutter run --release

# Hot reload is automatic in debug mode (press 'r')
# Hot restart (press 'R')
```

### Building
```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

### Testing
```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/services/auth_service_test.dart

# Run specific test by name pattern
flutter test --name "AuthService"

# Run tests with coverage
flutter test --coverage

# Run widget tests
flutter test test/widgets/

# Run integration tests
flutter test integration_test/
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format all Dart files
flutter pub run dart_format .

# Get dependencies
flutter pub get

# Clean build artifacts
flutter clean

# Run code generation (for freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs
```

## Code Style Guidelines

### Imports
- Order imports: dart libraries → flutter → external packages → internal imports
- Use relative imports for files within the same package directory
- Group imports with blank lines between groups
```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../models/venue.dart';
```

### Formatting
- Use **2 spaces** for indentation (Flutter standard)
- Maximum line length: 80 characters (configurable, but keep reasonable)
- Always use trailing commas for function/constructor parameters and collections
- Use `const` constructors wherever possible for performance

### Types
- **Always declare return types** explicitly
- Use nullable types (`?`) appropriately
- Prefer `final` for immutable variables
- Avoid using `dynamic` unless absolutely necessary
- Use type inference for local variables when type is obvious

### Naming Conventions
- **Classes**: `PascalCase` (e.g., `VenueCard`, `AuthService`)
- **Files**: `snake_case` (e.g., `venue_card.dart`, `auth_service.dart`)
- **Variables/Functions**: `camelCase` (e.g., `currentUser`, `signInWithGoogle`)
- **Constants**: `camelCase` or `lowerCamelCase` (e.g., `const maxRetries = 3`)
- **Private members**: prefix with `_` (e.g., `_handleAuthError`)
- **Enums**: `PascalCase` for type, `camelCase` for values

### Error Handling
- Use `try-catch` blocks for async operations
- Create custom error messages that are user-friendly
- Rethrow errors with context using `throw _handleAuthError(e)`
- Log errors appropriately for debugging
- Handle network failures gracefully with proper error states

### Documentation
- Use `///` for public API documentation
- Document classes, methods, and complex logic
- Keep comments concise and meaningful
- Update docs when changing functionality

### Architecture Patterns
- **Models**: Plain Dart classes in `lib/data/models/`
  - Use factory constructors for JSON parsing (`fromJson`)
  - Implement `copyWith` for immutability
- **Services**: Business logic in `lib/data/services/`
  - Singleton pattern for app-wide services
  - Dependency injection via constructors
- **Repositories**: Data access layer in `lib/data/repositories/`
- **Widgets**: UI components in `lib/presentation/widgets/`
  - Keep widgets small and focused
  - Extract reusable components
- **Providers**: State management in `lib/presentation/providers/`

### Flutter Best Practices
- Always use `Key` for stateful widgets in lists
- Dispose controllers, streams, and subscriptions
- Use `const` constructors to optimize rebuilds
- Extract large build methods into separate widgets
- Use `ListView.builder` for long lists (not `ListView`)
- Handle async operations with `FutureBuilder` or `StreamBuilder`

### Supabase Integration
- Access Supabase through `SupabaseService.instance`
- Use Row Level Security (RLS) policies for data protection
- Handle auth state changes via streams
- Store files in Supabase Storage with proper paths

### State Management (Provider)
- Use `ChangeNotifier` for mutable state
- Call `notifyListeners()` after state changes
- Use `Consumer` or `Provider.of` for accessing state
- Prefer `context.watch<T>()` in widget `build` methods

## UI/UX Design Standards

### Reference Design Files
- **ALWAYS** check the `design/` folder before implementing UI
- Follow the premium aesthetic: clean, minimal, professional
- Reference HTML/CSS mockups for exact styling

### Color Palette (lib/core/theme/app_colors.dart)
- Primary: Nude (#E8D5C4), Soft Pink (#FFC9D9), Cream (#FFFBF5)
- Accent: Gold (#D4AF37) - for premium elements
- Base: White (#FFFFFF), Neutral grays

### Typography (Google Fonts)
- Headings: **Outfit** font family
- Body text: **Inter** font family
- Maintain visual hierarchy with font weights

## Git Commit Rules

**CRITICAL**: All commit messages MUST be in **Turkish** using Conventional Commits format.

### Format
```
<tip>(<kapsam>): <açıklama>
```

### Commit Types (Tipler)
- `feat`: Yeni özellik
- `fix`: Hata düzeltme
- `docs`: Dokümantasyon
- `style`: Görsel/biçimsel düzenleme
- `refactor`: Kod iyileştirme
- `perf`: Performans iyileştirmesi
- `test`: Test ekleme/düzenleme
- `build`: Bağımlılık değişikliği (pubspec vb.)
- `chore`: Diğer yardımcı işler

### Rules
- Use **past tense** in Turkish (e.g., "eklendi", "düzeltildi")
- Start description with lowercase
- No period at the end
- Be specific about scope: `(auth)`, `(venue)`, `(ui)`, etc.

### Examples
```bash
feat(auth): google login entegrasyonu eklendi
fix(venue): mekan kartı görüntüleme hatası düzeltildi
refactor(search): arama servisi yeniden yapılandırıldı
```

## Important File Locations

- **App Config**: `lib/config/app_config.dart` - Branding constants
- **Environment**: `lib/config/environment_config.dart` - API keys
- **Theme**: `lib/core/theme/` - Colors, text styles, app theme
- **Router**: `lib/core/utils/app_router.dart` - Navigation config
- **Main Entry**: `lib/main.dart` - App initialization

## Testing Guidelines

- Write tests for services and critical business logic
- Use `mockito` for mocking dependencies
- Test file naming: `<original_file>_test.dart`
- Keep tests focused and independent
- Mock Supabase calls to avoid external dependencies

## Common Patterns

### Async/Await
```dart
Future<void> loadData() async {
  try {
    final data = await repository.fetchData();
    // Handle success
  } catch (e) {
    // Handle error
  }
}
```

### Error Handling in Services
```dart
String _handleAuthError(Object error) {
  if (error is AuthException) {
    return error.message;
  }
  return 'Beklenmeyen bir hata oluştu';
}
```

### Widget Structure
```dart
class MyWidget extends StatelessWidget {
  final String title;
  
  const MyWidget({
    super.key,
    required this.title,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // Widget implementation
    );
  }
}
```

---

**Last Updated**: January 2026  
**Version**: 1.0.0
