-- Migration: Create Service Catalog System
-- Description: Creates a catalog of predefined services that venues can offer
-- This enables users to filter venues by services and venues to showcase their offerings

-- 1. Drop old services table if it exists (we'll recreate it properly)
DROP TABLE IF EXISTS public.services CASCADE;

-- 2. Create service_categories table (main catalog of all available services)
CREATE TABLE IF NOT EXISTS public.service_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  category TEXT NOT NULL, -- Main category (e.g., 'Kuaför', 'Tırnak', 'Cilt Bakımı')
  description TEXT NOT NULL,
  average_duration_minutes INTEGER NOT NULL,
  icon TEXT, -- Icon name for UI (Material Symbols)
  image_url TEXT, -- Header image for the service filter
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create venue_services junction table (which services each venue offers)
CREATE TABLE IF NOT EXISTS public.venue_services (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE NOT NULL,
  service_category_id UUID REFERENCES public.service_categories(id) ON DELETE CASCADE NOT NULL,
  custom_price NUMERIC, -- Venue-specific price for this service
  custom_duration_minutes INTEGER, -- Venue-specific duration
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(venue_id, service_category_id)
);

-- 4. Create services table (actual service instances with photos, experts, etc.)
CREATE TABLE IF NOT EXISTS public.services (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  venue_service_id UUID REFERENCES public.venue_services(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL, -- Display name (can be customized by venue)
  description TEXT,
  before_photo_url TEXT,
  after_photo_url TEXT,
  expert_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Enable RLS
ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.venue_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies
-- Service Categories: Read-only for everyone
CREATE POLICY "Service categories are viewable by everyone."
  ON public.service_categories FOR SELECT USING (true);

-- Venue Services: Public can view, only venue owners can manage
CREATE POLICY "Venue services are viewable by everyone."
  ON public.venue_services FOR SELECT USING (true);

CREATE POLICY "Venue owners can manage their venue services."
  ON public.venue_services FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.venues
    WHERE venues.id = venue_services.venue_id
    AND venues.owner_id = auth.uid()
  ));

-- Services: Public can view, only venue owners can manage
CREATE POLICY "Services are viewable by everyone."
  ON public.services FOR SELECT USING (true);

CREATE POLICY "Venue owners can manage their services."
  ON public.services FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.venue_services vs
    JOIN public.venues v ON v.id = vs.venue_id
    WHERE vs.id = services.venue_service_id
    AND v.owner_id = auth.uid()
  ));

-- 7. Create indexes for better performance
CREATE INDEX idx_venue_services_venue_id ON public.venue_services(venue_id);
CREATE INDEX idx_venue_services_service_category_id ON public.venue_services(service_category_id);
CREATE INDEX idx_services_venue_service_id ON public.services(venue_service_id);
CREATE INDEX idx_service_categories_category ON public.service_categories(category);

-- 8. Insert all service categories

