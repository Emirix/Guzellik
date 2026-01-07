-- Seed data for Güzellik Platformu

-- 1. Create a dummy profile (since we need an owner for venues)
DO $$
DECLARE
    dummy_owner_id UUID := '00000000-0000-0000-0000-000000000000';
    user1_id UUID := '11111111-1111-1111-1111-111111111111';
    user2_id UUID := '22222222-2222-2222-2222-222222222222';
    user3_id UUID := '33333333-3333-3333-3333-333333333333';
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url)
    VALUES 
    (dummy_owner_id, 'Test İşletmeci', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Owner'),
    (user1_id, 'Ayşe Yılmaz', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ayse'),
    (user2_id, 'Mehmet Demir', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Mehmet'),
    (user3_id, 'Zeynep Kaya', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Zeynep')
    ON CONFLICT (id) DO NOTHING;
END $$;

-- 2. Insert Venues with Rich Data (Expert Team & Working Hours)
INSERT INTO public.venues (id, name, description, address, location, is_verified, is_preferred, is_hygienic, owner_id, expert_team, working_hours, payment_options, features, accessibility, social_links)
VALUES 
(
    '11111111-1111-1111-1111-111111111111', 
    'Rose Güzellik Salonu', 
    'Şişli''nin kalbinde profesyonel hizmetler. Saç tasarımından cilt bakımına kadar geniş bir yelpazede hizmet sunuyoruz. Deneyimli kadromuzla kendinizi özel hissedin.', 
    'Şişli, İstanbul', 
    ST_SetSRID(ST_MakePoint(28.9872, 41.0601), 4326)::geography, 
    true, true, true, 
    '00000000-0000-0000-0000-000000000000',
    '[
        {"id": "exp1", "name": "Selin Y.", "title": "Saç Tasarım Uzmanı", "specialty": "Saç", "rating": 4.9, "photo_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=Selin"},
        {"id": "exp2", "name": "Burcu K.", "title": "Makyaj Artisti", "specialty": "Makyaj", "rating": 4.8, "photo_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=Burcu"}
    ]'::jsonb,
    '{"monday": "09:00 - 20:00", "tuesday": "09:00 - 20:00", "wednesday": "09:00 - 20:00", "thursday": "09:00 - 20:00", "friday": "09:00 - 20:00", "saturday": "10:00 - 19:00", "sunday": "Kapalı"}'::jsonb,
    '["Nakit", "Kredi Kartı", "Havale"]'::jsonb,
    '["Wi-Fi", "Ücretsiz Çay/Kahve", "Randevusuz"]'::jsonb,
    '{"parking": "Vale Mevcut", "wheelchair": "Uygun", "wifi": "Ücretsiz"}'::jsonb,
    '{"phone": "+902121234567", "instagram": "roseguzellik"}'::jsonb
),
(
    '22222222-2222-2222-2222-222222222222', 
    'Gold Touch Estetik', 
    'Nişantaşı''nda lüks estetik deneyimi. Son teknoloji cihazlarımız ve uzman doktorlarımızla hizmetinizdeyiz.', 
    'Nişantaşı, İstanbul', 
    ST_SetSRID(ST_MakePoint(28.9950, 41.0519), 4326)::geography, 
    true, true, false, 
    '00000000-0000-0000-0000-000000000000',
    '[
        {"id": "exp3", "name": "Dr. Ahmet B.", "title": "Medikal Estetik Hekimi", "specialty": "Estetik", "rating": 5.0, "photo_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=Ahmet"},
        {"id": "exp4", "name": "Elif D.", "title": "Güzellik Uzmanı", "specialty": "Cilt Bakımı", "rating": 4.7, "photo_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=Elif"}
    ]'::jsonb,
    '{"monday": "10:00 - 19:00", "tuesday": "10:00 - 19:00", "wednesday": "10:00 - 19:00", "thursday": "10:00 - 19:00", "friday": "10:00 - 19:00", "saturday": "10:00 - 18:00", "sunday": "Kapalı"}'::jsonb,
    '["Kredi Kartı", "Nakit"]'::jsonb,
    '["Doktor Kontrolü", "FDA Onaylı Cihazlar"]'::jsonb,
    '{"parking": "Otopark Yok", "wheelchair": "Asansör Var", "wifi": "Mevcut"}'::jsonb,
    '{"phone": "+902129876543", "whatsapp": "905321112233"}'::jsonb
),
(
    '33333333-3333-3333-3333-333333333333', 
    'Pırlanta Tırnak Stüdyosu', 
    'Tırnaklarınız bizimle parlasın. Nail art ve protez tırnakta en yeni trendler.', 
    'Beşiktaş, İstanbul', 
    ST_SetSRID(ST_MakePoint(29.0075, 41.0428), 4326)::geography, 
    false, true, true, 
    '00000000-0000-0000-0000-000000000000',
    '[
        {"id": "exp5", "name": "Melis A.", "title": "Nail Artist", "specialty": "Tırnak", "rating": 4.9, "photo_url": "https://api.dicebear.com/7.x/avataaars/svg?seed=Melis"}
    ]'::jsonb,
    '{"monday": "09:00 - 21:00", "tuesday": "09:00 - 21:00", "wednesday": "09:00 - 21:00", "thursday": "09:00 - 21:00", "friday": "09:00 - 21:00", "saturday": "09:00 - 21:00", "sunday": "11:00 - 18:00"}'::jsonb,
    '["Nakit", "Kredi Kartı"]'::jsonb,
    '["Nail Art", "Kalıcı Oje"]'::jsonb,
    '{"parking": "Sokak Parkı", "wifi": "Mevcut"}'::jsonb,
    '{"instagram": "pirlantanail"}'::jsonb
)
ON CONFLICT (id) DO UPDATE SET
    description = EXCLUDED.description,
    expert_team = EXCLUDED.expert_team,
    working_hours = EXCLUDED.working_hours,
    payment_options = EXCLUDED.payment_options,
    features = EXCLUDED.features,
    accessibility = EXCLUDED.accessibility,
    social_links = EXCLUDED.social_links;

-- 3. Insert Services
INSERT INTO public.services (venue_id, name, category, price, duration, description)
VALUES 
-- Services for Rose Güzellik Salonu
('11111111-1111-1111-1111-111111111111', 'Saç Kesimi & Fön', 'Saç', 450, 60, 'Yüz şeklinize uygun profesyonel kesim ve şekillendirme.'),
('11111111-1111-1111-1111-111111111111', 'Gelin Makyajı', 'Makyaj', 2500, 120, 'Özel gününüz için porselen makyaj uygulaması.'),
('11111111-1111-1111-1111-111111111111', 'Ombre / Sombre', 'Saç', 1800, 180, 'Doğal geçişli renklendirme işlemi.'),
('11111111-1111-1111-1111-111111111111', 'Manikür & Pedikür', 'Tırnak', 350, 60, 'Klasik bakım paketi.'),

-- Services for Gold Touch Estetik
('22222222-2222-2222-2222-222222222222', 'Hydrafacial Cilt Bakımı', 'Cilt Bakımı', 1200, 45, 'Derinlemesine temizlik ve yenileme.'),
('22222222-2222-2222-2222-222222222222', 'Lazer Epilasyon (Tüm Vücut)', 'Estetik', 3500, 90, 'Buz lazer teknolojisi ile acısız işlem.'),
('22222222-2222-2222-2222-222222222222', 'Dudak Dolgusu', 'Estetik', 4000, 30, 'FDA onaylı dolgu ile doğal hacim.'),

-- Services for Pırlanta Tırnak Stüdyosu
('33333333-3333-3333-3333-333333333333', 'Protez Tırnak', 'Tırnak', 650, 90, 'Jel veya akrilik sistem uzatma.'),
('33333333-3333-3333-3333-333333333333', 'Kalıcı Oje', 'Tırnak', 350, 45, '21 gün kalıcı parlak oje.'),
('33333333-3333-3333-3333-333333333333', 'Nail Art (Tırnak Başına)', 'Tırnak', 50, 15, 'Özel tasarım süslemeler.')
ON CONFLICT DO NOTHING;

-- 4. Insert Reviews (New Table)
INSERT INTO public.reviews (id, venue_id, user_id, rating, comment, created_at)
VALUES
-- Reviews for Rose
('10000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 5.0, 'Harika bir deneyimdi, Selin Hanım çok ilgiliydi.', NOW() - INTERVAL '2 days'),
('10000000-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 4.5, 'Fön işlemi biraz uzun sürdü ama sonuç güzel.', NOW() - INTERVAL '5 days'),
('10000000-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 5.0, 'Makyaj tam istediğim gibi oldu, teşekkürler!', NOW() - INTERVAL '1 week'),

-- Reviews for Gold Touch
('10000000-0000-0000-0000-000000000004', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 5.0, 'Çok profesyonel ve hijyenik bir klinik.', NOW() - INTERVAL '1 day'),
('10000000-0000-0000-0000-000000000005', '22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', 4.0, 'Fiyatlar biraz yüksek ama kaliteye değer.', NOW() - INTERVAL '2 weeks'),

-- Reviews for Pırlanta
('10000000-0000-0000-0000-000000000006', '33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 4.8, 'Tırnaklarım muhteşem oldu, Melis Hanım sanatçı gibi.', NOW() - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;
