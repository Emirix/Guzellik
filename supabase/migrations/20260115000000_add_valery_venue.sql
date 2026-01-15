-- Migration: Add Valery Beauty Salon
-- Description: Inserts Valery venue, specialists, services, and gallery photos.

DO $$
DECLARE
    v_venue_id UUID := '77777777-7777-7777-7777-777777777777';
    v_owner_id UUID := '00000000-0000-0000-0000-000000000000'; -- Default test owner
    v_category_id UUID;
    v_district_id UUID;
    v_lazer_id UUID;
    v_cilt_id UUID;
    v_incelme_id UUID;
    v_masaj_id UUID;
    v_micro_id UUID;
    v_dudak_id UUID;
    v_laminasyon_id UUID;
    v_kas_alimi_id UUID;
    v_base_url TEXT := 'https://bovusiymseuxvmgabtfi.supabase.co/storage/v1/object/public/venue-gallery/';
BEGIN
    -- 0. Create dummy owner if not exists
    INSERT INTO public.profiles (id, full_name, avatar_url)
    VALUES (v_owner_id, 'Admin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Admin')
    ON CONFLICT (id) DO NOTHING;

    -- 1. Get Category and District IDs
    SELECT id INTO v_category_id FROM public.venue_categories WHERE slug = 'guzellik-salonu' LIMIT 1;
    SELECT id INTO v_district_id FROM public.districts WHERE name = 'BODRUM' AND province_id = 48 LIMIT 1;

    -- 2. Insert Venue
    INSERT INTO public.venues (
        id, 
        name, 
        description, 
        address, 
        location, 
        province_id, 
        district_id, 
        is_verified, 
        is_preferred, 
        owner_id, 
        social_links,
        category_id,
        working_hours, 
        hero_images
    )
    VALUES (
        v_venue_id,
        'Valery',
        'Epilasyon, Cilt Bakımı, Bölgesel İncelme ve daha fazlası…',
        'Cevat Şakir mah Kıbrıs Şehitleri Cad. No:269/2, Bodrum, Muğla',
        ST_SetSRID(ST_MakePoint(27.4244, 37.0381), 4326)::geography,
        48,
        v_district_id,
        true,
        true,
        v_owner_id,
        jsonb_build_object(
            'phone', '0555 097 17 66',
            'whatsapp', '905550971766',
            'instagram', 'valeryguzelliksalonubodrum'
        ),
        v_category_id,
        '{"monday": "09:30 - 19:00", "tuesday": "09:30 - 19:00", "wednesday": "09:30 - 19:00", "thursday": "09:30 - 19:00", "friday": "09:30 - 19:00", "saturday": "09:30 - 19:00", "sunday": "09:30 - 19:00"}'::jsonb,
        jsonb_build_array(v_base_url || v_venue_id || '/WhatsApp%20Image%202026-01-15%20at%2013.00.36.jpeg')
    )
    ON CONFLICT (id) DO UPDATE SET
        working_hours = EXCLUDED.working_hours,
        social_links = EXCLUDED.social_links,
        description = EXCLUDED.description;

    -- 3. Specialists
    INSERT INTO public.specialists (venue_id, name, profession, gender)
    VALUES 
    (v_venue_id, 'Sude Yatkın', 'Cilt Bakımı Uzmanı', 'Kadın'),
    (v_venue_id, 'Buse Korkmaz', 'Masör ve Lazer Uzmanı', 'Kadın')
    ON CONFLICT DO NOTHING;

    -- 4. Services (Check and Insert if not exists)
    
    -- Lazer Epilasyon
    SELECT id INTO v_lazer_id FROM public.service_categories WHERE name = 'Lazer Epilasyon' LIMIT 1;
    IF v_lazer_id IS NULL THEN
        INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, venue_category_id)
        VALUES ('Lazer Epilasyon', 'Epilasyon - Lazer', 'Profesyonel lazer epilasyon hizmeti.', 60, v_category_id) RETURNING id INTO v_lazer_id;
    END IF;

    -- Cilt Bakımı
    SELECT id INTO v_cilt_id FROM public.service_categories WHERE name = 'Cilt Bakımı' LIMIT 1;
    IF v_cilt_id IS NULL THEN
        INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, venue_category_id)
        VALUES ('Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Derinlemesine cilt bakımı ve temizliği.', 60, v_category_id) RETURNING id INTO v_cilt_id;
    END IF;

    -- Bölgesel İncelme
    SELECT id INTO v_incelme_id FROM public.service_categories WHERE name = 'Bölgesel İncelme' LIMIT 1;
    IF v_incelme_id IS NULL THEN
        INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, venue_category_id)
        VALUES ('Bölgesel İncelme', 'İncelme - Bölgesel', 'Vücut şekillendirme ve bölgesel incelme.', 45, v_category_id) RETURNING id INTO v_incelme_id;
    END IF;

    -- Medikal Masaj
    SELECT id INTO v_masaj_id FROM public.service_categories WHERE name = 'Medikal Masaj' LIMIT 1;
    IF v_masaj_id IS NULL THEN
        INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, venue_category_id)
        VALUES ('Medikal Masaj', 'Masaj', 'Uzman masörler eşliğinde medikal masaj.', 60, v_category_id) RETURNING id INTO v_masaj_id;
    END IF;

    -- Microblading
    SELECT id INTO v_micro_id FROM public.service_categories WHERE name = 'Microblading' LIMIT 1;
    IF v_micro_id IS NULL THEN
        INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, venue_category_id)
        VALUES ('Microblading', 'Makyaj - Kalıcı', 'Kaş tasarımı ve Microblading uygulaması.', 120, v_category_id) RETURNING id INTO v_micro_id;
    END IF;

    -- Dudak Vitamini
    SELECT id INTO v_dudak_id FROM public.service_categories WHERE name = 'Dudak Vitamini' LIMIT 1;
    IF v_dudak_id IS NULL THEN
        INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, venue_category_id)
        VALUES ('Dudak Vitamini', 'Estetik - Uygulama', 'Dudak canlandırma ve vitamin bakımı.', 45, v_category_id) RETURNING id INTO v_dudak_id;
    END IF;

    -- Kirpik Kaş Laminasyon
    SELECT id INTO v_laminasyon_id FROM public.service_categories WHERE name = 'Kirpik Kaş Laminasyon' LIMIT 1;
    IF v_laminasyon_id IS NULL THEN
        INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, venue_category_id)
        VALUES ('Kirpik Kaş Laminasyon', 'Kaş & Kirpik - Tasarım', 'Kirpik lifting ve kaş laminasyonu.', 60, v_category_id) RETURNING id INTO v_laminasyon_id;
    END IF;

    -- Altın Oran Kaş Alımı
    SELECT id INTO v_kas_alimi_id FROM public.service_categories WHERE name = 'Altın Oran Kaş Alımı' LIMIT 1;
    IF v_kas_alimi_id IS NULL THEN
        INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, venue_category_id)
        VALUES ('Altın Oran Kaş Alımı', 'Kaş & Kirpik - Tasarım', 'Yüz hattına uygun altın oran kaş alımı.', 30, v_category_id) RETURNING id INTO v_kas_alimi_id;
    END IF;

    -- Link Services to Venue
    INSERT INTO public.venue_services (venue_id, service_category_id)
    VALUES 
    (v_venue_id, v_lazer_id),
    (v_venue_id, v_cilt_id),
    (v_venue_id, v_incelme_id),
    (v_venue_id, v_masaj_id),
    (v_venue_id, v_micro_id),
    (v_venue_id, v_dudak_id),
    (v_venue_id, v_laminasyon_id),
    (v_venue_id, v_kas_alimi_id)
    ON CONFLICT DO NOTHING;

    -- 5. Gallery Photos
    INSERT INTO public.venue_photos (venue_id, url, title, category, sort_order)
    VALUES 
    (v_venue_id, v_base_url || v_venue_id || '/WhatsApp%20Image%202026-01-15%20at%2013.00.36.jpeg', 'Galeri 1', 'interior', 1),
    (v_venue_id, v_base_url || v_venue_id || '/WhatsApp%20Image%202026-01-15%20at%2013.00.37%20(1).jpeg', 'Galeri 2', 'interior', 2),
    (v_venue_id, v_base_url || v_venue_id || '/WhatsApp%20Image%202026-01-15%20at%2013.00.37%20(2).jpeg', 'Galeri 3', 'interior', 3),
    (v_venue_id, v_base_url || v_venue_id || '/WhatsApp%20Image%202026-01-15%20at%2013.00.37.jpeg', 'Galeri 4', 'interior', 4)
    ON CONFLICT DO NOTHING;

END $$;
