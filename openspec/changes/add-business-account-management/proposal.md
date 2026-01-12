# Change: İşletme Hesabı Yönetimi

## Why

Platformda sadece kullanıcılar değil, aynı zamanda işletme sahipleri de aktif rol alacak. İşletme sahiplerinin kendi mekanlarını yönetebilmeleri, kampanya oluşturabilmeleri, randevuları takip edebilmeleri ve takipçilerine bildirim gönderebilmeleri için kapsamlı bir işletme hesabı sistemi gerekiyor.

Mevcut sistemde kullanıcılar sadece mekanları görüntüleyebiliyor ve takip edebiliyor. Bu değişiklikle birlikte:
- İşletme sahipleri kendi hesaplarını işletme hesabına dönüştürebilecek
- İşletme modunda özel bir yönetim paneline erişebilecek
- Hem normal kullanıcı hem de işletme sahibi olarak platformu kullanabilecek
- Web tabanlı admin panelinden detaylı yönetim yapabilecek

## What Changes

### 1. Database Schema Updates
- `profiles` tablosuna `is_business_account` boolean field ekleme
- `business_subscriptions` tablosu oluşturma (abonelik yönetimi için)
- `profiles` ve `venues` arasında 1-to-1 ilişki kurma
- İşletme başvurusu onaylandığında otomatik venue oluşturma

### 2. Authentication & Session Management
- Giriş sonrası işletme hesabı kontrolü
- Session bazlı mod seçimi (işletme/normal kullanıcı)
- Mod değiştirme özelliği

### 3. Business Mode UI (Flutter)
- İşletmeye özel bottom navigation bar
  - **Profilim**: Mevcut profil ekranı + işletmeye özel butonlar
  - **Abonelik**: Abonelik durumu ve detayları
  - **Mağaza**: İşletmeye özel özellikler satış sayfası
- Mod seçim popup'ı (işletme/normal kullanıcı)
- Profil ekranında "Yönetim Paneli" ve "Normal Hesaba Geç" butonları

### 4. Web Admin Panel (React - Ayrı Proje)
- `admin/` klasöründe yeni React projesi
- İşletme yönetim özellikleri:
  - Kampanya ekleme/düzenleme
  - Randevu yönetimi
  - Uzman ekibi yönetimi
  - Galeri ve fotoğraf yönetimi
  - Takipçilere bildirim gönderme
  - Yorum yönetimi
  - İşletme bilgileri düzenleme
- Mevcut tasarımla uyumlu responsive tasarım

### 5. Subscription System
- Standart abonelik paketi (tüm işletmeler için)
- Abonelik durumu görüntüleme
- İlerde Google Play abonelik entegrasyonu için altyapı

## Impact

### Affected Specs
- `database` (MODIFIED): Yeni tablolar ve ilişkiler
- `navigation` (MODIFIED): İşletme modu navigasyonu
- `authentication` (MODIFIED): İşletme hesabı kontrolü
- `business-management` (NEW): İşletme yönetimi özellikleri
- `subscriptions` (NEW): Abonelik sistemi

### Affected Code
- `lib/data/models/`: Yeni modeller (BusinessSubscription, BusinessMode)
- `lib/presentation/providers/`: Yeni provider'lar (BusinessProvider, SubscriptionProvider)
- `lib/presentation/screens/`: Yeni ekranlar (SubscriptionScreen, StoreScreen)
- `lib/presentation/widgets/common/custom_bottom_nav.dart`: İşletme modu desteği
- `lib/presentation/screens/profile_screen.dart`: İşletme butonları
- `lib/core/utils/app_router.dart`: Yeni route'lar
- `supabase/migrations/`: Yeni migration dosyaları
- `admin/`: Yeni React projesi (web admin panel)

### Breaking Changes
- **NONE**: Mevcut kullanıcı deneyimi etkilenmeyecek
- Sadece `is_business_account = true` olan kullanıcılar için yeni özellikler aktif olacak

### Dependencies
- Bu değişiklik mevcut `business_applications` sistemine bağımlı
- Web admin panel için React, Next.js veya Vite kurulumu gerekli
- Supabase auth ve RLS politikaları güncellenecek

## Risks & Considerations

1. **Session Management**: Kullanıcı her giriş yaptığında mod seçimi yapması UX açısından yorucu olabilir
   - Mitigation: Kullanıcı tercihini localStorage'da saklayıp varsayılan mod olarak kullanabiliriz

2. **Web Admin Panel Hosting**: Ayrı bir React projesi host edilmesi gerekecek
   - Mitigation: Vercel, Netlify gibi ücretsiz platformlar kullanılabilir

3. **Subscription Validation**: Abonelik süresi dolduğunda işletme özelliklerinin kısıtlanması
   - Mitigation: İlk aşamada tüm işletmelere standart abonelik verilecek

4. **Data Consistency**: Venue ve profile arasındaki 1-to-1 ilişkinin korunması
   - Mitigation: Database constraint'leri ve trigger'lar kullanılacak
