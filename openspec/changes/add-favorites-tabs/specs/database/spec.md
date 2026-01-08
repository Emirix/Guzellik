## ADDED Requirements

### Requirement: User Favorites Table
Sistem kullanıcıların favori mekanlarını saklamak için `user_favorites` tablosu içermelidir.

#### Scenario: Table structure
- **WHEN** `user_favorites` tablosu oluşturulur
- **THEN** tablo şu kolonları içermelidir:
  - `id` (UUID, primary key, auto-generated)
  - `user_id` (UUID, foreign key to profiles.id, NOT NULL)
  - `venue_id` (UUID, foreign key to venues.id, NOT NULL)
  - `created_at` (TIMESTAMPTZ, default NOW(), NOT NULL)
- **AND** `(user_id, venue_id)` kombinasyonu UNIQUE olmalıdır
- **AND** `user_id` silindiğinde ilgili favoriler CASCADE ile silinmelidir
- **AND** `venue_id` silindiğinde ilgili favoriler CASCADE ile silinmelidir

#### Scenario: Table indexes
- **WHEN** `user_favorites` tablosu oluşturulur
- **THEN** şu indeksler oluşturulmalıdır:
  - `idx_user_favorites_user` on `user_id`
  - `idx_user_favorites_venue` on `venue_id`
  - `idx_user_favorites_created` on `created_at DESC`
- **AND** indeksler query performansını optimize etmelidir

### Requirement: User Favorites RLS Policies
`user_favorites` tablosu Row Level Security (RLS) ile korunmalıdır.

#### Scenario: RLS enabled
- **WHEN** `user_favorites` tablosu oluşturulur
- **THEN** RLS aktif edilmelidir
- **AND** varsayılan olarak hiçbir kullanıcı erişememelidir

#### Scenario: Users can view own favorites
- **WHEN** kullanıcı kendi favorilerini sorgulamaya çalışır
- **THEN** sadece `user_id = auth.uid()` olan kayıtları görebilmelidir
- **AND** diğer kullanıcıların favorilerini görememelidir

#### Scenario: Users can manage own favorites
- **WHEN** kullanıcı favori ekleme/çıkarma işlemi yapar
- **THEN** sadece kendi `user_id`'si ile işlem yapabilmelidir
- **AND** başka kullanıcıların favorilerini değiştirememelidir

#### Scenario: Unauthenticated access denied
- **WHEN** giriş yapmamış bir kullanıcı favorilere erişmeye çalışır
- **THEN** erişim reddedilmelidir
- **AND** RLS policy tarafından bloklanmalıdır

### Requirement: Favorites Migration
Favoriler özelliği için veritabanı migration dosyası oluşturulmalıdır.

#### Scenario: Migration file created
- **WHEN** migration oluşturulur
- **THEN** dosya adı timestamp ile başlamalıdır (örn: `20260108230000_add_user_favorites.sql`)
- **AND** migration idempotent olmalıdır (birden fazla çalıştırılabilir)
- **AND** `CREATE TABLE IF NOT EXISTS` kullanmalıdır
- **AND** `CREATE INDEX IF NOT EXISTS` kullanmalıdır

#### Scenario: Migration applied successfully
- **WHEN** migration Supabase'e uygulanır
- **THEN** `user_favorites` tablosu oluşturulmalıdır
- **AND** tüm indeksler oluşturulmalıdır
- **AND** RLS policies aktif olmalıdır
- **AND** hata oluşmamalıdır

#### Scenario: Migration rollback
- **WHEN** migration geri alınması gerekirse
- **THEN** `DROP TABLE IF EXISTS user_favorites CASCADE` komutu çalıştırılabilmelidir
- **AND** tüm bağımlı objeler (indeksler, policies) otomatik silinmelidir
- **AND** diğer tablolar etkilenmemelidir
