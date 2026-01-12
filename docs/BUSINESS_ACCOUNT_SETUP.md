# İşletme Hesabı Yönetimi - Kurulum Rehberi

## Genel Bakış
Bu özellik, işletme sahiplerinin kendi mekanlarını yönetebilmeleri için kapsamlı bir sistem sağlar.

## Özellikler
- ✅ İşletme hesabı algılama ve mod seçimi
- ✅ Çift mod sistemi (Normal Kullanıcı ↔ İşletme Modu)
- ✅ İşletme navigasyonu (Profilim, Abonelik, Mağaza)
- ✅ Abonelik yönetimi
- ✅ Web admin paneli entegrasyonu
- ✅ Premium özellikler mağazası

## Veritabanı Şeması

### Yeni Tablolar

#### `business_subscriptions`
```sql
CREATE TABLE business_subscriptions (
  id UUID PRIMARY KEY,
  profile_id UUID REFERENCES profiles(id),
  subscription_type TEXT DEFAULT 'standard',
  status TEXT DEFAULT 'active',
  started_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  features JSONB,
  payment_method TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

### Güncellenen Tablolar

#### `profiles`
Yeni kolonlar:
- `is_business_account` (BOOLEAN) - İşletme hesabı bayrağı
- `business_venue_id` (UUID) - İşletmenin venue ID'si

## RPC Fonksiyonları

### `get_business_subscription(profile_id UUID)`
Kullanıcının aktif aboneliğini getirir.

### `check_business_feature(profile_id UUID, feature TEXT)`
Belirli bir özelliğin aktif olup olmadığını kontrol eder.

### `get_business_venue(profile_id UUID)`
Kullanıcının sahip olduğu mekanı getirir.

## Flutter Kullanımı

### İşletme Hesabı Kontrolü
```dart
final businessProvider = context.read<BusinessProvider>();
final isBusinessAccount = await businessProvider.checkBusinessAccount(userId);
```

### Mod Değiştirme
```dart
await businessProvider.switchMode(BusinessMode.business, userId);
```

### Abonelik Bilgisi
```dart
final subscriptionProvider = context.read<SubscriptionProvider>();
await subscriptionProvider.loadSubscription(userId);
final subscription = subscriptionProvider.subscription;
```

### Admin Panel Açma
```dart
final url = AdminConfig.getAdminUrl(venueId);
await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
```

## Ekranlar

### 1. Subscription Screen
- Abonelik detayları
- Kalan gün göstergesi
- Progress bar
- Admin panel butonu
- Hızlı erişim kartları

### 2. Store Screen
- Premium özellikler listesi
- Fiyatlandırma
- "Yakında" badge'leri

### 3. Profile Screen (Business Mode)
- İşletme hesabı göstergesi
- Yönetim Paneli butonu
- Mod değiştirme butonları

## Test Senaryoları

### 1. İşletme Hesabı Girişi
1. İşletme hesabıyla giriş yap
2. Mod seçim dialogu görünmeli
3. "İşletme Modu" seç
4. Business bottom navigation görünmeli

### 2. Mod Değiştirme
1. Profile ekranına git
2. "Normal Hesaba Geç" butonuna tıkla
3. Normal navigasyon görünmeli
4. "İşletme Moduna Geç" butonu görünmeli

### 3. Admin Panel Erişimi
1. Subscription ekranına git
2. "Admin Panele Git" butonuna tıkla
3. Tarayıcıda admin panel açılmalı

## Deployment

### Flutter App
Standart Flutter deployment süreci. Ek yapılandırma gerekmez.

### Admin Panel
Admin panel ayrı bir React projesi olarak deploy edilmelidir:
1. `admin/` klasöründe `npm run build`
2. Build çıktısını Vercel/Netlify'a deploy et
3. `lib/config/admin_config.dart` dosyasında URL'i güncelle

## Güvenlik

### RLS Policies
- Kullanıcılar sadece kendi aboneliklerini görebilir
- İşletme verileri sadece sahipler tarafından erişilebilir
- Subscription kontrolü tüm business özellikler için gereklidir

### Admin Panel
- Supabase authentication gereklidir
- `is_business_account = true` kontrolü yapılır
- Venue ownership doğrulanır

## Sorun Giderme

### "Mekan bilgisi bulunamadı" hatası
- `business_venue_id` alanının dolu olduğundan emin olun
- Venue kaydının mevcut olduğunu kontrol edin

### Admin panel açılmıyor
- `lib/config/admin_config.dart` dosyasındaki URL'i kontrol edin
- Admin panel'in deploy edildiğinden emin olun
- Tarayıcı izinlerini kontrol edin

### Mod değişmiyor
- BusinessProvider'ın doğru initialize edildiğinden emin olun
- SharedPreferences izinlerini kontrol edin
- Logout/login yaparak cache'i temizleyin

## Gelecek Geliştirmeler
- Google Play abonelik entegrasyonu
- Gelişmiş analitik özellikleri
- Push notification sistemi
- Kampanya yönetimi
- Randevu yönetimi
