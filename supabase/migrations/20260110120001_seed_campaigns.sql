-- Seed data for campaigns table
-- Add sample campaigns for testing

-- Insert sample campaigns
INSERT INTO public.campaigns (id, venue_id, title, description, discount_percentage, discount_amount, start_date, end_date, image_url, is_active)
VALUES 
-- Rose Güzellik Salonu campaigns
(
    '10000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111',
    'Yeni Yıl Özel %30 İndirim',
    'Tüm saç bakım hizmetlerinde geçerli. Keratin, boya ve kesim işlemlerinde %30 indirim fırsatı!',
    30,
    NULL,
    NOW() - INTERVAL '5 days',
    NOW() + INTERVAL '25 days',
    'https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1000&auto=format&fit=crop',
    true
),
(
    '10000000-0000-0000-0000-000000000002',
    '11111111-1111-1111-1111-111111111111',
    'Cilt Bakımında 200₺ İndirim',
    'Klasik cilt bakımı paketinde 200₺ indirim. Cildinizi yenileyin!',
    NULL,
    200.00,
    NOW() - INTERVAL '2 days',
    NOW() + INTERVAL '2 days',
    'https://images.unsplash.com/photo-1616394584738-fc6e612e71b9?q=80&w=1000&auto=format&fit=crop',
    true
),

-- Gold Touch Estetik campaigns
(
    '10000000-0000-0000-0000-000000000003',
    '22222222-2222-2222-2222-222222222222',
    'Hydrafacial Kampanyası',
    'Hydrafacial uygulamasında %25 indirim. Cildinize özel bakım fırsatı!',
    25,
    NULL,
    NOW() - INTERVAL '10 days',
    NOW() + INTERVAL '20 days',
    'https://images.unsplash.com/photo-1629909613654-28e377c37b09?q=80&w=1000&auto=format&fit=crop',
    true
),
(
    '10000000-0000-0000-0000-000000000004',
    '22222222-2222-2222-2222-222222222222',
    'Microblading Özel Fiyat',
    'Microblading uygulamasında 500₺ indirim. Kaşlarınız için mükemmel çözüm!',
    NULL,
    500.00,
    NOW() - INTERVAL '1 day',
    NOW() + INTERVAL '14 days',
    'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?q=80&w=1000&auto=format&fit=crop',
    true
),

-- Pırlanta Tırnak Stüdyosu campaigns
(
    '10000000-0000-0000-0000-000000000005',
    '33333333-3333-3333-3333-333333333333',
    'Protez Tırnak + Kalıcı Oje Paketi',
    'Protez tırnak ve kalıcı oje paketinde %20 indirim. Tırnaklarınız için özel fırsat!',
    20,
    NULL,
    NOW() - INTERVAL '7 days',
    NOW() + INTERVAL '23 days',
    'https://images.unsplash.com/photo-1632345031435-8727f6897d53?q=80&w=1000&auto=format&fit=crop',
    true
),

-- Expired campaign (for testing filtering)
(
    '10000000-0000-0000-0000-000000000006',
    '11111111-1111-1111-1111-111111111111',
    'Geçmiş Kampanya (Test)',
    'Bu kampanya süresi dolmuş, görünmemeli.',
    50,
    NULL,
    NOW() - INTERVAL '30 days',
    NOW() - INTERVAL '5 days',
    NULL,
    true
),

-- Inactive campaign (for testing)
(
    '10000000-0000-0000-0000-000000000007',
    '22222222-2222-2222-2222-222222222222',
    'Pasif Kampanya (Test)',
    'Bu kampanya pasif, görünmemeli.',
    40,
    NULL,
    NOW() - INTERVAL '1 day',
    NOW() + INTERVAL '30 days',
    NULL,
    false
)
ON CONFLICT (id) DO NOTHING;
