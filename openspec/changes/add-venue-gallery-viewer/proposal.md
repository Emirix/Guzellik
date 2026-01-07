# Change: Mekan detayda fotoğraf galerisi ve önce/sonra karşılaştırma görüntüleyici

## Why

Kullanıcılar mekan seçimi yaparken görsel içeriği en önemli karar faktörlerinden biri olarak kullanırlar. Şu anda mekan detay ekranı tek bir hero görseli desteklemekte, ancak kullanıcıların mekanın genel atmosferini, çalışma örneklerini ve hizmet kalitesini değerlendirmek için daha fazla görsele ihtiyaçları vardır.

Güzellik ve estetik sektöründe "önce/sonra" karşılaştırmaları özellikle kritik öneme sahiptir - kullanıcılar yapılacak işlemlerin sonuçlarını görerek güven kazanır ve karar verme süreçleri kolaylaşır.

## What Changes

- **Venue data model expansion**: Tek `imageUrl` yerine çoklu fotoğraf desteği (`galleryImages` listesi)
- **Photo model**: Fotoğraf meta verisi için yeni model (başlık, kategori, tarih, URL)
- **Hero carousel**: Mekan detay banner alanı kaydırılabilir carousel'e dönüşür
- **Services gallery**: İşlemler sekmesinde thumbnail bazlı galeri görünümü
- **Full-screen viewer**: Tam ekran fotoğraf görüntüleyici (zoom, swipe, metadata)
- **Before/after comparison**: Önce/sonra fotoğrafları için özel slider karşılaştırma görüntüleyici
- **Interactive features**: Fotoğraf paylaşma, indirme, beğenme özellikleri
- **Database schema**: Supabase'de `venue_photos` tablosu ve ilişkili migrations

## Impact

### Affected specs
- `venue-details`: Yeni galeri ve görüntüleyici gereksinimleri eklenir
- (Potansiyel) `database`: Eğer mevcut yoksa, `venue_photos` tablosu için yeni requirement

### Affected code
- **Data layer**:
  - `lib/data/models/venue.dart`: `galleryImages` özelliği eklenir
  - `lib/data/models/venue_photo.dart`: Yeni model (NEW FILE)
  - `lib/data/models/service.dart`: Mevcut `beforePhotoUrl`/`afterPhotoUrl` kullanımı korunur
  - `lib/data/repositories/venue_repository.dart`: Galeri fotoğraflarını çekmek için güncellemeler
  - `lib/data/services/storage_service.dart`: Batch upload desteği

- **Presentation layer**:
  - `lib/presentation/screens/venue_details/`: Hero carousel güncellemesi
  - `lib/presentation/screens/venue_details/tabs/services_tab.dart`: Thumbnail galeri eklenir
  - `lib/presentation/widgets/venue/photo_gallery_viewer.dart`: Tam ekran görüntüleyici (NEW FILE)
  - `lib/presentation/widgets/venue/before_after_viewer.dart`: Önce/sonra karşılaştırma widget (NEW FILE)
  - `lib/presentation/widgets/venue/components/photo_thumbnail_grid.dart`: Thumbnail grid widget (NEW FILE)

- **Backend**:
  - `supabase/migrations/`: `venue_photos` tablo migration (NEW FILE)
  - `supabase/migrations/`: `venues` tablo update migration (galleryImages array eklemek için)

### User-facing changes
- Mekan detay hero alanında çoklu fotoğraf kaydırma
- İşlemler sekmesinde fotoğraf galerisi
- Tam ekran fotoğraf görüntüleyici (zoom, paylaş, indir)
- Önce/sonra karşılaştırma için interaktif slider
- Gelişmiş görsel deneyim ve karar verme kolaylığı
