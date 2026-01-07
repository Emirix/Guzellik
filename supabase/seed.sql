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

-- 2. Insert Venues with Rich Data (Expert Team, Working Hours, Gallery)
INSERT INTO public.venues (id, name, description, address, location, is_verified, is_preferred, is_hygienic, owner_id, expert_team, working_hours, payment_options, features, accessibility, social_links, hero_images)
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
    '{"phone": "+902121234567", "instagram": "roseguzellik"}'::jsonb,
    '[
        "https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1000&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1522337360788-8b13df793f1f?q=80&w=1000&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=1000&auto=format&fit=crop"
    ]'::jsonb
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
    '{"phone": "+902129876543", "whatsapp": "905321112233"}'::jsonb,
    '[
        "https://images.unsplash.com/photo-1629909613654-28e377c37b09?q=80&w=1000&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1600334129128-685c45851240?q=80&w=1000&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=1000&auto=format&fit=crop"
    ]'::jsonb
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
    '{"instagram": "pirlantanail"}'::jsonb,
    '[
        "https://images.unsplash.com/photo-1632345031435-8727f6897d53?q=80&w=1000&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1604654894610-df490682160d?q=80&w=1000&auto=format&fit=crop"
    ]'::jsonb
)
ON CONFLICT (id) DO UPDATE SET
    description = EXCLUDED.description,
    expert_team = EXCLUDED.expert_team,
    working_hours = EXCLUDED.working_hours,
    payment_options = EXCLUDED.payment_options,
    features = EXCLUDED.features,
    accessibility = EXCLUDED.accessibility,
    social_links = EXCLUDED.social_links,
    hero_images = EXCLUDED.hero_images;

-- 3. Insert Services with Before/After Photos


-- 3. Insert into venue_services (Linking venues to the new catalog)
INSERT INTO public.venue_services (venue_id, service_category_id, custom_price, custom_duration_minutes)
VALUES 
-- Rose Güzellik Salonu (1111...)
('11111111-1111-1111-1111-111111111111', (SELECT id FROM service_categories WHERE name = 'Saç Kesimi (Kadın)'), 450, 60),
('11111111-1111-1111-1111-111111111111', (SELECT id FROM service_categories WHERE name = 'Klasik Cilt Bakımı'), 1200, 60),
('11111111-1111-1111-1111-111111111111', (SELECT id FROM service_categories WHERE name = 'Günlük Makyaj'), 800, 45),

-- Gold Touch Estetik (2222...)
('22222222-2222-2222-2222-222222222222', (SELECT id FROM service_categories WHERE name = 'Hydrafacial'), 1200, 45),
('22222222-2222-2222-2222-222222222222', (SELECT id FROM service_categories WHERE name = 'Microblading'), 3500, 120),
('22222222-2222-2222-2222-222222222222', (SELECT id FROM service_categories WHERE name = 'İsveç Masajı'), 1500, 60),

-- Pırlanta Tırnak Stüdyosu (3333...)
('33333333-3333-3333-3333-333333333333', (SELECT id FROM service_categories WHERE name = 'Protez Tırnak (Jel Tırnak)'), 650, 90),
('33333333-3333-3333-3333-333333333333', (SELECT id FROM service_categories WHERE name = 'Kalıcı Oje'), 450, 45),
('33333333-3333-3333-3333-333333333333', (SELECT id FROM service_categories WHERE name = 'Klasik Pedikür'), 500, 60)
ON CONFLICT (venue_id, service_category_id) DO NOTHING;

-- 4. Insert into services (Specific service instances with photos)
INSERT INTO public.services (venue_service_id, name, description, before_photo_url, after_photo_url, expert_name)
SELECT 
    vs.id as venue_service_id,
    sc.name,
    sc.description,
    CASE 
        WHEN sc.name = 'Hydrafacial' THEN 'https://images.unsplash.com/photo-1512290923902-8a9f81da236c?q=80&w=1000'
        WHEN sc.name = 'Protez Tırnak (Jel Tırnak)' THEN 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?q=80&w=1000'
        ELSE NULL
    END as before_photo_url,
    CASE 
        WHEN sc.name = 'Hydrafacial' THEN 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000'
        WHEN sc.name = 'Protez Tırnak (Jel Tırnak)' THEN 'https://images.unsplash.com/photo-1604654894610-df490682160d?q=80&w=1000'
        ELSE NULL
    END as after_photo_url,
    'Selin Y.' as expert_name
FROM venue_services vs
JOIN service_categories sc ON sc.id = vs.service_category_id;

-- 5. Insert Gallery Photos
INSERT INTO public.venue_photos (venue_id, url, title, category, sort_order)
VALUES 
('11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1000&auto=format&fit=crop', 'Ana Salon', 'interior', 1),
('11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1522337360788-8b13df793f1f?q=80&w=1000&auto=format&fit=crop', 'Bekleme Alanı', 'interior', 2),
('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?q=80&w=1000&auto=format&fit=crop', 'Klinik Giriş', 'exterior', 1),
('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1600334129128-685c45851240?q=80&w=1000&auto=format&fit=crop', 'Uygulama Odası', 'interior', 2),
('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=1000&auto=format&fit=crop', 'Lobi', 'interior', 3),
('22222222-2222-2222-2222-222222222222', 'https://plus.unsplash.com/premium_photo-1681966555545-927bb40d859e?q=80&w=1000&auto=format&fit=crop', 'Dudak Dolgusu Sonucu', 'service_result', 4),
('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?q=80&w=1000&auto=format&fit=crop', 'Cilt Yenileme Sonucu', 'service_result', 5),
('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000&auto=format&fit=crop', 'Modern Dinlenme Alanı', 'interior', 6),
('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?q=80&w=1000&auto=format&fit=crop', 'Ekipmanlarımız', 'equipment', 7),
('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1576091160550-217359971f8b?q=80&w=1000&auto=format&fit=crop', 'Klinik Ekibimiz', 'team', 8),
('33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?q=80&w=1000&auto=format&fit=crop', 'Tırnak Tasarım Masası', 'interior', 1)
ON CONFLICT DO NOTHING;

-- 5. Insert Reviews
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

