# Change: Favoriler Sayfasına İki Sekme Ekleme

## Why

Kullanıcıların favori mekanları ile takip ettikleri mekanları ayırt edebilmeleri için Favoriler sayfasında iki ayrı sekme gerekiyor. Şu anda "Favoriler" ve "Takip Etme" özellikleri farklı kavramlar olmasına rağmen, kullanıcı arayüzünde bunları görüntülemek için ayrı bir yapı bulunmuyor.

**Favoriler** ve **Takip Etme** arasındaki fark:
- **Favoriler**: Kullanıcının beğendiği ve daha sonra tekrar bakmak için kaydettiği mekanlar (bookmark benzeri)
- **Takip Etme**: Kullanıcının bildirim almak ve güncellemelerini takip etmek için izlediği mekanlar (follow sistemi)

## What Changes

- Favoriler sayfasına iki sekme (tab) eklenecek: "Favoriler" ve "Takip Ettiklerim"
- "Favoriler" sekmesinde kullanıcının favori olarak eklediği mekanlar listelenecek
- "Takip Ettiklerim" sekmesinde kullanıcının takip ettiği mekanlar listelenecek
- Veritabanında `user_favorites` tablosu oluşturulacak (takip için `follows` tablosu zaten mevcut)
- `VenueRepository`'ye favori ekleme/çıkarma ve favori mekanları listeleme metodları eklenecek
- `FavoritesProvider` state management sınıfı oluşturulacak
- Sekme tasarımı uygulama stiline uygun olacak (soft pink, nude tonları, premium estetik)

## Impact

- **Affected specs**: 
  - `favorites` (yeni capability)
  - `database` (yeni tablo ekleniyor)
  
- **Affected code**:
  - `lib/presentation/screens/favorites_screen.dart` (tamamen yeniden tasarlanacak)
  - `lib/data/repositories/venue_repository.dart` (favori metodları eklenecek)
  - `lib/presentation/providers/favorites_provider.dart` (yeni provider)
  - `lib/data/models/venue.dart` (isFavorited alanı eklenebilir)
  - `supabase/migrations/` (yeni migration: `user_favorites` tablosu)
  - `lib/presentation/widgets/venue/` (venue card'lara favori butonu eklenebilir)

- **Database changes**:
  - Yeni tablo: `user_favorites` (user_id, venue_id, created_at)
  - RLS policies eklenmesi gerekiyor
