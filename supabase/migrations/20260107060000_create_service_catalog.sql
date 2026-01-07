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
  icon TEXT, -- Icon name for UI
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
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Saç Kesimi (Kadın)', 'Kuaför - Kadın', 'Kadınlar için profesyonel saç kesimi ve şekillendirme hizmeti. Yüz şeklinize uygun kesim modelleri.', 45),
('Fön', 'Kuaför - Kadın', 'Saçlarınızı hacimlendiren ve şekillendiren profesyonel fön uygulaması.', 30),
('Saç Boyama (Tam Boy)', 'Kuaför - Kadın', 'Saçlarınızın tamamına uygulanan kalıcı boya ile yeni bir görünüm.', 120),
('Saç Boyama (Röfle)', 'Kuaför - Kadın', 'Sadece beyaz veya görünen köklerinize uygulanan boya işlemi.', 60),
('Ombre', 'Kuaför - Kadın', 'Saç diplerinden uçlarına doğru ton geçişli modern boyama tekniği.', 180),
('Balyaj', 'Kuaför - Kadın', 'Doğal görünümlü, güneşte açılmış efekti veren boyama tekniği.', 180),
('Saç Kaynak', 'Kuaför - Kadın', 'Saçlarınızı doğal bir şekilde uzatmak için kaynak uygulaması.', 240),
('Keratin Bakımı', 'Kuaför - Kadın', 'Saçları güçlendiren, parlak ve ipeksi yapan keratin tedavisi.', 150),
('Brezilya Fönü', 'Kuaför - Kadın', 'Saçları düzleştiren ve uzun süre şekilsiz bırakan kalıcı bakım.', 180),
('Saç Botoksu', 'Kuaför - Kadın', 'Yıpranmış saçları onaran ve dolgunlaştıran botoks tedavisi.', 120),
('Topuz', 'Kuaför - Kadın', 'Özel günler için şık ve zarif topuz modelleri.', 45),
('Saç Şekillendirme', 'Kuaför - Kadın', 'Dalgalı, bukle veya düz saç şekillendirme işlemleri.', 40),
('Perma', 'Kuaför - Kadın', 'Saçlara kalıcı dalgalı veya kıvırcık görünüm kazandırma.', 120),
('Düz Kalıcı', 'Kuaför - Kadın', 'Saçları kalıcı olarak düzleştiren kimyasal işlem.', 150),
('Maşa', 'Kuaför - Kadın', 'Geçici bukle veya dalgalar oluşturan maşa ile şekillendirme.', 30),
('Gelin Saçı', 'Kuaför - Kadın', 'En özel gününüz için profesyonel gelin saç tasarımı.', 90),
('Nişan Saçı', 'Kuaför - Kadın', 'Nişan törenleriniz için özel saç modeli ve tasarımı.', 75);

-- KUAFÖR HİZMETLERİ - ERKEK
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Saç Kesimi (Erkek)', 'Kuaför - Erkek', 'Erkekler için modern ve klasik saç kesimi hizmeti.', 30),
('Sakal Kesimi', 'Kuaför - Erkek', 'Sakalınızı düzenleyen ve şekillendiren profesyonel kesim.', 20),
('Sakal Şekillendirme', 'Kuaför - Erkek', 'Yüz hatlarınıza uygun sakal tasarımı ve şekillendirme.', 25),
('Traş', 'Kuaför - Erkek', 'Geleneksel ustura ile profesyonel berber traşı.', 25),
('Bıyık Kesimi', 'Kuaför - Erkek', 'Bıyık düzenleme ve şekillendirme hizmeti.', 15),
('Saç Boyama (Erkek)', 'Kuaför - Erkek', 'Erkekler için saç boyama ve beyaz kapatma işlemi.', 45);

