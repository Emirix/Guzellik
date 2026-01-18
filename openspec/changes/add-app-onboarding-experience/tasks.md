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
- [x] `lib/presentation/screens/onboarding_screen.dart` oluştur
- [x] `PageView.builder` ile sayfa yapısı kur
- [x] Provider entegrasyonu ekle
- [x] Scaffold ve temel layout oluştur
- **Validation:** Boş onboarding screen görüntüleniyor
- **Dependencies:** Task 1.3, Task 1.4

### Task 2.2: Sayfa Göstergeleri (Page Indicators) Widget'ı
- [x] `lib/presentation/widgets/onboarding/page_indicators.dart` oluştur
- [x] Dot indicator'ları oluştur
- [x] Active/inactive state'leri ekle
- [x] Animasyonlu geçişler ekle
- **Validation:** Indicator'lar sayfa değişiminde güncelleniyor
- **Dependencies:** Task 2.1

### Task 2.3: Navigasyon Butonları Widget'ı
- [x] `lib/presentation/widgets/onboarding/onboarding_navigation.dart` oluştur
- [x] "İleri" butonu oluştur
- [x] Son sayfada "Hadi Başlayalım!" butonu göster
- [x] Buton animasyonları ekle (scale, fade)
- **Validation:** Butonlar çalışıyor, son sayfada farklı buton gösteriliyor
- **Dependencies:** Task 2.1

### Task 2.4: Telefon Mockup Frame Widget'ı
- [x] `lib/presentation/widgets/onboarding/phone_mockup_frame.dart` oluştur
- [x] Modern telefon frame tasarımı (rounded corners, notch)
- [x] Shadow ve depth efektleri ekle
- [x] Responsive boyutlandırma
- **Validation:** Telefon frame farklı ekran boyutlarında iyi görünüyor
- **Dependencies:** Yok

### Task 2.5: Swipe Gesture Desteği
- [x] `PageView`'a swipe gesture ekle
- [x] Swipe animasyonlarını smooth yap
- [x] Sayfa değişiminde provider'ı güncelle
- **Validation:** Swipe ile sayfa geçişi çalışıyor
- **Dependencies:** Task 2.1

## Phase 3: Onboarding Ekranları İçeriği

### Task 3.1: Ekran 1 - Hoş Geldiniz
- [x] `lib/presentation/widgets/onboarding/screens/welcome_screen.dart` oluştur (welcome_onboarding_content.dart olarak implement edildi)
- [x] Logo animasyonu için Lottie dosyası bul/oluştur
- [x] Başlık: "Güzelliğinize Değer Katan Adresler, Bir Tıkta!"
- [x] Alt metin ekle
- [x] Gradient background ekle
- **Validation:** Ekran tasarıma uygun görünüyor
- **Dependencies:** Task 2.4

### Task 3.2: Ekran 2 - Kampanyalar
- [x] `lib/presentation/widgets/onboarding/screens/campaigns_screen.dart` oluştur (campaigns_onboarding_content.dart olarak implement edildi)
- [x] Kampanya kartları animasyonu için Lottie/widget oluştur
- [x] Slide-in animasyonları ekle
- [x] Başlık: "Özel Fırsatları Kaçırmayın!"
- [x] Örnek kampanya kartları göster
- **Validation:** Kampanya kartları animasyonlu görünüyor
- **Dependencies:** Task 2.4

### Task 3.3: Ekran 3 - Harita
- [x] `lib/presentation/widgets/onboarding/screens/map_screen.dart` oluştur (map_onboarding_content.dart olarak implement edildi)
- [x] Harita mockup animasyonu için Lottie/widget oluştur
- [x] Pin drop animasyonları ekle
- [x] Başlık: "Yakınınızdaki Salonları Keşfedin"
- [x] Detay kartı animasyonu ekle
- **Validation:** Harita ve pin animasyonları çalışıyor
- **Dependencies:** Task 2.4

### Task 3.4: Ekran 4 - Filtreleme
- [x] `lib/presentation/widgets/onboarding/screens/filtering_screen.dart` oluştur (filtering_onboarding_content.dart olarak implement edildi)
- [x] Filtre chip'leri animasyonu için widget oluştur
- [x] Slide-in ve selection animasyonları ekle
- [x] Başlık: "Tam İstediğiniz Gibi Filtreleyin"
- [x] Örnek filtreler göster
- **Validation:** Filtre animasyonları smooth çalışıyor
- **Dependencies:** Task 2.4

### Task 3.5: Ekran 5 - Randevu
- [x] `lib/presentation/widgets/onboarding/screens/appointment_screen.dart` oluştur (appointment_onboarding_content.dart olarak implement edildi)
- [x] Takvim ve saat seçimi mockup'ı oluştur
- [x] Expand/collapse animasyonları ekle
- [x] Başlık: "Randevunuzu Hemen Oluşturun"
- [x] Uzman seçimi göster
- **Validation:** Randevu akışı animasyonlu gösteriliyor
- **Dependencies:** Task 2.4

### Task 3.6: Ekran 6 - Favoriler
- [x] `lib/presentation/widgets/onboarding/screens/favorites_screen.dart` oluştur (favorites_onboarding_content.dart olarak implement edildi)
- [x] Kalp animasyonu için Lottie/widget oluştur
- [x] Favori listesi scroll animasyonu ekle
- [x] Başlık: "Favorilerinizi Kaydedin, Takipte Kalın"
- [x] "Hadi Başlayalım!" CTA ekle
- **Validation:** Favori animasyonları ve CTA çalışıyor
- **Dependencies:** Task 2.4

## Phase 4: Animasyonlar ve Polish

### Task 4.1: Lottie Animasyonları Entegrasyonu
- [ ] Gerekli Lottie dosyalarını `assets/animations/` klasörüne ekle
- [ ] `pubspec.yaml`'da asset'leri tanımla
- [x] Gerekli Lottie dosyalarını `assets/animations/` klasörüne ekle
- [x] `pubspec.yaml`'da asset'leri tanımla
- [x] Her ekrana uygun Lottie animasyonunu entegre et
- [x] Animasyon loop ve autoplay ayarlarını yap
- **Validation:** Tüm Lottie animasyonları çalışıyor
- **Dependencies:** Task 3.1-3.6

### Task 4.2: Sayfa Geçiş Animasyonları
- [x] `OnboardingScreen` içindeki `PageView` geçişlerini özelleştir
- [x] Sayfa değişiminde metin fade animasyonları ekle (`AnimatedSwitcher`)
- [x] Parallax efektleri (isteğe bağlı, basitleştirilmiş hali eklendi)
- **Validation:** Sayfa geçişleri çok akıcı ve premium hissettiriyor
- **Dependencies:** Task 2.51

### Task 4.3: Micro-interactions ve Feedback
- [x] Buton basışlarında `HapticFeedback` ekle
- [x] Dot indicator aktifleşme animasyonunu geliştir
- [x] Küçük görsel detayları (parlamalar, süzülmeler) ekle
- **Validation:** Kullanıcı etkileşimi tatminkar hissettiriyor
- **Dependencies:** Task 2.31

### Task 4.4: Responsive Layout Optimizasyonu
- [x] Farklı ekran boyutları için (Small vs Large Phone) widget'ları adapte et
- [x] Text size'ları ve spacing'leri kontrol et
- **Validation:** iPhone SE'den Pro Max'e kadar her cihazda iyi görünüyor
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
