# Sync Venue Ratings - Tasks

## Implementation Tasks

- [x] **1. Migration Oluştur**: `20260110110000_sync_venue_ratings.sql` dosyasını oluştur
  - Tüm venues için rating ve review_count'u reviews tablosundan hesapla
  - Validation: SQL syntax doğrulaması

- [x] **2. Migration Uygula**: Supabase'de migration'ı çalıştır
  - `supabase db push` veya SQL Editor üzerinden manuel
  - Validation: Venues tablosunda rating değerlerinin güncellendiğini kontrol et
  - **NOT**: Kullanıcı tarafından SQL Editor üzerinden manuel uygulandı.

- [x] **3. Manuel Test**: Uygulamada değerleri doğrula
  - Mekan listelerinde rating/yorum sayısı kontrolü
  - Mekan detay sayfasında gerçek yorumların görünmesi
  - Yeni yorum ekleyince değerlerin güncellenmesi

## Parallelizable Work

- Task 1 tek başına yapılabilir (migration dosyası oluşturma)
- Task 2 ve 3 sıralı olmalı

## Dependencies

- Supabase erişimi gerekli
- Mevcut `trigger_update_venue_rating` trigger'ının çalışır durumda olması
