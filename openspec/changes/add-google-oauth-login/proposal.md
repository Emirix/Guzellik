# Proposal: Add Google OAuth Login

## Why

Kullanıcı deneyimini iyileştirmek ve kayıt/giriş süreçlerini hızlandırmak için sosyal medya girişi önemlidir. Google OAuth kullanıcıların şifre oluşturma ve hatırlama yükünü ortadan kaldırır, kayıt sürecini tek tıklamaya indirger, ve Google'ın güvenlik altyapısı sayesinde kullanıcı güvenini artırır. Mevcut auth sisteminde Google giriş butonu UI'da hazır ancak fonksiyonel değil.

## What Changes

- Google OAuth 2.0 ile giriş ve kayıt yapabilme
- Supabase Auth'un native Google provider desteğini kullanma
- Google profil bilgilerini (ad, email, profil fotoğrafı) otomatik user profile'a aktarma
- Login ve Register ekranlarındaki mevcut Google butonlarını fonksiyonel hale getirme
- Deep linking configuration (Android/iOS) OAuth callback handling için
- AuthProvider'a `signInWithGoogle()` method ekleme
- AuthService'e OAuth-specific error handling ekleme

## Impact

### Affected Specs
- `google-oauth` (new spec) - Google OAuth authentication requirements
- `authentication` (modified) - Login/Register methods now include OAuth option

### Affected Code
- `lib/presentation/providers/auth_provider.dart` - OAuth methods
- `lib/data/services/auth_service.dart` - OAuth service calls
- `lib/presentation/screens/login_screen.dart` - Google button wiring
- `lib/presentation/screens/register_screen.dart` - Google button wiring

### Configuration Changes
- Supabase dashboard: Google OAuth provider configuration
- Google Cloud Console: OAuth 2.0 client creation
- Android: Deep link configuration in AndroidManifest.xml
- iOS: URL scheme configuration in Info.plist



## Proposed Solution

### Google OAuth Flow

```
User taps "Google ile Giriş Yap"
  ↓
AuthProvider.signInWithGoogle() triggered
  ↓
Supabase redirects to Google OAuth consent screen
  ↓
User authorizes app
  ↓
Google redirects back to app with auth code
  ↓
Supabase exchanges code for tokens
  ↓
User authenticated + Session created
  ↓
If new user → Create profile with Google data
  ↓
Redirect to intended destination
```

### Integration Points

- **Frontend**: AuthProvider methods, Login/Register screen button wiring
- **Backend**: Supabase Auth Google provider configuration
- **Mobile**: Deep linking for OAuth callback (Android/iOS)

### Profile Data Mapping

Google profile data automatically mapped to user metadata:
- `full_name` ← Google display name
- `avatar_url` ← Google profile picture URL
- `provider` ← "google"

### Security

- PKCE flow (Supabase handles)
- State parameter validation (Supabase handles)
- Secure token storage (Supabase SDK handles)

