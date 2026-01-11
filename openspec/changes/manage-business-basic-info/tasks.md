# Tasks: İşletme Temel Bilgileri Yönetimi

## Phase 1: Temel Bilgiler Ekranı

### Task 1.1: Admin Ana Ekrana Menü Öğesi Ekle
- [ ] `admin_dashboard_screen.dart` içinde "Temel Bilgiler" menü kartı ekle
- [ ] Icon: `Icons.storefront` veya `Icons.business`
- [ ] Subtitle: "İsim, Tanıtım Yazısı ve İletişim"
- [ ] Navigation: `/business/admin/basic-info`
- [ ] Tasarım referansı: `design/yonetim-index.html` (lines 124-142)

**Validation**: Yönetim ekranında "Temel Bilgiler" kartı görünür ve tıklanabilir

---

### Task 1.2: Temel Bilgiler Ekranı Oluştur
- [ ] `lib/presentation/screens/business/admin_basic_info_screen.dart` oluştur
- [ ] AppBar: "Temel Bilgiler" başlığı, geri butonu, kaydet butonu
- [ ] Form alanları:
  - İşletme Adı (TextFormField, required)
  - Tanıtım Yazısı (TextFormField, multiline, maxLines: 5)
  - Telefon (TextFormField, phone keyboard)
  - E-posta (TextFormField, email keyboard)
- [ ] Form validasyonu ekle
- [ ] Kaydet butonu ile değişiklikleri kaydet

**Validation**: Ekran açılır, form alanları görünür ve düzenlenebilir

---

### Task 1.3: Sosyal Medya Linkleri Bölümü
- [ ] Sosyal medya linkleri için genişletilebilir bölüm ekle
- [ ] Alanlar:
  - Instagram URL (TextFormField, URL validasyonu)
  - WhatsApp numarası (TextFormField, phone format)
  - Facebook URL (TextFormField, opsiyonel)
  - Website URL (TextFormField, opsiyonel)
- [ ] Her alan için format örneği göster (hint text)
- [ ] URL validasyonu ekle

**Validation**: Sosyal medya linkleri düzenlenebilir ve doğru formatta kaydedilir

---

### Task 1.4: BasicInfoProvider Oluştur
- [ ] `lib/presentation/providers/admin_basic_info_provider.dart` oluştur
- [ ] State: loading, venue data, error
- [ ] Methods:
  - `loadVenueBasicInfo(String venueId)` - Mevcut bilgileri yükle
  - `updateBasicInfo(Map<String, dynamic> data)` - Bilgileri güncelle
  - `validatePhone(String phone)` - Telefon validasyonu
  - `validateEmail(String email)` - Email validasyonu
  - `validateUrl(String url)` - URL validasyonu
- [ ] Supabase `venues` tablosuna UPDATE sorgusu
- [ ] Optimistic updates
- [ ] Error handling

**Validation**: Provider venues tablosunu doğru günceller

---

### Task 1.5: Route Ekle
- [ ] GoRouter'a `/business/admin/basic-info` route'u ekle
- [ ] Parent route: `/business/admin`
- [ ] BusinessProvider'dan venue_id al
- [ ] Route guard: Sadece business mode'da erişilebilir

**Validation**: Route çalışır ve doğru ekrana yönlendirir

---

## Phase 2: Çalışma Saatleri Ekranı

### Task 2.1: Çalışma Saatleri Menü Öğesi
- [ ] Temel Bilgiler ekranına "Çalışma Saatleri" alt menü butonu ekle
- [ ] Icon: `Icons.schedule`
- [ ] Mevcut çalışma saati özetini göster (örn: "Pzt-Cmt: 09:00-20:00")
- [ ] Navigation: `/business/admin/basic-info/working-hours`

**Validation**: Buton görünür ve çalışma saatleri ekranına yönlendirir

---

### Task 2.2: Çalışma Saatleri Ekranı Oluştur
- [ ] `lib/presentation/screens/business/admin_working_hours_screen.dart` oluştur
- [ ] Her gün için liste öğesi:
  - Gün adı (Pazartesi, Salı, vb.)
  - Açık/Kapalı switch
  - Açılış saati (TimePicker)
  - Kapanış saati (TimePicker)
- [ ] "Tüm Günler İçin Uygula" butonu
- [ ] Kaydet butonu

**Validation**: Ekran açılır, günler listelenmiş, saat seçilebilir

---

### Task 2.3: WorkingHoursProvider Oluştur
- [ ] `lib/presentation/providers/admin_working_hours_provider.dart` oluştur
- [ ] JSONB working_hours yapısını parse et:
  ```json
  {
    "monday": {"open": true, "start": "09:00", "end": "20:00"},
    "tuesday": {"open": true, "start": "09:00", "end": "20:00"},
    ...
  }
  ```
- [ ] Methods:
  - `loadWorkingHours(String venueId)`
  - `updateDayHours(String day, Map<String, dynamic> hours)`
  - `applyToAllDays(Map<String, dynamic> hours)`
  - `saveWorkingHours()`
- [ ] Supabase UPDATE ile working_hours JSONB güncelle

**Validation**: Çalışma saatleri doğru kaydedilir ve venue_details'da görünür

---

