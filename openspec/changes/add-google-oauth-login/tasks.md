## Implementation Tasks

### 1. Google Cloud Console Setup
- [ ] 1.1 Create new project in Google Cloud Console (or use existing)
- [ ] 1.2 Enable Google+ API for the project
- [ ] 1.3 Create OAuth 2.0 Client ID credentials
- [ ] 1.4 Configure OAuth consent screen (app name, logo, scopes)
- [ ] 1.5 Add authorized redirect URIs for Supabase
- [ ] 1.6 Copy Client ID and Client Secret for Supabase configuration

### 2. Supabase Configuration
- [ ] 2.1 Navigate to Authentication → Providers in Supabase dashboard
- [ ] 2.2 Enable Google provider
- [ ] 2.3 Enter Google Client ID and Client Secret
- [ ] 2.4 Configure redirect URLs
- [ ] 2.5 Test OAuth configuration with Supabase test flow
- [ ] 2.6 Document configuration steps in README

### 3. Flutter Deep Linking Setup
- [ ] 3.1 Configure Android deep linking in AndroidManifest.xml
- [ ] 3.2 Configure iOS URL schemes in Info.plist
- [ ] 3.3 Add intent filters for OAuth callback handling
- [ ] 3.4 Test deep link handling on both platforms

### 4. Backend Service Layer
- [ ] 4.1 Add `signInWithOAuth()` method to `AuthService`
- [ ] 4.2 Add `handleOAuthCallback()` method to process redirect
- [ ] 4.3 Add Google provider profile data extraction helper
- [ ] 4.4 Add error handling for OAuth-specific errors
- [ ] 4.5 Update `_handleAuthError()` with OAuth error messages

### 5. State Management (AuthProvider)
- [ ] 5.1 Add `signInWithGoogle()` method to `AuthProvider`
- [ ] 5.2 Add loading state for OAuth flow (`isOAuthInProgress`)
- [ ] 5.3 Add error state handling for OAuth failures
- [ ] 5.4 Implement OAuth callback handling and session restoration
- [ ] 5.5 Add `oauthError` field for displaying OAuth errors

### 6. UI Implementation - Login Screen
- [ ] 6.1 Wire existing Google button to `AuthProvider.signInWithGoogle()`
- [ ] 6.2 Add loading indicator during OAuth flow
- [ ] 6.3 Disable button during OAuth process
- [ ] 6.4 Display OAuth-specific error messages
- [ ] 6.5 Add visual feedback for OAuth redirect

### 7. UI Implementation - Register Screen
- [ ] 7.1 Wire existing Google button to `AuthProvider.signInWithGoogle()`
- [ ] 7.2 Add same loading and error handling as login screen
- [ ] 7.3 Ensure consistent UX between login and register flows

### 8. Profile Data Handling
- [ ] 8.1 Create utility function to extract Google profile data
- [ ] 8.2 Map Google name → `full_name` metadata
- [ ] 8.3 Map Google photo → `avatar_url` metadata
- [ ] 8.4 Set `provider: 'google'` in metadata for tracking
- [ ] 8.5 Update profile screen to display Google profile photo

### 9. Testing
- [ ] 9.1 Test Google OAuth flow on Android emulator
- [ ] 9.2 Test Google OAuth flow on iOS simulator
- [ ] 9.3 Test Google OAuth flow on physical devices
- [ ] 9.4 Test error scenarios (cancel, network failure, invalid config)
- [ ] 9.5 Test session persistence after OAuth login
- [ ] 9.6 Test profile data mapping and display
- [ ] 9.7 Test coexistence with email/password auth
- [ ] 9.8 Test redirect to intended destination after OAuth

### 10. Documentation
- [ ] 10.1 Document Google Cloud Console setup steps
- [ ] 10.2 Document Supabase OAuth configuration
- [ ] 10.3 Document testing procedures
- [ ] 10.4 Add troubleshooting guide for common OAuth errors
- [ ] 10.5 Update README with OAuth setup instructions

### 11. Security Validation
- [ ] 11.1 Verify no client secrets in mobile code
- [ ] 11.2 Verify redirect URI validation
- [ ] 11.3 Verify secure token storage
- [ ] 11.4 Review OAuth scopes (minimal necessary)
- [ ] 11.5 Test OAuth state parameter handling

### 12. Polish and Edge Cases
- [ ] 12.1 Handle user cancellation gracefully
- [ ] 12.2 Handle existing user with same email edge case
- [ ] 12.3 Add analytics event for Google sign-in success/failure
- [ ] 12.4 Test and optimize OAuth flow performance
- [ ] 12.5 Ensure accessibility (screen reader support for Google button)
