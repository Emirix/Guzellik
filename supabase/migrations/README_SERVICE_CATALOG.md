# Hizmet Katalog Sistemi - Migration Talimatları

## Genel Bakış

Bu migration, uygulamanıza kapsamlı bir hizmet katalog sistemi ekler. Kullanıcılar artık:
- 140+ önceden tanımlanmış hizmetten arayarak mekan bulabilir
- Mekanlar sunduğu hizmetleri seçip profillerinde gösterebilir
- Hizmetler kategorilere göre filtrelenebilir

## Veritabanı Yapısı

### 1. `service_categories` Tablosu
Tüm mevcut hizmetlerin ana katalogu (140+ hizmet).

**Kolonlar:**
- `id`: UUID (Primary Key)
- `name`: Hizmet adı (örn: "Saç Kesimi (Kadın)")
- `category`: Ana kategori (örn: "Kuaför - Kadın")
- `description`: 2 cümlelik hizmet açıklaması
- `average_duration_minutes`: Ortalama süre (dakika)
- `icon`: İkon adı (opsiyonel)
- `created_at`: Oluşturulma tarihi

### 2. `venue_services` Tablosu
Mekanların hangi hizmetleri sunduğunu gösteren junction table.

**Kolonlar:**
- `id`: UUID (Primary Key)
- `venue_id`: Mekan ID (Foreign Key → venues)
- `service_category_id`: Hizmet kategorisi ID (Foreign Key → service_categories)
- `custom_price`: Mekan özel fiyatı (opsiyonel)
- `custom_duration_minutes`: Mekan özel süresi (opsiyonel)
- `is_available`: Hizmetin aktif olup olmadığı
- `created_at`: Oluşturulma tarihi

### 3. `services` Tablosu (Güncellendi)
Hizmetlerin fotoğraf, uzman bilgisi gibi detaylarını içerir.

**Kolonlar:**
- `id`: UUID (Primary Key)
- `venue_service_id`: İlişkili venue_service (Foreign Key → venue_services)
- `name`: Gösterim adı (mekan tarafından özelleştirilebilir)
- `description`: Detaylı açıklama
- `before_photo_url`: Öncesi fotoğrafı
- `after_photo_url`: Sonrası fotoğrafı
- `expert_name`: Uzman adı
- `created_at`: Oluşturulma tarihi

## Hizmet Kategorileri

Migration aşağıdaki kategorilerde 140+ hizmet ekler:

### 💇 Kuaför
- **Kadın**: 17 hizmet (Saç Kesimi, Fön, Boyama, Balyaj, Keratin, vs.)
- **Erkek**: 6 hizmet (Saç Kesimi, Traş, Sakal, vs.)

### 💅 Tırnak
- **Manikür**: 8 hizmet (Klasik, Spa, Jel Tırnak, Kalıcı Oje, Nail Art, vs.)
- **Pedikür**: 6 hizmet (Klasik, Spa, Nasır Tedavisi, vs.)

### 🧖 Cilt Bakımı
- **Yüz**: 16 hizmet (Hydrafacial, Dermapen, Peeling, Leke Tedavisi, vs.)
- **Vücut**: 5 hizmet (Peeling, Masaj, Selülit, vs.)

### 💆 Masaj
10 hizmet (İsveç, Tayland, Hot Stone, Aromaterapi, vs.)

### 🧴 Epilasyon
- **Ağda**: 13 hizmet (Bacak, Bikini, Brazilian, vs.)
- **Lazer**: 12 hizmet (Bacak, Bikini, Brazilian, vs.)

### 👁️ Kaş & Kirpik
11 hizmet (Kaş Tasarım, Microblading, Kirpik Lifting, Laminasyon, vs.)

### 🌟 Özel Paket & Tedavi
12 hizmet (Gelin/Nişan Paketi, RF, PRP, Mezoterapi, vs.)

### 🕌 Hamam & Spa
6 hizmet (Türk Hamamı, Kese-Köpük, Sauna, vs.)

### 💄 Makyaj
7 hizmet (Gelin, Nişan, Smokey, Kalıcı Makyaj, vs.)

### 🦶 El & Ayak Bakımı
5 hizmet (Parafin, Nasır Tedavisi, Topuk Çatlağı, vs.)

## Yardımcı Fonksiyonlar

### `get_venue_services(venue_id)`
Bir mekanın tüm hizmetlerini detaylı şekilde getirir.

```sql
SELECT * FROM get_venue_services('venue-uuid-here');
```

