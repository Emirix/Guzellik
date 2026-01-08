## Context

Favoriler özelliği, kullanıcıların mekanları iki farklı şekilde kaydetmesine olanak tanır:

1. **Favoriler (Bookmarks)**: Kullanıcının beğendiği ve daha sonra tekrar bakmak istediği mekanlar. Bu, pasif bir kaydetme işlemidir ve bildirim gerektirmez.

2. **Takip Etme (Following)**: Kullanıcının aktif olarak takip ettiği ve güncellemelerinden haberdar olmak istediği mekanlar. Bu, mevcut `follows` tablosu ile yönetilmektedir ve bildirim sistemi ile entegredir.

Bu iki özellik farklı kullanım senaryolarına hitap eder ve kullanıcı deneyimini zenginleştirir.

## Goals / Non-Goals

### Goals
- Favoriler ve takip edilen mekanları ayrı sekmelerde göstermek
- Kullanıcıların her iki listeyi kolayca yönetebilmesini sağlamak
- Uygulama tasarım diline uygun premium bir sekme arayüzü oluşturmak
- Performanslı ve responsive bir liste görünümü sağlamak

### Non-Goals
- Favori koleksiyonları veya klasörleme sistemi (gelecekte eklenebilir)
- Favorileri paylaşma özelliği (gelecekte eklenebilir)
- Favorileri sıralama/filtreleme (ilk versiyonda sadece tarih sıralı liste)

## Decisions

### Decision 1: Ayrı Tablo Kullanımı
**Karar**: `user_favorites` için ayrı bir tablo oluşturulacak, `follows` tablosu değiştirilmeyecek.

**Neden**: 
- Favoriler ve takip etme farklı iş mantıklarına sahip
- `follows` tablosu bildirim sistemi ile entegre, bu ilişkiyi bozmak istemiyoruz
- Gelecekte favorilere özel özellikler eklenebilir (notlar, kategoriler vb.)

**Alternatifler**:
- `follows` tablosuna `is_favorite` boolean alanı eklemek → Reddedildi: İki farklı konsepti karıştırır
- Tek bir tablo ile `type` enum kullanmak → Reddedildi: Gereksiz karmaşıklık

### Decision 2: TabBar Widget Kullanımı
**Karar**: Flutter'ın native `TabBar` ve `TabBarView` widget'ları kullanılacak.

**Neden**:
- Material Design standartlarına uygun
- Gesture desteği (swipe) built-in
- Performanslı ve test edilmiş
- Özelleştirilebilir (renk, indicator, vb.)

**Alternatifler**:
- Custom tab implementation → Reddedildi: Gereksiz iş yükü
- PageView + custom buttons → Reddedildi: Daha az kullanıcı dostu

### Decision 3: Lazy Loading
**Karar**: İlk versiyonda tüm favoriler/takipler tek seferde yüklenecek, pagination eklenmeyecek.

**Neden**:
- Çoğu kullanıcının 10-50 arası favori/takip olması bekleniyor
- Basit implementasyon
- Daha hızlı geliştirme

**Gelecek İyileştirme**: Kullanıcı başına 100+ favori olursa pagination eklenebilir.

### Decision 4: UI Tasarım
**Karar**: Sekme göstergesi (indicator) soft pink renkte, seçili sekme bold font ile vurgulanacak.

**Tasarım Detayları**:
- Tab bar background: `AppColors.white`
- Active tab text: `AppColors.primary` (bold)
- Inactive tab text: `AppColors.gray600`
- Indicator: `AppColors.primary` (2px height)
- Tab bar elevation: 0 (flat design)
- Venue cards: Mevcut `SearchResultCard` benzeri tasarım

## Data Model

### user_favorites Table Schema
```sql
CREATE TABLE user_favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  venue_id UUID REFERENCES venues(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(user_id, venue_id)
);

CREATE INDEX idx_user_favorites_user ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_venue ON user_favorites(venue_id);
CREATE INDEX idx_user_favorites_created ON user_favorites(created_at DESC);
```

