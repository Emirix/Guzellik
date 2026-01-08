# Proposal: add-search-screen

## Summary
Navbar'a yeni bir "Ara" sekmesi ekleyerek kullanıcıların hizmetlere, mekanlara ve konumlara göre gelişmiş arama ve filtreleme yapabilmelerini sağlamak.

## Motivation
- Kullanıcılar hizmet, konum ve mekan türüne göre filtreleme yaparak istedikleri güzellik salonunu daha hızlı bulabilmeli
- Mevcut keşfet ekranındaki arama çubuğu temel arama yapıyor, ancak tam ekran arama deneyimi yok
- `design/ara/` tasarımlarına uygun bir arama sonuçları sayfası gerekli
- `design/filtreleme_sayfası/` tasarımlarına uygun gelişmiş filtreleme gerekli

## Scope

### In Scope
1. **Navbar Güncellemesi**
   - Navbar'a "Ara" sekmesi eklenmesi (Keşfet'ten hemen sonra, 2. sıra)
   - Mevcut sıralama: Keşfet → **Ara** → Favoriler → Bildirimler → Profil

2. **Arama Sayfası (SearchScreen)**
   - Tam ekran arama deneyimi
   - Son aramalar listesi (local storage)
   - Popüler hizmetler bölümü
   - Arama sonuçları listesi (tasarıma uygun)
   - Harita görünümüne geçiş butonu

3. **Filtreleme Özellikleri**
   - **Konum Filtresi**: İl/ilçe dropdown (otomatik konum tespiti, izin isteme)
   - **Mesafe Slider**: 1-50km arası uzaklık filtresi
   - **Hizmet Filtresi**: `services` tablosundan çekilen hizmetler (chip seçimi)
   - **Mekan Türü Filtresi**: Güzellik Salonu, Kuaför, Estetik Kliniği vb.
   - **Puan Filtresi**: Minimum puan seçimi
   - **Güven Rozetleri**: Onaylı, Hijyen, En Çok Tercih Edilen

4. **Son Aramalar Yönetimi**
   - Local storage'da arama geçmişi tutma
   - Son 10 aramayı gösterme
   - Tek tek veya toplu silme

### Out of Scope
- Backend arama algoritması değişiklikleri (mevcut `search_venues_advanced` RPC kullanılacak)
- Push notification entegrasyonu
- Arama analitikleri (Firebase Analytics)

## Design References
- `design/ara/code.html` - Arama sonuçları sayfası tasarımı
- `design/ara/screen.png` - Arama sonuçları görsel referansı
- `design/filtreleme_sayfası/code.html` - Filtreleme bottom sheet tasarımı
- `design/filtreleme_sayfası/screen.png` - Filtreleme görsel referansı
- `design/kesfet.html` - Keşfet sayfası referansı (Son Aramalar, Popüler Hizmetler)

## Technical Approach
1. `SearchScreen` oluşturulacak - `lib/presentation/screens/search_screen.dart`
2. `CustomBottomNav` güncellenerek "Ara" sekmesi eklenecek
3. `HomeScreen` güncellenerek yeni sekme için screen eklenecek
4. `AppStateProvider` güncellenerek yeni navbar index'i desteklenecek
5. `SearchProvider` oluşturulacak - arama durumu, son aramalar, filtreleme
6. `SearchFilterBottomSheet` oluşturulacak - gelişmiş filtreleme UI
7. `SearchResultCard` widget'ı oluşturulacak - tasarıma uygun sonuç kartları
8. `RecentSearchTile` widget'ı oluşturulacak - son arama öğeleri
9. `SharedPreferences` ile son aramalar local'de saklanacak

## Affected Specs
- `navigation` - Navbar güncellemesi
- `discovery` - Arama ve filtreleme gereksinimleri eklenmesi

## Dependencies
- Mevcut `services` tablosu ve `service_categories`
- Mevcut `search_venues_advanced` RPC
- Mevcut `VenueFilter` modeli
- `geolocator` paketi (konum izni için)
- `shared_preferences` paketi (son aramalar için)
- `geocoding` paketi (koordinat → il/ilçe dönüşümü)

## Risks
- Konum izni reddedildiğinde varsayılan konum davranışı netleştirilmeli
- Çok fazla hizmet olduğunda chip seçimi UI'ı karmaşıklaşabilir
