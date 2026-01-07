-- Seed data for Güzellik Platformu

-- 1. Create a dummy profile (since we need an owner for venues)
-- Note: In a real app, owners would be real users from auth.users
-- For test data, we just need a valid UUID in the profiles table.
-- We'll use a fixed UUID for consistency in tests.
DO $$
DECLARE
    dummy_owner_id UUID := '00000000-0000-0000-0000-000000000000';
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url)
    VALUES (dummy_owner_id, 'Test İşletmeci', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Test')
    ON CONFLICT (id) DO NOTHING;
END $$;

-- 2. Insert Venues
INSERT INTO public.venues (id, name, description, address, location, is_verified, is_preferred, is_hygienic, owner_id)
VALUES 
(
    '11111111-1111-1111-1111-111111111111', 
    'Rose Güzellik Salonu', 
    'Şişli''nin kalbinde profesyonel saç ve makyaj hizmetleri.', 
    'Şişli, İstanbul', 
    ST_SetSRID(ST_MakePoint(28.9872, 41.0601), 4326)::geography, 
    true, true, true, 
    '00000000-0000-0000-0000-000000000000'
),
(
    '22222222-2222-2222-2222-222222222222', 
    'Gold Touch Estetik', 
    'Nişantaşı''nda lüks estetik ve cilt bakımı uygulamaları.', 
    'Nişantaşı, İstanbul', 
    ST_SetSRID(ST_MakePoint(28.9950, 41.0519), 4326)::geography, 
    true, true, false, 
    '00000000-0000-0000-0000-000000000000'
),
(
    '33333333-3333-3333-3333-333333333333', 
    'Pırlanta Tırnak Stüdyosu', 
    'Beşiktaş''ta en kaliteli protez tırnak ve nail art hizmeti.', 
    'Beşiktaş, İstanbul', 
    ST_SetSRID(ST_MakePoint(29.0075, 41.0428), 4326)::geography, 
    false, true, true, 
    '00000000-0000-0000-0000-000000000000'
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    address = EXCLUDED.address,
    location = EXCLUDED.location,
    is_verified = EXCLUDED.is_verified,
    is_preferred = EXCLUDED.is_preferred,
    is_hygienic = EXCLUDED.is_hygienic;

-- 3. Insert Services
INSERT INTO public.services (venue_id, name, category, price, duration)
VALUES 
-- Services for Rose Güzellik Salonu
('11111111-1111-1111-1111-111111111111', 'Saç Kesimi & Fön', 'Saç', 450, 60),
('11111111-1111-1111-1111-111111111111', 'Gelin Makyajı', 'Makyaj', 2500, 120),
('11111111-1111-1111-1111-111111111111', 'Ombre / Sombre', 'Saç', 1800, 180),

-- Services for Gold Touch Estetik
('22222222-2222-2222-2222-222222222222', 'Hydrafacial Cilt Bakımı', 'Cilt Bakımı', 1200, 45),
('22222222-2222-2222-2222-222222222222', 'Lazer Epilasyon (Tüm Vücut)', 'Estetik', 3500, 90),
('22222222-2222-2222-2222-222222222222', 'Dudak Dolgusu', 'Estetik', 4000, 30),

-- Services for Pırlanta Tırnak Stüdyosu
('33333333-3333-3333-3333-333333333333', 'Protez Tırnak', 'Tırnak', 650, 90),
('33333333-3333-3333-3333-333333333333', 'Kalıcı Oje', 'Tırnak', 350, 45),
('33333333-3333-3333-3333-333333333333', 'Medikal Manikür', 'Tırnak', 250, 40)
ON CONFLICT DO NOTHING;