-- TIRNAK HİZMETLERİ - MANİKÜR
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Klasik Manikür', 'Tırnak - Manikür', 'El bakımı, tırnak kesimi, şekilendirme ve oje uygulaması.', 45),
('Spa Manikür', 'Tırnak - Manikür', 'Peeling, maske ve masaj içeren lüks el bakımı.', 60),
('Protez Tırnak (Jel Tırnak)', 'Tırnak - Manikür', 'Dayanıklı ve estetik jel tırnak uygulaması.', 90),
('Kalıcı Oje', 'Tırnak - Manikür', 'UV lambayla sertleşen, 2-3 hafta dayanıklı oje.', 45),
('Oje', 'Tırnak - Manikür', 'Klasik oje uygulama hizmeti.', 20),
('Tırnak Sanatı (Nail Art)', 'Tırnak - Manikür', 'Tırnaklarınıza özel tasarım ve süsleme işlemi.', 60),
('French Manikür', 'Tırnak - Manikür', 'Doğal ve zarif French tırnak tasarımı.', 50),
('Amerikan Manikür', 'Tırnak - Manikür', 'Modern ve doğal görünümlü Amerikan tarzı manikür.', 50);

-- TIRNAK HİZMETLERİ - PEDİKÜR
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Klasik Pedikür', 'Tırnak - Pedikür', 'Ayak bakımı, tırnak kesimi ve oje uygulaması.', 60),
('Spa Pedikür', 'Tırnak - Pedikür', 'Peeling, maske ve masaj içeren özel ayak bakımı.', 75),
('Kalıcı Oje (Ayak)', 'Tırnak - Pedikür', 'Ayak tırnaklarına kalıcı oje uygulaması.', 45),
('Protez Tırnak (Ayak)', 'Tırnak - Pedikür', 'Ayak tırnaklarına jel tırnak uygulaması.', 90),
('Nasır Tedavisi', 'Tırnak - Pedikür', 'Ayaklardaki nasırların profesyonel temizliği.', 30),
('Ayak Bakımı', 'Tırnak - Pedikür', 'Kapsamlı ayak temizliği ve bakım işlemi.', 45);

-- CİLT BAKIMI - YÜZ
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Klasik Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Temizlik, peeling, maske ve nemlendirici içeren temel yüz bakımı.', 60),
('Hydrafacial', 'Cilt Bakımı - Yüz', 'Derin temizlik ve nem veren gelişmiş cilt bakım teknolojisi.', 60),
('Oksijen Terapisi', 'Cilt Bakımı - Yüz', 'Cildi canlandıran ve yenileyen oksijen bazlı tedavi.', 45),
('Altın Maske', 'Cilt Bakımı - Yüz', 'Cildi sıkılaştıran ve ışıltı veren altın içerikli maske.', 50),
('Karbon Peeling', 'Cilt Bakımı - Yüz', 'Gözenekleri temizleyen ve sıkılaştıran lazer tedavisi.', 45),
('Kimyasal Peeling', 'Cilt Bakımı - Yüz', 'Ölü derileri atarak cildi yenileyen kimyasal uygulama.', 40),
('Dermapen', 'Cilt Bakımı - Yüz', 'Mikro iğnelerle cildi yenileyen ve iz gidermede etkili tedavi.', 60),
('Mikrodermabrazyon', 'Cilt Bakımı - Yüz', 'Cildin üst tabakasını nazikçe kazıyarak yenileyen işlem.', 45),
('Gençleştirici Bakım', 'Cilt Bakımı - Yüz', 'Yaşlanma karşıtı özel serumlar ve maskeler içeren bakım.', 75),
('Akne Tedavisi', 'Cilt Bakımı - Yüz', 'Sivilce ve akne problemlerine yönelik özel bakım programı.', 60),
('Leke Tedavisi', 'Cilt Bakımı - Yüz', 'Cilt lekelerini azaltan ve tonu eşitleyen tedavi.', 60),
('Nemlendirici Bakım', 'Cilt Bakımı - Yüz', 'Kuru ciltler için yoğun nem veren bakım.', 50),
('Yağlı Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Yağ dengesini düzenleyen ve gözenekleri temizleyen bakım.', 55),
('Kuru Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Kuru ve hassas ciltler için özel nemlendirici bakım.', 55),
('Hassas Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Hassas ciltler için yatıştırıcı ve koruyucu bakım.', 55),
('Göz Çevresi Bakımı', 'Cilt Bakımı - Yüz', 'Göz altı torbası ve kırışıklıklarına özel bakım.', 30);

