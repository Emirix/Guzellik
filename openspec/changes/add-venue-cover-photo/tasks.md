## 1. Database Değişiklikleri
- [x] 1.1 `venues` tablosuna `cover_photo_url` sütunu ekle (TEXT, nullable)
- [x] 1.2 Migration script'i oluştur ve test et

## 2. Model ve Repository Güncellemeleri
- [x] 2.1 `Venue` model'ine `coverPhotoUrl` field'ı ekle
- [x] 2.2 `fromJson` ve `toJson` metodlarını güncelle
- [x] 2.3 `copyWith` metodunu güncelle
- [x] 2.4 `VenueRepository`'de kapak fotoğrafı güncelleme metodu ekle

## 3. FTP Kategori Fotoğrafları Listeleme
- [x] 3.1 `StorageService`'e kategori fotoğraflarını listeleme metodu ekle
- [x] 3.2 FTP'den `/storage/categories/[kategori-slug]/` klasörünü okuma fonksiyonu
- [x] 3.3 Fotoğraf URL'lerini döndürme

## 4. Admin Cover Photo Screen
- [x] 4.1 `AdminCoverPhotoScreen` widget'ı oluştur
- [x] 4.2 Kategori bazında hazır fotoğrafları grid view ile göster
- [x] 4.3 Seçili fotoğrafı highlight et
- [x] 4.4 Özel fotoğraf yükleme butonu ve fonksiyonu ekle
- [x] 4.5 Image picker entegrasyonu
- [x] 4.6 Kaydet butonu ve API çağrısı
- [x] 4.7 Loading ve error state'leri

## 5. Admin Dashboard Entegrasyonu
- [x] 5.1 `AdminDashboardScreen`'e "Kapak Fotoğrafı" menü öğesi ekle
- [x] 5.2 Navigation route'u ekle

## 6. Venue Display Güncellemeleri
- [x] 6.1 `VenueCard` widget'ında `coverPhotoUrl` kullanımı (fallback: `heroImages[0]`)
- [x] 6.2 `VenueHeroV2` widget'ında `coverPhotoUrl` kullanımı
- [x] 6.3 Diğer venue gösterim widget'larını kontrol et ve güncelle

## 7. Provider Oluşturma
- [x] 7.1 `AdminCoverPhotoProvider` oluştur
- [x] 7.2 Kategori fotoğraflarını yükleme state management
- [x] 7.3 Fotoğraf seçme ve yükleme logic
- [x] 7.4 Venue güncelleme fonksiyonu

## 8. Test ve Doğrulama
- [x] 8.1 Farklı kategorilerdeki işletmeler için test et
- [x] 8.2 Özel fotoğraf yükleme test et
- [x] 8.3 Venue listelerinde doğru fotoğrafın gösterildiğini kontrol et
- [x] 8.4 FTP bağlantı hatalarını test et
- [x] 8.5 Image loading ve caching performansını kontrol et
