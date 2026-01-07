# Design: Keşfet Ana Ekranı Mimarisi

## Genel Bakış

Keşfet ana ekranı, kullanıcıların güzellik hizmetlerini keşfetmek için kullanacakları birincil giriş noktasıdır. Bu tasarım, kullanıcı deneyimini iyileştirmek için üç farklı görünüm modu sunar: Ana Sayfa, Harita ve Liste.

## Mimari Kararlar

### 1. View Mode Stratejisi

**Karar**: Tek bir `ExploreScreen` içinde üç farklı görünüm modu kullanılacak.

**Gerekçe**:
- State yönetimi merkezi ve tutarlı olur
- Görünümler arası geçiş smooth ve hızlı olur
- Code duplication azalır
- Provider state'i tüm görünümler arasında paylaşılır

**Alternatif**: Her görünüm için ayrı screen oluşturmak
- **Neden Reddedildi**: State senkronizasyonu zorlaşır, navigation karmaşıklaşır

### 2. State Management

**Karar**: Mevcut `DiscoveryProvider` genişletilecek, yeni bir provider oluşturulmayacak.

**Gerekçe**:
- Mevcut altyapı yeterli ve genişletilebilir
- Tek bir provider ile state yönetimi basitleşir
- Harita ve liste görünümleri ile state paylaşımı kolay olur

**State Yapısı**:
```dart
class DiscoveryProvider extends ChangeNotifier {
  // Mevcut state
  DiscoveryViewMode _viewMode = DiscoveryViewMode.home;
  List<Venue> _venues = [];
  VenueFilter _filter = VenueFilter();
  
  // Yeni state
  List<RecentSearch> _recentSearches = [];
  List<PopularService> _popularServices = [];
  List<Venue> _featuredVenues = [];
  String? _selectedCategory;
  bool _isLoadingHome = false;
}
```

### 3. Data Caching Stratejisi

**Karar**: Multi-level caching kullanılacak.

**Katmanlar**:
1. **Memory Cache**: Provider içinde, session boyunca
2. **Local Storage**: Son aramalar için kalıcı
3. **Supabase Cache**: Popüler hizmetler ve editör seçimleri için TTL-based

**TTL (Time To Live)**:
- Popüler Hizmetler: 5 dakika
- Editörün Seçimi: 30 dakika
- Son Aramalar: Kalıcı (kullanıcı silene kadar)

**Gerekçe**:
- Network trafiği azalır
- Sayfa yükleme hızı artar
- Offline deneyim iyileşir

### 4. Widget Hiyerarşisi

```
ExploreScreen
├── DiscoveryHomeView (yeni)
│   ├── HomeHeader (başlık + filtre butonu)
│   ├── DiscoverySearchBar (mevcut, güncellenecek)
│   ├── CategoryFilterChips (yeni)
│   ├── RecentSearches (yeni)
│   ├── PopularServices (yeni)
│   └── EditorsPick (yeni)
├── DiscoveryMapView (mevcut)
└── VenueListView (mevcut)
```

**Karar**: Her bölüm ayrı widget olacak.

**Gerekçe**:
- Reusability artar
- Testing kolaylaşır
- Code organization iyileşir
- Lazy loading uygulanabilir

### 5. Supabase Query Stratejisi

**Popüler Hizmetler**:
```sql
CREATE VIEW popular_services AS
SELECT 
  s.id,
  s.name,
  s.icon,
  COUNT(vs.venue_id) as venue_count,
  COUNT(DISTINCT sr.user_id) as search_count
FROM services s
LEFT JOIN venue_services vs ON s.id = vs.service_id
LEFT JOIN search_records sr ON s.name ILIKE '%' || sr.query || '%'
GROUP BY s.id, s.name, s.icon
ORDER BY search_count DESC, venue_count DESC
LIMIT 10;
```

**Editörün Seçimi**:
```sql
CREATE VIEW featured_venues AS
SELECT v.*
FROM venues v
WHERE v.is_featured = true
  AND v.is_active = true
  AND v.rating >= 4.5
ORDER BY v.featured_priority DESC, v.rating DESC
LIMIT 10;
```

**Karar**: View'lar kullanılacak, stored procedure yerine.

