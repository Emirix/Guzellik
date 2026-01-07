-- Test Notifications Script
-- Bu scripti Supabase SQL Editor'da çalıştırın

-- Önce mevcut kullanıcı ID'nizi bulalım (auth.users tablosundan)
-- Eğer henüz kullanıcınız yoksa, önce uygulamadan kayıt olun

-- Test bildirimleri ekle
-- NOT: 'YOUR_USER_ID' kısmını kendi user ID'nizle değiştirin
-- User ID'nizi bulmak için: SELECT id, email FROM auth.users;

INSERT INTO notifications (user_id, title, body, type, is_read, created_at, metadata)
VALUES
  -- Fırsat bildirimleri
  (
    'YOUR_USER_ID',
    '🎉 Özel İndirim!',
    'Favori salonunuzda %30 indirim fırsatı! Sadece bugün geçerli.',
    'opportunity',
    false,
    NOW() - INTERVAL '5 minutes',
    '{"venue_id": "1", "discount": 30}'::jsonb
  ),
  (
    'YOUR_USER_ID',
    '💆‍♀️ Yeni Hizmet',
    'Beauty Lounge artık cilt bakımı hizmeti veriyor. Hemen randevu alın!',
    'opportunity',
    false,
    NOW() - INTERVAL '2 hours',
    '{"venue_id": "2", "service": "cilt_bakimi"}'::jsonb
  ),
  (
    'YOUR_USER_ID',
    '⭐ Yakınınızda Yeni Salon',
    'Konumunuza 500m mesafede yeni bir güzellik salonu açıldı!',
    'opportunity',
    false,
    NOW() - INTERVAL '1 day',
    '{"venue_id": "3", "distance": 500}'::jsonb
  ),
  
  -- Sistem bildirimleri
  (
    'YOUR_USER_ID',
    '✅ Randevunuz Onaylandı',
    'Beauty Center ile 15 Ocak 14:00 randevunuz onaylandı.',
    'system',
    true,
    NOW() - INTERVAL '3 days',
    '{"appointment_id": "123", "venue_name": "Beauty Center"}'::jsonb
  ),
  (
    'YOUR_USER_ID',
    '🔔 Randevu Hatırlatması',
    'Yarın saat 14:00''de randevunuz var. Unutmayın!',
    'system',
    false,
    NOW() - INTERVAL '1 hour',
    '{"appointment_id": "124", "reminder_type": "24h_before"}'::jsonb
  ),
  (
    'YOUR_USER_ID',
    '💳 Ödeme Başarılı',
    '250 TL tutarındaki ödemeniz başarıyla alındı. Teşekkürler!',
    'system',
    true,
    NOW() - INTERVAL '5 days',
    '{"payment_id": "pay_123", "amount": 250}'::jsonb
  ),
  (
    'YOUR_USER_ID',
    '🎁 Puan Kazandınız',
    'Son randevunuzdan 50 puan kazandınız! Toplam puanınız: 150',
    'system',
    false,
    NOW() - INTERVAL '6 days',
    '{"points_earned": 50, "total_points": 150}'::jsonb
  ),
  (
    'YOUR_USER_ID',
    '📝 Değerlendirme Bekleniyor',
    'Beauty Lounge''daki deneyiminizi değerlendirin ve 10 puan kazanın!',
    'system',
    false,
    NOW() - INTERVAL '2 days',
    '{"venue_id": "2", "appointment_id": "125"}'::jsonb
  );

-- Eklenen bildirimleri kontrol et
SELECT 
  id,
  title,
  type,
  is_read,
  created_at,
  body
FROM notifications
WHERE user_id = 'YOUR_USER_ID'
ORDER BY created_at DESC;
