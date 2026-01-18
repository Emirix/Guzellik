---
name: turkish-localization
description: Manages Turkish language content, UI text, and business terminology for the Guzellik beauty platform. Use when adding Turkish strings, translating UI text, or working with Turkish business domain terms.
---

# Turkish Localization

## When to use this skill
- Adding new UI text in Turkish
- Translating features to Turkish
- Working with Turkish business terminology
- User mentions "Türkçe", "translation", "çeviri", "metin", "text"
- Creating Turkish content for the app

## Turkish Language Context

### Target Audience
- **Primary**: Women in Turkey seeking beauty services
- **Language**: Turkish (Türkçe)
- **Tone**: Professional, friendly, trustworthy
- **Cultural Context**: Turkish beauty industry standards

### Business Domain Terms

#### Venue Types (Mekan Türleri)
- **Güzellik Salonu** - Beauty Salon
- **Kuaför** - Hair Salon
- **Tırnak Stüdyosu** - Nail Studio
- **Estetik Kliniği** - Aesthetic Clinic
- **Solaryum** - Solarium Center
- **Ayak Bakım** - Foot Care

#### Service Categories (Hizmet Kategorileri)
- **Saç** - Hair
  - Kesim, Boya, Keratin, Kaynak, Perma
- **Cilt Bakımı** - Skin Care
  - Hydrafacial, Peeling, Leke Tedavisi, Akne Tedavisi
- **Tırnak** - Nails
  - Manikür, Protez Tırnak, Kalıcı Oje
- **Estetik** - Aesthetics
  - Botoks, Dolgu, Lazer Epilasyon, PRP, Mezoterapi
- **Vücut** - Body
  - Masaj, Zayıflama, Selülit Tedavisi
- **Kaş-Kirpik** - Brows & Lashes
  - Microblading, Laminasyon, Lifting

#### Trust & Verification (Güven ve Doğrulama)
- **Onaylı Mekan** - Verified Venue
- **En Çok Tercih Edilen** - Most Preferred
- **Hijyen Onaylı** - Hygiene Certified
- **Güven Rozeti** - Trust Badge

#### User Actions (Kullanıcı İşlemleri)
- **Takip Et** - Follow
- **Takipten Çık** - Unfollow
- **Favorilere Ekle** - Add to Favorites
- **Yorum Yap** - Write Review
- **Randevu Al** - Book Appointment
- **Paylaş** - Share

#### Business Account (İşletme Hesabı)
- **İşletme Modu** - Business Mode
- **Normal Hesap** - Normal Account
- **Abonelik** - Subscription
- **Yönetim Paneli** - Admin Panel
- **Premium Özellikler** - Premium Features
- **Mağaza** - Store

## Localization Patterns

### UI Text Guidelines

#### Buttons
```dart
// ✅ Good - Clear and action-oriented
'Takip Et'
'Randevu Al'
'Detayları Gör'
'Kaydet'

// ❌ Bad - Too verbose or unclear
'Takip Etmek İçin Tıklayın'
'Randevu Almak İster misiniz?'
```

#### Labels
```dart
// ✅ Good - Concise and descriptive
'Çalışma Saatleri'
'Hizmetler'
'Ekip'
'İletişim'

// ❌ Bad - Too long
'Bu Mekanın Çalışma Saatleri'
'Sunulan Hizmetler Listesi'
```

#### Messages
```dart
// ✅ Good - Friendly and informative
'Mekan favorilere eklendi'
'Takip ediyorsunuz'
'Yorum başarıyla gönderildi'

// ❌ Bad - Too technical or cold
'Favorilere ekleme işlemi tamamlandı'
'Takip durumu: aktif'
'Yorum veritabanına kaydedildi'
```

### Error Messages

#### User-Friendly Errors
```dart
// ✅ Good - Clear and helpful
'İnternet bağlantınızı kontrol edin'
'Bu mekan bulunamadı'
'Lütfen tüm alanları doldurun'

// ❌ Bad - Technical jargon
'Network error: 404'
'Null pointer exception'
'Database connection failed'
```

#### Validation Messages
```dart
// ✅ Good - Specific and actionable
'Telefon numarası 10 haneli olmalıdır'
'Geçerli bir e-posta adresi girin'
'Şifre en az 6 karakter olmalıdır'

// ❌ Bad - Vague
'Geçersiz giriş'
'Hata'
'Yanlış format'
```

### Success Messages

```dart
// ✅ Good - Positive and clear
'Profil güncellendi ✓'
'Mekan başarıyla eklendi'
'Aboneliğiniz aktif edildi'

// ❌ Bad - Too formal
'Profil güncelleme işlemi başarıyla tamamlanmıştır'
'Mekan ekleme prosedürü sonlandırılmıştır'
```

## Implementation Patterns

### Constants File Structure

