# Contributing to Güzellik Platformu

Thank you for contributing to the Beauty Services Platform! To maintain high code quality and consistency, please follow these guidelines.

## 🏛️ Architecture

We follow **Clean Architecture** with a clear separation of layers:

1.  **Presentation Layer (`lib/presentation/`)**: Widgets, screens, and providers. Use `ChangeNotifier` with Provider for state management.
2.  **Domain Layer**: (Implicitly handled via interfaces and models for the MVP).
3.  **Data Layer (`lib/data/`)**: Repositories and services. All external communication (Supabase, Firebase) must go through a dedicated service.

## 🎨 UI & Branding

-   **Branding**: All app names, logos, and global constants **MUST** be referenced from `lib/config/app_config.dart`.
-   **Theming**: Use the predefined color palette in `lib/core/theme/app_colors.dart`.
-   **Widgets**: Favor reusable components in `lib/presentation/widgets/common/`.
-   **Typography**: Headings use **Outfit**, body text uses **Inter**.

## 🛠️ Code Style

-   Follow standard Dart/Flutter naming conventions (`snake_case` for files, `PascalCase` for classes).
-   Explicitly declare return types for all functions.
-   Use `const` constructors where possible.
-   Run `flutter analyze` before committing.

## 🚀 Git Workflow

1.  Create a feature branch: `feature/your-feature-name`.
2.  Follow conventional commits:
    -   `feat:` for new features
    -   `fix:` for bug fixes
    -   `style:` for UI/styling changes
    -   `refactor:` for code improvements

## 🧪 Testing

-   Write unit tests for services in `test/services/`.
-   Write widget tests for common UI components in `test/widgets/`.
-   Ensure existing tests pass before submitting changes: `flutter test`.

---

Let's build the most premium beauty platform in Turkey together! 💅✨
