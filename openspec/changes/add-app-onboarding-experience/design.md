# Architecture Design: Uygulama Onboarding Deneyimi

## Overview

Güzellik Haritam uygulaması için 6 ekranlı, animasyonlu bir onboarding sistemi tasarlanmıştır. Bu sistem, yeni kullanıcıların uygulamanın temel özelliklerini öğrenmesini ve değer önerisini anlamasını sağlar.

**Temel Prensipler:**
- **Modüler Yapı:** Her onboarding ekranı bağımsız bir widget
- **State Management:** Provider pattern ile merkezi state yönetimi
- **Persistence:** SharedPreferences ile durum takibi
- **Performance:** Lazy loading ve optimize edilmiş animasyonlar
- **Extensibility:** Yeni ekranlar kolayca eklenebilir

## Components

### 1. OnboardingPreferences (Data Layer)
**Sorumluluk:**
- Onboarding durumunu kalıcı olarak saklamak
- `hasSeenOnboarding` flag'ini yönetmek
- Debug için reset fonksiyonu sağlamak

**Dependencies:**
- `shared_preferences` paketi

**Interfaces:**
```dart
class OnboardingPreferences {
  Future<bool> hasSeenOnboarding();
  Future<void> markOnboardingComplete();
  Future<void> resetOnboarding(); // Debug only
}
```

**Implementation Details:**
- Singleton pattern kullanılır
- SharedPreferences instance lazy initialize edilir
- Key: `'has_seen_onboarding'`

---

### 2. AppOnboardingProvider (State Management)
**Sorumluluk:**
- Onboarding akışının state'ini yönetmek
- Sayfa navigasyonunu kontrol etmek
- Onboarding tamamlama işlemini koordine etmek

**Dependencies:**
- `OnboardingPreferences`
- `ChangeNotifier` (Provider pattern)

**Interfaces:**
```dart
class AppOnboardingProvider extends ChangeNotifier {
  int currentPage;
  int totalPages = 6;
  
  void nextPage();
  void previousPage();
  void goToPage(int page);
  Future<void> completeOnboarding();
  bool get isLastPage;
}
```

**State:**
- `currentPage`: Aktif sayfa index'i (0-5)
- `totalPages`: Toplam sayfa sayısı (6)

**Events:**
- `nextPage()`: Sonraki sayfaya geç
- `previousPage()`: Önceki sayfaya geç
- `goToPage(int)`: Belirli bir sayfaya geç
- `completeOnboarding()`: Onboarding'i tamamla ve kaydet

---

### 3. OnboardingScreen (Presentation Layer)
**Sorumluluk:**
- Ana onboarding container
- PageView yönetimi
- Navigasyon UI'ı (butonlar, indicator'lar)
- Sayfa geçiş animasyonları

**Dependencies:**
- `AppOnboardingProvider`
- `PageView` widget
- `OnboardingNavigationButtons`
- `PageIndicators`
- Individual onboarding page widgets

**Structure:**
```dart
class OnboardingScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _buildPages(),
          ),
          Positioned(
            bottom: 100,
            child: PageIndicators(),
          ),
          Positioned(
            bottom: 40,
            child: OnboardingNavigationButtons(),
          ),
        ],
      ),
    );
  }
}
```

---

### 4. Individual Onboarding Pages
**Sorumluluk:**
- Belirli bir özelliği tanıtmak
- Animasyonları oynatmak
- İçeriği göstermek

**Pages:**
1. `WelcomeOnboardingPage` - Hoş geldiniz + değer önerisi
2. `CampaignsOnboardingPage` - Kampanyalar ve fırsatlar
3. `MapOnboardingPage` - Harita ve konum
4. `FilteringOnboardingPage` - Filtreleme sistemi
5. `AppointmentOnboardingPage` - Randevu oluşturma
6. `FavoritesOnboardingPage` - Favoriler ve takip

**Common Structure:**
```dart
class XOnboardingPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PhoneMockupFrame(
          child: AnimatedContent(),
        ),
        SizedBox(height: 40),
        Text(title),
        SizedBox(height: 16),
        Text(description),
      ],
    );
  }
}
```

**Dependencies:**
- `PhoneMockupFrame` widget
- Lottie animasyon dosyaları
- `AppColors`, `AppTheme`

---

### 5. PhoneMockupFrame (Reusable Widget)
**Sorumluluk:**
- Telefon frame görünümü sağlamak
- İçeriği frame içinde göstermek
- Responsive boyutlandırma

**Interfaces:**
```dart
class PhoneMockupFrame extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  
  const PhoneMockupFrame({
    required this.child,
    this.width,
    this.height,
  });
}
```

**Visual Details:**
- Modern telefon tasarımı (rounded corners, notch)
- Shadow ve depth efektleri
- Responsive sizing (ekran boyutuna göre)
- Default boyut: 300x600 (aspect ratio: 9:19.5)

---

### 6. PageIndicators (UI Component)
**Sorumluluk:**
- Sayfa göstergelerini (dots) render etmek
- Aktif/pasif durumları göstermek
- Geçiş animasyonları

