# Change: Initialize Flutter Project

## Why

This is the foundational change that sets up the entire Flutter application infrastructure for the beauty services platform. We need to create a production-ready Flutter project with proper architecture, dependencies, and configuration that aligns with the project conventions defined in `openspec/project.md`.

## What Changes

- Create Flutter project structure with clean architecture layers
- Configure Supabase integration for backend services
- Set up Firebase Cloud Messaging for push notifications
- Integrate Google Maps for location-based features
- Implement centralized app configuration (`app_config.dart`) for branding
- Set up theme system with the defined color palette (nude, soft pink, cream, gold)
- Create base widget structure (Header, Navbar, BottomNav, etc.)
- Configure state management with Provider/Riverpod
- Set up repository and service patterns
- Initialize project dependencies and configuration files

## Impact

### Affected Specs
- `project-setup`: New capability for project initialization
- `app-configuration`: New capability for centralized branding management
- `theme-system`: New capability for design system implementation
- `navigation`: New capability for app navigation structure

### Affected Code
- Creates entire `lib/` directory structure
- Adds `pubspec.yaml` with all required dependencies
- Creates platform-specific configurations (Android/iOS)
- Sets up Firebase configuration files
- Initializes Supabase configuration

### Breaking Changes
None - this is the initial setup.

## Dependencies

- Flutter SDK (latest stable)
- Supabase account and project
- Firebase project for FCM
- Google Maps API key
- Android Studio / VS Code with Flutter extensions

## Success Criteria

- [ ] Flutter project runs successfully on both Android and iOS
- [ ] Supabase connection is established
- [ ] Firebase notifications are configured
- [ ] Google Maps displays correctly
- [ ] App name and logo are managed from single config file
- [ ] Theme system applies correct color palette
- [ ] Navigation structure is functional
- [ ] All base widgets are reusable and properly organized
