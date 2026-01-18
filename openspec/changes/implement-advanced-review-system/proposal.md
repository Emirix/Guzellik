# Change: Implement Advanced Review System (Gelişmiş Yorum Sistemi)

## Why
Mevcut yorum sistemi sosyal etkileşim, fotoğraf paylaşımı ve işletme moderasyonu gibi kritik özelliklerden yoksundur. Bu durum platform güvenilirliğini ve kullanıcı bağlılığını sınırlamaktadır.

## What Changes
- `reviews` tablosuna `status`, `business_reply`, `reply_at` ve `helpful_count` alanları eklenecek.
- Kullanıcı yorumlarına maksimum 2 fotoğraf ekleme desteği (Storage + `entity_media` entegrasyonu).
- İşletmeler için yorum onay ve şablon yanıt mekanizması eklenecek.
- Yorumları "Faydalı" olarak işaretleme ve çoklu filtreleme (fotoğraflı, puan vb.) özellikleri eklenecek.

## Impact
- Affected specs: `reviews-and-ratings`, `business-account-management`
- Affected code: `lib/data/models/review_model.dart`, `lib/presentation/widgets/review/`, `lib/presentation/screens/business/review_management_screen.dart`
