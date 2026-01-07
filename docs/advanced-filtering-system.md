# Gelişmiş Filtreleme ve Arama Sistemi 🔍

## Genel Bakış
PRD'de belirtilen "Botoks + Jawline" gibi spesifik aramaları destekleyen gelişmiş filtreleme sistemi.

## Özellikler

### 1. VenueFilter Modeli
**Dosya:** `lib/data/models/venue_filter.dart`

Filtreleme kriterleri:
- **Kategoriler**: Çoklu kategori seçimi (Saç, Cilt Bakımı, Kaş-Kirpik, vb.)
- **Fiyat Aralığı**: Min/Max fiyat filtreleme
- **Puan**: Minimum puan filtreleme
- **Uzaklık**: Konum bazlı arama yarıçapı (1-50 km)
- **Güven Rozetleri**: 
  - Onaylı Mekan (`is_verified`)
  - En Çok Tercih Edilen (`is_preferred`)
  - Hijyen Onaylı (`is_hygienic`)

### 2. VenueRepository Güncellemeleri
**Dosya:** `lib/data/repositories/venue_repository.dart`

Yeni metodlar:
```dart
Future<List<Venue>> searchVenues({
  String? query,
  VenueFilter? filter,
  double? lat,
  double? lng,
})
```

- Arama sorgusu: Mekan adı, açıklama ve adres üzerinde arama
- Filtre desteği: VenueFilter parametreleri ile filtreleme
- Konum bazlı: Kullanıcının konumuna göre yakınlık sıralaması
- Fallback mekanizması: RPC yoksa local filtreleme

### 3. DiscoveryProvider Güncellemeleri
**Dosya:** `lib/presentation/providers/discovery_provider.dart`

Yeni özellikler:
- `VenueFilter _filter`: Aktif filtre durumu
- `updateFilter(VenueFilter)`: Filtreleri güncelleme
- `resetFilters()`: Tüm filtreleri temizleme
- Otomatik konum izni isteme (WidgetsBinding ile)
- Akıllı venue yükleme (filtre/arama/konum bazlı)

### 4. FilterBottomSheet Widget
**Dosya:** `lib/presentation/widgets/discovery/filter_bottom_sheet.dart`

UI Bileşenleri:
- **Kategori Seçimi**: FilterChip ile çoklu seçim
- **Uzaklık Slider**: 1-50 km arası ayarlanabilir
- **Güven Rozetleri**: Checkbox ile seçim
- **Fiyat Aralığı**: Min/Max TextField'lar
- **Temizle Butonu**: Tüm filtreleri sıfırlama
- **Uygula Butonu**: Filtreleri aktif etme

### 5. Konum İzinleri
**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

**iOS:** `ios/Runner/Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Yakınınızdaki güzellik merkezlerini harita üzerinde görebilmek için konum izni gereklidir.</string>
```

## Kullanım Örnekleri

### Arama Yapma
```dart
// Provider üzerinden arama
context.read<DiscoveryProvider>().setSearchQuery('Botoks');
```

### Filtre Uygulama
```dart
final filter = VenueFilter(
  categories: ['Estetik', 'Cilt Bakımı'],
  maxDistanceKm: 5.0,
  onlyVerified: true,
  minPrice: 500,
  maxPrice: 2000,
);

context.read<DiscoveryProvider>().updateFilter(filter);
```

### Filtreleri Temizleme
```dart
context.read<DiscoveryProvider>().resetFilters();
```

## Teknik Detaylar

### Arama Algoritması
1. Önce konum kontrolü yapılır
2. Eğer filtre veya arama varsa `searchVenues` çağrılır
3. Sadece konum varsa `getVenuesNearby` kullanılır
4. Hiçbiri yoksa tüm venue'ler getirilir

### Performans Optimizasyonları
- Local filtreleme: RPC yoksa Dart tarafında filtreleme
- Debounce: Arama için otomatik gecikme (TextField onChange)
- Lazy loading: Sadece gerektiğinde venue yükleme

### Gelecek Geliştirmeler
- [ ] Supabase RPC fonksiyonu (`advanced_venue_search`)
- [ ] Puan bazlı filtreleme (reviews tablosu gerekli)
- [ ] Hizmet bazlı fiyat filtreleme
- [ ] Arama geçmişi
- [ ] Popüler aramalar
- [ ] Otomatik tamamlama

## Test Senaryoları

1. **Kategori Filtreleme**: "Saç" kategorisi seçildiğinde sadece saç hizmeti veren mekanlar gösterilmeli
2. **Uzaklık Filtreleme**: 5km seçildiğinde sadece 5km içindeki mekanlar gösterilmeli
3. **Çoklu Filtre**: Kategori + Uzaklık + Rozet kombinasyonları çalışmalı
4. **Arama + Filtre**: "Estetik" araması + "Onaylı Mekan" filtresi birlikte çalışmalı
5. **Konum İzni**: İzin verilmediğinde tüm mekanlar gösterilmeli
6. **Filtre Temizleme**: Temizle butonuna basıldığında tüm filtreler sıfırlanmalı

## Notlar
- Konum izni ilk açılışta otomatik olarak istenir
- Filtreler bottom sheet ile modern bir UI ile sunulur
- Tüm filtreler birbirleriyle uyumlu çalışır
- Performans için local filtreleme kullanılır (RPC opsiyonel)