**Gerekçe**:
- Basit ve performanslı
- Supabase client ile kolay query
- Maintenance kolay

### 6. Search Flow

**Akış**:
1. Kullanıcı arama çubuğuna tıklar
2. Arama çubuğu expand olur (veya ayrı ekrana geçer)
3. Kullanıcı yazmaya başlar
4. Debounce ile (300ms) arama yapılır
5. Sonuçlar liste görünümünde gösterilir
6. Arama kaydedilir (recent searches)

**Karar**: Arama sonuçları otomatik liste görünümüne geçer.

**Gerekçe**:
- Liste görünümü arama sonuçları için daha uygun
- Kullanıcı beklentisi ile uyumlu
- Harita görünümünde çok fazla marker karışıklık yaratabilir

### 7. Category Filtering

**Kategoriler**:
- Tümü (default)
- Saç Tasarım
- Cilt Bakım
- Tırnak
- Estetik
- Vücut
- Kaş-Kirpik

**Karar**: Kategori seçimi hem ana sayfada hem de diğer görünümlerde aktif kalacak.

**Gerekçe**:
- Tutarlı filtreleme deneyimi
- Kullanıcı beklentisi ile uyumlu
- State yönetimi basit

### 8. Performance Optimizations

**Lazy Loading**:
- Editörün seçimi: İlk 5 mekan göster, "Tümünü Gör" ile daha fazla
- Popüler hizmetler: İlk 10 hizmet

**Image Optimization**:
- Thumbnail kullan (200x200)
- Lazy loading uygula
- `cached_network_image` package kullan

**Debouncing**:
- Arama: 300ms
- Kategori değişimi: Anında (debounce yok)

## Veri Akışı

```
User Action → Provider → Repository → Supabase
                ↓
            UI Update
```

**Örnek: Popüler Hizmet Tıklama**:
1. Kullanıcı "Botoks" chip'ine tıklar
2. `DiscoveryProvider.filterByService("Botoks")` çağrılır
3. `VenueRepository.getVenuesByService("Botoks")` çağrılır
4. Supabase query çalışır
5. Sonuçlar `_venues` state'ine yazılır
6. `notifyListeners()` çağrılır
7. UI güncellenir (liste görünümüne geçer)

## Error Handling

**Stratejiler**:
1. **Network Error**: Retry butonu + cached data göster
2. **Empty State**: Uygun mesaj + alternatif öneriler
3. **Loading State**: Skeleton loader kullan
4. **Timeout**: 10 saniye sonra hata göster

**Error Mesajları**:
- Network: "Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin."
- Empty: "Henüz arama geçmişiniz yok. Keşfetmeye başlayın!"
- Timeout: "İşlem zaman aşımına uğradı. Tekrar deneyin."

## Testing Strategy

**Unit Tests**:
- Provider metodları
- Repository metodları
- Model serialize/deserialize

**Widget Tests**:
- Her widget ayrı ayrı
- State değişimlerine göre UI güncellemeleri
- User interaction'lar

**Integration Tests**:
- Ana sayfa yükleme
- Kategori filtreleme
- Arama akışı
- Görünüm geçişleri

## Accessibility

- Semantic labels ekle
- Screen reader desteği
- Minimum touch target size (48x48)
- Color contrast ratio (WCAG AA)

## Gelecek İyileştirmeler

1. **Personalization**: Kullanıcı tercihlerine göre öneriler
2. **AI-Powered Search**: Doğal dil işleme ile akıllı arama
3. **Voice Search**: Sesli arama desteği
4. **Trending Services**: Trend olan hizmetler bölümü
5. **Nearby Venues**: Yakınımdaki mekanlar (location-based)

## Trade-offs

### Memory vs Network
**Seçim**: Memory cache kullan
**Trade-off**: Daha fazla RAM kullanımı, ama daha hızlı yükleme

### Complexity vs Flexibility
**Seçim**: Tek provider, çoklu görünüm
**Trade-off**: Provider biraz karmaşık, ama state yönetimi kolay

### Real-time vs Cached
**Seçim**: TTL-based cache
**Trade-off**: Bazen eski data gösterilir, ama performans yüksek