### RLS Policies
```sql
-- Users can view their own favorites
CREATE POLICY "Users can view own favorites" 
  ON user_favorites FOR SELECT 
  USING (auth.uid() = user_id);

-- Users can manage their own favorites
CREATE POLICY "Users can manage own favorites" 
  ON user_favorites FOR ALL 
  USING (auth.uid() = user_id);
```

## API Methods

### VenueRepository
```dart
// Favori ekle
Future<void> addFavorite(String venueId);

// Favoriyi kaldır
Future<void> removeFavorite(String venueId);

// Favori mekanları getir
Future<List<Venue>> getFavoriteVenues();

// Mekanın favori olup olmadığını kontrol et
Future<bool> isFavorite(String venueId);

// Takip edilen mekanları getir (zaten var mı kontrol edilecek)
Future<List<Venue>> getFollowedVenues();
```

## Component Hierarchy

```
FavoritesScreen (StatefulWidget)
├── CustomHeader (title: "Favorilerim")
├── TabBar
│   ├── Tab("Favoriler")
│   └── Tab("Takip Ettiklerim")
└── TabBarView
    ├── FavoritesTab
    │   ├── ListView.builder (if has favorites)
    │   └── EmptyState (if no favorites)
    └── FollowingTab
        ├── ListView.builder (if has following)
        └── EmptyState (if no following)
```

## Risks / Trade-offs

### Risk 1: Kullanıcı Karmaşası
**Risk**: Kullanıcılar favoriler ve takip etme arasındaki farkı anlamayabilir.

**Mitigation**: 
- Her sekmenin altında kısa açıklayıcı metin ekle
- Boş state'lerde özelliği açıklayan mesajlar göster
- İkonlar kullan (kalp için favoriler, bildirim için takip)

### Risk 2: Performans
**Risk**: Çok sayıda favori/takip olan kullanıcılarda yavaşlama.

**Mitigation**:
- İlk versiyonda kabul edilebilir (100'e kadar sorun yok)
- Gelecekte pagination eklenebilir
- Venue card'lar optimize edilmiş widget'lar kullanacak

### Trade-off: Tek Tablo vs İki Tablo
**Trade-off**: İki ayrı tablo daha fazla veritabanı query gerektirir.

**Kabul**: Kod netliği ve esneklik için bu trade-off kabul edilebilir. Query sayısı minimal olacak (sayfa açılışında 2 query).

## Migration Plan

### Phase 1: Database Setup
1. Migration dosyası oluştur
2. Supabase'e uygula
3. RLS policies test et

### Phase 2: Backend Implementation
1. Repository metodları ekle
2. Unit test'ler yaz
3. Supabase ile entegrasyonu test et

### Phase 3: Frontend Implementation
1. FavoritesProvider oluştur
2. FavoritesScreen'i yeniden tasarla
3. Sekme UI'ını implement et
4. Boş state'leri ekle

### Phase 4: Integration
1. Venue detay sayfasına favori butonu ekle
2. Diğer sayfalara favori butonları ekle (opsiyonel)
3. End-to-end test

### Rollback Plan
Eğer bir sorun olursa:
1. Migration geri alınabilir (DROP TABLE user_favorites)
2. Eski FavoritesScreen placeholder'a geri dönülebilir
3. Kullanıcı verisi kaybolmaz (follows tablosu değişmedi)

## Open Questions

- ✅ Favoriler ve takip etme arasındaki fark net mi? → **Evet, açıklandı**
- ✅ Tasarım referansı var mı? → **Hayır, uygulama stiline uygun tasarlanacak**
- ⏳ Venue card'larda favori butonu nerede olmalı? → **Implementation sırasında karar verilecek**
- ⏳ Favorileri sıralama seçeneği gerekli mi? → **İlk versiyonda hayır, gelecekte eklenebilir**