```dart
// lib/core/constants/app_strings.dart
class AppStrings {
  // Venue Types
  static const String beautysalon = 'Güzellik Salonu';
  static const String hairSalon = 'Kuaför';
  static const String nailStudio = 'Tırnak Stüdyosu';
  static const String aestheticClinic = 'Estetik Kliniği';
  static const String solarium = 'Solaryum';
  static const String footCare = 'Ayak Bakım';
  
  // Actions
  static const String follow = 'Takip Et';
  static const String unfollow = 'Takipten Çık';
  static const String addToFavorites = 'Favorilere Ekle';
  static const String bookAppointment = 'Randevu Al';
  static const String writeReview = 'Yorum Yap';
  static const String share = 'Paylaş';
  
  // Trust Badges
  static const String verifiedVenue = 'Onaylı Mekan';
  static const String mostPreferred = 'En Çok Tercih Edilen';
  static const String hygieneApproved = 'Hijyen Onaylı';
  
  // Business Account
  static const String businessMode = 'İşletme Modu';
  static const String normalAccount = 'Normal Hesap';
  static const String subscription = 'Abonelik';
  static const String adminPanel = 'Yönetim Paneli';
  static const String premiumFeatures = 'Premium Özellikler';
  static const String store = 'Mağaza';
  
  // Messages
  static const String venueAddedToFavorites = 'Mekan favorilere eklendi';
  static const String nowFollowing = 'Takip ediyorsunuz';
  static const String reviewSubmitted = 'Yorum başarıyla gönderildi';
  
  // Errors
  static const String checkInternetConnection = 'İnternet bağlantınızı kontrol edin';
  static const String venueNotFound = 'Bu mekan bulunamadı';
  static const String fillAllFields = 'Lütfen tüm alanları doldurun';
}
```

### Usage in Widgets

```dart
// ✅ Good - Use constants
Text(AppStrings.follow)
ElevatedButton(
  onPressed: () {},
  child: Text(AppStrings.bookAppointment),
)

// ❌ Bad - Hardcoded strings
Text('Takip Et')
ElevatedButton(
  onPressed: () {},
  child: Text('Randevu Al'),
)
```

### Dynamic Text with Variables

```dart
// ✅ Good - Clear interpolation
String followersCount(int count) => '$count takipçi';
String reviewsCount(int count) => '$count yorum';
String daysRemaining(int days) => '$days gün kaldı';

// Usage
Text(AppStrings.followersCount(venue.followersCount))
```

## Turkish Grammar Rules

### Plural Forms
- Turkish doesn't use 's' for plurals in counts
- Use singular form with numbers

```dart
// ✅ Correct
'5 yorum'  // 5 reviews
'10 takipçi'  // 10 followers
'3 mekan'  // 3 venues

// ❌ Wrong
'5 yorumlar'
'10 takipçiler'
```

### Capitalization
- Sentence case for most UI text
- Title case for proper nouns and brands

```dart
// ✅ Correct
'Güzellik salonu'  // In sentences
'Güzellik Salonu'  // As category title

// ❌ Wrong
'GÜZELLİK SALONU'  // All caps (unless for emphasis)
```

### Formal vs Informal
- Use informal "sen" form (not formal "siz")
- Be friendly but professional

```dart
// ✅ Correct - Informal
'Profilini güncelle'
'Favorilerine ekle'

// ❌ Wrong - Too formal
'Profilinizi güncelleyin'
'Favorilerinize ekleyin'
```

## Checklist: Adding Turkish Content

### Before Adding Text
- [ ] Check if string already exists in `AppStrings`
- [ ] Verify Turkish grammar and spelling
- [ ] Ensure tone matches app's voice
- [ ] Consider context (where will it appear?)
- [ ] Check for similar existing strings

### During Implementation
- [ ] Add to `AppStrings` constants
- [ ] Use meaningful constant names
- [ ] Group related strings together
- [ ] Add comments for context if needed
- [ ] Use string interpolation for dynamic content

### After Implementation
- [ ] Test text in actual UI
- [ ] Verify text fits in UI elements
- [ ] Check on different screen sizes
- [ ] Ensure consistency with similar features
- [ ] Review with native Turkish speaker if possible

## Common Mistakes to Avoid

### ❌ Hardcoded Strings
```dart
// Bad
Text('Takip Et')

// Good
Text(AppStrings.follow)
```

### ❌ English in UI
```dart
// Bad
Text('Follow')

// Good
Text(AppStrings.follow)  // 'Takip Et'
```

### ❌ Overly Formal Language
```dart
// Bad
'Lütfen bekleyiniz'

// Good
'Lütfen bekleyin'
```

### ❌ Technical Jargon in User Messages
```dart
// Bad
'API hatası oluştu'

// Good
'Bir sorun oluştu, lütfen tekrar deneyin'
```

### ❌ Inconsistent Terminology
```dart
// Bad - Using different terms for same thing
'Takip Et' in one place
'İzle' in another place

// Good - Consistent
'Takip Et' everywhere
```

## Resources

### Key Files
- `lib/core/constants/app_strings.dart` - All Turkish strings
- `openspec/project.md` - Domain terminology reference
- `docs/ASO_METINLERI.md` - App Store Turkish content

### Reference Materials
- Turkish beauty industry terminology
- Competitor app language analysis
- User feedback on clarity

### Quality Standards
- Professional but friendly tone
- Clear and concise
- Culturally appropriate
- Grammatically correct
- Consistent across app
