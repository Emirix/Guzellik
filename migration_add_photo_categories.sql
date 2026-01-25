-- Create photo_categories table
CREATE TABLE IF NOT EXISTS public.photo_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.photo_categories ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read categories
CREATE POLICY "Allow public read access to photo_categories"
    ON public.photo_categories FOR SELECT
    USING (true);

-- Insert default categories
INSERT INTO public.photo_categories (name, slug) VALUES
('İç Mekan', 'interior'),
('Dış Mekan', 'exterior'),
('Ekipman', 'equipment'),
('Ekip', 'team'),
('Uygulama Sonuçları', 'service_result'),
('Ürünler', 'products'),
('Sertifikalar', 'certificates'),
('Uygulama Anı', 'service_in_progress')
ON CONFLICT (slug) DO NOTHING;

-- Add category_id to venue_photos if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'venue_photos' AND COLUMN_NAME = 'category_id') THEN
        ALTER TABLE public.venue_photos ADD COLUMN category_id UUID REFERENCES public.photo_categories(id) ON DELETE SET NULL;
    END IF;
END $$;

-- Migrate existing string-based categories to UUID-based category_id
UPDATE public.venue_photos vp
SET category_id = pc.id
FROM public.photo_categories pc
WHERE vp.category = pc.slug
AND vp.category_id IS NULL;
