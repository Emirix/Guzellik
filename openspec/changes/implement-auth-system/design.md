# Design: Authentication System

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ LoginScreen  │  │RegisterScreen│  │ AuthRequired │      │
│  │              │  │              │  │   Screen     │      │
│  └──────┬───────┘  └──────┬───────┘  └──────────────┘      │
│         │                  │                                 │
│         └──────────┬───────┘                                 │
│                    │                                         │
│         ┌──────────▼───────────┐                            │
│         │   AuthProvider       │                            │
│         │  (State Management)  │                            │
│         └──────────┬───────────┘                            │
└────────────────────┼─────────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────────┐
│                      Data Layer                              │
│         ┌──────────────────────┐                            │
│         │    AuthService       │                            │
│         │  (Business Logic)    │                            │
│         └──────────┬───────────┘                            │
│                    │                                         │
│         ┌──────────▼───────────┐                            │
│         │  SupabaseService     │                            │
│         │  (Auth Integration)  │                            │
│         └──────────────────────┘                            │
└──────────────────────────────────────────────────────────────┘
```

## Component Design

### 1. Auth Screens

#### LoginScreen
**Location**: `lib/presentation/screens/auth/login_screen.dart`

**Responsibilities**:
- Email/telefon ve şifre input alanları
- Form validasyonu
- Giriş işlemi tetikleme
- Şifremi unuttum navigasyonu
- Kayıt ekranına navigasyon
- Sosyal giriş butonları (UI hazır, gelecek için)

**State Dependencies**:
- `AuthProvider` - Giriş işlemi ve loading state

**Design Reference**: `design/login.html`

#### RegisterScreen
**Location**: `lib/presentation/screens/auth/register_screen.dart`

**Responsibilities**:
- Kullanıcı bilgileri input alanları (ad, email, telefon, şifre)
- Form validasyonu (email format, şifre güçlülüğü, şifre eşleşmesi)
- Kayıt işlemi tetikleme
- Giriş ekranına navigasyon
- Sosyal kayıt butonları (UI hazır)

**State Dependencies**:
- `AuthProvider` - Kayıt işlemi ve loading state

**Design Reference**: `design/login.html` (aynı stil, farklı form alanları)

#### AuthRequiredScreen
**Location**: `lib/presentation/screens/auth/auth_required_screen.dart`

**Responsibilities**:
- Bilgilendirme mesajı gösterme
- Login ekranına yönlendirme butonu
- Opsiyonel: Kayıt ekranına yönlendirme

**Props**:
- `String requiredFor` - Hangi sayfa için auth gerekli (örn: "Profilim", "Favoriler")
- `String? redirectPath` - Auth sonrası yönlendirilecek path

### 2. Auth Guard Middleware

#### AuthGuard Widget
**Location**: `lib/core/widgets/auth_guard.dart`

**Responsibilities**:
- Auth durumunu kontrol etme
- Authenticated ise child widget'ı gösterme
- Unauthenticated ise AuthRequiredScreen gösterme

**Usage**:
```dart
AuthGuard(
  requiredFor: 'Profilim',
  redirectPath: '/profile',
  child: ProfileScreen(),
)
```

### 3. Updated Profile Screen

#### ProfileScreen (Redesigned)
**Location**: `lib/presentation/screens/profile_screen.dart`

**Responsibilities**:
- Kullanıcı bilgilerini gösterme
- Avatar düzenleme
- İstatistikleri gösterme (randevular, favoriler, puanlar)
- Menü navigasyonları
- Çıkış yapma

**State Dependencies**:
- `AuthProvider` - Kullanıcı bilgileri ve çıkış işlemi
- `UserProfileProvider` (yeni) - Profil detayları ve istatistikler

**Design Reference**: `design/profilim.php`

**Sub-components**:
- `ProfileHeader` - Avatar ve kullanıcı bilgileri
- `ProfileStats` - İstatistik kartları
- `ProfileMenuItem` - Menü öğeleri
- `LogoutButton` - Çıkış butonu

### 4. Router Updates

#### AppRouter Modifications
**Location**: `lib/core/utils/app_router.dart`

**Changes**:
- Auth gerektiren route'lar için redirect logic
- Auth state listener ekleme
- Initial route belirleme (authenticated → home, unauthenticated → splash/home)

**Protected Routes**:
```dart
GoRoute(
  path: '/profile',
  name: 'profile',
  builder: (context, state) => AuthGuard(
    requiredFor: 'Profilim',
    redirectPath: '/profile',
    child: ProfileScreen(),
  ),
)
```

## Data Flow

### Login Flow
```
User enters credentials
  ↓
