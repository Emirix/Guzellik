-- Create venue_features table (Master list of all available features)
CREATE TABLE IF NOT EXISTS public.venue_features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    icon TEXT NOT NULL,
    category TEXT NOT NULL, -- 'hygiene', 'service', 'comfort', 'payment', 'transport', 'communication'
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create venue_selected_features junction table (Many-to-many relationship)
CREATE TABLE IF NOT EXISTS public.venue_selected_features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id UUID NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
    feature_id UUID NOT NULL REFERENCES public.venue_features(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(venue_id, feature_id)
);

-- Enable RLS
ALTER TABLE public.venue_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.venue_selected_features ENABLE ROW LEVEL SECURITY;

-- RLS Policies for venue_features (Public read access)
CREATE POLICY "Allow public read access for venue_features"
ON public.venue_features FOR SELECT
TO public
USING (is_active = true);

-- RLS Policies for venue_selected_features (Public read, owner write)
CREATE POLICY "Allow public read access for venue_selected_features"
ON public.venue_selected_features FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow venue owners to manage their features"
ON public.venue_selected_features FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.venues
        WHERE venues.id = venue_selected_features.venue_id
        AND venues.owner_id = auth.uid()
    )
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_venue_selected_features_venue_id ON public.venue_selected_features(venue_id);
CREATE INDEX IF NOT EXISTS idx_venue_selected_features_feature_id ON public.venue_selected_features(feature_id);
CREATE INDEX IF NOT EXISTS idx_venue_features_category ON public.venue_features(category);
CREATE INDEX IF NOT EXISTS idx_venue_features_display_order ON public.venue_features(display_order);

-- Seed initial features
INSERT INTO public.venue_features (name, slug, icon, category, description, display_order) VALUES
-- Hygiene & Safety
('Sterilizasyon', 'sterilizasyon', 'science', 'hygiene', 'Profesyonel sterilizasyon cihazı kullanılır', 1),
('Tek Kullanımlık Malzeme', 'tek-kullanimlik-malzeme', 'sanitizer', 'hygiene', 'Hijyenik tek kullanımlık ürünler', 2),
('Sertifikalı Ürünler', 'sertifikali-urunler', 'verified', 'hygiene', 'Onaylı ve sertifikalı kozmetik ürünler', 3),

-- Service
('Online Randevu', 'online-randevu', 'event_available', 'service', 'Dijital randevu sistemi mevcut', 4),
('Paket Servis', 'paket-servis', 'card_giftcard', 'service', 'Paket hizmet seçenekleri', 5),
('Ev Hizmeti', 'ev-hizmeti', 'home', 'service', 'Eve gelen hizmet imkanı', 6),
('Ücretsiz Danışma', 'ucretsiz-danisma', 'chat', 'service', 'İlk danışma ücretsiz', 7),

-- Comfort & Amenities
('Klima', 'klima', 'ac_unit', 'comfort', 'Klimalı ortam', 8),
('Ücretsiz İçecek', 'ucretsiz-icecek', 'local_cafe', 'comfort', 'Çay, kahve ikramı', 9),
('Çocuk Oyun Alanı', 'cocuk-oyun-alani', 'child_care', 'comfort', 'Çocuklar için oyun alanı', 10),
('Dergi/Gazete', 'dergi-gazete', 'menu_book', 'comfort', 'Okuma materyali mevcut', 11),
('Müzik', 'muzik', 'music_note', 'comfort', 'Rahatlatıcı müzik ortamı', 12),
('Wi-Fi', 'wifi', 'wifi', 'comfort', 'Ücretsiz kablosuz internet', 13),

-- Payment Options
('Kredi Kartı', 'kredi-karti', 'credit_card', 'payment', 'Kredi kartı ile ödeme', 14),
('Taksit İmkanı', 'taksit-imkani', 'payments', 'payment', 'Kredi kartına taksit seçeneği', 15),
('Mobil Ödeme', 'mobil-odeme', 'contactless', 'payment', 'QR kod ve contactless ödeme', 16),
('Nakit', 'nakit', 'money', 'payment', 'Nakit ödeme kabul edilir', 17),

-- Transport & Access
('Otopark', 'otopark', 'local_parking', 'transport', 'Otopark imkanı mevcut', 18),
('Toplu Taşıma Yakını', 'toplu-tasima-yakini', 'directions_bus', 'transport', 'Metro/Otobüs duraklarına yakın', 19),
('Vale Hizmeti', 'vale-hizmeti', 'local_taxi', 'transport', 'Otopark vale hizmeti', 20),
('Engelli Uygun', 'engelli-uygun', 'accessible', 'transport', 'Tekerlekli sandalye erişimi', 21),

-- Communication
('WhatsApp Randevu', 'whatsapp-randevu', 'chat_bubble', 'communication', 'WhatsApp üzerinden randevu', 22),
('Instagram Aktif', 'instagram-aktif', 'photo_camera', 'communication', 'Aktif Instagram hesabı', 23)
ON CONFLICT (slug) DO NOTHING;
