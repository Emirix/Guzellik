## Context
İşletme profil yönetimi sistemine kapak fotoğrafı seçme/yükleme özelliği ekleniyor. Bu özellik, işletmelerin profillerini daha çekici hale getirmesini sağlayacak.

### Mevcut Durum
- İşletmeler şu anda `hero_images` array'i ile çoklu fotoğraf yükleyebiliyor
- `image_url` field'ı deprecated olarak işaretlenmiş
- Venue kartlarında ve detay sayfalarında `heroImages[0]` kullanılıyor
- FTP storage sistemi mevcut ve çalışıyor

### Kısıtlamalar
- FTP'de `/storage/categories/` altında kategori bazında klasörler mevcut
- Her işletme sadece kendi kategorisine ait hazır fotoğrafları görebilmeli
- Özel fotoğraf yükleme de desteklenmeli

## Goals / Non-Goals

### Goals
- İşletmelerin kategori bazında hazır kapak fotoğrafları seçebilmesi
- Özel kapak fotoğrafı yükleme imkanı
- Seçilen kapak fotoğrafının venue listelerinde kullanılması
- Kolay ve sezgisel bir admin arayüzü

### Non-Goals
- Çoklu kapak fotoğrafı seçimi (sadece 1 tane)
- Fotoğraf düzenleme/crop özellikleri (ilk versiyonda)
- Kategori fotoğraflarının admin tarafından yönetimi (manuel FTP yönetimi)

## Decisions

### Decision 1: Yeni Sütun vs Mevcut Sütun Kullanımı
**Seçim**: Yeni `cover_photo_url` sütunu eklenecek

**Alternatifler**:
1. `image_url` sütununu yeniden kullan → Deprecated olduğu için uygun değil
2. `hero_images[0]`'ı otomatik olarak kapak fotoğrafı yap → Kullanıcı kontrolü olmaz
3. Yeni `cover_photo_url` sütunu → ✅ En temiz ve esnek çözüm

**Rationale**: Ayrı bir sütun, geriye uyumluluk sağlar ve kapak fotoğrafı ile hero images'ı bağımsız yönetmeyi mümkün kılar.

### Decision 2: FTP Listeleme Yöntemi
**Seçim**: PHP API endpoint üzerinden FTP klasör listeleme

**Alternatifler**:
1. Doğrudan FTP bağlantısı Flutter'dan → Güvenlik riski
2. PHP API endpoint → ✅ Mevcut StorageService pattern'ine uygun
3. Supabase Storage'a migrate et → Scope dışı, büyük değişiklik

**Rationale**: Mevcut FTP altyapısını kullanarak, güvenli ve tutarlı bir çözüm sağlanır.

### Decision 3: Fallback Stratejisi
**Seçim**: `coverPhotoUrl ?? heroImages.firstOrNull ?? defaultPlaceholder`

**Rationale**: 
- Önce kapak fotoğrafı gösterilir
- Yoksa hero images'tan ilki
- Hiçbiri yoksa placeholder
- Geriye uyumlu ve esnek

## Technical Approach

### Database Schema
```sql
ALTER TABLE venues 
ADD COLUMN cover_photo_url TEXT;
```

### API Endpoint (PHP)
```
GET /api/list-category-photos.php?category={category_slug}
Response: { "success": true, "photos": ["url1", "url2", ...] }
```

### Flutter Flow
1. Admin ekranı açılır
2. Venue'nun kategorisi alınır
3. FTP'den kategori fotoğrafları listelenir
4. Grid view ile gösterilir
5. Kullanıcı seçim yapar veya özel fotoğraf yükler
6. `VenueRepository.updateCoverPhoto(venueId, photoUrl)` çağrılır
7. Database güncellenir

## Risks / Trade-offs

### Risk 1: FTP Klasör Yapısı Tutarsızlığı
**Risk**: Kategori slug'ları ile FTP klasör isimleri eşleşmeyebilir
**Mitigation**: 
- Kategori slug'larını normalize et (lowercase, türkçe karakter dönüşümü)
- FTP klasör isimleri için mapping tablosu oluştur

### Risk 2: Büyük Fotoğraf Listeleri
**Risk**: Bir kategoride çok fazla fotoğraf olursa performans sorunu
**Mitigation**:
- İlk versiyonda sayfalama yok, makul sayıda fotoğraf varsayımı
- Gelecekte lazy loading eklenebilir

### Risk 3: Özel Fotoğraf Yükleme Başarısızlığı
**Risk**: FTP upload sırasında hata oluşabilir
**Mitigation**:
- Retry mekanizması
- Kullanıcıya net hata mesajları
- Loading state'leri

## Migration Plan

### Deployment Steps
1. Database migration'ı çalıştır (`ALTER TABLE` komutu)
2. PHP API endpoint'i deploy et
3. Flutter app'i güncelle ve deploy et

### Rollback Plan
- Database sütunu nullable olduğu için geri alma kolay
- Eski kod `heroImages` fallback'i ile çalışmaya devam eder
- Gerekirse sütun drop edilebilir

### Data Migration
- Mevcut venue'ler için `cover_photo_url` NULL kalacak
- Fallback mekanizması sayesinde sorun olmaz
- İşletmeler kendi kapak fotoğraflarını zamanla seçecek

## Open Questions
- ✅ FTP'de kategori klasörleri mevcut mu? → Evet, kullanıcı onayladı
- ✅ Hangi kategoriler var? → VenueCategory tablosundan alınacak
- ⚠️ PHP API endpoint'i kim geliştirecek? → Implementasyon sırasında netleşecek