LoginScreen validates input
  ↓
AuthProvider.signIn() called
  ↓
AuthService.signIn() called
  ↓
SupabaseService.signInWithEmail()
  ↓
Success → Update AuthProvider state
  ↓
Navigate to redirect path or home
```

### Register Flow
```
User enters registration info
  ↓
RegisterScreen validates input
  ↓
AuthProvider.signUp() called
  ↓
AuthService.signUp() called
  ↓
SupabaseService.signUpWithEmail()
  ↓
Success → Update AuthProvider state
  ↓
Navigate to home or onboarding
```

### Auth Guard Flow
```
User navigates to protected route
  ↓
AuthGuard checks AuthProvider.isAuthenticated
  ↓
If authenticated → Show child widget
  ↓
If not authenticated → Show AuthRequiredScreen
  ↓
User clicks "Giriş Yap"
  ↓
Navigate to LoginScreen with redirect path
  ↓
After successful login → Navigate to redirect path
```

## Design Patterns

### 1. Provider Pattern
- `AuthProvider` manages authentication state
- Screens consume provider via `Consumer` or `context.watch`
- Single source of truth for auth state

### 2. Guard Pattern
- `AuthGuard` widget wraps protected content
- Declarative auth checking
- Reusable across multiple routes

### 3. Repository Pattern
- `AuthService` abstracts Supabase implementation
- Easy to test and mock
- Future-proof for potential auth provider changes

## Error Handling

### Login Errors
- Invalid credentials → "Geçersiz e-posta veya şifre"
- Network error → "Bağlantı hatası. Lütfen tekrar deneyin"
- Server error → "Sunucu hatası. Lütfen daha sonra tekrar deneyin"

### Register Errors
- Email already exists → "Bu e-posta adresi zaten kullanımda"
- Weak password → "Şifre en az 6 karakter olmalıdır"
- Network error → "Bağlantı hatası. Lütfen tekrar deneyin"

### Display Strategy
- Show errors in SnackBar
- Inline validation for form fields
- Loading indicators during async operations

## UI/UX Considerations

### Design System Alignment
- Use `AppColors` from theme system
- Use `Plus Jakarta Sans` font
- Rounded corners (1rem default, full for buttons)
- Consistent spacing and padding

### Accessibility
- Proper labels for input fields
- Screen reader support
- Keyboard navigation
- High contrast mode support

### Responsive Design
- Support different screen sizes
- Keyboard-aware scrolling
- Safe area handling

### Loading States
- Show loading indicator during auth operations
- Disable buttons during loading
- Prevent multiple submissions

### Animations
- Smooth transitions between screens
- Fade-in for error messages
- Scale animation for buttons

## Security Considerations

### Password Handling
- Never store passwords in plain text
- Use Supabase's built-in password hashing
- Minimum 6 character requirement
- Optional: Password strength indicator

### Session Management
- Use Supabase's session handling
- Auto-refresh tokens
- Secure storage of tokens

### Input Validation
- Client-side validation for UX
- Server-side validation for security
- Sanitize all inputs

## Testing Strategy

### Unit Tests
- AuthService methods
- Form validation logic
- Error handling

### Widget Tests
- LoginScreen UI and interactions
- RegisterScreen UI and interactions
- AuthGuard behavior
- ProfileScreen rendering

### Integration Tests
- Complete login flow
- Complete registration flow
- Auth guard redirection
- Logout flow

## Migration Strategy

### Existing Users
- No migration needed (auth system already exists)
- Update UI to match new design
- Preserve existing sessions

### Database Changes
- No schema changes required
- Use existing Supabase auth tables

## Performance Considerations

### Optimization
- Lazy load profile data
- Cache user metadata
- Minimize re-renders with proper provider usage

### Metrics
- Login time < 2 seconds
- Registration time < 3 seconds
- Screen transition < 300ms

## Future Enhancements

### Phase 2
- Social authentication (Google, Apple, Facebook)
- Email verification
- Phone number verification

### Phase 3
- Two-factor authentication
- Biometric authentication
- Password strength requirements

### Phase 4
- Account recovery options
- Session management UI
- Login history