-- CİLT BAKIMI - VÜCUT
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Vücut Peeling', 'Cilt Bakımı - Vücut', 'Vücuttaki ölü derileri temizleyen peeling uygulaması.', 45),
('Vücut Masajı', 'Cilt Bakımı - Vücut', 'Rahatlatıcı ve kan dolaşımını hızlandıran masaj.', 60),
('Selülit Masajı', 'Cilt Bakımı - Vücut', 'Selülitleri azaltmaya yönelik özel masaj tekniği.', 60),
('Sıkılaştırıcı Bakım', 'Cilt Bakımı - Vücut', 'Vücut cildini sıkılaştıran ve şekillendiren bakım.', 75),
('Nemlendirici Vücut Bakımı', 'Cilt Bakımı - Vücut', 'Vücut cildinize yoğun nem veren bakım.', 60);

-- MASAJ HİZMETLERİ
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('İsveç Masajı', 'Masaj', 'Klasik ve rahatlatıcı tüm vücut masajı tekniği.', 60),
('Tayland Masajı', 'Masaj', 'Esneklik ve enerji veren geleneksel Tayland masajı.', 90),
('Refleksoloji', 'Masaj', 'Ayak tabanı noktalarına basınçla yapılan şifa masajı.', 45),
('Aromaterapi Masajı', 'Masaj', 'Uçucu yağlarla yapılan rahatlatıcı ve terapötik masaj.', 75),
('Hot Stone Masajı', 'Masaj', 'Sıcak taşlarla kasları gevşeten özel masaj tekniği.', 90),
('Derin Doku Masajı', 'Masaj', 'Kas gerginliklerini çözen yoğun basınçlı masaj.', 75),
('Spor Masajı', 'Masaj', 'Sporcular için kas iyileşmesine yardımcı masaj.', 60),
('Hamam Masajı', 'Masaj', 'Geleneksel Türk hamamında köpüklü masaj.', 45),
('Balinese Masajı', 'Masaj', 'Bali adasından gelen derin rahatlatıcı masaj tekniği.', 90),
('Lomi Lomi Masajı', 'Masaj', 'Hawaii geleneksel ritimli ve akışkan masaj tekniği.', 90);

-- EPİLASYON - AĞDA
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Bacak Ağda', 'Epilasyon - Ağda', 'Yarım bacak ağda epilasyon işlemi.', 30),
('Tüm Bacak Ağda', 'Epilasyon - Ağda', 'Tam bacak ağda epilasyon işlemi.', 45),
('Kol Ağda', 'Epilasyon - Ağda', 'Kol bölgesi ağda epilasyon işlemi.', 25),
('Bikini Ağda', 'Epilasyon - Ağda', 'Bikini bölgesi ağda epilasyon işlemi.', 20),
('Brazilian Ağda', 'Epilasyon - Ağda', 'Tam bikini bölgesi ağda epilasyon işlemi.', 30),
('Bıyık Üstü Ağda', 'Epilasyon - Ağda', 'Üst dudak bölgesi ağda epilasyon işlemi.', 10),
('Kaş Arası Ağda', 'Epilasyon - Ağda', 'Kaşlar arası bölge ağda epilasyon işlemi.', 10),
('Yanaklar Ağda', 'Epilasyon - Ağda', 'Yanak bölgesi ağda epilasyon işlemi.', 15),
('Gerdanlık Ağda', 'Epilasyon - Ağda', 'Boyun bölgesi ağda epilasyon işlemi.', 15),
('Koltuk Altı Ağda', 'Epilasyon - Ağda', 'Koltuk altı bölgesi ağda epilasyon işlemi.', 15),
('Göğüs Ağda', 'Epilasyon - Ağda', 'Göğüs bölgesi ağda epilasyon işlemi.', 30),
('Sırt Ağda', 'Epilasyon - Ağda', 'Sırt bölgesi ağda epilasyon işlemi.', 35),
('Karın Ağda', 'Epilasyon - Ağda', 'Karın bölgesi ağda epilasyon işlemi.', 25);

