# Design: Google OAuth Integration

## Context

Mevcut authentication sistemi Supabase Auth kullanıyor ve email/password ile giriş destekliyor. Google OAuth eklemek, kullanıcı deneyimini iyileştirecek ve kayıt sürecini hızlandıracak. Supabase Auth native OAuth provider desteği sunuyor, bu da implementasyonu kolaylaştırıyor.

### Key Stakeholders
- Mobile kullanıcılar (daha hızlı giriş)
- Development team (maintenance, security)
- Supabase (auth provider)
- Google (OAuth provider)

### Constraints
- Supabase Auth kullanımı zorunlu (mevcut sistem)
- Mobile-first (iOS ve Android)
- Deep linking desteği gerekli
- Google Cloud Console erişimi gerekli

## Goals / Non-Goals

### Goals
- Google OAuth 2.0 entegrasyonu ile hızlı giriş
- Supabase Auth'un native Google provider'ını kullanma
- Minimal kod değişikliği (mevcut auth altyapısını kullan)
- Güvenli OAuth flow (PKCE, state validation)
- Kullanıcı profil bilgilerini otomatik doldurma

### Non-Goals
- Custom OAuth implementation
- Firebase Authentication entegrasyonu
- Diğer OAuth provider'lar (Facebook, Apple)
- Account linking/merging (farklı provider'larla aynı email)
- Offline OAuth support

## Technical Decisions

### Decision 1: Supabase Native OAuth vs Google Sign-In Plugin

**Choice**: Supabase Auth'un native OAuth flow'u kullanılacak

**Rationale**:
- Supabase Auth zaten kullanılıyor, ek dependency gerektirmez
- Güvenlik (token management, session handling) Supabase tarafından handle ediliyor
- Consistency - tüm auth flow'ları aynı sistem üzerinden
- Backend integration otomatik (Supabase user'lar direkt database'e yazılıyor)

**Alternatives Considered**:
- **google_sign_in plugin**: Direkt Google Sign-In yapar ama Supabase session'ı ile sync problemi yaratır. Custom backend entegrasyonu gerektirir.
- **Custom OAuth**: Güvenlik riskleri, maintenance yükü, testing overhead.

### Decision 2: Deep Linking Strategy

**Choice**: Platform-native deep linking (Android App Links + iOS Universal Links)

**Rationale**:
- OAuth callback'leri için gerekli
- Platform standartları kullanarak güvenli
- Kullanıcı mobil tarayıcıdan uygulamaya sorunsuz dönüş

**Implementation**:
- Android: `intent-filter` with `https://` scheme
- iOS: Associated domains + URL schemes
- Redirect URI format: `io.supabase.guzellikapp://login-callback`

**Alternatives Considered**:
- **Custom URL schemes only**: Android'de güvenlik problemi (any app can register)
- **No deep linking**: Web-only OAuth, mobil kullanıcı deneyimi kötü

### Decision 3: Profile Photo Storage

**Choice**: Google profil fotoğrafı URL'ini direkt kullan (Supabase Storage'a kopyalama yok)

