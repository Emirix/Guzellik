# Onboarding Deneyimi Tasarım Özeti

**Tarih:** 2026-01-18  
**Konu:** Uygulama Onboarding ve İlk Kullanım Deneyimi  
**OpenSpec Change ID:** `add-app-onboarding-experience`

## Özet

Güzellik Haritam uygulaması için 6 ekranlı, animasyonlu, premium bir onboarding deneyimi tasarlandı. Bu tasarım, yeni kullanıcıların uygulamanın değer önerisini anlamasını ve temel özellikleri keşfetmesini sağlayacak.

## Tasarım Kararları

### 1. Yaklaşım: Özellik Odaklı Walkthrough
**Seçilen:** 5-6 ekranlık detaylı özellik tanıtımı  
**Alternatifler:** Minimalist (3-4 ekran), İnteraktif tutorial, Hibrit  
**Neden:** Kullanıcıların tüm özellikleri öğrenmesi ve değer önerisini tam anlaması için

### 2. Ekran Sıralaması: Değer Önerisi Odaklı
**Seçilen:** Kampanyalar → Harita → Filtreleme → Randevu → Favoriler  
**Alternatifler:** Kullanıcı yolculuğu odaklı, Keşif odaklı  
**Neden:** Kullanıcıyı hemen kampanyalarla çekerek engagement artırma

### 3. Görsel Stil: Animasyonlu Mockup
**Seçilen:** Telefon frame içinde Lottie + Flutter animasyonları  
**Alternatifler:** İllüstrasyon, Screenshot, Minimal icon  
**Neden:** Premium görünüm, performans dengesi, marka kimliğine uygunluk

### 4. Tamamlama: Direkt Ana Ekran
**Seçilen:** Onboarding → Home (konum onboarding otomatik)  
**Alternatifler:** Zorunlu konum, Bonus ekranı, İzin istekleri  
**Neden:** En akıcı kullanıcı deneyimi, minimum sürtünme

### 5. Atlama: Zorunlu Onboarding
**Seçilen:** Atlama yok, tamamlanmalı  
**Alternatifler:** Her ekranda atla, Sadece ilk ekranda, Akıllı atlama  
**Neden:** Kullanıcıların uygulamayı tam anlaması kritik

### 6. Durum Takibi: SharedPreferences
**Seçilen:** Lokal storage ile flag  
**Alternatifler:** Supabase user metadata, Hibrit, Versiyon bazlı  
**Neden:** Basit, hızlı, güvenilir

## Onboarding Ekranları

### Ekran 1: Hoş Geldiniz
- **Başlık:** "Güzelliğinize Değer Katan Adresler, Bir Tıkta!"
- **Animasyon:** Logo fade-in + bounce, altın parıltı efekti
- **Amaç:** Değer önerisini ve marka kimliğini tanıtmak

### Ekran 2: Kampanyalar
- **Başlık:** "Özel Fırsatları Kaçırmayın!"
- **Animasyon:** Kampanya kartları slide-in, badge pulse
- **Amaç:** Kullanıcıyı hemen çekmek, değer göstermek

### Ekran 3: Harita
- **Başlık:** "Yakınınızdaki Salonları Keşfedin"
- **Animasyon:** Harita zoom-in, pin drop, detay kartı açılma
- **Amaç:** Konum tabanlı keşif özelliğini tanıtmak

### Ekran 4: Filtreleme
- **Başlık:** "Tam İstediğiniz Gibi Filtreleyin"
- **Animasyon:** Filtre chip'leri slide-in, selection highlight
- **Amaç:** Kişiselleştirme ve arama özelliklerini göstermek

### Ekran 5: Randevu
- **Başlık:** "Randevunuzu Hemen Oluşturun"
- **Animasyon:** Takvim expand, saat slotları fade-in
- **Amaç:** Randevu sistemini tanıtmak, conversion'a yönlendirmek