-- EPİLASYON - LAZER
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Bacak Lazer', 'Epilasyon - Lazer', 'Yarım bacak lazer epilasyon işlemi.', 40),
('Tüm Bacak Lazer', 'Epilasyon - Lazer', 'Tam bacak lazer epilasyon işlemi.', 60),
('Kol Lazer', 'Epilasyon - Lazer', 'Kol bölgesi lazer epilasyon işlemi.', 30),
('Bikini Lazer', 'Epilasyon - Lazer', 'Bikini bölgesi lazer epilasyon işlemi.', 25),
('Brazilian Lazer', 'Epilasyon - Lazer', 'Tam bikini bölgesi lazer epilasyon işlemi.', 35),
('Bıyık Üstü Lazer', 'Epilasyon - Lazer', 'Üst dudak bölgesi lazer epilasyon işlemi.', 15),
('Çene Lazer', 'Epilasyon - Lazer', 'Çene bölgesi lazer epilasyon işlemi.', 15),
('Yanaklar Lazer', 'Epilasyon - Lazer', 'Yanak bölgesi lazer epilasyon işlemi.', 20),
('Koltuk Altı Lazer', 'Epilasyon - Lazer', 'Koltuk altı bölgesi lazer epilasyon işlemi.', 20),
('Göğüs Lazer', 'Epilasyon - Lazer', 'Göğüs bölgesi lazer epilasyon işlemi.', 35),
('Sırt Lazer', 'Epilasyon - Lazer', 'Sırt bölgesi lazer epilasyon işlemi.', 45),
('Karın Lazer', 'Epilasyon - Lazer', 'Karın bölgesi lazer epilasyon işlemi.', 30);

-- KAŞ & KİRPİK
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Kaş Tasarım', 'Kaş & Kirpik', 'Yüz şeklinize uygun profesyonel kaş tasarımı.', 30),
('Kaş Alma (İplik)', 'Kaş & Kirpik', 'İplik yöntemiyle kaş alma ve şekillendirme.', 15),
('Kaş Boyama', 'Kaş & Kirpik', 'Kaşlarınızı belirginleştiren boya uygulaması.', 20),
('Microblading', 'Kaş & Kirpik', 'Kalıcı kaş tasarımı için mikro pigmentasyon tekniği.', 120),
('Kaş Laminasyonu', 'Kaş & Kirpik', 'Kaşları düzenli ve dolgun gösteren laminasyon işlemi.', 45),
('Kirpik Lifting', 'Kaş & Kirpik', 'Kirpiklere kıvrım veren kalıcı lifting işlemi.', 60),
('Kirpik Botoksu', 'Kaş & Kirpik', 'Kirpikleri besleyen ve güçlendiren botoks tedavisi.', 45),
('Kirpik Perması', 'Kaş & Kirpik', 'Kirpiklere kalıcı kıvrım kazandıran perma işlemi.', 50),
('Takma Kirpik', 'Kaş & Kirpik', 'Özel günler için geçici takma kirpik uygulaması.', 30),
('Ipek Kirpik', 'Kaş & Kirpik', 'Doğal ve kalıcı ipek kirpik uygulaması.', 90),
('Kirpik Boyama', 'Kaş & Kirpik', 'Kirpikleri belirginleştiren boya uygulaması.', 20);

