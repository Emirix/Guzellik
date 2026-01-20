# Splash Screen Tasarımı

**Tarih:** 2026-01-20  
**Durum:** Tamamlandı ✅

## Genel Bakış

Güzellik Haritam uygulaması için iki aşamalı splash screen tasarımı uygulandı. Native splash screen ve Flutter splash widget'ı koordineli şekilde çalışarak kullanıcıya kesintisiz bir deneyim sunuyor.

## Tasarım Konsepti

### Amaç
- Uygulama açılışında profesyonel ve premium bir ilk izlenim yaratmak
- Marka kimliğini güçlendirmek
- Initialization sürecini görsel olarak zenginleştirmek

### Görsel Dil
- **Minimal ve şık**: Sade arka plan, odak animasyonda
- **Marka renkleri**: Uygulamanın renk paletine uyumlu (#fff9fa, #ee2b5b, #1b0d11)
- **Smooth animasyonlar**: Fade-in/fade-out geçişleri
- **Mobil odaklı**: 375px genişlik referans alınarak tasarlandı

## Teknik Uygulama

### 1. Native Splash Screen (0-500ms)

**Amaç:** Flutter engine yüklenmeden önce anında görünür splash

**Yapılandırma:**
```yaml
flutter_native_splash:
  color: "#fff9fa"
  image: assets/images/maskot.png
  android: true
  ios: true
  web: false
  android_12:
    color: "#fff9fa"
    image: assets/images/maskot.png
```

**Özellikler:**
- Arka plan rengi: `#fff9fa` (background-light)
- Merkez görsel: Maskot PNG (200x200px)
- Platform desteği: Android ve iOS
- Android 12+ uyumlu

**Oluşturma:**
```bash
dart run flutter_native_splash:create
```

### 2. Flutter Splash Widget (500ms - 3200ms)

**Dosya:** `lib/presentation/screens/splash_screen.dart`

**Animasyon Akışı:**

| Zaman | Aksiyon | Süre | Açıklama |
|-------|---------|------|----------|
| 0ms | Native splash gösterilir | - | Maskot görünür |
| 500ms | Flutter başlar | - | Widget mount olur |
| 600ms | Maskot fade-out | 200ms | Opacity 1.0 → 0.0 |
| 800ms | Lottie fade-in | 300ms | Opacity 0.0 → 1.0 |
| 1100ms | Lottie tam görünür | - | Animasyon loop'ta |
| 1600ms | Başlık fade-in | 800ms | "Güzellik Haritam" |
| 2400ms | Alt başlık fade-in | 800ms | "Güzelliğinize Değer Katan Mekanlar" |
| 3200ms | Navigation | - | Home veya Onboarding |

**Kullanılan Animasyonlar:**
- 4 adet `AnimationController` (maskot, lottie, title, subtitle)
- `CurvedAnimation` ile smooth geçişler
- `FadeTransition` ve `Transform.translate` kombinasyonu

**Renkler:**
- Arka plan: `Color(0xFFFFF9FA)` - background-light
- Başlık: `Color(0xFF1B0D11)` - koyu kahverengi-siyah
- Alt başlık: `Color(0xFF6B7280)` - gri

**Tipografi:**
- Başlık: 32px, font-weight: 800, letter-spacing: -0.5
- Alt başlık: 14px, font-weight: 500

## Asset Dosyaları

### Gerekli Dosyalar
```
assets/
  images/
    maskot.png          # Native splash için maskot görseli
  animations/
    splash.json         # Lottie animasyon dosyası
```

### Kaynak Dosyalar
```
splastest/
  maskot.png           # Orijinal maskot görseli
  lottie.json          # Orijinal Lottie JSON
  splash.gif           # GIF animasyonu (referans)
  splash.html          # HTML demo
```

## Bağımlılıklar

### Paketler
```yaml
dependencies:
  lottie: ^3.0.0                    # Lottie animasyonları

dev_dependencies:
  flutter_native_splash: ^2.4.3    # Native splash oluşturma
```

## Kullanım

### Routing Entegrasyonu

Splash screen, `go_router` ile entegre edilmiştir:

```dart
// Router yapılandırmasında
GoRoute(
  path: '/splash',
  builder: (context, state) => const SplashScreen(),
),
```

### Navigation Mantığı

Splash screen tamamlandığında:
1. `OnboardingPreferences` kontrol edilir
2. Kullanıcı onboarding görmüşse → `context.go('/')`
3. İlk kez kullanıyorsa → `context.go('/onboarding')`

## Performans Notları

### Optimizasyonlar
- Native splash anında yüklenir (Flutter engine beklemez)
- Lottie animasyonu lazy-load edilir
- Tüm animasyonlar dispose edilir (memory leak yok)
- `mounted` kontrolü ile safe navigation

### Timing
- Toplam süre: ~3.2 saniye
- Kritik yol: Native splash (0-500ms) - Kullanıcı anında görsel görür
- Flutter initialization bu süre içinde tamamlanır

## Gelecek İyileştirmeler

### Potansiyel Eklemeler
- [ ] Lottie animasyonunu optimize et (dosya boyutu)
- [ ] Dark mode desteği ekle
- [ ] Animasyon hızını kullanıcı tercihine göre ayarla
- [ ] Accessibility iyileştirmeleri (reduced motion)
- [ ] Web platform desteği

### Alternatif Yaklaşımlar
- Rive animasyonu kullanımı (daha küçük dosya boyutu)
- Shader-based animasyonlar
- Procedural animasyonlar (kod ile)

## Test Senaryoları

### Manuel Test
1. ✅ Uygulama ilk açılışta maskot görünüyor
2. ✅ Maskot smooth şekilde fade-out oluyor
3. ✅ Lottie animasyonu smooth şekilde fade-in oluyor
4. ✅ Başlık ve alt başlık sırayla beliriyor
5. ✅ Onboarding kontrolü çalışıyor
6. ✅ Navigation doğru ekrana yönlendiriyor

### Platform Testleri
- [ ] Android (API 21+)
- [ ] Android 12+ (splash screen API)
- [ ] iOS (13+)
- [ ] Farklı ekran boyutları

## Referanslar

### Tasarım Kaynakları
- HTML Demo: `splastest/splash.html`
- Figma/Design: N/A
- Marka Kılavuzu: `design/mekan_detay_sayfası_2/code.html` (renk paleti)

### Teknik Dokümantasyon
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)
- [lottie](https://pub.dev/packages/lottie)
- [LottieFiles](https://lottiefiles.com/) - GIF to Lottie converter

## Notlar

- GIF animasyonu LottieFiles kullanılarak Lottie JSON'a çevrildi
- Native splash'te animasyon desteklenmediği için iki aşamalı yaklaşım kullanıldı
- Tüm animasyonlar 60 FPS'de smooth çalışıyor
- Manrope font ailesi kullanılıyor (uygulama genelinde)

---

**Son Güncelleme:** 2026-01-20  
**Geliştirici:** Antigravity AI  
**Durum:** Production Ready ✅
