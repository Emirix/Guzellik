-- Create venue_categories table
CREATE TABLE IF NOT EXISTS public.venue_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    icon TEXT,
    image_url TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Add category_id to venues
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES public.venue_categories(id);

-- Enable RLS
ALTER TABLE public.venue_categories ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access for venue_categories"
ON public.venue_categories FOR SELECT
TO public
USING (true);

-- Seed initial categories
INSERT INTO public.venue_categories (name, slug, icon) VALUES
('KİRPİK & KAŞ STÜDYO', 'kirpik-kas-studyo', 'remove_red_eye'),
('EPİLASYON MERKEZLERİ', 'epilasyon-merkezleri', 'bolt'),
('CİLT BAKIM MERKEZLERİ', 'cilt-bakim-merkezleri', 'face'),
('Güzellik Salonu', 'guzellik-salonu', 'spa'),
('Kadın Kuaförleri', 'kadin-kuaforleri', 'content_cut'),
('Tırnak Stüdyoları', 'tirnak-studyolari', 'clean_hands'),
('Estetik Yerleri', 'estetik-yerleri', 'medical_services'),
('Ayak Bakım', 'ayak-bakim', 'accessibility')
ON CONFLICT (name) DO NOTHING;