**Interfaces:**
```dart
class PageIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  
  const PageIndicators({
    required this.currentPage,
    required this.totalPages,
  });
}
```

**Visual:**
- Aktif dot: 12px, primary color
- Pasif dot: 8px, gray color
- Spacing: 8px
- Animasyon: 200ms scale + color transition

---

### 7. OnboardingNavigationButtons (UI Component)
**Sorumluluk:**
- "İleri" ve "Hadi Başlayalım!" butonlarını göstermek
- Buton press animasyonları
- Provider ile etkileşim

**Interfaces:**
```dart
class OnboardingNavigationButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onComplete;
  final bool isLastPage;
  
  const OnboardingNavigationButtons({
    required this.onNext,
    required this.onComplete,
    required this.isLastPage,
  });
}
```

**Behavior:**
- Sayfa 1-5: "İleri" butonu göster
- Sayfa 6: "Hadi Başlayalım!" butonu göster
- Buton press: Scale down/up animasyonu (150ms)

---

## Data Flow

### 1. İlk Açılış Akışı
```
App Start
  ↓
SplashScreen
  ↓
OnboardingPreferences.hasSeenOnboarding() → false
  ↓
Navigate to /onboarding
  ↓
OnboardingScreen renders
  ↓
AppOnboardingProvider initialized (currentPage = 0)
  ↓
WelcomeOnboardingPage displayed
```

### 2. Sayfa Geçiş Akışı
```
User swipes right / taps "İleri"
  ↓
PageView.onPageChanged triggered
  ↓
AppOnboardingProvider.nextPage() called
  ↓
currentPage incremented
  ↓
notifyListeners() called
  ↓
PageIndicators updated
  ↓
New page animations start
```

### 3. Onboarding Tamamlama Akışı
```
User on page 6
  ↓
User taps "Hadi Başlayalım!"
  ↓
AppOnboardingProvider.completeOnboarding() called
  ↓
OnboardingPreferences.markOnboardingComplete() called
  ↓
SharedPreferences updated (hasSeenOnboarding = true)
  ↓
Navigate to / (home)
  ↓
LocationOnboardingProvider.checkLocationOnboarding() triggered
```

### 4. İkinci Açılış Akışı
```
App Start
  ↓
SplashScreen
  ↓
OnboardingPreferences.hasSeenOnboarding() → true
  ↓
Skip onboarding
  ↓
Navigate to / (home)
```

---

## Trade-offs

### Option 1: Video-Based Onboarding
**Pros:**
- Çok engaging ve görsel
- Gerçek uygulama kullanımı gösterilebilir
- Profesyonel görünüm

**Cons:**
- Büyük dosya boyutu (app size artışı)
- Yükleme süresi uzun
- Düşük seviye cihazlarda performans sorunu
- Video üretimi zaman alıcı

### Option 2: Static Images + Text (Chosen Initially, Then Rejected)
**Pros:**
- Çok basit implementasyon
- Küçük dosya boyutu
- Hızlı yükleme

**Cons:**
- Sıkıcı ve engaging değil
- Premium hissi vermiyor
- Kullanıcı dikkatini çekmiyor
- Modern uygulamalar için yetersiz

### Option 3: Lottie Animations + Flutter Widgets (CHOSEN)
**Pros:**
- ✅ Smooth ve performanslı animasyonlar
- ✅ Küçük dosya boyutu (JSON format)
- ✅ Premium ve modern görünüm
- ✅ Kolay customize edilebilir
- ✅ Düşük seviye cihazlarda da çalışır
- ✅ Lottie dosyaları hazır bulunabilir (LottieFiles.com)

**Cons:**
- Lottie dosyası bulma/oluşturma gerekir
- Bazı karmaşık animasyonlar için Flutter widget'ları gerekir
- İlk implementasyon biraz daha uzun sürer

**Why Chosen:**
- Performans ve görsel kalite dengesi en iyi
- Dosya boyutu optimize
- Premium görünüm sağlar
- Maintainable ve extensible
- Güzellik Haritam'ın lüks brand identity'sine uygun

### Option 4: Interactive Tutorial (Overlay-based)
**Pros:**
- Kullanıcı gerçek UI'da öğrenir
- Contextual ve pratik
- Daha az intrusive

**Cons:**
- Karmaşık implementasyon
- İlk açılışta kafa karıştırıcı olabilir
- Tüm özellikleri göstermek zor
- State management karmaşık

**Why Not Chosen:**
- İlk kullanıcılar için çok karmaşık
- Değer önerisini hemen göstermek zor
- Gelecek iterasyonda eklenebilir (hibrit yaklaşım)

---

## Animation Strategy

### Lottie Animations
**Kullanım Alanları:**
- Logo animasyonu (Sayfa 1)
- Kampanya kartları (Sayfa 2)
- Harita ve pin'ler (Sayfa 3)
- Kalp animasyonu (Sayfa 6)

