# Spec Delta: Business Authentication

## ADDED Requirements

### Requirement: Business Account Detection on Login
**GIVEN** a user successfully logs in  
**WHEN** the authentication flow completes  
**THEN** the system SHALL check if the user's profile has `is_business_account = true`

#### Scenario: Business account login
- User logs in with credentials
- System queries profile and finds `is_business_account = true`
- Mode selection dialog is displayed
- User can choose between business and normal mode

#### Scenario: Normal account login
- User logs in with credentials
- System queries profile and finds `is_business_account = false`
- User is directly taken to normal mode
- No mode selection dialog is shown

---

### Requirement: Business Mode Selection
**GIVEN** a user with `is_business_account = true` has logged in  
**WHEN** the mode selection dialog is displayed  
**THEN** the user SHALL be able to choose between:
- "İşletme Olarak Devam Et" (Business Mode)
- "Normal Kullanıcı Olarak Devam Et" (Normal Mode)

#### Scenario: User selects business mode
- User taps "İşletme Olarak Devam Et"
- App navigates to business home (profile screen with business nav)
- Business bottom navigation is displayed
- Business features are accessible

#### Scenario: User selects normal mode
- User taps "Normal Kullanıcı Olarak Devam Et"
- App navigates to normal home (explore screen)
- Normal bottom navigation is displayed
- Business features are hidden

---

### Requirement: Session-Based Mode Persistence
**GIVEN** a user has selected their mode (business or normal)  
**WHEN** the user navigates within the app  
**THEN** the selected mode SHALL persist for the current session

#### Scenario: Mode persists during session
- User selects business mode
- User navigates between screens
- Business mode remains active
- Business navigation remains visible

#### Scenario: Mode resets on logout
- User logs out
- Mode preference is cleared
- Next login shows mode selection dialog again

---

### Requirement: Mode Switching from Profile
**GIVEN** a user is in business mode  
**WHEN** they tap "Normal Hesaba Geç" button in profile screen  
**THEN** the app SHALL switch to normal mode without logging out

#### Scenario: Switch from business to normal
- User is in business mode
- User taps "Normal Hesaba Geç" in profile
- App switches to normal mode
- Normal bottom navigation is displayed
- User remains logged in

#### Scenario: Switch from normal to business
- User is in normal mode (but has `is_business_account = true`)
- User navigates to profile
- User sees "İşletme Moduna Geç" button
- User taps button and switches to business mode

---

### Requirement: Business Data Loading
**GIVEN** a user enters business mode  
**WHEN** the business mode is activated  
**THEN** the system SHALL load:
- User's business venue data
- Current subscription information
- Business statistics (if available)

#### Scenario: Successful business data load
- User switches to business mode
- System fetches venue where `owner_id = user.id`
- System fetches subscription where `profile_id = user.id`
- Data is cached in BusinessProvider
- Business screens can access this data

#### Scenario: Business data not found
- User has `is_business_account = true` but no venue
- System shows appropriate message
- User is prompted to complete business setup
- Limited business features are available

---

## MODIFIED Requirements

### Requirement: Authentication Flow
**GIVEN** the existing authentication system  
**WHEN** business account support is added  
**THEN** the login flow SHALL be extended to:
1. Authenticate user credentials
2. Check `is_business_account` flag
3. Show mode selection if business account
4. Navigate to appropriate home screen based on mode

#### Scenario: Backward compatibility
- Existing non-business users experience no change
- Login flow remains the same for normal accounts
- No breaking changes to auth flow
