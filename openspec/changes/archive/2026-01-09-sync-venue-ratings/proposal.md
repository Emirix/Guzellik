# Sync Venue Ratings Proposal

## Why

Mekan listelerinde (arama sonuçları, öne çıkanlar, yakındakiler) gösterilen **değerlendirme puanı** ve **yorum sayısı** gerçek verileri yansıtmıyor. Statik/varsayılan değerler gösteriliyor ancak mekan detay sayfasına girildiğinde gerçek yorumlar bulunamıyor veya sayı uyuşmuyor.

### Root Cause Analysis

1. **`venues.rating`** ve **`venues.review_count`** sütunları `20260107060100_update_venues_table.sql` migration'ında eklendi
2. **`trigger_update_venue_rating`** aynı migration'da tanımlandı - `reviews` tablosunda INSERT/UPDATE/DELETE olduğunda venues tablosunu güncelliyor
3. **Sorun**: Seed data (`seed.sql`) içinde yorumlar INSERT edilmiş, ancak:
   - Trigger migration'dan önce seed çalıştırılmış olabilir
   - Veya migration sonrası venues tablosundaki rating/review_count değerleri hiçbir zaman senkronize edilmemiş
4. **Sonuç**: Veritabanındaki `venues.rating = 0` ve `venues.review_count = 0` durumunda kalmış

## Proposed Solution

Tek seferlik bir senkronizasyon migration'ı oluşturarak mevcut tüm yorumlardan rating/review_count değerlerini hesaplayacağız. Trigger zaten mevcut olduğu için gelecekteki yorumlar otomatik olarak senkronize olacak.

> [!NOTE]
> Cron job gerekli değil. Mevcut trigger mekanizması yeterli - sadece mevcut verilerin bir kez senkronize edilmesi yeterli.

## What Changes

### Database Layer

#### [NEW] [20260110110000_sync_venue_ratings.sql](file:///c:/Users/Emir/Documents/Proje/Guzellik/supabase/migrations/20260110110000_sync_venue_ratings.sql)

Mevcut tüm yorumlardan `venues.rating` ve `venues.review_count` değerlerini hesaplayan tek seferlik migration:

```sql
-- Tüm venue'ların rating ve review_count değerlerini
-- reviews tablosundan hesaplayarak güncelle
UPDATE venues v SET
  rating = COALESCE(
    (SELECT AVG(r.rating) FROM reviews r WHERE r.venue_id = v.id),
    0
  ),
  review_count = (
    SELECT COUNT(*) FROM reviews r WHERE r.venue_id = v.id
  );
```

---

### No Code Changes Required

Flutter tarafında herhangi bir değişiklik gerekmiyor çünkü:
- `Venue.fromJson()` zaten `rating` ve `review_count` alanlarını parse ediyor
- UI widget'ları (`venue.rating`, `venue.ratingCount`) doğru şekilde gösteriyor
- Sadece veritabanı değerleri düzeltilmeli

## Verification Plan

### Automated Tests

1. Migration'ı çalıştır:
   ```bash
   supabase db push
   ```

2. Değerlerin güncellendiğini doğrula (Supabase SQL Editor):
   ```sql
   SELECT id, name, rating, review_count, 
          (SELECT COUNT(*) FROM reviews r WHERE r.venue_id = v.id) as actual_count,
          (SELECT AVG(rating) FROM reviews r WHERE r.venue_id = v.id) as actual_rating
   FROM venues v
   WHERE EXISTS (SELECT 1 FROM reviews WHERE venue_id = v.id);
   ```

### Manual Verification

1. Uygulamayı yeniden başlat
2. Ana sayfa veya arama sonuçlarında mekan kartlarını kontrol et
3. Rating ve yorum sayısının gerçek değerleri gösterdiğini doğrula
4. Mekan detay sayfasına gir ve yorumların gösterildiğini kontrol et
5. Yeni bir yorum ekle ve değerlerin güncellendiğini doğrula
