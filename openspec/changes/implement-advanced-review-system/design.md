# Architecture Design: Advanced Review System

## Overview
Bu tasarım, mevcut polimorfik `reviews` sistemini sosyal etkileşim ve moderasyon yetenekleriyle genişletmeyi hedefler. Merkeziyetçi bir model (`status` alanı üzerinden) kullanılarak performans ve tutarlılık sağlanacaktır.

## Components

### 1. Database Layer (Supabase)
- **Table: reviews (Modified)**
  - `status`: enum ('pending', 'approved', 'rejected') - Varsayılan: 'pending'.
  - `business_reply`: text - İşletmenin verdiği cevap.
  - `reply_at`: timestamptz - Cevap verilme zamanı.
  - `helpful_count`: integer - Faydalı bulan kullanıcı sayısı.
- **Table: review_reactions (New)**
  - `id`, `user_id`, `review_id`, `created_at`.
  - Kullanıcıların mükerrer beğeni yapmasını önlemek için.
- **Table: entity_media (Modified)**
  - `entity_type` alanına 'review_photo' tipi eklenecek.

### 2. Business Logic (RPC & Triggers)
- `approve_review(review_id, reply_text)`: İşletmenin yorumu onaylaması ve opsiyonel cevap vermesi için.
- `toggle_review_helpful(review_id)`: Kullanıcının bir yorumu faydalı bulup bulmadığını işaretlemesi.
- `get_filtered_reviews(target_type, target_id, filter_type, limit, offset)`: Filtrelenmiş yorumları getiren fonksiyon.

### 3. Frontend Layer (Flutter)
- **ReviewProvider:** Yorum ekleme, beğenme ve filtreleme durumlarını yönetecek.
- **ReviewManagementProvider:** İşletme tarafındaki onay ve yanıt süreçlerini yönetecek.
- **UI Widgets:**
  - `ReviewSubmissionForm`: Fotoğraf seçimi ve puanlama.
  - `ReviewCard`: Fotoğraf galerisi ve işletme yanıtı gösterimi.
  - `ReviewFilterBar`: Yatay kaydırılabilir filtre çipleri.

## Data Flow
1. Kullanıcı `ReviewSubmissionForm` üzerinden yorumu gönderir.
2. Fotoğraflar `Storage`'a yüklenir, metadata `entity_media`'ya, yorum `reviews` tablosuna `pending` statüsünde kaydedilir.
3. İşletme paneli (Realtime veya Refresh) yeni yorumu "Onay Bekleyenler" listesinde gösterir.
4. İşletme `approve_review` RPC'sini çağırır.
5. Yorum `approved` olur ve tüm kullanıcılara açık hale gelir.

## Trade-offs

### Option 1: Integrated Model (Chosen)
- **Pros:** Tek bir tablo üzerinden hızlı sorgulama, düşük karmaşıklık.
- **Cons:** Tablo genişlemesi (doğru indekslerle yönetilebilir).
- **Reason:** Mevcut mimariyi koruyarak en hızlı ve stabil çözümü sunar.

### Option 2: Modular System
- **Pros:** Maksimum esneklik, her etkileşim tipi (foto, beğeni, video) için ayrı tablo.
- **Cons:** Yüksek JOIN maliyeti, State yönetiminde zorluk.
- **Reason:** Şu anki ihtiyaçlar için aşırı mühendislik (over-engineering) kaçınıldı.

## Migration Strategy
- Mevcut yorumların `status` alanı 'approved' olarak güncellenecek.
- `reviews` tablosuna yeni kolonlar eklenecek.
- `entity_media` için 'review_photo' kısıtlamaları ve RLS politikaları güncellenecek.