**Optimizasyon:**
- Dosya boyutu < 100KB per animation
- Frame rate: 30-60 FPS
- Duration: 2-3 saniye loop
- Autoplay: true
- Repeat: true

### Flutter Implicit Animations
**Kullanım Alanları:**
- Sayfa geçişleri (PageView)
- Buton press animasyonları
- Dot indicator geçişleri
- Filtre chip animasyonları

**Timing:**
- Page transitions: 400ms
- Button press: 150ms
- Dot transitions: 200ms
- Element fade-in: 300ms

**Easing:**
- Curves.easeInOutCubic (default)
- Curves.bounceOut (logo, CTA button)
- Curves.elasticOut (heart animation)

---

## Migration Strategy

### Phase 1: Altyapı (Gün 1-3)
1. Dependencies ekle (`lottie`, `shared_preferences`)
2. `OnboardingPreferences` service oluştur
3. `AppOnboardingProvider` oluştur
4. Router'a `/onboarding` route'u ekle
5. `SplashScreen` güncelle (onboarding kontrolü)

### Phase 2: Temel UI (Gün 4-6)
1. `OnboardingScreen` oluştur (PageView container)
2. `PhoneMockupFrame` widget'ı oluştur
3. `PageIndicators` widget'ı oluştur
4. `OnboardingNavigationButtons` widget'ı oluştur
5. Swipe gesture ve navigasyon test et

### Phase 3: İçerik (Gün 7-10)
1. 6 onboarding page widget'ı oluştur
2. Her sayfa için içerik ekle (başlık, metin)
3. Telefon mockup içine UI görselleri ekle
4. Responsive layout ayarla

### Phase 4: Animasyonlar (Gün 11-13)
1. Lottie dosyalarını bul/oluştur
2. Lottie animasyonlarını entegre et
3. Flutter animasyonlarını ekle
4. Timing ve easing ayarla
5. Performance optimize et

### Phase 5: Test ve Polish (Gün 14)
1. Farklı cihazlarda test et
2. Edge case'leri handle et
3. Konum onboarding entegrasyonu
4. Final polish ve QA

---

## Performance Considerations

### Memory Management
- Lottie animasyonları dispose edilmeli
- PageView'da sadece aktif ±1 sayfa render edilmeli
- Kullanılmayan asset'ler memory'den temizlenmeli

### Asset Optimization
- Lottie dosyaları compress edilmeli (< 100KB)
- Gereksiz frame'ler kaldırılmalı
- Image asset'ler WebP format kullanmalı

### Rendering Performance
- 60 FPS hedeflenmeli
- Gereksiz rebuild'ler önlenmeli (const constructor'lar)
- AnimationController'lar dispose edilmeli
- RepaintBoundary kullanılmalı (complex widgets için)

### Loading Performance
- İlk sayfa hızlı yüklenmeli (< 500ms)
- Lottie dosyaları lazy load edilmeli
- Asset precaching yapılmalı

---

## Testing Strategy

### Unit Tests
- `OnboardingPreferences` CRUD operations
- `AppOnboardingProvider` state management
- Navigation logic

### Widget Tests
- Individual onboarding pages
- `PhoneMockupFrame` rendering
- `PageIndicators` state changes
- `OnboardingNavigationButtons` behavior

### Integration Tests
- Full onboarding flow (start to finish)
- Swipe gestures
- Button navigation
- Completion and persistence
- Router integration

### Manual Tests
- Different screen sizes
- Different devices (Android, iOS)
- Low-end devices
- Edge cases (back button, app backgrounding)

---

## Future Enhancements

### Phase 2 (Gelecek İterasyonlar)
- Analytics tracking (completion rate, drop-off points)
- A/B testing altyapısı (farklı onboarding varyasyonları)
- Contextual tooltips (ilk kullanımda overlay'ler)
- Onboarding'i tekrar gösterme özelliği (settings'ten)
- Video content (opsiyonel)
- Personalization (kullanıcı tipine göre farklı onboarding)

### Metrics to Track
- Completion rate
- Average time spent
- Drop-off points
- Skip rate (eğer eklersek)
- User engagement after onboarding

---

## Dependencies Graph

```
main.dart
  ├─> AppOnboardingProvider
  │     └─> OnboardingPreferences
  │           └─> shared_preferences
  │
  └─> AppRouter
        └─> OnboardingScreen
              ├─> AppOnboardingProvider
              ├─> PageView
              ├─> PageIndicators
              ├─> OnboardingNavigationButtons
              └─> Onboarding Pages (6)
                    ├─> PhoneMockupFrame
                    ├─> Lottie
                    └─> AppTheme/AppColors
```

---

## Conclusion

Bu tasarım, Güzellik Haritam uygulaması için modern, performanslı ve engaging bir onboarding deneyimi sağlar. Lottie animasyonları ve Flutter widget'larının kombinasyonu, hem görsel kalite hem de performans açısından optimal bir çözüm sunar. Modüler yapı sayesinde gelecekte yeni ekranlar eklemek veya mevcut ekranları güncellemek kolay olacaktır.
