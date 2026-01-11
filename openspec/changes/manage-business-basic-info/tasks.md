# Tasks: İşletme Temel Bilgileri Yönetimi

## Phase 1: Temel Bilgiler Ekranı

### Task 1.1: Admin Ana Ekrana Menü Öğesi Ekle
- [x] `admin_dashboard_screen.dart` içinde "Temel Bilgiler" menü kartı ekle
- [x] Icon: `Icons.storefront` veya `Icons.business`
- [x] Subtitle: "İsim, Tanıtım Yazısı ve İletişim"
- [x] Navigation: `/business/admin/basic-info`
- [x] Tasarım referansı: `design/yonetim-index.html` (lines 124-142)

**Validation**: Yönetim ekranında "Temel Bilgiler" kartı görünür ve tıklanabilir

---

### Task 1.2: Temel Bilgiler Ekranı Oluştur
- [x] `lib/presentation/screens/business/admin_basic_info_screen.dart` oluştur
- [x] AppBar: "Temel Bilgiler" başlığı, geri butonu, kaydet butonu
- [x] Form alanları:
  - İşletme Adı (TextFormField, required)
  - Tanıtım Yazısı (TextFormField, multiline, maxLines: 5)
  - Telefon (TextFormField, phone keyboard)
  - E-posta (TextFormField, email keyboard)
- [x] Form validasyonu ekle
- [x] Kaydet butonu ile değişiklikleri kaydet

**Validation**: Ekran açılır, form alanları görünür ve düzenlenebilir

---

### Task 1.3: Sosyal Medya Linkleri Bölümü
- [x] Sosyal medya linkleri için genişletilebilir bölüm ekle
- [x] Alanlar:
  - Instagram URL (TextFormField, URL validasyonu)
  - WhatsApp numarası (TextFormField, phone format)
  - Facebook URL (TextFormField, opsiyonel)
  - Website URL (TextFormField, opsiyonel)
- [x] Her alan için format örneği göster (hint text)
- [x] URL validasyonu ekle

**Validation**: Sosyal medya linkleri düzenlenebilir ve doğru formatta kaydedilir

---

### Task 1.4: BasicInfoProvider Oluştur
- [x] `lib/presentation/providers/admin_basic_info_provider.dart` oluştur
- [x] State: loading, venue data, error
- [x] Methods:
  - `loadVenueBasicInfo(String venueId)` - Mevcut bilgileri yükle
  - `updateBasicInfo(Map<String, dynamic> data)` - Bilgileri güncelle
  - `validatePhone(String phone)` - Telefon validasyonu
  - `validateEmail(String email)` - Email validasyonu
  - `validateUrl(String url)` - URL validasyonu
- [x] Supabase `venues` tablosuna UPDATE sorgusu
- [x] Optimistic updates
- [x] Error handling

**Validation**: Provider venues tablosunu doğru günceller

---

### Task 1.5: Route Ekle
- [x] GoRouter'a `/business/admin/basic-info` route'u ekle
- [x] Parent route: `/business/admin`
- [x] BusinessProvider'dan venue_id al
- [x] Route guard: Sadece business mode'da erişilebilir

**Validation**: Route çalışır ve doğru ekrana yönlendirir

---

## Phase 2: Çalışma Saatleri Ekranı

### Task 2.1: Çalışma Saatleri Menü Öğesi
- [x] Temel Bilgiler ekranına "Çalışma Saatleri" alt menü butonu ekle
- [x] Icon: `Icons.schedule`
- [x] Mevcut çalışma saati özetini göster (örn: "Pzt-Cmt: 09:00-20:00")
- [x] Navigation: `/business/admin/basic-info/working-hours`

**Validation**: Buton görünür ve çalışma saatleri ekranına yönlendirir

---

### Task 2.2: Çalışma Saatleri Ekranı Oluştur
- [x] `lib/presentation/screens/business/admin_working_hours_screen.dart` oluştur
- [x] Her gün için liste öğesi:
  - Gün adı (Pazartesi, Salı, vb.)
  - Açık/Kapalı switch
  - Açılış saati (TimePicker)
  - Kapanış saati (TimePicker)
- [x] "Tüm Günler İçin Uygula" butonu
- [x] Kaydet butonu

**Validation**: Ekran açılır, günler listelenmiş, saat seçilebilir

---

### Task 2.3: WorkingHoursProvider Oluştur
- [x] `lib/presentation/providers/admin_working_hours_provider.dart` oluştur
- [x] JSONB working_hours yapısını parse et:
  ```json
  {
    "monday": {"open": true, "start": "09:00", "end": "20:00"},
    "tuesday": {"open": true, "start": "09:00", "end": "20:00"},
    ...
  }
  ```
- [x] Methods:
  - `loadWorkingHours(String venueId)`
  - `updateDayHours(String day, Map<String, dynamic> hours)`
  - `applyToAllDays(Map<String, dynamic> hours)`
  - `saveWorkingHours()`
- [x] Supabase UPDATE ile working_hours JSONB güncelle

**Validation**: Çalışma saatleri doğru kaydedilir ve venue_details'da görünür

---

### Task 2.4: Time Picker Widget
- [x] Özel time picker widget oluştur veya `showTimePicker` kullan
- [x] 24 saat formatı
- [x] Türkçe lokalizasyon
- [x] Açılış < Kapanış validasyonu

