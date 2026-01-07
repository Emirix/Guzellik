-- Mock Data for Venue Gallery and Photos

-- First, let's update some venues with hero images
UPDATE venues 
SET hero_images = '[
  "https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1000&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1522337360788-8b13df793f1f?q=80&w=1000&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?q=80&w=1000&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=1000&auto=format&fit=crop"
]'::jsonb
WHERE name LIKE '%Güzellik%' OR name LIKE '%Salon%';

-- Now add individual photos to venue_photos
DO $$ 
DECLARE 
    v_id UUID;
    s_id UUID;
BEGIN
    FOR v_id IN SELECT id FROM venues LIMIT 5 LOOP
        -- Interior photos
        INSERT INTO venue_photos (venue_id, url, title, category, sort_order)
        VALUES 
        (v_id, 'https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1000&auto=format&fit=crop', 'Ana Salon', 'interior', 1),
        (v_id, 'https://images.unsplash.com/photo-1522337360788-8b13df793f1f?q=80&w=1000&auto=format&fit=crop', 'Bekleme Alanı', 'interior', 2);

        -- Team
        INSERT INTO venue_photos (venue_id, url, title, category, sort_order)
        VALUES 
        (v_id, 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000&auto=format&fit=crop', 'Uzman Kadromuz', 'team', 3);

        -- Service Results (Before/After)
        -- Get a service id for this venue
        SELECT id INTO s_id FROM services WHERE venue_id = v_id LIMIT 1;
        
        IF s_id IS NOT NULL THEN
            -- Update service with before/after for testing the viewer
            UPDATE services 
            SET before_photo_url = 'https://images.unsplash.com/photo-1512290923902-8a9f81da236c?q=80&w=1000&auto=format&fit=crop',
                after_photo_url = 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000&auto=format&fit=crop'
            WHERE id = s_id;

            INSERT INTO venue_photos (venue_id, url, title, category, service_id, sort_order)
            VALUES 
            (v_id, 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000&auto=format&fit=crop', 'Cilt Bakımı Sonucu', 'service_result', s_id, 4);
        END IF;
    END LOOP;
END $$;
