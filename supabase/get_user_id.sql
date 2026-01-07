-- Kullanıcı ID'nizi bulmak için bu scripti çalıştırın
-- Supabase Dashboard > SQL Editor'da çalıştırın

SELECT 
  id as user_id,
  email,
  created_at,
  raw_user_meta_data->>'full_name' as full_name
FROM auth.users
ORDER BY created_at DESC;

-- Çıktıda gördüğünüz 'user_id' değerini kopyalayın
-- ve test_notifications.sql dosyasındaki 'YOUR_USER_ID' ile değiştirin
