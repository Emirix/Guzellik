# Design: Venue Gallery and Before/After Viewer

## Context

Güzellik platformunda görsel içerik kullanıcı kararlarının temel belirleyicisidir. Mevcut sistemde her mekan için tek bir `imageUrl` bulunmakta, ancak kullanıcılar mekanı daha kapsamlı değerlendirmek için çoklu fotoğraf ve özellikle hizmet sonuçlarını gösteren önce/sonra karşılaştırmalarına ihtiyaç duymaktadır.

**Stakeholders**:
- **End users**: Mekan hakkında görsel bilgi toplayan kadın kullanıcılar
- **Venue owners**: Mekanlarını tanıtmak isteyen işletme sahipleri
- **Product team**: Premium deneyim ve conversion optimization hedefleyen ekip

**Technical constraints**:
- Flutter/Supabase stack
- Mobile-first responsive design
- Image optimization gereksinimi (lazy loading, caching, thumbnails)
- Storage costs (Supabase Storage)

## Goals / Non-Goals

### Goals
- Mekan detay hero alanında çoklu fotoğraf carousel desteği
- İşlemler sekmesinde thumbnail grid galeri
- Tam ekran fotoğraf görüntüleyici (zoom, swipe, share, download)
- Önce/sonra fotoğrafları için slider-based karşılaştırma görüntüleyici
- Fotoğraf meta data yönetimi (başlık, kategori, tarih)
- Performanslı image loading (thumbnails, caching, lazy loading)

### Non-Goals
- Video galeri desteği (sonraki iterasyon)
- User-generated photo uploads (şimdilik sadece venue owner yükleyebilir)
- Advanced editing (filters, crop) - backend tarafında yapılır
- Photo comments/reactions (simple like yeterli)
- AI-powered photo tagging (manuel kategorileme kullanılır)

## Decisions

### 1. Data Model Strategy

**Decision**: Hybrid approach - hem `venue.galleryImages` array hem de ayrı `VenuePhoto` modeli kullanılır.

**Rationale**:
- **Simple use case** (hero carousel): `galleryImages: List<String>` yeterli, hızlı çekim
- **Complex use case** (gallery with metadata): `VenuePhoto` model ile detaylı bilgi
- Backward compatibility: Mevcut `imageUrl` korunur (hero'nun ilk fotoğrafı)

**VenuePhoto Model**:
```dart
class VenuePhoto {
  final String id;
  final String venueId;
  final String url;
  final String? thumbnailUrl;
  final String? title;
  final PhotoCategory category; // enum: interior, exterior, service_result, team, equipment
  final DateTime uploadedAt;
  final int sortOrder;
  final bool isHeroImage;
}
```

**Venue Model Update**:
```dart
class Venue {
  // Existing
  final String? imageUrl; // DEPRECATED, hero carousel'in ilk fotoğrafı

  // NEW
  final List<String> heroImages; // Hero carousel için URLs
  final List<VenuePhoto>? galleryPhotos; // Detaylı galeri (lazy loaded)
}
```

**Alternatives considered**:
- ❌ Sadece array: Metadata eksikliği
- ❌ Sadece model: Basit durumlarda over-engineering
- ✅ Hybrid: Her iki ihtiyacı da karşılar

### 2. Before/After Storage

**Decision**: Mevcut `service.beforePhotoUrl` ve `service.afterPhotoUrl` kullanılır, sadece UI katmanı eklenir.

**Rationale**:
- Zaten `Service` modelinde bu alanlar mevcut
- Schema değişikliği gerektirmez
- Before/after mantıksal olarak service'e bağlı
- Separate concerns: Gallery = venue, Before/After = service

**Enhancement**: `VenuePhoto` modelinde `serviceId` referansı eklenebilir (opsiyonel), böylece galeri fotoğrafları da service'lere bağlanabilir.

### 3. UI Component Architecture

**Decision**: Üç ana widget seti oluşturulur:

**a) Hero Carousel** (`VenueHeroCarousel`):
- PageView.builder ile kaydırma
- Parallax effect (mevcut tasarımda var)
- Pagination dots
- Full-screen tap gesture

**b) Thumbnail Gallery** (`PhotoThumbnailGrid`):
- GridView with auto-sizing
- Category filtering (hepsi, interior, service results, vb.)
- Lazy loading + caching (cached_network_image)
- Tap → Full-screen viewer

**c) Full-Screen Viewers**:
- **PhotoGalleryViewer**: Genel fotoğraflar için
  - PhotoViewGallery package kullanılır (pinch-zoom, swipe)
  - Bottom metadata sheet (başlık, tarih)
  - Action bar (share, download, like, close)

- **BeforeAfterViewer**: Önce/sonra karşılaştırma
  - Custom slider widget (dikey/yatay bölme çizgisi)
  - Swipe/drag ile comparison position ayarı
  - Metadata + action bar

**Alternatives considered**:
- ❌ Tek generic viewer: Before/after için özel UX gerekiyor
- ❌ Native Flutter widgets only: Zoom/pan için mature package daha iyi
- ✅ Specialized viewers: Her use case optimize edilmiş

### 4. Image Optimization Strategy

**Decision**: Multi-tier caching + thumbnail generation

**Pipeline**:
```
Upload → Original (Supabase Storage)
       → Thumbnail generation (Supabase Edge Function / manual)
       → CDN delivery
       → Flutter cached_network_image → Local cache
```

