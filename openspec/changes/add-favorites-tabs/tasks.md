## 1. Database Migration

- [x] 1.1 `user_favorites` tablosu oluştur (user_id, venue_id, created_at, unique constraint)
- [x] 1.2 RLS policies ekle (kullanıcılar sadece kendi favorilerini görebilir/yönetebilir)
- [x] 1.3 İndeksler ekle (user_id, venue_id, created_at için)
- [x] 1.4 Migration'ı Supabase'e uygula ve test et

## 2. Data Layer

- [x] 2.1 `VenueRepository`'ye `addFavorite(venueId)` metodu ekle
- [x] 2.2 `VenueRepository`'ye `removeFavorite(venueId)` metodu ekle
- [x] 2.3 `VenueRepository`'ye `getFavoriteVenues()` metodu ekle
- [x] 2.4 `VenueRepository`'ye `getFollowedVenues()` metodu ekle (zaten var mı kontrol et)
- [x] 2.5 `VenueRepository`'ye `checkIfFavorited(venueId)` metodu ekle
- [x] 2.6 `Venue` modeline `isFavorited` boolean alanı ekle (opsiyonel)

## 3. State Management

- [x] 3.1 `FavoritesProvider` sınıfı oluştur (ChangeNotifier)
- [x] 3.2 Favori mekanlar listesi state'i ekle
- [x] 3.3 Takip edilen mekanlar listesi state'i ekle
- [x] 3.4 Loading ve error state'leri ekle
- [x] 3.5 `loadFavorites()` metodu implement et
- [x] 3.6 `loadFollowedVenues()` metodu implement et
- [x] 3.7 `toggleFavorite(venue)` metodu implement et
- [x] 3.8 Aktif sekme state'i ekle (favorites/following)

## 4. UI Components

- [x] 4.1 `FavoritesScreen`'i yeniden tasarla (TabBar ile)
- [x] 4.2 Premium stil sekme tasarımı uygula (soft pink, nude tonları)
- [x] 4.3 "Favoriler" sekmesi içeriğini oluştur
- [x] 4.4 "Takip Ettiklerim" sekmesi içeriğini oluştur
- [x] 4.5 Boş state tasarımları ekle (her iki sekme için)
- [x] 4.6 Venue card'ları liste halinde göster
- [ ] 4.7 Loading state'i için shimmer/skeleton ekle (CircularProgressIndicator eklendi)
- [x] 4.8 Error state'i için hata mesajı tasarımı ekle

## 5. Integration

- [x] 5.1 Venue detay sayfasına favori butonu ekle
- [x] 5.2 Arama sonuçlarına favori butonu ekle (opsiyonel)
- [x] 5.3 Keşfet sayfasındaki venue card'lara favori butonu ekle (opsiyonel)
- [x] 5.4 Favori butonuna tıklandığında `FavoritesProvider.toggleFavorite()` çağır
- [x] 5.5 Favori durumu değiştiğinde UI'ı güncelle

## 6. Testing & Validation

- [ ] 6.1 Favori ekleme/çıkarma işlevselliğini test et
- [ ] 6.2 Sekme geçişlerinin düzgün çalıştığını doğrula
- [ ] 6.3 Boş state'lerin doğru göründüğünü kontrol et
- [ ] 6.4 RLS policies'in çalıştığını test et (farklı kullanıcılar)
- [ ] 6.5 Loading ve error state'lerini test et
- [ ] 6.6 Tasarımın uygulama stiliyle uyumlu olduğunu doğrula