### Ekran 6: Favoriler
- **Başlık:** "Favorilerinizi Kaydedin, Takipte Kalın"
- **Animasyon:** Kalp büyüme, liste scroll, CTA bounce
- **Amaç:** Retention özelliklerini tanıtmak, başlama CTA'sı

## Teknik Mimari

### Bileşenler
1. **OnboardingPreferences** - SharedPreferences wrapper
2. **AppOnboardingProvider** - State management (ChangeNotifier)
3. **OnboardingScreen** - Ana container (PageView)
4. **PhoneMockupFrame** - Reusable telefon frame widget
5. **PageIndicators** - Sayfa göstergeleri (dots)
6. **OnboardingNavigationButtons** - İleri/Tamamla butonları
7. **6 Individual Page Widgets** - Her ekran için özel widget

### Animasyon Stratejisi
- **Lottie:** Logo, kampanya kartları, harita, kalp (< 100KB per file)
- **Flutter:** Sayfa geçişleri, buton press, dot transitions
- **Timing:** 200-400ms, Curves.easeInOutCubic
- **Performance:** 60 FPS hedef, lazy loading

### Data Flow
```
Splash → OnboardingPreferences.check() 
  → if false: Onboarding → Complete → Home → Location Onboarding
  → if true: Home
```

## Beklenen Sonuçlar

### Metrikler
- **Day 1 Retention:** %40 → %60 (+50%)
- **Özellik Keşfi:** %30 → %70 (+133%)
- **İlk Randevu:** %15 → %35 (+133%)
- **App Store Rating:** 4.2 → 4.6

### İş Değeri
- Daha iyi ilk izlenim
- Artan kullanıcı engagement'ı
- Premium brand perception
- Rekabet avantajı
- Daha yüksek conversion rate

## İmplementasyon

### Tahmini Süre: 11-14 gün

**Phase 1 (2-3 gün):** Altyapı - Dependencies, Provider, Router  
**Phase 2 (3-4 gün):** UI - Screen, widgets, navigation  
**Phase 3 (4-5 gün):** Animasyonlar - Lottie, transitions  
**Phase 4 (2 gün):** Polish - Performance, testing

### Toplam Task Sayısı: 34
- Phase 1: 5 tasks (Altyapı)
- Phase 2: 5 tasks (Temel Widget'lar)
- Phase 3: 6 tasks (İçerik)
- Phase 4: 5 tasks (Animasyon)
- Phase 5: 5 tasks (Entegrasyon)
- Phase 6: 4 tasks (Polish)
- Phase 7: 4 tasks (Final)

## Riskler ve Mitigasyon

1. **Animasyon Performansı** → Optimize Lottie, fallback animasyonlar
2. **Dosya Boyutu** → Compression, lazy loading
3. **Kullanıcı Rahatsızlığı** → Kısa tutma (< 60 saniye)
4. **Konum Onboarding Çakışması** → Smooth geçiş, bağlayıcı mesaj

## Gelecek İyileştirmeler

- Analytics tracking (completion rate, drop-off)
- A/B testing altyapısı
- Contextual tooltips (hibrit yaklaşım)
- Onboarding tekrar gösterme (settings)
- Personalization (kullanıcı tipine göre)

## Dokümanlar

- **Proposal:** `openspec/changes/add-app-onboarding-experience/proposal.md`
- **Tasks:** `openspec/changes/add-app-onboarding-experience/tasks.md`
- **Spec:** `openspec/changes/add-app-onboarding-experience/specs/onboarding-ui/spec.md`
- **Design:** `openspec/changes/add-app-onboarding-experience/design.md`
- **Bu Özet:** `docs/plans/2026-01-18-onboarding-experience-design.md`

---

**Onaylayan:** Emir  
**Durum:** Tasarım tamamlandı, implementasyon bekliyor  
**Sonraki Adım:** `/openspec-apply` workflow ile implementasyona başla
