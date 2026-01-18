# Uygulama Onboarding Deneyimi

## Problem

Güzellik Haritam uygulaması yeni kullanıcılar için tanıtım ekranlarına ve özellik walkthrough'una sahip değil. Kullanıcılar:
- Uygulamanın ne sunduğunu anlamadan direkt ana ekrana yönlendiriliyor
- Harita, filtreleme, kampanyalar gibi temel özelliklerin nasıl kullanılacağını bilmiyor
- İlk kullanım deneyimi kafa karıştırıcı ve yönlendirici değil
- Uygulamanın değer önerisini hemen göremiyorlar

Bu durum:
- Kullanıcı engagement'ını düşürüyor
- Özellik keşfini zorlaştırıyor
- İlk izlenimi zayıflatıyor
- Churn rate'i artırıyor

## Solution

6 ekranlı, animasyonlu, premium bir onboarding deneyimi oluşturulacak:

### Onboarding Ekranları (Sırasıyla)

1. **Hoş Geldiniz + Ana Değer Önerisi**
   - Uygulama tanıtımı ve misyon
   - Premium logo animasyonu
   - "Güzelliğinize Değer Katan Adresler, Bir Tıkta!"

2. **Kampanyalar ve Özel Fırsatlar**
   - Kampanya kartları animasyonu
   - Değer önerisini öne çıkarma
   - Kullanıcıyı hemen çekme stratejisi

3. **Harita ve Yakındaki Yerler**
   - Harita kullanımı gösterimi
   - Konum tabanlı keşif
   - Pin ve detay kartı etkileşimi

4. **Filtreleme ve Kişiselleştirme**
   - Filtre sisteminin tanıtımı
   - Kategori, fiyat, puan filtreleri
   - Kişiselleştirilmiş arama

5. **Randevu ve Rezervasyon**
   - Randevu oluşturma akışı
   - Takvim ve saat seçimi
   - Uzman seçimi

6. **Favoriler ve Takip**
   - Favori sistemi
   - Kampanya bildirimleri
   - "Hadi Başlayalım!" CTA

### Teknik Özellikler

- **Görsel Stil:** Telefon frame içinde animasyonlu UI mockup'ları
- **Animasyon:** Lottie + Flutter implicit animations
- **Navigasyon:** Swipe gesture + ileri butonu + sayfa göstergeleri
- **Atlama:** Zorunlu onboarding (atlama yok)
- **Takip:** SharedPreferences ile lokal kayıt (`hasSeenOnboarding`)
- **Tamamlama:** Direkt ana ekrana yönlendirme, konum onboarding otomatik tetiklenir

### Tasarım Prensipleri

- **Renkler:** Marka renkleri (Altın #DCAD2E, Pembe #D88C8C)
- **Tipografi:** Epilogue font ailesi
- **Animasyon Timing:** 200-400ms arası smooth transitions
- **Premium Görünüm:** Lüks, modern, minimal estetik

## Scope

### Dahil Olanlar
- ✅ 6 ekranlı onboarding flow
- ✅ Animasyonlu UI mockup'ları
- ✅ Swipe ve buton navigasyonu
- ✅ Sayfa göstergeleri (dots)
- ✅ SharedPreferences ile durum takibi
- ✅ Splash screen'den sonra otomatik gösterim
- ✅ Onboarding tamamlandıktan sonra ana ekrana yönlendirme
- ✅ Turkish localization
- ✅ Responsive tasarım

### Dahil Olmayanlar
- ❌ İnteraktif tutorial (contextual tooltips)
- ❌ Video içerik
- ❌ Kullanıcı profili oluşturma onboarding'de
- ❌ A/B testing altyapısı
- ❌ Analytics tracking (gelecek iterasyonda)
- ❌ Onboarding'i tekrar gösterme özelliği

### Bağımlılıklar
- Mevcut `splash_screen.dart` - Onboarding'e yönlendirme için
- Mevcut `app_router.dart` - Route tanımlaması için
- `shared_preferences` paketi - Durum takibi için
- `lottie` paketi - Animasyonlar için
- Mevcut `AppColors` ve `AppTheme` - Tasarım tutarlılığı için

## Success Criteria

- [x] 6 onboarding ekranı oluşturuldu ve tasarım dokümanına uygun
- [ ] Her ekran için animasyonlar implement edildi
- [ ] Swipe gesture ile ekranlar arası geçiş çalışıyor
- [ ] "İleri" butonu ve sayfa göstergeleri çalışıyor
- [ ] Son ekranda "Hadi Başlayalım!" butonu ana ekrana yönlendiriyor
- [ ] SharedPreferences ile onboarding durumu kaydediliyor
- [ ] İlk açılışta splash → onboarding → home akışı çalışıyor
- [ ] İkinci açılışta direkt home'a gidiyor (onboarding atlanıyor)
- [ ] Onboarding tamamlandıktan sonra konum onboarding otomatik tetikleniyor
- [ ] Tüm metinler Türkçe ve doğru
- [ ] Responsive tasarım farklı ekran boyutlarında çalışıyor
- [ ] Animasyonlar smooth ve performanslı
- [ ] Premium görünüm ve marka kimliğine uygunluk sağlanıyor

## Risks

### Risk 1: Animasyon Performansı
**Risk:** Lottie animasyonları bazı düşük seviye cihazlarda yavaş çalışabilir.

**Mitigation:**
- Lottie dosyalarını optimize et (gereksiz layer'ları kaldır)
- Fallback olarak basit Flutter animasyonları hazırla
- Performance profiling ile test et
- Gerekirse animasyon karmaşıklığını azalt

### Risk 2: Dosya Boyutu
**Risk:** Lottie dosyaları ve görseller app size'ı artırabilir.

**Mitigation:**
- Lottie dosyalarını compress et
- Gereksiz frame'leri kaldır
- Asset optimization uygula
- Lazy loading kullan

### Risk 3: Kullanıcı Rahatsızlığı
**Risk:** Zorunlu onboarding bazı kullanıcıları rahatsız edebilir.

**Mitigation:**
- Onboarding'i kısa tut (maksimum 60 saniye)
- Animasyonları hızlı ve engaging yap
- Her ekranı değerli ve bilgilendirici kıl
- Gelecek iterasyonda kullanıcı feedback'i topla

### Risk 4: Konum Onboarding Çakışması
**Risk:** Onboarding sonrası konum onboarding'i çift onboarding hissi verebilir.

**Mitigation:**
- İki onboarding arasında smooth geçiş sağla
- Konum onboarding'i beklenen bir adım olarak sun
- Onboarding'de konum özelliğinden bahset (3. ekran)
- Kullanıcıya "Şimdi konumunuzu seçelim" gibi bağlayıcı mesaj göster

## Implementation Phases

### Phase 1: Temel Yapı (2-3 gün)
- Onboarding screen ve widget'ları oluştur
- PageView ve navigasyon implementasyonu
- SharedPreferences entegrasyonu
- Router güncelleme

### Phase 2: İçerik ve Tasarım (3-4 gün)
- 6 ekran için içerik oluşturma
- Telefon mockup widget'ı
- Sayfa göstergeleri ve butonlar
- Responsive layout

### Phase 3: Animasyonlar (4-5 gün)
- Lottie dosyaları hazırlama/bulma
- Animasyon entegrasyonu
- Geçiş animasyonları
- Micro-interactions

### Phase 4: Polish ve Test (2 gün)
- Performance optimization
- Farklı cihazlarda test
- Edge case'ler
- Final touches

**Toplam Tahmini Süre:** 11-14 gün
