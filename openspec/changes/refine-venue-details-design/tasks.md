# Tasks: Mekan Detay Sayfası Tasarım İyileştirmesi

## Öncelik Sırası
1. Renk Paleti ve Tipografi Güncellemeleri (Foundation)
2. Hero Section İyileştirmeleri
3. About Tab Zenginleştirme
4. Service Cards Yenileme
5. Expert Cards Premium Tasarım
6. Booking Bottom Bar Ekleme
7. Test ve Doğrulama

---

## 1. Renk Paleti ve Tipografi Güncellemeleri

### Task 1.1: AppColors Güncelleme
**Hedef**: Design klasöründeki renk paletini AppColors'a entegre etmek.

**Adımlar**:
- [x] `lib/core/theme/app_colors.dart` dosyasını aç
- [x] Design dosyalarından renkleri çıkar:
  - Nude: `#F5E6D3`
  - Soft Pink: `#FFB6C1` 
  - Gold: `#D4AF37`
  - Açık gri arka planlar için: `#FAFAFA`
- [x] Mevcut renkleri design paletine göre güncelle
- [x] Gradient tanımları ekle (hero overlay için)

**Doğrulama**: Renkler design dosyalarıyla eşleşmeli

---

### Task 1.2: Typography Güncellemeleri
**Hedef**: Google Fonts ile Inter/Outfit fontlarını entegre etmek.

**Adımlar**:
- [x] `pubspec.yaml`'da google_fonts package'ının olduğunu doğrula
- [x] `lib/core/theme/app_text_styles.dart` dosyasını aç
- [x] Inter ve Outfit fontlarını ekle (Manrope kullanıldı)
- [x] Design dosyalarındaki font ağırlıklarını uygula:
  - Başlıklar: FontWeight.w600
  - Body text: FontWeight.w400
  - Alt başlıklar: FontWeight.w500

**Doğrulama**: Fontlar design dosyalarıyla eşleşmeli

---

## 2. Hero Section İyileştirmeleri

### Task 2.1: QuickActionButton Component
**Hedef**: Hero image üzerindeki aksiyon butonları için yeniden kullanılabilir component.

**Adımlar**:
- [x] `lib/presentation/widgets/venue/components/quick_action_button.dart` oluştur
- [x] Parametreler: icon, label, onTap, backgroundColor (şeffaf varsayılan)
- [x] Design: Circular button, beyaz ikon, şeffaf arka plan, hafif shadow
- [x] Responsive boyutlandırma

**Doğrulama**: Buton design dosyalarındaki gibi görünmeli

---

### Task 2.2: VenueHero Widget Güncelleme
**Hedef**: Hero section'a quick action buttons eklemek.

**Adımlar**:
- [x] `lib/presentation/widgets/venue/venue_hero.dart` dosyasını aç
- [x] QuickActionButton'ları import et (VenueQuickActions olarak)
- [x] 4 buton ekle: WhatsApp, Telefon, Harita, Instagram
- [x] Butonları hero image altına yerleştir (ayrı widget)
- [x] url_launcher package'ını entegre et
- [x] Gradient overlay ekle (AppColors.heroGradient)

**Bağımlılıklar**: Task 2.1

**Doğrulama**: 
- Butonlar tıklanabilir olmalı
- WhatsApp, telefon, harita linkleri çalışmalı
- Paylaş butonu mekan bilgilerini paylaşmalı

---

## 3. About Tab Zenginleştirme

### Task 3.1: WorkingHoursCard Component
**Hedef**: Çalışma saatlerini gösteren premium card.

**Adımlar**:
- [x] `lib/presentation/widgets/venue/components/working_hours_card.dart` oluştur
- [x] Parametreler: Map<String, String> hours (gün: saat formatında)
- [x] Bugünün saatini yeşil renkte vurgula
- [x] Kapalı günleri "Kapalı" olarak göster
- [x] Design dosyalarındaki card stilini uygula

**Doğrulama**: Bugünün saati vurgulanmalı

---

### Task 3.2: AboutTab Widget Güncelleme
**Hedef**: Mekan hikayesi, çalışma saatleri ve ödeme bilgilerini eklemek.

**Adımlar**:
- [x] `lib/presentation/widgets/venue/tabs/about_tab.dart` dosyasını aç
- [x] Mekan hikayesi bölümü ekle (expandable text)
- [x] WorkingHoursCard'ı entegre et
- [x] Ödeme yöntemleri bölümü ekle (ikonlarla)
- [x] Konum haritası bölümünü güncelle
- [x] Bölümler arası spacing'i design dosyalarına göre ayarla

**Bağımlılıklar**: Task 3.1

**Doğrulama**: 
- Tüm bölümler görünür olmalı
- "Devamını Oku" çalışmalı

---

## 4. Service Cards Yenileme

### Task 4.1: ServiceCard Component
**Hedef**: Before/after fotoğraflı premium hizmet kartı.

**Adımlar**:
- [x] `lib/presentation/widgets/venue/components/service_card.dart` oluştur
- [x] Parametreler: Service model, onAddToBooking callback
- [x] Before/after fotoğrafları yan yana göster
- [x] Ortada dikey ayırıcı çizgi ekle
- [x] "Önce" ve "Sonra" etiketleri ekle
- [x] Alt kısımda: hizmet adı, açıklama, uzman, fiyat
- [x] "Hizmeti Randevuya Ekle" butonu (pembe)
- [x] Card shadow ve border radius design dosyalarına göre