-- ÖZEL BAKIM & TEDAVİ
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Gelin Paketi', 'Özel Paket', 'En özel gününüz için kapsamlı güzellik paketi.', 240),
('Nişan Paketi', 'Özel Paket', 'Nişan töreniniz için özel hazırlanmış bakım paketi.', 180),
('Damat Paketi', 'Özel Paket', 'Damatlar için özel hazırlanmış bakım paketi.', 120),
('Gün Paketi', 'Özel Paket', 'Kendinizi şımartmak için tam gün spa paketi.', 360),
('G5 Masajı', 'Özel Tedavi', 'Vibrasyon teknolojisi ile selülit ve yağ azaltma masajı.', 45),
('Kupa Terapi', 'Özel Tedavi', 'Geleneksel kupa tedavisi ile kas gevşetme ve detoks.', 40),
('Radyofrekans (RF)', 'Özel Tedavi', 'Cildi sıkılaştıran ve kırışıklıkları azaltan RF tedavisi.', 60),
('Kavitasyon', 'Özel Tedavi', 'Ultrason dalgalarıyla yağ hücrelerini parçalayan tedavi.', 45),
('Mezotopi', 'Özel Tedavi', 'Bölgesel incelme için özel iğneli tedavi yöntemi.', 30),
('PRP Tedavisi', 'Özel Tedavi', 'Kendi kanınızdan elde edilen plazma ile yenilenme tedavisi.', 60),
('Mezoterapi', 'Özel Tedavi', 'Vitamin ve mineraller içeren enjeksiyon tedavisi.', 45),
('Medikal Cilt Bakımı', 'Özel Tedavi', 'Dermatolog kontrolünde yapılan tıbbi cilt bakımı.', 75);

-- HAMAM & SPA
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Hamam', 'Hamam & Spa', 'Geleneksel Türk hamamı deneyimi.', 90),
('Kese-Köpük', 'Hamam & Spa', 'Kese ve köpük masajı ile derin temizlik.', 60),
('Türk Hamamı', 'Hamam & Spa', 'Otantik Türk hamamı ritüeli.', 120),
('Sauna', 'Hamam & Spa', 'Kuru sauna ile vücut arındırma ve rahatlatma.', 30),
('Buhar Odası', 'Hamam & Spa', 'Buhar ile gözenek açma ve detoks.', 20),
('Jakuzi', 'Hamam & Spa', 'Hidromasaj ile kas gevşetme ve rahatlama.', 30);

-- MAKYAJ
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Günlük Makyaj', 'Makyaj', 'Doğal ve hafif günlük makyaj uygulaması.', 30),
('Gece Makyajı', 'Makyaj', 'Özel günler ve davetler için göz alıcı makyaj.', 45),
('Gelin Makyajı', 'Makyaj', 'Düğün gününüz için profesyonel gelin makyajı.', 60),
('Nişan Makyajı', 'Makyaj', 'Nişan töreniniz için özel makyaj uygulaması.', 50),
('Smokey Makyaj', 'Makyaj', 'Göz alıcı smokey göz makyajı tekniği.', 40),
('Kalıcı Makyaj', 'Makyaj', 'Kaş, eyeliner veya dudak için kalıcı makyaj.', 120),
('Airbrush Makyaj', 'Makyaj', 'Hava fırçası ile kusursuz makyaj uygulaması.', 45);

-- AYAK & EL BAKIMI
INSERT INTO public.service_categories (name, category, description, average_duration_minutes) VALUES
('Parafin Tedavisi', 'El & Ayak Bakımı', 'Sıcak parafin ile el veya ayak bakımı.', 30),
('El Bakımı', 'El & Ayak Bakımı', 'Kapsamlı el temizliği ve nemlendirme bakımı.', 40),
('Ayak Bakımı', 'El & Ayak Bakımı', 'Profesyonel ayak bakımı ve peeling.', 50),
('Nasır Tedavisi', 'El & Ayak Bakımı', 'Ayaklardaki nasırların profesyonel tedavisi.', 30),
('Topuk Çatlağı Bakımı', 'El & Ayak Bakımı', 'Topuk çatlaklarını onarıcı özel bakım.', 40);

-- 9. Update discovery views to work with new structure
DROP VIEW IF EXISTS popular_services;

CREATE OR REPLACE VIEW popular_services AS
SELECT
  sc.id,
  sc.name,
  sc.icon,
  COUNT(DISTINCT vs.venue_id) as venue_count,
  0 as search_count
FROM service_categories sc
LEFT JOIN venue_services vs ON sc.id = vs.service_category_id
WHERE vs.is_available = true
GROUP BY sc.id, sc.name, sc.icon
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
