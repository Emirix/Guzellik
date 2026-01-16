# Change: İşletme Kapak Fotoğrafı Yönetimi

## Why
İşletmeler, profillerini daha çekici hale getirmek için kategori bazında hazır kapak fotoğrafları seçebilmeli veya kendi özel kapak fotoğraflarını yükleyebilmelidir. Bu özellik, işletme profillerinin görsel kalitesini artıracak ve kullanıcı deneyimini iyileştirecektir.

## What Changes
- Yeni bir admin ekranı (`AdminCoverPhotoScreen`) eklenir
- FTP'deki `/storage/categories/[kategori-adi]/` klasörlerinden kategori bazında hazır fotoğraflar listelenir
- İşletme sahibi, kategorisine ait hazır fotoğraflardan birini seçebilir veya kendi fotoğrafını yükleyebilir
- Seçilen/yüklenen kapak fotoğrafı `venues` tablosundaki `cover_photo_url` sütununda saklanır
- Venue listelerinde (keşif, arama, vb.) kapak fotoğrafı kullanılır

## Impact
- **Affected specs**: `venue-profile` (yeni capability), `database`, `venue-details`
- **Affected code**: 
  - Yeni ekran: `lib/presentation/screens/business/admin/admin_cover_photo_screen.dart`
  - Model güncellemesi: `lib/data/models/venue.dart`
  - Repository güncellemesi: `lib/data/repositories/venue_repository.dart`
  - Widget güncellemeleri: `lib/presentation/widgets/venue/venue_card.dart`, `lib/presentation/widgets/venue/v2/venue_hero_v2.dart`
  - Database migration: `cover_photo_url` sütunu eklenmesi
