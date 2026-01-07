# Google OAuth Authentication Specification Delta

## ADDED Requirements

### Requirement: Google OAuth Sign-In
Users SHALL be able to sign in to the application using their Google account via OAuth 2.0.

#### Scenario: First-time Google sign-in
- **GIVEN** a new user with a Google account
- **WHEN** the user taps "Google ile Giriş Yap" button
- **AND** authorizes the application in Google consent screen
- **THEN** a new user account is created in the system
- **AND** the user's Google profile data (name, email, photo) is imported
- **AND** the user is authenticated and redirected to the home screen
- **AND** the user's session is persisted

#### Scenario: Returning Google user sign-in
- **GIVEN** an existing user who previously signed in with Google
- **WHEN** the user taps "Google ile Giriş Yap" button
- **AND** authorizes the application
- **THEN** the user is authenticated with their existing account
- **AND** the user is redirected to their intended destination
- **AND** their last login timestamp is updated

#### Scenario: User cancels Google authorization
- **GIVEN** a user initiating Google sign-in
- **WHEN** the user cancels the Google consent screen
- **THEN** the OAuth flow is terminated gracefully
- **AND** the user remains on the login screen
- **AND** a message "Google girişi iptal edildi" is displayed
- **AND** alternative login options remain available

#### Scenario: Network error during OAuth flow
- **GIVEN** a user initiating Google sign-in
- **WHEN** network connectivity is lost during the OAuth flow
- **THEN** an error message "Bağlantı hatası. Lütfen tekrar deneyin" is displayed
- **AND** the user can retry the sign-in process

#### Scenario: Google OAuth configuration error
- **GIVEN** misconfigured OAuth settings (invalid client ID or redirect URI)
- **WHEN** the user attempts to sign in with Google
- **THEN** an error message "Google girişi şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin" is displayed
- **AND** alternative login methods (email/password) are suggested

### Requirement: Google Profile Data Mapping
When a user signs in with Google, their profile information SHALL be automatically imported and mapped to the user's account.

#### Scenario: Profile data import on first sign-in
- **GIVEN** a new user signing in with Google for the first time
- **WHEN** the OAuth flow completes successfully
- **THEN** the user's Google display name is saved as `full_name` in user metadata
- **AND** the user's Google profile photo URL is saved as `avatar_url`
- **AND** the user's Google email is saved as the primary email
- **AND** `email_verified` is automatically set to true
- **AND** `provider: 'google'` is recorded in metadata

#### Scenario: Profile photo display
- **GIVEN** a user who signed in with Google and has a profile photo
- **WHEN** the user navigates to their profile screen
- **THEN** their Google profile photo is displayed as their avatar
- **AND** if the photo URL fails to load, a default avatar is shown

### Requirement: OAuth Deep Link Handling
The application SHALL handle OAuth callback redirects using platform-native deep linking.

#### Scenario: Successful OAuth callback on Android
- **GIVEN** a user completing Google authorization on Android
- **WHEN** Google redirects to the callback URI `io.supabase.guzellikapp://login-callback`
- **THEN** the application receives the deep link intent
- **AND** the authorization code is extracted from the URL
- **AND** the code is exchanged for an access token via Supabase
- **AND** the user session is established

#### Scenario: Successful OAuth callback on iOS
- **GIVEN** a user completing Google authorization on iOS
- **WHEN** Google redirects to the callback URI
- **THEN** the application receives the universal link callback
- **AND** the authorization code is processed
- **AND** the user session is established

#### Scenario: Invalid callback URL
- **GIVEN** a misconfigured deep link or invalid callback
- **WHEN** the application receives an unexpected callback format
- **THEN** an error is logged for debugging
- **AND** the user sees an error message "Google girişi tamamlanamadı"
- **AND** the user is returned to the login screen

### Requirement: OAuth Loading States
OAuth authentication flows SHALL provide appropriate visual feedback during processing.

#### Scenario: Loading indicator during OAuth
- **GIVEN** a user taps the "Google ile Giriş Yap" button
- **WHEN** the OAuth flow is initiated
- **THEN** a loading indicator is displayed
- **AND** the Google sign-in button is disabled
- **AND** all other input fields and buttons are disabled
- **AND** a message "Google'a yönlendiriliyor..." is shown

#### Scenario: Loading indicator during token exchange
- **GIVEN** a user returning from Google consent screen
- **WHEN** the authorization code is being exchanged for tokens
- **THEN** a loading indicator is displayed
- **AND** a message "Giriş yapılıyor..." is shown

