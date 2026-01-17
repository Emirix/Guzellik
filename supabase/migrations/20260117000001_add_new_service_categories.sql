-- Add new service categories for Hair, Nails, and Makeup
INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, icon, venue_category_id)
VALUES 
-- Kuaförler (Renklendirme)
('Röfle', 'Renklendirme', 'Saçın belirli tutamlarının renginin açılması işlemi.', 180, 'brush', 'd89c9e27-e239-49a3-b141-3333aa5efab8'),
('Baleyaj', 'Renklendirme', 'Saç uçlarına ve boylarına uygulanan doğal görünümlü ışıltı işlemi.', 150, 'brush', 'd89c9e27-e239-49a3-b141-3333aa5efab8'),
('Ombre & Sombre', 'Renklendirme', 'Saç diplerinden uçlarına doğru açılan renk geçişi işlemi.', 180, 'brush', 'd89c9e27-e239-49a3-b141-3333aa5efab8'),
('Facelight', 'Renklendirme', 'Yüz hattını ön plana çıkaran ön saç tutamlarını aydınlatma işlemi.', 120, 'brush', 'd89c9e27-e239-49a3-b141-3333aa5efab8'),
('Freelight', 'Renklendirme', 'Saça doğal güneş ışıltısı veren serbest el boyama tekniği.', 120, 'brush', 'd89c9e27-e239-49a3-b141-3333aa5efab8'),
('Kişisel Renklendirme', 'Renklendirme', 'Kişinin ten rengine ve stiline özel renk danışmanlığı ve uygulama.', 60, 'color_lens', 'd89c9e27-e239-49a3-b141-3333aa5efab8'),

-- Kuaförler (Saç Bakımı & Onarım)
('Keratin Bakımı', 'Saç Bakımı & Onarım', 'Yıpranmış saçları onaran ve parlaklık veren yoğun keratin yüklemesi.', 90, 'spa', 'd89c9e27-e239-49a3-b141-3333aa5efab8'),
('Brezilya Fönü', 'Saç Bakımı & Onarım', 'Saçları düzleştiren ve kabarık görünümü gideren kalıcı fön işlemi.', 180, 'auto_fix_high', 'd89c9e27-e239-49a3-b141-3333aa5efab8'),

-- Tırnak Stüdyoları (Manikür İşlemleri)
('Tırnak Bakım', 'Manikür İşlemleri', 'Tırnak temizliği, şekillendirme ve bakım uygulaması.', 45, 'clean_hands', '24aaaa57-4874-48f2-912a-bc8d80d94590'),

-- Güzellik Salonu (Makyaj Uygulamaları)
('Özel Gün Makyajı', 'Makyaj Uygulamaları', 'Düğün, nişan ve özel davetler için profesyonel makyaj uygulaması.', 60, 'face_retouching_natural', '83c4ea6e-9f0d-4eed-b60c-a4d2e0aa9602'),
('Porselen Makyaj', 'Makyaj Uygulamaları', 'Yüksek kapatıcılık ve uzun süre kalıcılık sağlayan profesyonel porselen makyaj.', 90, 'face_3', '83c4ea6e-9f0d-4eed-b60c-a4d2e0aa9602')
ON CONFLICT (id) DO NOTHING; -- Using ID if it was fixed, but we are using default gen_random_uuid(). 
-- Actually, ON CONFLICT (name, venue_category_id) would be better if we had a unique constraint there.
-- For now, this SQL file is just for documentation/version control since I already applied them via MCP.
