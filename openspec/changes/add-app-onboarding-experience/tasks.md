# Implementation Tasks: Uygulama Onboarding Deneyimi

## Phase 1: Temel Yapı ve Altyapı

### Task 1.1: Dependencies Ekleme
- [x] `pubspec.yaml`'a `lottie` paketi ekle (^3.0.0)
- [x] `pubspec.yaml`'a `shared_preferences` paketi ekle (^2.2.0)
- [x] `flutter pub get` çalıştır
- **Validation:** Paketler başarıyla yüklendi ve import edilebiliyor
- **Dependencies:** Yok

### Task 1.2: Onboarding Preferences Service Oluşturma
- [x] `lib/data/services/onboarding_preferences.dart` oluştur
- [x] `hasSeenOnboarding` getter/setter metodları ekle
- [x] `markOnboardingComplete()` metodu ekle
- [x] `resetOnboarding()` metodu ekle (debug için)
- **Validation:** Service test edildi, SharedPreferences'a yazıyor/okuyor
- **Dependencies:** Task 1.1

### Task 1.3: Onboarding Provider Oluşturma
- [x] `lib/presentation/providers/app_onboarding_provider.dart` oluştur
- [x] `ChangeNotifier` extend et
- [x] `currentPage` state'i ekle
- [x] `nextPage()`, `previousPage()`, `skipToEnd()` metodları ekle
- [x] `completeOnboarding()` metodu ekle (preferences'a kaydet)
- **Validation:** Provider state yönetimi çalışıyor
- **Dependencies:** Task 1.2

### Task 1.4: Router Güncelleme
- [x] `lib/core/utils/app_router.dart`'a `/onboarding` route'u ekle
- [x] Splash screen'den onboarding'e yönlendirme logiği ekle
- [x] Onboarding tamamlandıktan sonra home'a yönlendirme ekle
- **Validation:** Route'lar çalışıyor, navigasyon akışı doğru
- **Dependencies:** Task 1.3

### Task 1.5: Splash Screen Güncelleme
- [x] `splash_screen.dart`'da onboarding kontrolü ekle
- [x] `OnboardingPreferences` ile kontrol et
- [x] Eğer görülmediyse `/onboarding`'e yönlendir
- [x] Eğer görüldüyse `/` (home)'a yönlendir
- **Validation:** İlk açılışta onboarding, sonraki açılışlarda home gösteriliyor
- **Dependencies:** Task 1.2, Task 1.4

## Phase 2: Onboarding Screen ve Temel Widget'lar

### Task 2.1: Onboarding Screen Oluşturma
- [ ] `lib/presentation/screens/onboarding_screen.dart` oluştur
- [ ] `PageView.builder` ile sayfa yapısı kur
- [ ] Provider entegrasyonu ekle
- [ ] Scaffold ve temel layout oluştur
- **Validation:** Boş onboarding screen görüntüleniyor
- **Dependencies:** Task 1.3, Task 1.4

### Task 2.2: Sayfa Göstergeleri (Page Indicators) Widget'ı
- [ ] `lib/presentation/widgets/onboarding/page_indicators.dart` oluştur
- [ ] Dot indicator'ları oluştur
- [ ] Active/inactive state'leri ekle
- [ ] Animasyonlu geçişler ekle
- **Validation:** Indicator'lar sayfa değişiminde güncelleniyor
- **Dependencies:** Task 2.1

### Task 2.3: Navigasyon Butonları Widget'ı
- [ ] `lib/presentation/widgets/onboarding/onboarding_navigation.dart` oluştur
- [ ] "İleri" butonu oluştur
- [ ] Son sayfada "Hadi Başlayalım!" butonu göster
- [ ] Buton animasyonları ekle (scale, fade)
- **Validation:** Butonlar çalışıyor, son sayfada farklı buton gösteriliyor
- **Dependencies:** Task 2.1

### Task 2.4: Telefon Mockup Frame Widget'ı
- [ ] `lib/presentation/widgets/onboarding/phone_mockup_frame.dart` oluştur
- [ ] Modern telefon frame tasarımı (rounded corners, notch)
- [ ] Shadow ve depth efektleri ekle
- [ ] Responsive boyutlandırma
- **Validation:** Telefon frame farklı ekran boyutlarında iyi görünüyor
- **Dependencies:** Yok

### Task 2.5: Swipe Gesture Desteği
- [ ] `PageView`'a swipe gesture ekle
- [ ] Swipe animasyonlarını smooth yap
- [ ] Sayfa değişiminde provider'ı güncelle
- **Validation:** Swipe ile sayfa geçişi çalışıyor
- **Dependencies:** Task 2.1

## Phase 3: Onboarding Ekranları İçeriği

### Task 3.1: Ekran 1 - Hoş Geldiniz
- [ ] `lib/presentation/widgets/onboarding/screens/welcome_screen.dart` oluştur
- [ ] Logo animasyonu için Lottie dosyası bul/oluştur
- [ ] Başlık: "Güzelliğinize Değer Katan Adresler, Bir Tıkta!"
- [ ] Alt metin ekle
- [ ] Gradient background ekle
- **Validation:** Ekran tasarıma uygun görünüyor
- **Dependencies:** Task 2.4

### Task 3.2: Ekran 2 - Kampanyalar
- [ ] `lib/presentation/widgets/onboarding/screens/campaigns_screen.dart` oluştur
- [ ] Kampanya kartları animasyonu için Lottie/widget oluştur
- [ ] Slide-in animasyonları ekle
- [ ] Başlık: "Özel Fırsatları Kaçırmayın!"
- [ ] Örnek kampanya kartları göster
- **Validation:** Kampanya kartları animasyonlu görünüyor
- **Dependencies:** Task 2.4

### Task 3.3: Ekran 3 - Harita
- [ ] `lib/presentation/widgets/onboarding/screens/map_screen.dart` oluştur
- [ ] Harita mockup animasyonu için Lottie/widget oluştur
- [ ] Pin drop animasyonları ekle
- [ ] Başlık: "Yakınınızdaki Salonları Keşfedin"
- [ ] Detay kartı animasyonu ekle
- **Validation:** Harita ve pin animasyonları çalışıyor
- **Dependencies:** Task 2.4

### Task 3.4: Ekran 4 - Filtreleme
- [ ] `lib/presentation/widgets/onboarding/screens/filtering_screen.dart` oluştur
- [ ] Filtre chip'leri animasyonu için widget oluştur
- [ ] Slide-in ve selection animasyonları ekle
- [ ] Başlık: "Tam İstediğiniz Gibi Filtreleyin"
- [ ] Örnek filtreler göster
- **Validation:** Filtre animasyonları smooth çalışıyor
- **Dependencies:** Task 2.4

### Task 3.5: Ekran 5 - Randevu
- [ ] `lib/presentation/widgets/onboarding/screens/appointment_screen.dart` oluştur
- [ ] Takvim ve saat seçimi mockup'ı oluştur
- [ ] Expand/collapse animasyonları ekle
- [ ] Başlık: "Randevunuzu Hemen Oluşturun"
- [ ] Uzman seçimi göster
- **Validation:** Randevu akışı animasyonlu gösteriliyor
- **Dependencies:** Task 2.4

### Task 3.6: Ekran 6 - Favoriler
- [ ] `lib/presentation/widgets/onboarding/screens/favorites_screen.dart` oluştur
- [ ] Kalp animasyonu için Lottie/widget oluştur
- [ ] Favori listesi scroll animasyonu ekle
- [ ] Başlık: "Favorilerinizi Kaydedin, Takipte Kalın"
- [ ] "Hadi Başlayalım!" CTA ekle
- **Validation:** Favori animasyonları ve CTA çalışıyor
- **Dependencies:** Task 2.4

## Phase 4: Animasyonlar ve Polish

### Task 4.1: Lottie Animasyonları Entegrasyonu
- [ ] Gerekli Lottie dosyalarını `assets/animations/` klasörüne ekle
- [ ] `pubspec.yaml`'da asset'leri tanımla
- [ ] Her ekrana uygun Lottie animasyonunu entegre et
- [ ] Animasyon loop ve autoplay ayarlarını yap
- **Validation:** Tüm Lottie animasyonları çalışıyor
- **Dependencies:** Task 3.1-3.6

### Task 4.2: Sayfa Geçiş Animasyonları
- [ ] PageView için custom page transition ekle
- [ ] Fade + slide kombinasyonu kullan
- [ ] Timing ve easing ayarla (400ms, easeInOutCubic)
- [ ] Smooth geçişler sağla
- **Validation:** Sayfa geçişleri smooth ve premium görünüyor
- **Dependencies:** Task 2.1

### Task 4.3: Micro-interactions
- [ ] Buton hover/press animasyonları ekle
- [ ] Dot indicator'lara pulse efekti ekle
- [ ] Telefon frame'e subtle shadow animasyonu ekle
- [ ] Haptic feedback ekle (vibration)
- **Validation:** Tüm etkileşimler responsive ve engaging
- **Dependencies:** Task 2.2, Task 2.3

### Task 4.4: Responsive Layout Optimizasyonu
- [ ] Farklı ekran boyutları için layout testleri yap
- [ ] Tablet layout'u optimize et
- [ ] Küçük ekranlar için font size'ları ayarla
- [ ] Padding ve spacing'leri responsive yap
- **Validation:** Tüm cihazlarda iyi görünüyor
- **Dependencies:** Task 3.1-3.6

### Task 4.5: Performance Optimizasyonu
- [ ] Lottie dosyalarını optimize et
- [ ] Gereksiz rebuild'leri önle
- [ ] Image caching ekle
- [ ] Memory leak kontrolü yap
- **Validation:** 60 FPS smooth animasyon, düşük memory kullanımı
- **Dependencies:** Task 4.1, Task 4.2

## Phase 5: Entegrasyon ve Test

### Task 5.1: Provider Entegrasyonu main.dart'a
- [ ] `main.dart`'a `AppOnboardingProvider` ekle
- [ ] Provider dependency'lerini kur
- [ ] Initialization sırasını kontrol et
- **Validation:** Provider uygulama genelinde erişilebilir
- **Dependencies:** Task 1.3

### Task 5.2: Konum Onboarding Entegrasyonu
- [ ] Onboarding tamamlandıktan sonra konum kontrolü ekle
- [ ] Eğer konum seçilmemişse `LocationOnboardingProvider` tetikle
- [ ] Smooth geçiş sağla
- [ ] Kullanıcıya bilgilendirme mesajı göster
- **Validation:** Onboarding → Konum onboarding akışı çalışıyor
- **Dependencies:** Task 1.5, Task 5.1

### Task 5.3: Edge Case Testleri
- [ ] Uygulama silme/yeniden yükleme testi
- [ ] SharedPreferences temizleme testi
- [ ] Hızlı swipe testi
- [ ] Geri tuşu davranışı testi
- [ ] Arka plana alma/geri getirme testi
- **Validation:** Tüm edge case'ler handle ediliyor
- **Dependencies:** Tüm önceki task'lar

### Task 5.4: Farklı Cihazlarda Test
- [ ] Android (farklı versiyonlar) testi
- [ ] iOS testi
- [ ] Tablet testi
- [ ] Düşük seviye cihaz testi
- **Validation:** Tüm cihazlarda sorunsuz çalışıyor
- **Dependencies:** Tüm önceki task'lar

### Task 5.5: Turkish Localization Kontrolü
- [ ] Tüm metinleri Türkçe kontrol et
- [ ] Yazım hatalarını düzelt
- [ ] Ton ve dil tutarlılığını sağla
- [ ] Uzun metinlerin layout'u bozup bozmadığını kontrol et
- **Validation:** Tüm metinler doğru ve tutarlı
- **Dependencies:** Task 3.1-3.6

## Phase 6: Final Polish ve Dokümantasyon

### Task 6.1: Code Review ve Refactoring
- [ ] Kod kalitesini kontrol et
- [ ] Gereksiz kod ve comment'leri temizle
- [ ] Widget'ları daha modüler hale getir
- [ ] Naming convention'ları kontrol et
- **Validation:** Kod temiz ve maintainable
- **Dependencies:** Tüm önceki task'lar

### Task 6.2: Dokümantasyon
- [ ] Widget'lara dartdoc comment'leri ekle
- [ ] README güncelle (onboarding özelliği ekle)
- [ ] Spec dosyasını güncelle
- [ ] Kullanım örnekleri ekle
- **Validation:** Dokümantasyon eksiksiz
- **Dependencies:** Task 6.1

### Task 6.3: Analytics Hazırlığı (Opsiyonel)
- [ ] Onboarding event tracking noktalarını belirle
- [ ] Analytics service'e event'leri ekle
- [ ] Completion rate tracking hazırla
- [ ] Screen view tracking ekle
- **Validation:** Analytics event'leri doğru tetikleniyor
- **Dependencies:** Task 5.1

### Task 6.4: Final Testing ve QA
- [ ] Tüm success criteria'ları kontrol et
- [ ] User acceptance testing yap
- [ ] Bug fix'leri uygula
- [ ] Final polish
- **Validation:** Tüm success criteria karşılanıyor
- **Dependencies:** Tüm önceki task'lar

## Summary

**Total Tasks:** 34
**Estimated Time:** 11-14 gün
**Priority:** High (UX improvement)
**Complexity:** Medium-High

### Task Dependencies Grafiği
```
Phase 1 (Altyapı)
  └─> Phase 2 (Temel Widget'lar)
      └─> Phase 3 (İçerik)
          └─> Phase 4 (Animasyon)
              └─> Phase 5 (Entegrasyon)
                  └─> Phase 6 (Polish)
```

### Quick Start Checklist
- [ ] Dependencies yükle (Task 1.1)
- [ ] Preferences service oluştur (Task 1.2)
- [ ] Provider oluştur (Task 1.3)
- [ ] Onboarding screen'i oluştur (Task 2.1)
- [ ] İlk ekranı implement et (Task 3.1)
- [ ] Test et ve iterate et
