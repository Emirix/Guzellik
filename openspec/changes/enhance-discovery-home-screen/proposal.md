# Proposal: Keşfet Ana Ekranını Geliştirme

## Motivasyon

Mevcut keşfet ekranı doğrudan harita veya liste görünümü sunarak kullanıcıyı hemen arama moduna sokuyor. Ancak kullanıcı deneyimini iyileştirmek için, kullanıcıların önce popüler hizmetleri, son aramalarını ve editörün seçtiği mekanları görebileceği bir "ana sayfa" deneyimi sunmak gerekiyor.

Bu değişiklik:
- Kullanıcıların keşif yolculuğuna daha yumuşak bir giriş yapmasını sağlar
- Popüler hizmetler ve editör seçimleri ile kullanıcıya ilham verir
- Son aramaları göstererek hızlı erişim sağlar
- Kategori bazlı filtreleme ile kullanıcının aradığını daha hızlı bulmasına yardımcı olur

## Önerilen Değişiklik

Keşfet ekranına üç görünüm modu eklenecek:
1. **Ana Sayfa (Home)** - Varsayılan görünüm, popüler hizmetler, son aramalar ve editör seçimleri
2. **Harita Görünümü** - Mevcut harita görünümü
3. **Liste Görünümü** - Mevcut liste görünümü

### Ana Sayfa Bileşenleri

1. **Başlık ve Filtre Butonu**
   - Sol üstte "Keşfet" başlığı
   - Sağ üstte "Filtrele" butonu (pembe/kırmızı renk)

2. **Arama Çubuğu**
   - Placeholder: "Mekan, hizmet veya klinik ara..."
   - Arama ikonlu
   - Tıklandığında arama moduna geçiş

3. **Kategori Filtreleri**
   - Yatay scroll edilen kategori butonları
   - Seçili kategori vurgulanır (pembe arka plan)
   - Kategoriler: Tümü, Saç Tasarım, Cilt Bakım, vb.

4. **Son Aramalar**
   - Kullanıcının son aramalarını gösterir
   - "Temizle" butonu ile tüm geçmişi silme
   - Her arama öğesi silinebilir (X butonu)
   - İkon ile görsel zenginlik

5. **Popüler Hizmetler**
   - Yatay scroll edilen hizmet chip'leri
   - Tıklanabilir, ilgili hizmeti filtreler
   - Örnekler: Botoks, Hydrafacial, İpek Kirpik, Altın İğne, Microblading, Kalıcı Oje

6. **Editörün Seçimi**
   - "Tümünü Gör" butonu ile
   - Mekan kartları (rating, konum, hizmet türleri)
   - Yatay scroll veya grid layout

### Teknik Yaklaşım

- `DiscoveryViewMode` enum'ına `home` modu eklenecek
- `DiscoveryProvider`'a son aramalar için state eklenecek
- Yeni widget'lar: `DiscoveryHomeView`, `CategoryFilterChips`, `RecentSearches`, `PopularServices`, `EditorsPick`
- Supabase'de popüler hizmetler ve editör seçimleri için query'ler

## Etki Alanı

### Değişecek Dosyalar
- `lib/presentation/providers/discovery_provider.dart` - Yeni view mode ve state
- `lib/presentation/screens/explore_screen.dart` - Ana sayfa görünümü entegrasyonu
- `lib/presentation/widgets/discovery/` - Yeni widget'lar

### Yeni Dosyalar
- `lib/presentation/widgets/discovery/home_view.dart`
- `lib/presentation/widgets/discovery/category_filter_chips.dart`
- `lib/presentation/widgets/discovery/recent_searches.dart`
- `lib/presentation/widgets/discovery/popular_services.dart`
- `lib/presentation/widgets/discovery/editors_pick.dart`

### Veri Modeli
- `lib/data/models/recent_search.dart` - Son arama modeli
- `lib/data/models/popular_service.dart` - Popüler hizmet modeli

### Repository
- `lib/data/repositories/discovery_repository.dart` - Popüler hizmetler ve editör seçimleri için metodlar

## Riskler ve Azaltma

### Risk 1: Performans
**Risk**: Çok fazla veri yükleme ana sayfayı yavaşlatabilir
**Azaltma**: Lazy loading, pagination ve cache kullanımı

### Risk 2: Kullanıcı Alışkanlığı
**Risk**: Mevcut kullanıcılar doğrudan harita/liste görünümüne alışmış olabilir
**Azaltma**: Hızlı geçiş butonları ve kullanıcı tercihlerini hatırlama

### Risk 3: Veri Tutarlılığı
**Risk**: Popüler hizmetler ve editör seçimleri güncel olmayabilir
**Azaltma**: Periyodik güncelleme mekanizması ve cache invalidation

## Alternatifler

### Alternatif 1: Mevcut Ekranı Koruma
Mevcut harita/liste görünümünü koruyup sadece filtreleme özelliklerini geliştirmek.
**Neden Reddedildi**: Kullanıcı deneyimi için ilham verici bir başlangıç noktası eksik.

### Alternatif 2: Ayrı Bir "Keşfet" Sekmesi
Ana sayfayı ayrı bir sekme olarak eklemek.
**Neden Reddedildi**: Navigasyon karmaşıklığı artar, mevcut yapı yeterli.

## Başarı Kriterleri

1. Ana sayfa 2 saniyeden kısa sürede yüklenir
2. Kullanıcılar popüler hizmetlerden birini tıklayarak ilgili mekanları görebilir
3. Son aramalar doğru şekilde kaydedilir ve gösterilir
4. Kategori filtreleri çalışır ve sonuçları günceller
5. Editörün seçimi bölümü en az 5 mekan gösterir
6. Harita ve liste görünümlerine geçiş sorunsuz çalışır

## Bağımlılıklar

- Mevcut `DiscoveryProvider` ve `VenueRepository` altyapısı
- Supabase'de `popular_services` ve `featured_venues` için view'lar veya query'ler
- Tasarım sistemi (AppColors, typography)

## Zaman Tahmini

- **Tasarım ve Planlama**: 0.5 gün
- **Backend (Supabase queries)**: 1 gün
- **Frontend (Widget'lar ve state)**: 2 gün
- **Test ve İyileştirme**: 1 gün
- **Toplam**: ~4.5 gün