### Requirement: OAuth Security
Google OAuth authentication SHALL implement security best practices for mobile applications.

#### Scenario: PKCE flow validation
- **GIVEN** a mobile app initiating OAuth
- **WHEN** the OAuth authorization request is made
- **THEN** a PKCE code verifier SHALL be generated
- **AND** a code challenge SHALL be sent with the authorization request
- **AND** the code verifier SHALL be used during token exchange
- **AND** Supabase Auth SHALL validate the PKCE flow

#### Scenario: State parameter validation
- **GIVEN** an OAuth authorization request
- **WHEN** the request is initiated
- **THEN** a unique state parameter SHALL be generated
- **AND** the state SHALL be validated upon callback
- **AND** requests with invalid or missing state SHALL be rejected

#### Scenario: Secure token storage
- **GIVEN** successful Google OAuth authentication
- **WHEN** access and refresh tokens are received
- **THEN** tokens SHALL be stored securely using Supabase SDK encryption
- **AND** tokens SHALL NOT be exposed in application logs
- **AND** tokens SHALL NOT be accessible to other applications

### Requirement: Coexistence with Email/Password Auth
Google OAuth SHALL work seamlessly alongside existing email/password authentication.

#### Scenario: Same email with different auth methods
- **GIVEN** a user with email "user@example.com" registered via email/password
- **WHEN** the same user attempts to sign in with Google using "user@example.com"
- **THEN** Supabase SHALL link the Google provider to the existing account
- **AND** the user SHALL be authenticated successfully
- **AND** both authentication methods remain valid for future logins

#### Scenario: Switching between auth methods
- **GIVEN** a user who signed up with Google
- **WHEN** the user signs out and returns to the login screen
- **THEN** both "Google ile Giriş Yap" and email/password options are available
- **AND** the user can choose either method for subsequent logins

### Requirement: OAuth Error Recovery
Users SHALL be provided with clear error messages and recovery options when OAuth fails.

#### Scenario: OAuth error with fallback suggestion
- **GIVEN** a user experiencing Google OAuth failure
- **WHEN** the error is displayed
- **THEN** a user-friendly error message in Turkish is shown
- **AND** a suggestion to use email/password login is provided
- **AND** a "Email ile Giriş Yap" button is available

#### Scenario: Retry after OAuth failure
- **GIVEN** a user who encountered a temporary OAuth error
- **WHEN** the user taps "Tekrar Dene" button
- **THEN** the OAuth flow is reinitiated
- **AND** previous error messages are cleared

### Requirement: OAuth Analytics
Google OAuth authentication events SHALL be tracked for monitoring and optimization.

#### Scenario: Track OAuth success
- **GIVEN** a user successfully completes Google sign-in
- **WHEN** the authentication is finalized
- **THEN** an analytics event "google_sign_in_success" is logged
- **AND** the event includes metadata (first-time user vs returning user)

#### Scenario: Track OAuth failure
- **GIVEN** a user experiences Google sign-in failure
- **WHEN** the error occurs
- **THEN** an analytics event "google_sign_in_failure" is logged
- **AND** the error type and message are included in event metadata

#### Scenario: Track OAuth cancellation
- **GIVEN** a user cancels the Google consent screen
- **WHEN** the cancellation is detected
- **THEN** an analytics event "google_sign_in_cancelled" is logged

## MODIFIED Requirements

### Requirement: User Login
Users SHALL be able to log in to the application using email/phone and password **or Google OAuth**.

#### Scenario: Multiple login methods available
- **GIVEN** an unauthenticated user on the login screen
- **WHEN** the screen loads
- **THEN** email/phone input fields are displayed
- **AND** password input field is displayed
- **AND** "Giriş Yap" button for email/password is displayed
- **AND** "Google ile Giriş Yap" button is displayed
- **AND** both methods are equally accessible

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
Users SHALL be able to create a new account using email and password **or Google OAuth**.

#### Scenario: Registration options displayed
- **GIVEN** an unauthenticated user on the register screen
- **WHEN** the screen loads
- **THEN** email, name, and password input fields are displayed
- **AND** "Kayıt Ol" button for email/password registration is displayed
- **AND** "Google ile Kayıt Ol" button is displayed
- **AND** both registration methods are equally accessible

#### Scenario: Successful registration with email
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

## REMOVED Requirements

None - This is an additive change to existing authentication capabilities.
