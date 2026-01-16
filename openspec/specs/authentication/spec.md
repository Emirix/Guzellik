---
status: proposed
created: 2026-01-16
author: AI Assistant
---

# Authentication System Specification

## Purpose
Define comprehensive authentication and authorization system for the Güzellik platform, covering user registration, login, password management, business account conversion, and session handling.

## Requirements

### Requirement: Email/Password Registration
The system SHALL allow new users to create accounts using email and password.

#### Scenario: Successful registration
- **GIVEN** a new user provides valid email and password
- **WHEN** the registration form is submitted
- **THEN** a new user SHALL be created in Supabase Auth
- **AND** a corresponding profile SHALL be created in the `profiles` table
- **AND** a verification email SHALL be sent to the user's email
- **AND** the user SHALL be redirected to the complete profile screen

#### Scenario: Registration with existing email
- **GIVEN** a user attempts to register with an already registered email
- **WHEN** the registration form is submitted
- **THEN** an error message SHALL be displayed: "Bu e-posta adresi zaten kullanılıyor"
- **AND** the registration SHALL NOT proceed

#### Scenario: Invalid email format
- **GIVEN** a user provides an invalid email format
- **WHEN** the registration form is submitted
- **THEN** a validation error SHALL be displayed
- **AND** the form SHALL NOT be submitted

#### Scenario: Weak password
- **GIVEN** a user provides a password shorter than 8 characters
- **WHEN** the registration form is submitted
- **THEN** a validation error SHALL be displayed: "Şifre en az 8 karakter olmalıdır"
- **AND** the form SHALL NOT be submitted

---

### Requirement: Email Verification
The system SHALL require users to verify their email addresses before full account access.

#### Scenario: Email verification link clicked
- **GIVEN** a user receives a verification email
- **WHEN** the user clicks the verification link
- **THEN** the user's email SHALL be marked as verified in Supabase Auth
- **AND** the user SHALL be redirected to the app with a success message
- **AND** the user SHALL have full access to the platform

#### Scenario: Resend verification email
- **GIVEN** a user has not received the verification email
- **WHEN** the user requests to resend the verification email
- **THEN** a new verification email SHALL be sent
- **AND** a confirmation message SHALL be displayed

---

### Requirement: User Login
The system SHALL allow registered users to log in using their email and password.

#### Scenario: Successful login
- **GIVEN** a registered user with verified email
- **WHEN** the user enters correct email and password
- **THEN** the user SHALL be authenticated
- **AND** an auth session SHALL be created
- **AND** the user SHALL be redirected to the home screen

#### Scenario: Login with incorrect password
- **GIVEN** a registered user
- **WHEN** the user enters an incorrect password
- **THEN** an error message SHALL be displayed: "E-posta veya şifre hatalı"
- **AND** the user SHALL remain on the login screen

#### Scenario: Login with unverified email
- **GIVEN** a registered user with unverified email
- **WHEN** the user attempts to log in
- **THEN** a message SHALL be displayed: "Lütfen e-postanızı doğrulayın"
- **AND** an option to resend verification email SHALL be provided

---

### Requirement: Password Reset
The system SHALL allow users to reset their passwords via email.

#### Scenario: Request password reset
- **GIVEN** a user has forgotten their password
- **WHEN** the user enters their email on the password reset screen
- **THEN** a password reset email SHALL be sent to the user
- **AND** a confirmation message SHALL be displayed

#### Scenario: Complete password reset
- **GIVEN** a user receives a password reset email
- **WHEN** the user clicks the reset link and enters a new password
- **THEN** the user's password SHALL be updated
- **AND** the user SHALL be redirected to the login screen
- **AND** a success message SHALL be displayed

---

### Requirement: Session Management
The system SHALL maintain user authentication sessions securely.

#### Scenario: Session persistence
- **GIVEN** a logged-in user
- **WHEN** the user closes and reopens the app
- **THEN** the user SHALL remain logged in
- **AND** the session SHALL be automatically restored

#### Scenario: Session expiration
- **GIVEN** a user session has expired (after 7 days of inactivity)
- **WHEN** the user attempts to access protected content
- **THEN** the user SHALL be redirected to the login screen
- **AND** a message SHALL be displayed: "Oturumunuz sona erdi, lütfen tekrar giriş yapın"

#### Scenario: Logout
- **GIVEN** a logged-in user
- **WHEN** the user taps the logout button
- **THEN** the user's session SHALL be terminated
- **AND** the user SHALL be redirected to the login screen
- **AND** all cached user data SHALL be cleared

---

### Requirement: Business Account Conversion
The system SHALL allow regular users to convert their accounts to business accounts.

#### Scenario: Initiate business account conversion
- **GIVEN** a logged-in regular user
- **WHEN** the user navigates to "İşletme Hesabına Geç" in settings
- **THEN** the user SHALL be shown subscription plan options
- **AND** the user SHALL be able to select a plan

#### Scenario: Complete business account conversion
- **GIVEN** a user has selected a subscription plan
- **WHEN** the user completes the payment/setup process
- **THEN** the user's `is_business_account` flag SHALL be set to true
- **AND** a default subscription SHALL be created
- **AND** the user SHALL be redirected to the business dashboard
- **AND** the bottom navigation SHALL switch to business mode

---

### Requirement: Profile Completion
The system SHALL require new users to complete their profiles after registration.

#### Scenario: First-time user completes profile
- **GIVEN** a newly registered user with verified email
- **WHEN** the user logs in for the first time
- **THEN** the user SHALL be redirected to the complete profile screen
- **AND** the user SHALL be prompted to enter: full name, phone number, location
- **WHEN** the user submits the profile information
- **THEN** the profile SHALL be updated in the database
- **AND** the user SHALL be redirected to the home screen