**Doğrulama**: Kart design dosyalarındaki gibi görünmeli

---

### Task 4.2: ServicesTab Widget Güncelleme
**Hedef**: ServiceCard component'ini kullanmak.

**Adımlar**:
- [x] `lib/presentation/widgets/venue/tabs/services_tab.dart` dosyasını aç
- [x] ServiceCard'ı import et
- [x] Mevcut hizmet listesini ServiceCard ile render et
- [x] "Randevuya Ekle" callback'ini implement et
- [x] Loading ve empty state'leri güncelle

**Bağımlılıklar**: Task 4.1

**Doğrulama**: Hizmetler before/after fotoğraflarla gösterilmeli

---

## 5. Expert Cards Premium Tasarım

### Task 5.1: ExpertCard Component
**Hedef**: Premium uzman kartı component'i.

**Adımlar**:
- [x] `lib/presentation/widgets/venue/components/expert_card.dart` oluştur
- [x] Parametreler: Expert model (veya map)
- [x] Yuvarlak profil fotoğrafı
- [x] Uzman adı, uzmanlık alanı
- [x] Yıldız ikonu ile puan gösterimi
- [x] Card design: beyaz arka plan, shadow, rounded corners
- [x] Responsive layout

**Doğrulama**: Kart design dosyalarındaki gibi görünmeli

---

### Task 5.2: ExpertsTab Widget Güncelleme
**Hedef**: ExpertCard component'ini kullanmak.

**Adımlar**:
- [x] `lib/presentation/widgets/venue/tabs/experts_tab.dart` dosyasını aç
- [x] ExpertCard'ı import et
- [x] Mevcut uzman listesini ExpertCard ile render et
- [x] Grid veya list layout uygula (design dosyalarına göre)
- [x] Loading ve empty state'leri güncelle

**Bağımlılıklar**: Task 5.1

**Doğrulama**: Uzmanlar premium kartlarla gösterilmeli

---

## 6. Booking Bottom Bar Ekleme

### Task 6.1: BookingBottomBar Component
**Hedef**: Sabit alt bar ile randevu butonu.

**Adımlar**:
- [x] `lib/presentation/widgets/venue/components/booking_bottom_bar.dart` oluştur
- [x] Parametreler: onBookingTap callback, totalPrice (opsiyonel)
- [x] Tam genişlikte pembe buton
- [x] "Randevu Oluştur" text
- [x] Hafif shadow (yukarı doğru)
- [x] Safe area padding

**Doğrulama**: Buton sabit kalmalı, scroll edilebilir olmalı

---

### Task 6.2: VenueDetailsScreen Güncelleme
**Hedef**: BookingBottomBar'ı ekrana entegre etmek.

**Adımlar**:
- [x] `lib/presentation/screens/venue/venue_details_screen.dart` dosyasını aç
- [x] BookingBottomBar'ı import et
- [x] Scaffold body'sini Stack ile sar
- [x] NestedScrollView'i Stack içine al
- [x] BookingBottomBar'ı Stack'in en üstüne ekle (Positioned.bottom)
- [x] Randevu oluşturma callback'ini implement et

**Bağımlılıklar**: Task 6.1

**Doğrulama**: 
- Buton her zaman altta görünmeli
- Tıklandığında randevu ekranına gitmeli

---

## 7. Test ve Doğrulama

### Task 7.1: Visual Regression Testing
**Hedef**: Tasarımın design dosyalarıyla eşleştiğini doğrulamak.

**Adımlar**:
- [ ] Her bir ekranın screenshot'ını al
- [ ] Design dosyalarıyla karşılaştır
- [ ] Renk, spacing, typography farklılıklarını düzelt

**Bağımlılıklar**: Tüm UI task'ları

---

### Task 7.2: Functionality Testing
**Hedef**: Tüm özelliklerin çalıştığını doğrulamak.

**Adımlar**:
- [ ] Quick action butonlarını test et (WhatsApp, telefon, harita, paylaş)
- [ ] Çalışma saatleri doğru görüntüleniyor mu kontrol et
- [ ] Hizmet kartlarında before/after fotoğrafları test et
- [ ] Randevu butonu tıklanabilir mi kontrol et
- [ ] Farklı ekran boyutlarında responsive test et

**Bağımlılıklar**: Tüm task'lar

---

## 8. Dependencies Installation

### Task 8.1: Package Dependencies
**Hedef**: Gerekli package'ları yüklemek.

**Adımlar**:
- [x] `pubspec.yaml` dosyasını aç
- [x] Gerekli package'ları ekle:
  - `url_launcher: ^6.2.0` (WhatsApp, telefon, harita)
  - `share_plus: ^7.2.0` (paylaşım)
  - `google_fonts: ^6.1.0` (zaten var mı kontrol et)
- [x] `flutter pub get` çalıştır

**Doğrulama**: Package'lar başarıyla yüklenmeli

---

## Paralel Çalışılabilir Task'lar
- Task 1.1 ve 1.2 (Foundation)
- Task 2.1, 3.1, 4.1, 5.1, 6.1 (Component'ler birbirinden bağımsız)

## Kritik Yol
1. Task 8.1 (Dependencies) → 2. Task 1.1, 1.2 (Foundation) → 3. Component'ler → 4. Integration → 5. Testing
