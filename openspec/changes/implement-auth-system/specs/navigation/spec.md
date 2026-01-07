# Navigation Specification Delta

## ADDED Requirements

### Requirement: Auth Guard Integration
The navigation system SHALL integrate authentication guards for protected routes.

#### Scenario: Navigate to protected route when authenticated
- **GIVEN** an authenticated user
- **WHEN** the user navigates to "/profile"
- **THEN** the ProfileScreen is displayed
- **AND** no authentication prompt is shown

#### Scenario: Navigate to protected route when unauthenticated
- **GIVEN** an unauthenticated user
- **WHEN** the user navigates to "/profile"
- **THEN** the AuthRequiredScreen is displayed
- **AND** the original route path is preserved for redirect

#### Scenario: Redirect after successful login
- **GIVEN** an unauthenticated user attempted to access "/favorites"
- **WHEN** the user successfully logs in
- **THEN** the user is redirected to "/favorites"
- **AND** the favorites screen content is displayed

### Requirement: Auth Route Navigation
Users SHALL be able to navigate between authentication-related screens.

#### Scenario: Navigate from login to registration
- **GIVEN** a user on the login screen
- **WHEN** the user taps "Kayıt Ol"
- **THEN** the user is navigated to the registration screen
- **AND** the back button returns to login

#### Scenario: Navigate to password reset
- **GIVEN** a user on the login screen
- **WHEN** the user taps "Şifremi Unuttum?"
- **THEN** the user is navigated to the password reset screen
- **AND** the back button returns to login

### Requirement: Post-Auth Navigation
After successful authentication, users SHALL be navigated appropriately.

#### Scenario: Login from auth-required screen
- **GIVEN** a user on AuthRequiredScreen with redirect path "/notifications"
- **WHEN** the user successfully logs in
- **THEN** the user is navigated to "/notifications"
- **AND** the auth flow screens are removed from navigation stack

#### Scenario: Login from direct navigation
- **GIVEN** a user navigates directly to "/login"
- **WHEN** the user successfully logs in
- **THEN** the user is navigated to the home screen "/"
- **AND** the login screen is removed from navigation stack

### Requirement: Logout Navigation
After logout, users SHALL be navigated to appropriate screens.

#### Scenario: Logout from profile screen
- **GIVEN** an authenticated user on the profile screen
- **WHEN** the user taps "Çıkış Yap"
- **THEN** the user is navigated to the home screen "/"
- **AND** the user session is cleared
- **AND** protected routes become inaccessible

## MODIFIED Requirements

### Requirement: Route Configuration
The existing route configuration SHALL be updated to support auth guards.

#### Scenario: Protected routes configuration
- **GIVEN** the app router is initialized
- **THEN** the following routes are protected with auth guards: "/profile", "/favorites", "/notifications"

#### Scenario: Public routes configuration
- **GIVEN** the app router is initialized
- **THEN** the following routes are accessible without authentication: "/", "/explore", "/search", "/venue/:id"

## REMOVED Requirements

None - This extends existing navigation capabilities.