---

### Requirement: Auth State Management
The system SHALL provide a centralized auth state management system.

#### Scenario: Auth state changes are propagated
- **GIVEN** a user logs in or logs out
- **WHEN** the auth state changes
- **THEN** all listeners SHALL be notified
- **AND** the UI SHALL update accordingly
- **AND** protected routes SHALL be re-evaluated

---

### Requirement: Social Authentication (Future)
The system SHOULD support social authentication providers.

#### Scenario: Google Sign-In
- **GIVEN** a user wants to sign in with Google
- **WHEN** the user taps "Google ile Giriş Yap"
- **THEN** the Google OAuth flow SHALL be initiated
- **AND** upon success, a profile SHALL be created or linked
- **AND** the user SHALL be logged in

---

## Non-Functional Requirements

### Performance
- Login/registration SHALL complete within 3 seconds
- Session restoration SHALL complete within 1 second
- Password reset email SHALL be sent within 30 seconds

### Security
- Passwords SHALL be hashed using bcrypt (handled by Supabase)
- Auth tokens SHALL be stored securely (handled by Supabase)
- Session tokens SHALL expire after 7 days of inactivity
- Password reset links SHALL expire after 1 hour
- Failed login attempts SHALL be rate-limited (5 attempts per 15 minutes)

### Reliability
- Auth service SHALL have 99.9% uptime
- Failed auth operations SHALL provide clear error messages
- Network errors SHALL be handled gracefully with retry logic

---

## Data Model

### profiles table (existing)
```sql
- id: UUID (PK, FK to auth.users)
- email: TEXT
- full_name: TEXT
- phone: TEXT
- avatar_url: TEXT
- is_business_account: BOOLEAN (default: false)
- business_venue_id: UUID (FK to venues.id, nullable)
- province_id: UUID (FK to provinces.id, nullable)
- district_id: UUID (FK to districts.id, nullable)
- created_at: TIMESTAMPTZ
- updated_at: TIMESTAMPTZ
```

### auth.users table (Supabase managed)
```sql
- id: UUID (PK)
- email: TEXT
- encrypted_password: TEXT
- email_confirmed_at: TIMESTAMPTZ
- last_sign_in_at: TIMESTAMPTZ
- created_at: TIMESTAMPTZ
- updated_at: TIMESTAMPTZ
```

---

## API Integration

### AuthService Methods

```dart
// Registration
Future<AuthResponse> signUp({
  required String email,
  required String password,
  required String fullName,
});

// Login
Future<AuthResponse> signIn({
  required String email,
  required String password,
});

// Logout
Future<void> signOut();

// Password Reset
Future<void> resetPassword(String email);

// Update Password
Future<void> updatePassword(String newPassword);

// Resend Verification Email
Future<void> resendVerificationEmail();

// Get Current User
User? getCurrentUser();

// Check Auth State
Stream<AuthState> authStateChanges();
```

### AuthProvider State

```dart
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;
  
  Future<void> signUp(...);
  Future<void> signIn(...);
  Future<void> signOut();
  Future<void> resetPassword(...);
}
```

---

## UI/UX Requirements

### Login Screen
- Email input field with validation
- Password input field with show/hide toggle
- "Giriş Yap" button (disabled until valid input)
- "Şifremi Unuttum" link
- "Hesabın yok mu? Kayıt Ol" link
- Social login buttons (future)
- Loading indicator during auth

### Registration Screen
- Email input field with validation
- Password input field with strength indicator
- Password confirmation field
- "Kayıt Ol" button (disabled until valid input)
- "Zaten hesabın var mı? Giriş Yap" link
- Terms and privacy policy checkbox
- Loading indicator during registration

### Password Reset Screen
- Email input field
- "Sıfırlama Linki Gönder" button
- Success/error message display
- "Giriş Sayfasına Dön" link

### Complete Profile Screen
- Full name input field
- Phone number input field
- Province/district selection
- "Profili Tamamla" button
- Skip option (with warning)

---

## Testing Requirements

### Unit Tests
- Test email validation logic
- Test password strength validation
- Test auth state management
- Test error handling

### Integration Tests
- Test complete registration flow
- Test login flow
- Test password reset flow
- Test session persistence
- Test business account conversion

### E2E Tests
- Test user journey from registration to first login
- Test password reset complete flow
- Test logout and re-login

---

## Error Handling

### Common Errors

| Error Code | Message | User Action |
|------------|---------|-------------|
| `email-already-in-use` | "Bu e-posta adresi zaten kullanılıyor" | Try logging in or use password reset |
| `invalid-email` | "Geçersiz e-posta adresi" | Enter valid email |
| `weak-password` | "Şifre en az 8 karakter olmalıdır" | Enter stronger password |
| `wrong-password` | "E-posta veya şifre hatalı" | Re-enter credentials |
| `user-not-found` | "Bu e-posta ile kayıtlı kullanıcı bulunamadı" | Register or check email |
| `email-not-verified` | "Lütfen e-postanızı doğrulayın" | Resend verification email |
| `too-many-requests` | "Çok fazla deneme yaptınız, lütfen daha sonra tekrar deneyin" | Wait and retry |
| `network-error` | "Bağlantı hatası, lütfen internet bağlantınızı kontrol edin" | Check connection and retry |

---

## Dependencies
- Supabase Auth
- `supabase_flutter` package
- `AuthProvider` (state management)
- `go_router` (navigation)

---

## Future Enhancements
- Social authentication (Google, Apple, Facebook)
- Two-factor authentication (2FA)
- Biometric authentication (fingerprint, face ID)
- Magic link authentication
- Phone number authentication
- Multi-device session management
- Account deletion
- Account recovery