**Validation**: Saat seçimi kullanıcı dostu ve doğru çalışıyor

---

## Phase 3: Konum Yönetimi

### Task 3.1: Konum Menü Öğesi
- [x] Temel Bilgiler ekranına "Konum ve Adres" alt menü butonu ekle
- [x] Icon: `Icons.location_on`
- [x] Mevcut adresi göster
- [x] Navigation: `/business/admin/basic-info/location`

**Validation**: Buton görünür ve konum ekranına yönlendirir

---

### Task 3.2: Konum Ekranı Oluştur
- [x] `lib/presentation/screens/business/admin_location_screen.dart` oluştur
- [x] Adres text field (autocomplete ile)
- [x] Google Maps widget (küçük önizleme)
- [x] Harita üzerinde marker ile konum seçimi
- [x] Manuel koordinat girişi (opsiyonel)
- [x] İl/İlçe dropdown'ları
- [x] Kaydet butonu

**Validation**: Harita görünür, konum seçilebilir

---

### Task 3.3: LocationProvider Oluştur
- [x] `lib/presentation/providers/admin_location_provider.dart` oluştur
- [x] Methods:
  - `loadLocation(String venueId)`
  - `updateAddress(String address)`
  - `updateCoordinates(double lat, double lng)`
  - `updateProvinceDistrict(int provinceId, String districtId)`
  - `saveLocation()`
- [x] Supabase UPDATE: address, latitude, longitude, location (geography)
- [x] PostGIS point güncelleme: `ST_SetSRID(ST_MakePoint(lng, lat), 4326)`

**Validation**: Konum bilgileri doğru kaydedilir

---

### Task 3.4: Google Places Autocomplete
- [x] Google Places API entegrasyonu (MapPicker ile sağlandı)
- [x] Adres autocomplete widget (Haritadan seçim ile otomatik doldurma)
- [x] Seçilen adresten koordinatları al
- [x] Fallback: Manuel adres girişi

**Validation**: Adres autocomplete çalışır veya manuel giriş yapılabilir

---

## Phase 4: Entegrasyon ve Test

### Task 4.1: Provider'ları MultiProvider'a Ekle
- [x] `main.dart` içinde:
  - `AdminBasicInfoProvider`
  - `AdminWorkingHoursProvider`
  - `AdminLocationProvider`
- [x] Provider'ları ChangeNotifierProvider ile wrap et

**Validation**: Provider'lar uygulamada erişilebilir

---

### Task 4.2: VenueDetailsScreen Entegrasyonu
- [x] Temel bilgiler güncellendiğinde VenueDetailsScreen otomatik yenilensin
- [x] Realtime subscription veya provider listener kullan
- [x] Optimistic UI updates

**Validation**: Değişiklikler anında venue details'da görünür

---

### Task 4.3: Form Validasyonu ve Error Handling
- [x] Tüm formlarda validasyon:
  - Boş alan kontrolü (required fields)
  - Telefon format kontrolü
  - Email format kontrolü
  - URL format kontrolü
- [x] Error mesajları Türkçe
- [x] SnackBar ile kullanıcıya bildirim
- [x] Loading states

**Validation**: Geçersiz veri girildiğinde uygun hata mesajı gösterilir

---

### Task 4.4: RLS Politika Kontrolü
- [x] Venues tablosunda mevcut RLS politikalarını kontrol et
- [x] Sadece `owner_id = auth.uid()` kontrolü yeterli mi? (Evet, kontrol edildi)
- [x] Gerekirse yeni politika ekle (Venue Photos için güvenlik açığı giderildi)
- [x] Test: Başka kullanıcı başkasının venue'sunu düzenleyemesin

**Validation**: RLS politikaları çalışıyor, güvenlik sağlanmış

---

### Task 4.5: UI/UX Polishing
- [x] Tasarım referansına uygunluk kontrolü (yonetim-index.html)
- [x] Mevcut admin ekranları ile tutarlılık
- [x] Loading indicators
- [x] Success/error animations
- [x] Responsive layout
- [x] Dark mode desteği

**Validation**: UI premium ve kullanıcı dostu

---

### Task 4.6: End-to-End Test
- [x] İşletme sahibi olarak giriş yap
- [x] Yönetim paneline git
- [x] Temel Bilgiler'i aç
- [x] Tüm alanları düzenle ve kaydet
- [x] Çalışma saatlerini güncelle
- [x] Konumu değiştir
- [x] Venue details ekranında değişiklikleri kontrol et
- [x] Arama sonuçlarında güncel bilgileri kontrol et

**Validation**: Tüm akış sorunsuz çalışıyor

---

## Acceptance Criteria

- [x] İşletme sahipleri temel bilgilerini mobil uygulamadan düzenleyebilir
- [x] Çalışma saatleri ekranı kullanıcı dostu
- [x] Konum seçimi harita ile yapılabilir
- [x] Sosyal medya linkleri doğru formatta kaydedilir
- [x] Değişiklikler anında venue_details'da görünür
- [x] Form validasyonu çalışır
- [x] RLS politikaları güvenliği sağlar
- [x] UI tasarımı tutarlı ve premium