**Thumbnail specs**:
- Grid thumbnails: 300x300px
- Hero carousel: 1080x720px (compressed)
- Full-screen: Original (lazy loaded)

**Implementation**:
- **Phase 1**: Manual thumbnail upload (venue owners upload both)
- **Phase 2**: Automatic generation (Supabase Edge Function + Sharp library)

**Rationale**:
- Performance: Grid'de original yüklemek bandwidth israfı
- User experience: Smooth scrolling
- Cost optimization: Thumbnail'ler daha az storage kullanır

### 5. Database Schema

**Decision**: `venue_photos` tablosu eklenir, `venues.hero_images` JSONB array.

**Schema**:
```sql
-- Yeni tablo
CREATE TABLE venue_photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venue_id UUID REFERENCES venues(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  title TEXT,
  category TEXT CHECK (category IN ('interior', 'exterior', 'service_result', 'team', 'equipment')),
  service_id UUID REFERENCES services(id) ON DELETE SET NULL, -- opsiyonel service bağlantısı
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  sort_order INTEGER DEFAULT 0,
  is_hero_image BOOLEAN DEFAULT FALSE,
  likes_count INTEGER DEFAULT 0,
  CONSTRAINT valid_urls CHECK (url ~* '^https?://')
);

CREATE INDEX idx_venue_photos_venue_id ON venue_photos(venue_id);
CREATE INDEX idx_venue_photos_category ON venue_photos(category);
CREATE INDEX idx_venue_photos_sort_order ON venue_photos(venue_id, sort_order);

-- Mevcut venues tablosuna ekleme
ALTER TABLE venues ADD COLUMN hero_images JSONB DEFAULT '[]'::jsonb;
```

**Alternatives considered**:
- ❌ JSONB only: Query performance ve normalization sorunları
- ❌ Separate table per category: Over-engineering
- ✅ Single normalized table + indexes: Clean, scalable

### 6. Navigation Flow

**Decision**: Multiple entry points for gallery access

**Flow**:
1. **Hero Carousel** → Tap any photo → `PhotoGalleryViewer` (starts at tapped index)
2. **Services Tab Thumbnails** → Tap photo → `PhotoGalleryViewer` (category filtered)
3. **Services Tab Before/After** → Tap → `BeforeAfterViewer` (specific service)
4. **Optional "Tüm Fotoğraflar" button** → Full gallery (all categories)

**Rationale**:
- Context-aware: User sees relevant photos
- Flexible: Tüm erişim yolları desteklenir
- Premium feel: Seamless transitions

## Risks / Trade-offs

### Risk 1: Storage Costs
**Mitigation**:
- Thumbnail generation ile bandwidth tasarrufu
- Image compression policies (max 2MB per photo)
- Venue başına fotoğraf limiti (örn: 50 fotoğraf)

### Risk 2: Upload/Load Performance
**Mitigation**:
- Lazy loading (initial load'da sadece hero images)
- Pagination for large galleries
- Progressive image loading (blur placeholder → thumbnail → full)

### Risk 3: Content Moderation
**Mitigation**:
- Venue owner uploads (admin review sürecinde kontrol)
- Future: Automated inappropriate content detection

### Risk 4: Schema Migration
**Mitigation**:
- Backward compatible: `imageUrl` korunur
- Default values: Mevcut venues için `hero_images = [imageUrl]`
- Gradual rollout: Önce yeni venues, sonra mevcut venues migrate edilir

## Migration Plan

### Phase 1: Schema + Data Layer (Week 1)
1. Create `venue_photos` table migration
2. Add `hero_images` column to `venues`
3. Implement `VenuePhoto` model
4. Update `VenueRepository` to fetch gallery data
5. Backfill existing `imageUrl` → `hero_images[0]`

### Phase 2: UI Components (Week 2)
1. Build `VenueHeroCarousel` widget
2. Build `PhotoThumbnailGrid` widget
3. Integrate into venue details screen

### Phase 3: Viewers (Week 3)
1. Implement `PhotoGalleryViewer` with PhotoViewGallery
2. Implement `BeforeAfterViewer` with custom slider
3. Add share/download/like functionality
4. Connect navigation flows

### Phase 4: Optimization (Week 4)
1. Implement thumbnail generation (manual or automated)
2. Add image caching strategy
3. Performance testing + optimization
4. Analytics integration (photo views, interactions)

### Rollback Plan
- Feature flag: `ENABLE_VENUE_GALLERY`
- If issues: Disable flag → Falls back to single `imageUrl` hero
- Database changes are non-breaking (new columns/tables)

## Open Questions

1. **Thumbnail generation**: Manual upload mı yoksa Supabase Edge Function ile otomatik mi?
   - **Recommendation**: Phase 1'de manual, Phase 2'de automated

2. **Photo limits**: Venue başına max kaç fotoğraf?
   - **Recommendation**: 50 fotoğraf limit (adjust based on usage analytics)

3. **Before/After category**: Ayrı bir `BeforeAfterPhoto` model mi yoksa `VenuePhoto` category'si mi?
   - **Decision**: Category kullan, daha esnek (service bağlantısı ile)

4. **Download feature**: Watermark eklensin mi?
   - **Recommendation**: İlk versiyonda watermark yok, feedback'e göre ekle

5. **Analytics**: Hangi metrikleri track edelim?
   - **Recommendation**: Photo views, full-screen opens, before/after comparisons, shares