**Dönen Alanlar:**
- id, venue_id, name, category
- price (custom_price veya varsayılan)
- duration (custom_duration veya average)
- description, before_photo_url, after_photo_url, expert_name

### `search_venues_by_service(service_category_id)`
Belirli bir hizmeti sunan tüm mekanları bulur.

```sql
SELECT * FROM search_venues_by_service('service-category-uuid-here');
```

## View'ler

### `popular_services`
En popüler hizmetleri (en çok mekanın sunduğu) gösterir.

```sql
SELECT * FROM popular_services LIMIT 20;
```

### `featured_venues`
Yüksek puanlı öne çıkan mekanları gösterir (rating >= 4.0).

```sql
SELECT * FROM featured_venues LIMIT 10;
```

## Migration'ı Çalıştırma

```bash
# Supabase CLI ile
supabase db push

# Veya manuel olarak SQL dosyalarını sırayla çalıştırın:
# 1. supabase/migrations/20260107060000_create_service_catalog.sql
# 2. supabase/migrations/20260107060100_update_venues_table.sql
```

## Dart Modelleri

Yeni modeller eklendi:
- `lib/data/models/service_category.dart`
- `lib/data/models/venue_service.dart`
- `lib/data/models/service.dart` (güncellendi)

## Örnek Kullanım

### Mekan Sahibi: Hizmet Ekleme
```dart
// 1. Hizmet kategorisini seç
final categories = await supabase
  .from('service_categories')
  .select()
  .eq('category', 'Kuaför - Kadın');

// 2. Mekanına ekle
await supabase.from('venue_services').insert({
  'venue_id': venueId,
  'service_category_id': categories[0]['id'],
  'custom_price': 150.0,
  'custom_duration_minutes': 45,
  'is_available': true,
});

// 3. Detaylarını ekle (opsiyonel)
await supabase.from('services').insert({
  'venue_service_id': venueServiceId,
  'name': 'Kadın Saç Kesimi - Uzman Ayşe',
  'description': 'Premium saç kesimi hizmeti',
  'expert_name': 'Ayşe Yılmaz',
  'before_photo_url': '...',
  'after_photo_url': '...',
});
```

### Kullanıcı: Hizmet Arama
```dart
// Hizmet kategorisini bul
final serviceCategory = await supabase
  .from('service_categories')
  .select()
  .eq('name', 'Saç Kesimi (Kadın)')
  .single();

// Bu hizmeti sunan mekanları getir
final venues = await supabase
  .rpc('search_venues_by_service', params: {
    'p_service_category_id': serviceCategory['id']
  });
```

### Mekan Hizmetlerini Listeleme
```dart
final services = await supabase
  .rpc('get_venue_services', params: {
    'p_venue_id': venueId
  });

// Kategorilere göre grupla
Map<String, List> groupedServices = {};
for (var service in services) {
  final category = service['category'];
  if (!groupedServices.containsKey(category)) {
    groupedServices[category] = [];
  }
  groupedServices[category]!.add(service);
}
```

## Önemli Notlar

1. **Eski services tablosu**: Migration eski `services` tablosunu siler ve yeni yapıyla yeniden oluşturur. Mevcut veriniz varsa yedek alın!

2. **Row Level Security**: Tüm tablolar RLS korumalı:
   - Herkes service_categories'i görebilir (read-only)
   - Herkes venue_services ve services'i görebilir
   - Sadece mekan sahipleri kendi hizmetlerini yönetebilir

3. **Indexes**: Performans için indexler eklendi:
   - venue_services: venue_id, service_category_id
   - services: venue_service_id
   - service_categories: category

4. **Venue Güncellemeleri**: venues tablosuna eksik kolonlar eklendi:
   - latitude, longitude (otomatik hesaplanır)
   - rating, review_count (trigger ile otomatik güncellenir)
   - is_active, features

## Sorun Giderme

**Hata: column "latitude" already exists**
- Normal, ALTER TABLE IF NOT EXISTS kullanıldı

**Hata: function get_venue_services already exists**
- CREATE OR REPLACE kullanıldı, sorun değil

**Migration sırası önemli mi?**
- Evet! Önce service_catalog, sonra update_venues_table çalıştırın

## Sonraki Adımlar

1. Migration'ları çalıştırın
2. UI'da hizmet seçimi için dropdown/search ekleyin
3. Filtreleme sistemine hizmet filtresi ekleyin
4. Mekan profilinde hizmetleri gösterin
5. Popüler hizmetler bölümünü ana sayfaya ekleyin
