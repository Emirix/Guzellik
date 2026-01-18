# Implementation Tasks: Advanced Review System

## Phase 1: Database & Backend (Supabase)
- [x] T1: `reviews` tablosunu genişleten SQL migrasyonunu oluştur.
  - Genişletilecek alanlar: `status`, `business_reply`, `reply_at`, `helpful_count`.
  - Validation: Supabase üzerinde tablo yapısını kontrol et.
- [x] T2: `review_reactions` tablosunu ve RLS politikalarını oluştur.
  - Validation: Farklı kullanıcıların tepki verip veremediğini test et.
- [x] T3: `toggle_review_helpful` RPC fonksiyonunu yaz.
  - Validation: Beğeni sayısının doğru artıp azaldığını doğrula.
- [x] T4: `approve_review` RPC fonksiyonunu yaz.
  - Validation: Statü değişikliğini ve cevap metninin kaydedildiğini doğrula.
- [x] T5: `get_filtered_reviews` RPC fonksiyonunu yaz.
  - Validation: Filtre tiplerine (yeni, puan, fotoğraflı vb.) göre doğru veri geldiğini test et.

## Phase 2: Core Models & Providers (Flutter)
- [x] T6: `ReviewModel` sınıfını yeni alanlarla güncelle.
  - Validation: Serileştirme (JSON parsing) testleri.
- [x] T7: `ReviewRepository` katmanına yeni RPC çağrılarını ekle.
  - Validation: Unit testlerle API entegrasyonunu doğrula.
- [x] T8: `ReviewProvider` (Riverpod/Provider) mantığını kur.
  - Validation: State değişimlerininUI'a yansımasını kontrol et.

## Phase 3: Frontend UI - User Side
- [x] T9: `ReviewSubmissionSheet` bileşenini tasarla ve foto yükleme entegrasyonu yap.
  - Validation: Maksimum 2 fotoğraf sınırını test et.
- [x] T10: `ReviewFilterBar` bileşenini oluştur.
  - Validation: Yatay kaydırma ve filtre seçim durumlarını doğrula.
- [x] T11: `ReviewCard` bileşenini fotoğraflar ve işletme yanıtı için güncelle.
  - Validation: Fotoğrafların doğru boyutta ve tıklandığında tam ekran açıldığını doğrula.

## Phase 4: Frontend UI - Business Side
- [x] T12: İşletme paneline "Yorum Yönetimi" sayfasını ekle.
  - Validation: Onay bekleyen yorumların listelenmesini sağla.
- [x] T13: Şablon yanıt seçici ve onay modalını uygula.
  - Validation: Şablon seçildiğinde metin kutusuna dolmasını ve onay işlemini test et.

## Phase 5: Testing & Polishing
- [ ] T14: Tüm akışı (Yorum yap -> Onayla -> Görüntüle) test et.
- [ ] T15: UI/UX detaylarını (BlurHash, loading stateleri, hata mesajları) iyileştir.