### Task 2.4: Time Picker Widget
- [ ] Özel time picker widget oluştur veya `showTimePicker` kullan
- [ ] 24 saat formatı
- [ ] Türkçe lokalizasyon
- [ ] Açılış < Kapanış validasyonu

**Validation**: Saat seçimi kullanıcı dostu ve doğru çalışıyor

---

## Phase 3: Konum Yönetimi

### Task 3.1: Konum Menü Öğesi
- [ ] Temel Bilgiler ekranına "Konum ve Adres" alt menü butonu ekle
- [ ] Icon: `Icons.location_on`
- [ ] Mevcut adresi göster
- [ ] Navigation: `/business/admin/basic-info/location`

**Validation**: Buton görünür ve konum ekranına yönlendirir

---

### Task 3.2: Konum Ekranı Oluştur
- [ ] `lib/presentation/screens/business/admin_location_screen.dart` oluştur
- [ ] Adres text field (autocomplete ile)
- [ ] Google Maps widget (küçük önizleme)
- [ ] Harita üzerinde marker ile konum seçimi
- [ ] Manuel koordinat girişi (opsiyonel)
- [ ] İl/İlçe dropdown'ları
- [ ] Kaydet butonu

**Validation**: Harita görünür, konum seçilebilir

---

### Task 3.3: LocationProvider Oluştur
- [ ] `lib/presentation/providers/admin_location_provider.dart` oluştur
- [ ] Methods:
  - `loadLocation(String venueId)`
  - `updateAddress(String address)`
  - `updateCoordinates(double lat, double lng)`
  - `updateProvinceDistrict(int provinceId, String districtId)`
  - `saveLocation()`
- [ ] Supabase UPDATE: address, latitude, longitude, location (geography)
- [ ] PostGIS point güncelleme: `ST_SetSRID(ST_MakePoint(lng, lat), 4326)`

**Validation**: Konum bilgileri doğru kaydedilir

---

### Task 3.4: Google Places Autocomplete
- [ ] Google Places API entegrasyonu (opsiyonel)
- [ ] Adres autocomplete widget
- [ ] Seçilen adresten koordinatları al
- [ ] Fallback: Manuel adres girişi

**Validation**: Adres autocomplete çalışır veya manuel giriş yapılabilir

---

## Phase 4: Entegrasyon ve Test

### Task 4.1: Provider'ları MultiProvider'a Ekle
- [ ] `main.dart` içinde:
  - `AdminBasicInfoProvider`
  - `AdminWorkingHoursProvider`
  - `AdminLocationProvider`
- [ ] Provider'ları ChangeNotifierProvider ile wrap et

**Validation**: Provider'lar uygulamada erişilebilir

---

### Task 4.2: VenueDetailsScreen Entegrasyonu
- [ ] Temel bilgiler güncellendiğinde VenueDetailsScreen otomatik yenilensin
- [ ] Realtime subscription veya provider listener kullan
- [ ] Optimistic UI updates

**Validation**: Değişiklikler anında venue details'da görünür

---

### Task 4.3: Form Validasyonu ve Error Handling
- [ ] Tüm formlarda validasyon:
  - Boş alan kontrolü (required fields)
  - Telefon format kontrolü
  - Email format kontrolü
  - URL format kontrolü
- [ ] Error mesajları Türkçe
- [ ] SnackBar ile kullanıcıya bildirim
- [ ] Loading states

**Validation**: Geçersiz veri girildiğinde uygun hata mesajı gösterilir

---

### Task 4.4: RLS Politika Kontrolü
- [ ] Venues tablosunda mevcut RLS politikalarını kontrol et
- [ ] Sadece `owner_id = auth.uid()` kontrolü yeterli mi?
- [ ] Gerekirse yeni politika ekle
- [ ] Test: Başka kullanıcı başkasının venue'sunu düzenleyemesin

**Validation**: RLS politikaları çalışıyor, güvenlik sağlanmış

---

### Task 4.5: UI/UX Polishing
- [ ] Tasarım referansına uygunluk kontrolü (yonetim-index.html)
- [ ] Mevcut admin ekranları ile tutarlılık
- [ ] Loading indicators
- [ ] Success/error animations
- [ ] Responsive layout
- [ ] Dark mode desteği

**Validation**: UI premium ve kullanıcı dostu

---

### Task 4.6: End-to-End Test
- [ ] İşletme sahibi olarak giriş yap
- [ ] Yönetim paneline git
- [ ] Temel Bilgiler'i aç
- [ ] Tüm alanları düzenle ve kaydet
- [ ] Çalışma saatlerini güncelle
- [ ] Konumu değiştir
- [ ] Venue details ekranında değişiklikleri kontrol et
- [ ] Arama sonuçlarında güncel bilgileri kontrol et

**Validation**: Tüm akış sorunsuz çalışıyor

---

## Acceptance Criteria

- [ ] İşletme sahipleri temel bilgilerini mobil uygulamadan düzenleyebilir
- [ ] Çalışma saatleri ekranı kullanıcı dostu
- [ ] Konum seçimi harita ile yapılabilir
- [ ] Sosyal medya linkleri doğru formatta kaydedilir
- [ ] Değişiklikler anında venue_details'da görünür
- [ ] Form validasyonu çalışır
- [ ] RLS politikaları güvenliği sağlar
- [ ] UI tasarımı tutarlı ve premium
