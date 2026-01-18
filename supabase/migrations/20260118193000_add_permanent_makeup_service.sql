-- Add Permanent Makeup (Kalıcı Makyaj) to service_categories
INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, icon, image_url, venue_category_id)
SELECT 
    'Kalıcı Makyaj', 
    'Makyaj - Kalıcı', 
    'Kaş, eyeliner veya dudak için profesyonel kalıcı makyaj uygulaması.', 
    120, 
    'history_edu', 
    'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000',
    id 
FROM public.venue_categories 
WHERE slug = 'estetik-yerleri'
ON CONFLICT (name) DO NOTHING;
