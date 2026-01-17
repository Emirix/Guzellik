# Authentication Specification Delta

## ADDED Requirements

### Requirement: Phone Number Registration
Users SHALL be able to create a new account using a phone number and password without OTP verification.

#### Scenario: Successful phone registration
- **GIVEN** a new user with phone number "905551234567"
- **WHEN** the user fills in required fields (name, phone, password)
- **AND** the phone number follows the `90XXXXXXXXXX` format
- **AND** taps "Kayıt Ol"
- **THEN** a new account is created
- **AND** the user is automatically logged in
- **AND** no OTP code is requested

#### Scenario: Invalid phone format during registration
- **GIVEN** a phone number that does not start with "90" or is not 12 digits
- **WHEN** the user attempts to register
- **THEN** an error message "Geçerli bir telefon numarası giriniz (90XXXXXXXXXX)" is displayed

### Requirement: Phone Number Login
Users SHALL be able to log in using their phone number and password.

#### Scenario: Successful login with phone
- **GIVEN** a registered user with phone "905551234567"
- **WHEN** the user enters their phone number and password
- **AND** taps "Giriş Yap"
- **THEN** the user is authenticated
- **AND** redirected to the home screen

## MODIFIED Requirements

### Requirement: User Login
- **Requirement**: Users SHALL be able to log in using email OR phone number.
- **Modification**: The login input field now automatically detects if the input is a phone number (numeric and starts with 90) and processes authentication accordingly.

#### Scenario: Unified login field detection
- **GIVEN** a user on the login screen
- **WHEN** the user enters a value starting with "90" and containing only digits
- **THEN** the system SHALL treat this as a phone number login attempt
- **AND** if valid credentials are provided, the user SHALL be authenticated.

## REMOVED Requirements
None.
