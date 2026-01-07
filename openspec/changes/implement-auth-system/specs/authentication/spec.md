# Authentication Specification Delta

## ADDED Requirements

### Requirement: User Login
Users SHALL be able to log in to the application using email/phone and password.

#### Scenario: Successful login with email
- **GIVEN** a registered user with email "user@example.com" and password "password123"
- **WHEN** the user enters their credentials and taps "Giriş Yap"
- **THEN** the user is authenticated
- **AND** the user is redirected to the home screen or their intended destination
- **AND** the user's session is persisted

#### Scenario: Successful login with phone number
- **GIVEN** a registered user with phone "+905551234567" and password "password123"
- **WHEN** the user enters their phone number and password and taps "Giriş Yap"
- **THEN** the user is authenticated
- **AND** the user is redirected to the home screen or their intended destination

#### Scenario: Failed login with invalid credentials
- **GIVEN** an unregistered email "invalid@example.com"
- **WHEN** the user attempts to log in
- **THEN** an error message "Geçersiz e-posta veya şifre" is displayed
- **AND** the user remains on the login screen

#### Scenario: Network error during login
- **GIVEN** no internet connection
- **WHEN** the user attempts to log in
- **THEN** an error message "Bağlantı hatası. Lütfen tekrar deneyin" is displayed

### Requirement: User Registration
Users SHALL be able to create a new account using email and password.

#### Scenario: Successful registration
- **GIVEN** a new user with email "newuser@example.com"
- **WHEN** the user fills in all required fields (name, email, password, password confirmation)
- **AND** taps "Kayıt Ol"
- **THEN** a new account is created
- **AND** the user is automatically logged in
- **AND** the user is redirected to the home screen

#### Scenario: Registration with existing email
- **GIVEN** an email "existing@example.com" that is already registered
- **WHEN** the user attempts to register with this email
- **THEN** an error message "Bu e-posta adresi zaten kullanımda" is displayed
- **AND** the user remains on the registration screen

#### Scenario: Registration with weak password
- **GIVEN** a password with less than 6 characters
- **WHEN** the user attempts to register
- **THEN** an error message "Şifre en az 6 karakter olmalıdır" is displayed
- **AND** the registration is prevented

### Requirement: Password Reset
Users SHALL be able to reset their password if forgotten.

#### Scenario: Request password reset
- **GIVEN** a registered user with email "user@example.com"
- **WHEN** the user taps "Şifremi Unuttum?" on the login screen
- **AND** enters their email address
- **AND** taps "Şifre Sıfırlama Linki Gönder"
- **THEN** a password reset email is sent to the user
- **AND** a confirmation message is displayed

### Requirement: User Logout
Authenticated users SHALL be able to log out of the application.

#### Scenario: Successful logout
- **GIVEN** an authenticated user
- **WHEN** the user taps "Çıkış Yap" on the profile screen
- **THEN** the user's session is cleared
- **AND** the user is redirected to the home screen
- **AND** auth-required screens become inaccessible

### Requirement: Auth-Required Screen Access
Certain screens SHALL require authentication to access.

#### Scenario: Accessing profile screen without authentication
- **GIVEN** an unauthenticated user
- **WHEN** the user attempts to navigate to the profile screen
- **THEN** the AuthRequiredScreen is displayed
- **AND** a message "Bu sayfayı görüntülemek için giriş yapmanız gerekmektedir" is shown
- **AND** a "Giriş Yap" button is available

#### Scenario: Redirect after login from auth-required screen
- **GIVEN** an unauthenticated user on the AuthRequiredScreen for "/profile"
- **WHEN** the user successfully logs in
- **THEN** the user is redirected to "/profile"
- **AND** the profile screen content is displayed

### Requirement: Public Screen Access
Certain screens SHALL be accessible without authentication.

#### Scenario: Accessing home screen without authentication
- **GIVEN** an unauthenticated user
- **WHEN** the user navigates to the home screen
- **THEN** the home screen content is displayed
- **AND** no authentication prompt is shown

#### Scenario: Accessing venue details without authentication
- **GIVEN** an unauthenticated user
- **WHEN** the user navigates to a venue details screen
- **THEN** the venue details are displayed
- **AND** the user can view all venue information

### Requirement: Session Persistence
User sessions SHALL persist across app restarts.

#### Scenario: App restart with active session
- **GIVEN** an authenticated user
- **WHEN** the user closes and reopens the app
- **THEN** the user remains authenticated
- **AND** no login is required

### Requirement: Input Validation
All authentication forms SHALL validate user input.

#### Scenario: Email format validation
- **GIVEN** an invalid email format "notanemail"
- **WHEN** the user attempts to submit the form
- **THEN** an error message "Geçerli bir e-posta adresi giriniz" is displayed
- **AND** the form submission is prevented

#### Scenario: Empty field validation on login
- **GIVEN** empty email or password fields
- **WHEN** the user attempts to log in
- **THEN** error messages are displayed for empty fields
- **AND** the login is prevented

### Requirement: Loading States
Authentication operations SHALL show appropriate loading indicators.

#### Scenario: Loading state during login
- **GIVEN** a user submitting login credentials
- **WHEN** the authentication request is in progress
- **THEN** a loading indicator is displayed
- **AND** the "Giriş Yap" button is disabled
- **AND** user input is disabled

### Requirement: Design Consistency
Authentication screens SHALL match the provided design specifications.

#### Scenario: Login screen design
- **GIVEN** the login screen is displayed
- **THEN** the screen matches the design in `design/login.html`
- **AND** uses Primary color (#e23661) for buttons
- **AND** uses Gold color (#C5A059) for "Şifremi Unuttum?" link
- **AND** uses Plus Jakarta Sans font
- **AND** has rounded corners on input fields and buttons

## MODIFIED Requirements

None - This is a new capability.

## REMOVED Requirements

None - This is a new capability.
