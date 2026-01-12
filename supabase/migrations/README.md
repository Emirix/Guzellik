# Database Migrations - Admin Panel

Bu klasördeki migration dosyaları admin panel özelliklerini desteklemek için gerekli veritabanı değişikliklerini içerir.

## Migration Dosyaları

1. **20260111_create_specialists_table.sql**
   - `specialists` tablosunu oluşturur
   - RLS politikalarını ekler
   - İndeksleri ve trigger'ları oluşturur

2. **20260111_update_admin_tables.sql**
   - `venue_services` tablosuna custom alanlar ekler
   - `venue_photos` tablosuna hero image ve sort_order ekler
   - `campaigns` tablosunu günceller
   - Tüm tablolar için RLS politikalarını günceller

3. **20260111_create_storage_buckets.sql**
   - `venue-gallery` bucket'ını oluşturur (5MB limit)
   - `specialists` bucket'ını oluşturur (2MB limit)
   - `campaigns` bucket'ını oluşturur (5MB limit)
   - Storage RLS politikalarını ekler

## Migration'ları Çalıştırma

### Yöntem 1: Supabase Dashboard (Önerilen)

1. [Supabase Dashboard](https://supabase.com/dashboard)'a gidin
2. Projenizi seçin: `lhvvhxlqwqxbcvvbhfgw`
3. Sol menüden **SQL Editor**'ü açın
4. **New Query** butonuna tıklayın
5. Migration dosyalarını sırayla kopyalayıp çalıştırın:
   - Önce `20260111_create_specialists_table.sql`
   - Sonra `20260111_update_admin_tables.sql`
   - En son `20260111_create_storage_buckets.sql`
6. Her dosya için **Run** butonuna tıklayın

### Yöntem 2: Supabase CLI

```bash
# Supabase CLI kurulu değilse:
npm install -g supabase

# Migration'ları çalıştır
supabase db push
```

### Yöntem 3: MCP Tool (Eğer yetki varsa)

```
mcp_supabase-mcp-server_apply_migration ile her migration dosyasını sırayla çalıştırın
```

## Doğrulama

Migration'lar başarıyla çalıştırıldıktan sonra aşağıdakileri kontrol edin:

### Tablolar
```sql
-- specialists tablosunu kontrol et
SELECT * FROM specialists LIMIT 1;

-- venue_services yeni kolonları kontrol et
SELECT custom_name, custom_description, is_active, sort_order 
FROM venue_services LIMIT 1;

-- venue_photos yeni kolonları kontrol et
SELECT is_hero_image, sort_order 
FROM venue_photos LIMIT 1;

-- campaigns tablosunu kontrol et
SELECT title, discount_percentage, is_active 
FROM campaigns LIMIT 1;
```

### Storage Buckets
```sql
-- Bucket'ları kontrol et
SELECT id, name, public, file_size_limit 
FROM storage.buckets 
WHERE id IN ('venue-gallery', 'specialists', 'campaigns');
```

### RLS Policies
```sql
-- Politikaları kontrol et
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('specialists', 'venue_services', 'venue_photos', 'campaigns')
ORDER BY tablename, policyname;
```

## Rollback (Geri Alma)

Eğer bir sorun olursa, aşağıdaki komutlarla geri alabilirsiniz:

```sql
-- specialists tablosunu sil
DROP TABLE IF EXISTS specialists CASCADE;

-- Eklenen kolonları kaldır (DİKKAT: Veri kaybı olabilir!)
ALTER TABLE venue_services 
  DROP COLUMN IF EXISTS custom_name,
  DROP COLUMN IF EXISTS custom_description,
  DROP COLUMN IF EXISTS custom_image_url,
  DROP COLUMN IF EXISTS price,
  DROP COLUMN IF EXISTS duration_minutes,
  DROP COLUMN IF EXISTS is_active,
  DROP COLUMN IF EXISTS sort_order;

-- Storage bucket'ları sil
DELETE FROM storage.buckets WHERE id IN ('venue-gallery', 'specialists', 'campaigns');
```

## Notlar

- ⚠️ **Önemli**: Migration'ları sırayla çalıştırın
- ✅ Her migration'dan sonra hata mesajlarını kontrol edin
- 📝 Production'da çalıştırmadan önce test ortamında deneyin
- 🔒 RLS politikaları otomatik olarak etkinleştirilir
- 📸 Storage bucket'ları public olarak ayarlanmıştır (herkes okuyabilir, sadece sahipler yazabilir)

## Sorun Giderme

### "relation already exists" hatası
- Bu normal, migration zaten çalıştırılmış demektir
- `IF NOT EXISTS` ve `ON CONFLICT DO NOTHING` kullanıldığı için güvenle tekrar çalıştırabilirsiniz

### "permission denied" hatası
- Supabase hesabınızın yeterli yetkisi olmayabilir
- Dashboard üzerinden manuel olarak çalıştırmayı deneyin

### Storage bucket oluşturulamıyor
- Dashboard'dan manuel olarak oluşturun:
  1. Storage > Create new bucket
  2. Bucket adı: `venue-gallery`, `specialists`, veya `campaigns`
  3. Public bucket: ✅ Evet
  4. File size limit: 5MB (gallery/campaigns) veya 2MB (specialists)
  5. Allowed MIME types: `image/jpeg, image/png, image/webp`