**Rationale**:
- Basit implementation
- Google CDN performansı iyi
- Storage maliyeti yok
- Otomatik olarak güncel kalır (kullanıcı Google'da değiştirirse)

**Trade-offs**:
- ✅ Pros: Basit, maliyet yok, güncel kalır
- ❌ Cons: External dependency, Google photo silinirse broken link

**Alternatives Considered**:
- **Supabase Storage'a kopyalama**: Ownership var ama implementation complexity, storage cost, sync problemi
- **Lazy loading + fallback**: URL kullan ama hata durumunda Supabase'e kopyala (v2 feature olabilir)

### Decision 4: OAuth Error Handling

**Choice**: User-friendly Türkçe hata mesajları + fallback email/password login önerisi

**Rationale**:
- Kullanıcı OAuth hatalarını anlamalı
- Alternatif yöntem sunmak (email/password) kullanıcı kaybını önler

**Error Categories**:
1. **User cancellation**: "Google girişi iptal edildi" - normal flow, error sayılmaz
2. **Network errors**: "Bağlantı hatası. Lütfen tekrar deneyin"
3. **Configuration errors**: "Google girişi şu anda kullanılamıyor" + support link
4. **Account issues**: "Hesap erişimi engellenmiş" + support link

**Implementation**:
- `AuthService._handleAuthError()` OAuth error mapping ekle
- `AuthProvider.oauthError` state field
- UI'da error banner + "Email ile giriş yap" alternatif buton

### Decision 5: Session Persistence

**Choice**: Supabase Flutter SDK'nın built-in session persistence kullan

**Rationale**:
- Supabase SDK zaten session'ı secure storage'da saklıyor
- OAuth ve email/password auth için consistent davranış
- Otomatik token refresh

**No additional work needed** - mevcut sistem zaten destekliyor

## Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Flutter App                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐           ┌─────────────────────────────┐ │
│  │ LoginScreen  │───────────│   AuthProvider              │ │
│  │ (Google btn) │           │   - signInWithGoogle()      │ │
│  └──────────────┘           │   - isOAuthInProgress       │ │
│                              │   - oauthError              │ │
│  ┌──────────────┐           └──────────────┬──────────────┘ │
│  │RegisterScreen│                           │                │
│  │ (Google btn) │                           │                │
│  └──────────────┘                           │                │
│                                              │                │
│                              ┌───────────────▼──────────────┐ │
│                              │   AuthService                │ │
│                              │   - signInWithOAuth()        │ │
│                              │   - handleOAuthCallback()    │ │
│                              └───────────────┬──────────────┘ │
│                                              │                │
│                              ┌───────────────▼──────────────┐ │
│                              │   SupabaseService            │ │
│                              │   - signInWithOAuth()        │ │
│                              │   - auth.signInWithOAuth()   │ │
│                              └───────────────┬──────────────┘ │
└──────────────────────────────────────────────┼────────────────┘
                                               │
                                               │ HTTPS
                                               │
┌──────────────────────────────────────────────▼────────────────┐
│                      Supabase Auth                            │
│  - OAuth provider configuration                              │
│  - Token exchange                                             │
│  - Session management                                         │
└───────────────────────────────┬───────────────────────────────┘
                                │
                                │ OAuth 2.0
                                │
┌───────────────────────────────▼───────────────────────────────┐
│                    Google OAuth Server                        │
│  - Authorization endpoint                                     │
│  - Token endpoint                                             │
│  - User info endpoint                                         │
└───────────────────────────────────────────────────────────────┘
```

### OAuth Flow Sequence

```
User                Flutter App          Supabase           Google
 │                       │                   │                │
 │  Tap Google button    │                   │                │
 ├──────────────────────►│                   │                │
 │                       │ signInWithOAuth() │                │
 │                       ├──────────────────►│                │
 │                       │                   │ Authorize URL  │
 │                       │◄──────────────────┤                │
 │                       │                   │                │
 │  Launch browser       │                   │                │
 │◄──────────────────────┤                   │                │
 │                       │                   │                │
 │  OAuth consent screen │                   │  Redirect to   │
 │                       │                   │  consent       │
 │◄──────────────────────┼───────────────────┼───────────────►│
 │                       │                   │                │
 │  Authorize            │                   │                │
 ├──────────────────────►│                   │◄───────────────┤
 │                       │                   │  Auth code     │
 │                       │                   │                │
 │  Deep link callback   │                   │  Exchange      │
 │  with auth code       │                   │  code for      │
 ├──────────────────────►│                   │  tokens        │
 │                       │  handleCallback() │                │
 │                       ├──────────────────►│───────────────►│
 │                       │                   │                │
 │                       │  Session + tokens │                │
 │                       │◄──────────────────┼───────────────►│
 │                       │                   │                │
 │  Navigate to home     │                   │                │
 │◄──────────────────────┤                   │                │
 │                       │                   │                │
```

## Data Model

### User Metadata Schema

OAuth ile giriş yapan kullanıcılar için metadata:

```json
{
  "full_name": "Ayşe Yılmaz",
  "avatar_url": "https://lh3.googleusercontent.com/a/...",
  "provider": "google",
  "google_id": "1234567890",
  "email_verified": true,
  "created_at": "2026-01-07T10:30:00Z"
}
```

### Database Impact

OAuth login mevcut `auth.users` tablosunu kullanır:
- `id`: Supabase user UUID
- `email`: Google email
- `email_confirmed_at`: OAuth'da otomatik dolacak
- `raw_user_meta_data`: JSON metadata
- `provider`: "google"

**No database schema changes needed** - mevcut yapı yeterli.

## Security Considerations

### OAuth Security Checklist

- ✅ **PKCE (Proof Key for Code Exchange)**: Supabase Auth otomatik handle eder
- ✅ **State parameter validation**: Supabase Auth otomatik handle eder
- ✅ **Redirect URI validation**: Supabase dashboard'da whitelist yapılacak
- ✅ **No client secrets in app**: Supabase server-side exchange yapar
- ✅ **Secure token storage**: Supabase SDK encrypted storage kullanır
- ✅ **HTTPS only**: Supabase ve Google HTTPS enforce eder

### Additional Security Measures

1. **Scope minimization**: Sadece `email` ve `profile` scope'ları kullan
2. **Token expiry handling**: Supabase SDK otomatik refresh yapar
3. **Revocation handling**: Kullanıcı Google'da revoke ederse Supabase session invalid olur

## Configuration Management

### Environment-Specific Configuration

| Environment | Redirect URI                                    | Google Client ID       |
|-------------|-------------------------------------------------|------------------------|
| Development | `io.supabase.guzellikapp://login-callback`      | Dev project client ID  |
| Production  | `io.supabase.guzellikapp://login-callback`      | Prod project client ID |

**Best Practice**: Development ve production için ayrı Google Cloud projects kullan.

### Supabase Configuration

```yaml
# Supabase Dashboard → Authentication → Providers → Google
enabled: true
client_id: <GOOGLE_CLIENT_ID>
client_secret: <GOOGLE_CLIENT_SECRET>
redirect_urls:
  - https://<project-ref>.supabase.co/auth/v1/callback
scopes:
  - email
  - profile
```

## Risks and Mitigations

### Risk 1: Google API quota limits
**Impact**: OAuth requests rate-limited during high traffic
**Probability**: Low (generous free tier limits)
**Mitigation**: Monitor usage, implement retry logic, fallback to email/password

### Risk 2: Deep link configuration errors
**Impact**: OAuth callback fails, user stuck in browser
**Probability**: Medium (platform-specific configuration)
**Mitigation**: Comprehensive testing on both platforms, clear documentation, fallback error message

### Risk 3: Google profile photo unavailable
**Impact**: Broken image in profile
**Probability**: Low but possible (user deletes photo, privacy settings change)
**Mitigation**: Fallback to default avatar, graceful error handling

### Risk 4: Email already exists with different provider
**Impact**: User can't sign in with Google if email used for password auth
**Probability**: Medium (common scenario)
**Mitigation**: Supabase handles this - same email = same user (merged identity)

## Migration Plan

### Phase 1: Configuration (Week 1)
- Google Cloud Console setup
- Supabase OAuth provider configuration
- Deep linking configuration

### Phase 2: Implementation (Week 1-2)
- AuthService OAuth methods
- AuthProvider Google sign-in
- UI button wiring
- Error handling

### Phase 3: Testing (Week 2)
- Manual testing on Android/iOS
- OAuth error scenarios
- Session persistence validation

### Phase 4: Launch (Week 2)
- Deploy to production
- Monitor OAuth success/failure rates
- Gather user feedback

### Rollback Plan
OAuth entegrasyonu additive change - mevcut email/password auth'u etkilemez. Eğer sorun olursa:
1. Supabase dashboard'da Google provider'ı disable et
2. UI'da Google butonlarını gizle (feature flag)
3. Existing OAuth users email/password auth'a yönlendir

## Open Questions

1. **Q**: Google Cloud Console'a kimde erişim var?
   **A**: TBD - Project owner veya admin gerekli

2. **Q**: Production domain URL'i nedir?
   **A**: TBD - Henüz deploy edilmemiş

3. **Q**: Email uniqueness conflict nasıl handle edilecek?
   **A**: Supabase default behavior: Aynı email = aynı user (provider farklı olsa bile)

4. **Q**: Google profil fotoğrafı güncellemesi real-time olacak mı?
   **A**: Hayır - sadece ilk login'de alınır. Manuel refresh gerekirse profile screen'de "Sync from Google" butonu eklenebilir (v2)

## Testing Strategy

### Unit Tests
- `AuthService.signInWithOAuth()` - Mock Supabase response
- `AuthProvider.signInWithGoogle()` - State management
- OAuth error handling logic

### Integration Tests
- End-to-end OAuth flow (requires test Google account)
- Deep link handling
- Session persistence after OAuth
- Profile data mapping

### Manual Testing Checklist
- [ ] Android emulator OAuth flow
- [ ] iOS simulator OAuth flow
- [ ] Physical device testing (Android/iOS)
- [ ] User cancels OAuth consent
- [ ] Network error during OAuth
- [ ] Invalid redirect URI (misconfiguration test)
- [ ] Existing user with same email
- [ ] New user profile data mapping
- [ ] Session persistence after app restart

## Documentation Requirements

### Developer Documentation
- Google Cloud Console setup guide
- Supabase OAuth configuration steps
- Deep linking configuration (Android/iOS)
- Troubleshooting common errors

### User-Facing Documentation
- "Google ile Giriş Yap" nedir?
- Neden Google hesabımı kullanmalıyım?
- Güvenlik ve gizlilik

### Code Documentation
- Inline comments for OAuth flow
- AuthProvider method documentation
- Error code mapping documentation

## Performance Considerations

### OAuth Flow Latency
- **Expected**: 2-5 seconds (user consent + redirect + token exchange)
- **Optimization**: Pre-load Google OAuth consent screen assets
- **Monitoring**: Track OAuth completion time with analytics

### Network Usage
- OAuth flow: ~50KB (consent screen assets)
- Token exchange: ~5KB
- Profile photo URL: External, not counted

### Memory Impact
- Minimal - sadece user metadata JSON
- Profile photo cached by `cached_network_image` package

## Success Criteria

1. ✅ Kullanıcılar Google butonu ile 5 saniyede giriş yapabilir
2. ✅ OAuth success rate >95%
3. ✅ Profil bilgileri doğru şekilde eşleştirilir
4. ✅ Mevcut email/password auth etkilenmez
5. ✅ Tüm platform testleri başarılı (Android/iOS)
6. ✅ Supabase dashboard'da OAuth analytics görünür