-- KUAFÖR HİZMETLERİ - KADIN
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Saç Kesimi (Kadın)', 'Kuaför - Kadın', 'Kadınlar için profesyonel saç kesimi ve şekillendirme hizmeti. Yüz şeklinize uygun kesim modelleri.', 45, 'content_cut', 'https://images.unsplash.com/photo-1562322140-8baeececf3df?q=80&w=1000'),
('Fön', 'Kuaför - Kadın', 'Saçlarınızı hacimlendiren ve şekillendiren profesyonel fön uygulaması.', 30, 'air', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000'),
('Saç Boyama (Tam Boy)', 'Kuaför - Kadın', 'Saçlarınızın tamamına uygulanan kalıcı boya ile yeni bir görünüm.', 120, 'palette', 'https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1000'),
('Saç Boyama (Röfle)', 'Kuaför - Kadın', 'Sadece beyaz veya görünen köklerinize uygulanan boya işlemi.', 60, 'colorize', 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?q=80&w=1000'),
('Ombre', 'Kuaför - Kadın', 'Saç diplerinden uçlarına doğru ton geçişli modern boyama tekniği.', 180, 'layers', 'https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?q=80&w=1000'),
('Balyaj', 'Kuaför - Kadın', 'Doğal görünümlü, güneşte açılmış efekti veren boyama tekniği.', 180, 'auto_awesome', 'https://images.unsplash.com/photo-1527799822340-30276d9101d2?q=80&w=1000'),
('Saç Kaynak', 'Kuaför - Kadın', 'Saçlarınızı doğal bir şekilde uzatmak için kaynak uygulaması.', 240, 'add_link', 'https://images.unsplash.com/photo-1582095133179-bfd08e2ec6b3?q=80&w=1000'),
('Keratin Bakımı', 'Kuaför - Kadın', 'Saçları güçlendiren, parlak ve ipeksi yapan keratin tedavisi.', 150, 'smooth', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Brezilya Fönü', 'Kuaför - Kadın', 'Saçları düzleştiren ve uzun süre şekilsiz bırakan kalıcı bakım.', 180, 'straighten', 'https://images.unsplash.com/photo-1503926359680-945bbcc95851?q=80&w=1000'),
('Saç Botoksu', 'Kuaför - Kadın', 'Yıpranmış saçları onaran ve dolgunlaştıran botoks tedavisi.', 120, 'vaccines', 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=1000'),
('Topuz', 'Kuaför - Kadın', 'Özel günler için şık ve zarif topuz modelleri.', 45, 'stars', 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=1000'),
('Saç Şekillendirme', 'Kuaför - Kadın', 'Dalgalı, bukle veya düz saç şekillendirme işlemleri.', 40, 'style', 'https://images.unsplash.com/photo-1562322140-8baeececf3df?q=80&w=1000'),
('Perma', 'Kuaför - Kadın', 'Saçlara kalıcı dalgalı veya kıvırcık görünüm kazandırma.', 120, 'gesture', 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?q=80&w=1000'),
('Düz Kalıcı', 'Kuaför - Kadın', 'Saçları kalıcı olarak düzleştiren kimyasal işlem.', 150, 'horizontal_rule', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000'),
('Maşa', 'Kuaför - Kadın', 'Geçici bukle veya dalgalar oluşturan maşa ile şekillendirme.', 30, 'waves', 'https://images.unsplash.com/photo-1527799822340-30276d9101d2?q=80&w=1000'),
('Gelin Saçı', 'Kuaför - Kadın', 'En özel gününüz için profesyonel gelin saç tasarımı.', 90, 'card_giftcard', 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1000'),
('Nişan Saçı', 'Kuaför - Kadın', 'Nişan törenleriniz için özel saç modeli ve tasarımı.', 75, 'diamond', 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?q=80&w=1000');

-- TIRNAK HİZMETLERİ - MANİKÜR
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Klasik Manikür', 'Tırnak - Manikür', 'El bakımı, tırnak kesimi, şekilendirme ve oje uygulaması.', 45, 'clean_hands', 'https://images.unsplash.com/photo-1604654894610-df49ff66a7cb?q=80&w=1000'),
('Spa Manikür', 'Tırnak - Manikür', 'Peeling, maske ve masaj içeren lüks el bakımı.', 60, 'hot_tub', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000'),
('Protez Tırnak (Jel Tırnak)', 'Tırnak - Manikür', 'Dayanıklı ve estetik jel tırnak uygulaması.', 90, 'vibration', 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?q=80&w=1000'),
('Kalıcı Oje', 'Tırnak - Manikür', 'UV lambayla sertleşen, 2-3 hafta dayanıklı oje.', 45, 'brush', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000'),
('Oje', 'Tırnak - Manikür', 'Klasik oje uygulama hizmeti.', 20, 'colorize', 'https://images.unsplash.com/photo-1515377905703-c473232bbad1?q=80&w=1000'),
('Tırnak Sanatı (Nail Art)', 'Tırnak - Manikür', 'Tırnaklarınıza özel tasarım ve süsleme işlemi.', 60, 'drawing_palette', 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?q=80&w=1000'),
('French Manikür', 'Tırnak - Manikür', 'Doğal ve zarif French tırnak tasarımı.', 50, 'brightness_low', 'https://images.unsplash.com/photo-1604654894610-df49ff66a7cb?q=80&w=1000'),
('Amerikan Manikür', 'Tırnak - Manikür', 'Modern ve doğal görünümlü Amerikan tarzı manikür.', 50, 'public', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000');

-- TIRNAK HİZMETLERİ - PEDİKÜR
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Klasik Pedikür', 'Tırnak - Pedikür', 'Ayak bakımı, tırnak kesimi ve oje uygulaması.', 60, 'footprint', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000'),
('Spa Pedikür', 'Tırnak - Pedikür', 'Peeling, maske ve masaj içeren özel ayak bakımı.', 75, 'spa', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000'),
('Kalıcı Oje (Ayak)', 'Tırnak - Pedikür', 'Ayak tırnaklarına kalıcı oje uygulaması.', 45, 'brush', 'https://images.unsplash.com/photo-1604654894610-df49ff66a7cb?q=80&w=1000'),
('Protez Tırnak (Ayak)', 'Tırnak - Pedikür', 'Ayak tırnaklarına jel tırnak uygulaması.', 90, 'vibration', 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?q=80&w=1000'),
('Nasır Tedavisi', 'Tırnak - Pedikür', 'Ayaklardaki nasırların profesyonel temizliği.', 30, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Ayak Bakımı', 'Tırnak - Pedikür', 'Kapsamlı ayak temizliği ve bakım işlemi.', 45, 'self_care', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000');

-- CİLT BAKIMI - YÜZ
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Klasik Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Temizlik, peeling, maske ve nemlendirici içeren temel yüz bakımı.', 60, 'face', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000'),
('Hydrafacial', 'Cilt Bakımı - Yüz', 'Derin temizlik ve nem veren gelişmiş cilt bakım teknolojisi.', 60, 'water_drop', 'https://images.unsplash.com/photo-1515377905703-c473232bbad1?q=80&w=1000'),
('Oksijen Terapisi', 'Cilt Bakımı - Yüz', 'Cildi canlandıran ve yenileyen oksijen bazlı tedavi.', 45, 'air', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Altın Maske', 'Cilt Bakımı - Yüz', 'Cildi sıkılaştıran ve ışıltı veren altın içerikli maske.', 50, 'diamond', 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1000'),
('Karbon Peeling', 'Cilt Bakımı - Yüz', 'Gözenekleri temizleyen ve sıkılaştıran lazer tedavisi.', 45, 'blur_on', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Kimyasal Peeling', 'Cilt Bakımı - Yüz', 'Ölü derileri atarak cildi yenileyen kimyasal uygulama.', 40, 'science', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Dermapen', 'Cilt Bakımı - Yüz', 'Mikro iğnelerle cildi yenileyen ve iz gidermede etkili tedavi.', 60, 'grid_4x4', 'https://images.unsplash.com/photo-1544161515-4af6b1d462c2?q=80&w=1000'),
('Mikrodermabrazyon', 'Cilt Bakımı - Yüz', 'Cildin üst tabakasını nazikçe kazıyarak yenileyen işlem.', 45, 'texture', 'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?q=80&w=1000'),
('Gençleştirici Bakım', 'Cilt Bakımı - Yüz', 'Yaşlanma karşıtı özel serumlar ve maskeler içeren bakım.', 75, 'auto_awesome', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000'),
('Akne Tedavisi', 'Cilt Bakımı - Yüz', 'Sivilce ve akne problemlerine yönelik özel bakım programı.', 60, 'healing', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Leke Tedavisi', 'Cilt Bakımı - Yüz', 'Cilt lekelerini azaltan ve tonu eşitleyen tedavi.', 60, 'filter_tilt_shift', 'https://images.unsplash.com/photo-1515377905703-c473232bbad1?q=80&w=1000'),
('Nemlendirici Bakım', 'Cilt Bakımı - Yüz', 'Kuru ciltler için yoğun nem veren bakım.', 50, 'opacity', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000'),
('Yağlı Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Yağ dengesini düzenleyen ve gözenekleri temizleyen bakım.', 55, 'oil_barrel', 'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?q=80&w=1000'),
('Kuru Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Kuru ve hassas ciltler için özel nemlendirici bakım.', 55, 'water', 'https://images.unsplash.com/photo-1515377905703-c473232bbad1?q=80&w=1000'),
('Hassas Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Hassas ciltler için yatıştırıcı ve koruyucu bakım.', 55, 'volunteer_activism', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000'),
('Göz Çevresi Bakımı', 'Cilt Bakımı - Yüz', 'Göz altı torbası ve kırışıklıklarına özel bakım.', 30, 'visibility', 'https://images.unsplash.com/photo-1544161515-4af6b1d462c2?q=80&w=1000');

-- CİLT BAKIMI - VÜCUT
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Vücut Peeling', 'Cilt Bakımı - Vücut', 'Vücuttaki ölü derileri temizleyen peeling uygulaması.', 45, 'texture', 'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?q=80&w=1000'),
('Vücut Masajı', 'Cilt Bakımı - Vücut', 'Rahatlatıcı ve kan dolaşımını hızlandıran masaj.', 60, 'self_care', 'https://images.unsplash.com/photo-1544161515-4af6b1d462c2?q=80&w=1000'),
('Selülit Masajı', 'Cilt Bakımı - Vücut', 'Selülitleri azaltmaya yönelik özel masaj tekniği.', 60, 'vibration', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Sıkılaştırıcı Bakım', 'Cilt Bakımı - Vücut', 'Vücut cildini sıkılaştıran ve şekillendiren bakım.', 75, 'fitness_center', 'https://images.unsplash.com/photo-1515377905703-c473232bbad1?q=80&w=1000'),
('Nemlendirici Vücut Bakımı', 'Cilt Bakımı - Vücut', 'Vücut cildinize yoğun nem veren bakım.', 60, 'opacity', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000');

-- MASAJ HİZMETLERİ
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('İsveç Masajı', 'Masaj', 'Klasik ve rahatlatıcı tüm vücut masajı tekniği.', 60, 'spa', 'https://images.unsplash.com/photo-1544161515-4af6b1d462c2?q=80&w=1000'),
('Tayland Masajı', 'Masaj', 'Esneklik ve enerji veren geleneksel Tayland masajı.', 90, 'self_care', 'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?q=80&w=1000'),
('Refleksoloji', 'Masaj', 'Ayak tabanı noktalarına basınçla yapılan şifa masajı.', 45, 'footprint', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000'),
('Aromaterapi Masajı', 'Masaj', 'Uçucu yağlarla yapılan rahatlatıcı ve terapötik masaj.', 75, 'oil_barrel', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Hot Stone Masajı', 'Masaj', 'Sıcak taşlarla kasları gevşeten özel masaj tekniği.', 90, 'tsunami', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000'),
('Derin Doku Masajı', 'Masaj', 'Kas gerginliklerini çözen yoğun basınçlı masaj.', 75, 'fitness_center', 'https://images.unsplash.com/photo-1544161515-4af6b1d462c2?q=80&w=1000'),
('Spor Masajı', 'Masaj', 'Sporcular için kas iyileşmesine yardımcı masaj.', 60, 'sports_handball', 'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?q=80&w=1000'),
('Hamam Masajı', 'Masaj', 'Geleneksel Türk hamamında köpüklü masaj.', 45, 'hot_tub', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000'),
('Balinese Masajı', 'Masaj', 'Bali adasından gelen derin rahatlatıcı masaj tekniği.', 90, 'nature', 'https://images.unsplash.com/photo-1544161515-4af6b1d462c2?q=80&w=1000'),
('Lomi Lomi Masajı', 'Masaj', 'Hawaii geleneksel ritimli ve akışkan masaj tekniği.', 90, 'waves', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000');

-- EPİLASYON - AĞDA
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Bacak Ağda', 'Epilasyon - Ağda', 'Yarım bacak ağda epilasyon işlemi.', 30, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Tüm Bacak Ağda', 'Epilasyon - Ağda', 'Tam bacak ağda epilasyon işlemi.', 45, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Kol Ağda', 'Epilasyon - Ağda', 'Kol bölgesi ağda epilasyon işlemi.', 25, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Bikini Ağda', 'Epilasyon - Ağda', 'Bikini bölgesi ağda epilasyon işlemi.', 20, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Brazilian Ağda', 'Epilasyon - Ağda', 'Tam bikini bölgesi ağda epilasyon işlemi.', 30, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Bıyık Üstü Ağda', 'Epilasyon - Ağda', 'Üst dudak bölgesi ağda epilasyon işlemi.', 10, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Kaş Arası Ağda', 'Epilasyon - Ağda', 'Kaşlar arası bölge ağda epilasyon işlemi.', 10, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Yanaklar Ağda', 'Epilasyon - Ağda', 'Yanak bölgesi ağda epilasyon işlemi.', 15, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Gerdanlık Ağda', 'Epilasyon - Ağda', 'Boyun bölgesi ağda epilasyon işlemi.', 15, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Koltuk Altı Ağda', 'Epilasyon - Ağda', 'Koltuk altı bölgesi ağda epilasyon işlemi.', 15, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Göğüs Ağda', 'Epilasyon - Ağda', 'Göğüs bölgesi ağda epilasyon işlemi.', 30, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Sırt Ağda', 'Epilasyon - Ağda', 'Sırt bölgesi ağda epilasyon işlemi.', 35, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000'),
('Karın Ağda', 'Epilasyon - Ağda', 'Karın bölgesi ağda epilasyon işlemi.', 25, 'bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000');

-- EPİLASYON - LAZER
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Bacak Lazer', 'Epilasyon - Lazer', 'Yarım bacak lazer epilasyon işlemi.', 40, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Tüm Bacak Lazer', 'Epilasyon - Lazer', 'Tam bacak lazer epilasyon işlemi.', 60, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Kol Lazer', 'Epilasyon - Lazer', 'Kol bölgesi lazer epilasyon işlemi.', 30, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Bikini Lazer', 'Epilasyon - Lazer', 'Bikini bölgesi lazer epilasyon işlemi.', 25, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Brazilian Lazer', 'Epilasyon - Lazer', 'Tam bikini bölgesi lazer epilasyon işlemi.', 35, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Bıyık Üstü Lazer', 'Epilasyon - Lazer', 'Üst dudak bölgesi lazer epilasyon işlemi.', 15, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Çene Lazer', 'Epilasyon - Lazer', 'Çene bölgesi lazer epilasyon işlemi.', 15, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Yanaklar Lazer', 'Epilasyon - Lazer', 'Yanak bölgesi lazer epilasyon işlemi.', 20, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Koltuk Altı Lazer', 'Epilasyon - Lazer', 'Koltuk altı bölgesi lazer epilasyon işlemi.', 20, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Göğüs Lazer', 'Epilasyon - Lazer', 'Göğüs bölgesi lazer epilasyon işlemi.', 35, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Sırt Lazer', 'Epilasyon - Lazer', 'Sırt bölgesi lazer epilasyon işlemi.', 45, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000'),
('Karın Lazer', 'Epilasyon - Lazer', 'Karın bölgesi lazer epilasyon işlemi.', 30, 'fire', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000');

-- KAŞ & KİRPİK
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Kaş Tasarım', 'Kaş & Kirpik', 'Yüz şeklinize uygun profesyonel kaş tasarımı.', 30, 'remove_red_eye', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000'),
('Kaş Alma (İplik)', 'Kaş & Kirpik', 'İplik yöntemiyle kaş alma ve şekillendirme.', 15, 'content_cut', 'https://images.unsplash.com/photo-1562322140-8baeececf3df?q=80&w=1000'),
('Kaş Boyama', 'Kaş & Kirpik', 'Kaşlarınızı belirginleştiren boya uygulaması.', 20, 'brush', 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?q=80&w=1000'),
('Microblading', 'Kaş & Kirpik', 'Kalıcı kaş tasarımı için mikro pigmentasyon tekniği.', 120, 'edit', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000'),
('Kaş Laminasyonu', 'Kaş & Kirpik', 'Kaşları düzenli and dolgun gösteren laminasyon işlemi.', 45, 'auto_awesome', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000'),
('Kirpik Lifting', 'Kaş & Kirpik', 'Kirpiklere kıvrım veren kalıcı lifting işlemi.', 60, 'expand_less', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000'),
('Kirpik Botoksu', 'Kaş & Kirpik', 'Kirpikleri besleyen ve güçlendiren botoks tedavisi.', 45, 'vaccines', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Kirpik Perması', 'Kaş & Kirpik', 'Kirpiklere kalıcı kıvrım kazandıran perma işlemi.', 50, 'gesture', 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?q=80&w=1000'),
('Takma Kirpik', 'Kaş & Kirpik', 'Özel günler için geçici takma kirpik uygulaması.', 30, 'add', 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?q=80&w=1000'),
('Ipek Kirpik', 'Kaş & Kirpik', 'Doğal ve kalıcı ipek kirpik uygulaması.', 90, 'star', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000'),
('Kirpik Boyama', 'Kaş & Kirpik', 'Kirpikleri belirginleştiren boya uygulaması.', 20, 'palette', 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?q=80&w=1000');

-- ÖZEL BAKIM & TEDAVİ
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Gelin Paketi', 'Özel Paket', 'En özel gününüz için kapsamlı güzellik paketi.', 240, 'card_giftcard', 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1000'),
('Nişan Paketi', 'Özel Paket', 'Nişan töreniniz için özel hazırlanmış bakım paketi.', 180, 'card_giftcard', 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1000'),
('Damat Paketi', 'Özel Paket', 'Damatlar için özel hazırlanmış bakım paketi.', 120, 'card_giftcard', 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1000'),
('Gün Paketi', 'Özel Paket', 'Kendinizi şımartmak için tam gün spa paketi.', 360, 'card_giftcard', 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1000'),
('G5 Masajı', 'Özel Tedavi', 'Vibrasyon teknolojisi ile selülit ve yağ azaltma masajı.', 45, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Kupa Terapi', 'Özel Tedavi', 'Geleneksel kupa tedavisi ile kas gevşetme ve detoks.', 40, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Radyofrekans (RF)', 'Özel Tedavi', 'Cildi sıkılaştıran ve kırışıklıkları azaltan RF tedavisi.', 60, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Kavitasyon', 'Özel Tedavi', 'Ultrason dalgalarıyla yağ hücrelerini parçalayan tedavi.', 45, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Mezotopi', 'Özel Tedavi', 'Bölgesel incelme için özel iğneli tedavi yöntemi.', 30, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('PRP Tedavisi', 'Özel Tedavi', 'Kendi kanınızdan elde edilen plazma ile yenilenme tedavisi.', 60, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Mezoterapi', 'Özel Tedavi', 'Vitamin ve mineraller içeren enjeksiyon tedavisi.', 45, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Medikal Cilt Bakımı', 'Özel Tedavi', 'Dermatolog kontrolünde yapılan tıbbi cilt bakımı.', 75, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000');

-- HAMAM & SPA
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Hamam', 'Hamam & Spa', 'Geleneksel Türk hamamı deneyimi.', 90, 'hot_tub', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000'),
('Kese-Köpük', 'Hamam & Spa', 'Kese ve köpük masajı ile derin temizlik.', 60, 'hot_tub', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000'),
('Türk Hamamı', 'Hamam & Spa', 'Otantik Türk hamamı ritüeli.', 120, 'hot_tub', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000'),
('Sauna', 'Hamam & Spa', 'Kuru sauna ile vücut arındırma ve rahatlatma.', 30, 'hot_tub', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000'),
('Buhar Odası', 'Hamam & Spa', 'Buhar ile gözenek açma ve detoks.', 20, 'hot_tub', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000'),
('Jakuzi', 'Hamam & Spa', 'Hidromasaj ile kas gevşetme ve rahatlama.', 30, 'hot_tub', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000');

-- MAKYAJ
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Günlük Makyaj', 'Makyaj', 'Doğal ve hafif günlük makyaj uygulaması.', 30, 'brush', 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?q=80&w=1000'),
('Gece Makyajı', 'Makyaj', 'Özel günler ve davetler için göz alıcı makyaj.', 45, 'auto_fix_high', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000'),
('Gelin Makyajı', 'Makyaj', 'Düğün gününüz için profesyonel gelin makyajı.', 60, 'card_giftcard', 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1000'),
('Nişan Makyajı', 'Makyaj', 'Nişan töreniniz için özel makyaj uygulaması.', 50, 'diamond', 'https://images.unsplash.com/photo-1515377905703-c473232bbad1?q=80&w=1000'),
('Smokey Makyaj', 'Makyaj', 'Göz alıcı smokey göz makyajı tekniği.', 40, 'visibility', 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?q=80&w=1000'),
('Kalıcı Makyaj', 'Makyaj', 'Kaş, eyeliner veya dudak için kalıcı makyaj.', 120, 'history_edu', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000'),
('Airbrush Makyaj', 'Makyaj', 'Hava fırçası ile kusursuz makyaj uygulaması.', 45, 'air', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000');

-- AYAK & EL BAKIMI
INSERT INTO public.service_categories (name, category, description, average_duration_minutes, icon, image_url) VALUES
('Parafin Tedavisi', 'El & Ayak Bakımı', 'Sıcak parafin ile el veya ayak bakımı.', 30, 'self_care', 'https://images.unsplash.com/photo-1515377905703-c473232bbad1?q=80&w=1000'),
('El Bakımı', 'El & Ayak Bakımı', 'Kapsamlı el temizliği ve nemlendirme bakımı.', 40, 'clean_hands', 'https://images.unsplash.com/photo-1604654894610-df49ff66a7cb?q=80&w=1000'),
('Ayak Bakımı', 'El & Ayak Bakımı', 'Profesyonel ayak bakımı ve peeling.', 50, 'footprint', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000'),
('Nasır Tedavisi', 'El & Ayak Bakımı', 'Ayaklardaki nasırların profesyonel tedavisi.', 30, 'medical_services', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000'),
('Topuk Çatlağı Bakımı', 'El & Ayak Bakımı', 'Topuk çatlaklarını onarıcı özel bakım.', 40, 'healing', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000');

-- 9. Update discovery views to work with new structure
DROP VIEW IF EXISTS popular_services;

CREATE OR REPLACE VIEW popular_services AS
SELECT
  sc.id,
  sc.name,
  sc.icon,
  sc.image_url,
  COUNT(DISTINCT vs.venue_id) as venue_count,
  0 as search_count
FROM service_categories sc
LEFT JOIN venue_services vs ON sc.id = vs.service_category_id
WHERE vs.is_available = true
GROUP BY sc.id, sc.name, sc.icon, sc.image_url
HAVING COUNT(DISTINCT vs.venue_id) > 0
ORDER BY venue_count DESC, sc.name ASC
LIMIT 20;

-- Grant permissions
GRANT SELECT ON popular_services TO anon, authenticated;

-- 10. Create helper function to get services by venue
CREATE OR REPLACE FUNCTION get_venue_services(p_venue_id UUID)
RETURNS TABLE (
  id UUID,
  venue_id UUID,
  name TEXT,
  category TEXT,
  price NUMERIC,
  duration INTEGER,
  description TEXT,
  before_photo_url TEXT,
  after_photo_url TEXT,
  expert_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.id,
    vs.venue_id,
    COALESCE(s.name, sc.name) as name,
    sc.category,
    COALESCE(vs.custom_price, 0::numeric) as price,
    COALESCE(vs.custom_duration_minutes, sc.average_duration_minutes) as duration,
    s.description,
    s.before_photo_url,
    s.after_photo_url,
    s.expert_name
  FROM venue_services vs
  JOIN service_categories sc ON sc.id = vs.service_category_id
  LEFT JOIN services s ON s.venue_service_id = vs.id
  WHERE vs.venue_id = p_venue_id
    AND vs.is_available = true
  ORDER BY sc.category, sc.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Create function to search venues by service
CREATE OR REPLACE FUNCTION search_venues_by_service(p_service_category_id UUID)
RETURNS SETOF venues AS $$
BEGIN
  RETURN QUERY
  SELECT v.*
  FROM venues v
  JOIN venue_services vs ON vs.venue_id = v.id
  WHERE vs.service_category_id = p_service_category_id
    AND vs.is_available = true
  ORDER BY v.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION get_venue_services(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION search_venues_by_service(UUID) TO anon, authenticated;
