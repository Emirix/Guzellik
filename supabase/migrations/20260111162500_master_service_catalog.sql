-- Migration: Master Service Catalog v2
-- Description: Refreshes the service catalog with a comprehensive list of ~54 services across all beauty sectors.
-- This replaces the initial limited catalog.

-- 1. Temizlik: Mevcut hizmet verilerini sıfırla
TRUNCATE public.services, public.venue_services, public.service_categories RESTART IDENTITY CASCADE;

-- 2. Yeni Genişletilmiş Hizmet Kataloğunu Ekle
DO $$
DECLARE
    v_kuafor_id UUID;
    v_tirnak_id UUID;
    v_cilt_id UUID;
    v_epilasyon_id UUID;
    v_kas_kirpik_id UUID;
    v_estetik_id UUID;
    v_ayak_id UUID;
    v_guzellik_id UUID;
BEGIN
    SELECT id INTO v_kuafor_id FROM public.venue_categories WHERE slug = 'kadin-kuaforleri';
    SELECT id INTO v_tirnak_id FROM public.venue_categories WHERE slug = 'tirnak-studyolari';
    SELECT id INTO v_cilt_id FROM public.venue_categories WHERE slug = 'cilt-bakim-merkezleri';
    SELECT id INTO v_epilasyon_id FROM public.venue_categories WHERE slug = 'epilasyon-merkezleri';
    SELECT id INTO v_kas_kirpik_id FROM public.venue_categories WHERE slug = 'kirpik-kas-studyo';
    SELECT id INTO v_estetik_id FROM public.venue_categories WHERE slug = 'estetik-yerleri';
    SELECT id INTO v_ayak_id FROM public.venue_categories WHERE slug = 'ayak-bakim';
    SELECT id INTO v_guzellik_id FROM public.venue_categories WHERE slug = 'guzellik-salonu';

INSERT INTO public.service_categories (name, sub_category, description, average_duration_minutes, icon, image_url, venue_category_id) VALUES
-- KUAFÖR - KESİM & ŞEKİL
('Saç Kesimi (Kadın)', 'Kuaför - Kesim & Şekil', 'Yüz hattına uygun modern kadın saç kesimi ve yıkama.', 45, 'content_cut', 'https://images.unsplash.com/photo-1560869713-7d0a29430863?q=80&w=1000', v_kuafor_id),
('Kakül / Perçem Kesimi', 'Kuaför - Kesim & Şekil', 'Sadece ön bölge kakül veya perçem düzeltme işlemi.', 15, 'content_cut', 'https://images.unsplash.com/photo-1562322140-8baeececf3df?q=80&w=1000', v_kuafor_id),
('Fön (Düz/Dalgalı)', 'Kuaför - Kesim & Şekil', 'Klasik düz veya doğal dalgalı profesyonel fön.', 30, 'air', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000', v_kuafor_id),
('Vag Fön / Hollywood Style', 'Kuaför - Kesim & Şekil', 'Belirgin ve hacimli Hollywood dalgaları.', 45, 'movie_filter', 'https://images.unsplash.com/photo-1562322140-8baeececf3df?q=80&w=1000', v_kuafor_id),
('Maşa', 'Kuaför - Kesim & Şekil', 'Şekillendirici maşa ile geçici bukleler.', 40, 'waves', 'https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?q=80&w=1000', v_kuafor_id),
('Topuz (Özel Gün)', 'Kuaför - Kesim & Şekil', 'Davet ve özel günler için şık topuz tasarımları.', 60, 'stars', 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=1000', v_kuafor_id),
('Gelin Saçı & Prova', 'Kuaför - Kesim & Şekil', 'Düğün günü saç tasarımı ve öncesinde prova seansı.', 150, 'card_giftcard', 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1000', v_kuafor_id),

-- KUAFÖR - RENKLENDİRME
('Dip Boyası', 'Kuaför - Boyama', 'Kök bölgesindeki beyaz veya doğal saçların kapatılması.', 60, 'colorize', 'https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1000', v_kuafor_id),
('Tam Boya', 'Kuaför - Boyama', 'Tüm saçın seçilen tek renge boyanması işlemi.', 90, 'palette', 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?q=80&w=1000', v_kuafor_id),
('Ombre & Balyaj', 'Kuaför - Renklendirme', 'Diplerden uçlara doğru kademeli açma ve tonlama.', 180, 'layers', 'https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?q=80&w=1000', v_kuafor_id),
('Röfle / Meç', 'Kuaför - Renklendirme', 'Saç aralarına uygulanan sık ve ince paketlerle açma.', 150, 'colorize', 'https://images.unsplash.com/photo-1527799822340-30276d9101d2?q=80&w=1000', v_kuafor_id),
('Babylights', 'Kuaför - Renklendirme', 'Çok ince ve doğal geçişli, güneşte açılmış efekti veren teknik.', 180, 'brightness_high', 'https://images.unsplash.com/photo-1522338140262-f46f5913618a?q=80&w=1000', v_kuafor_id),

-- KUAFÖR - BAKIM & KAYNAK
('Keratin Bakımı', 'Kuaför - Bakım', 'Yıpranmış saçları onaran ve düzleştiren kalıcı bakım.', 120, 'smooth', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000', v_kuafor_id),
('Saç Botoksu', 'Kuaför - Bakım', 'Saça dolgunluk kazandıran yoğun vitamin ve keratin yüklemesi.', 90, 'vaccines', 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=1000', v_kuafor_id),
('Olaplex Onarım', 'Kuaför - Bakım', 'Kopmuş saç bağlarını birleştiren profesyonel onarım sistemi.', 60, 'medical_services', 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=1000', v_kuafor_id),
('Mikro Kaynak', 'Kuaför - Kaynak', 'En doğal görünümlü, mikro kapsül saç uzatma tekniği.', 240, 'grid_view', 'https://images.unsplash.com/photo-1582095133179-bfd08e2ec6b3?q=80&w=1000', v_kuafor_id),

-- TIRNAK SİSTEMLERİ
('Klasik Manikür', 'Tırnak - Manikür', 'Tırnak eti temizliği, şekillendirme ve klasik oje.', 45, 'clean_hands', 'https://images.unsplash.com/photo-1604654894610-df49ff66a7cb?q=80&w=1000', v_tirnak_id),
('Kuru (Rus) Manikürü', 'Tırnak - Manikür', 'Cihazla tırnak eti temizliği ve derin temizlik.', 50, 'dry_cleaning', 'https://images.unsplash.com/photo-1604654894610-df49ff66a7cb?q=80&w=1000', v_tirnak_id),
('Kalıcı Oje Uygulama', 'Tırnak - Manikür', 'UV lambayla kuruyan, 3 haftaya kadar dayanan oje.', 45, 'brush', 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?q=80&w=1000', v_tirnak_id),
('Protez Tırnak (Jel)', 'Tırnak - Protez', 'Tırnak uzatma ve güçlendirme amaçlı jel sistemi.', 90, 'category', 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?q=80&w=1000', v_tirnak_id),
('Protez Tırnak Bakımı', 'Tırnak - Protez', 'Zamanı gelen protez tırnakların dipten doldurulması.', 60, 'build', 'https://images.unsplash.com/photo-1604654894610-df49ff66a7cb?q=80&w=1000', v_tirnak_id),
('Nail Art (Detaylı)', 'Tırnak - Sanat', 'Tüm tırnaklara karmaşık desen ve taş süsleme.', 45, 'art_track', 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?q=80&w=1000', v_tirnak_id),
('Klasik Pedikür', 'Tırnak - Pedikür', 'Ayak tırnak bakımı, topuk temizliği ve oje.', 60, 'footprint', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000', v_tirnak_id),
('Spa Pedikür', 'Tırnak - Pedikür', 'Özel tuzlar, peeling ve masaj içeren lüks ayak bakımı.', 75, 'spa', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000', v_tirnak_id),

-- CİLT BAKIMI & İNCELME
('Klasik Cilt Bakımı', 'Cilt Bakımı - Yüz', 'Temel temizlik, peeling, maske ve nemlendirici.', 60, 'face', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000', v_cilt_id),
('Hydrafacial', 'Cilt Bakımı - Yüz', 'Vakum sistemiyle derin temizlik ve serum ile besleme.', 60, 'water_drop', 'https://images.unsplash.com/photo-1515377905703-c473232bbad1?q=80&w=1000', v_cilt_id),
('Karbon Peeling', 'Cilt Bakımı - Yüz', 'Lazer ve karbon ile gözenek sıkılaştırma ve renk açma.', 45, 'blur_on', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000', v_cilt_id),
('Dermapen', 'Cilt Bakımı - Yüz', 'Mikro iğneleme ile cilt yenileme ve skar tedavisi.', 60, 'grid_4x4', 'https://images.unsplash.com/photo-1544161515-4af6b1d462c2?q=80&w=1000', v_cilt_id),
('Anti-Aging Bakım', 'Cilt Bakımı - Yüz', 'Yaşlanma karşıtı yoğun kolajen ve vitamin bakımı.', 75, 'auto_awesome', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000', v_cilt_id),
('G5 Selülit Masajı', 'İncelme - Bölgesel', 'Vibrasyonlu masaj ile selülit giderme ve sıkılaştırma.', 40, 'vibration', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000', v_cilt_id),
('Lenf Drenaj', 'İncelme - Bölgesel', 'Basınçlı hava ile ödem atma ve dolaşım hızlandırma.', 30, 'air', 'https://images.unsplash.com/photo-1515377905703-c473232bbad1?q=80&w=1000', v_cilt_id),
('Heykeltıraş Seansı', 'İncelme - Bölgesel', 'Yüksek frekanslı ses dalgalarıyla bölgesel incelme.', 60, 'accessibility', 'https://images.unsplash.com/photo-1512290923902-8a9f81da236c?q=80&w=1000', v_cilt_id),

-- EPİLASYON
('Tüm Vücut Lazer (Bitme Garantili)', 'Epilasyon - Lazer', 'Komple vücut için paket halinde lazer epilasyon.', 90, 'bolt', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000', v_epilasyon_id),
('Yarım Bacak Lazer', 'Epilasyon - Lazer', 'Diz altı veya diz üstü lazer epilasyon seansı.', 30, 'bolt', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000', v_epilasyon_id),
('Koltuk Altı Lazer', 'Epilasyon - Lazer', 'Koltuk altı bölgesi için lazer epilasyon seansı.', 15, 'bolt', 'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?q=80&w=1000', v_epilasyon_id),
('Tüm Vücut Ağda', 'Epilasyon - Ağda', 'Naturel çamsakızı veya sir ağda ile tüm vücut temizliği.', 60, 'electric_bolt', 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=1000', v_epilasyon_id),

-- KAŞ & KİRPİK
('Kaş Tasarımı & Alımı', 'Kaş & Kirpik - Tasarım', 'Yüz hattına göre ölçülü kaş alımı ve tasarımı.', 25, 'remove_red_eye', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000', v_kas_kirpik_id),
('Kaş Laminasyonu', 'Kaş & Kirpik - Tasarım', 'Kaşların yukarı taranıp formunun sabitlenmesi.', 45, 'style', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000', v_kas_kirpik_id),
('Kirpik Lifting', 'Kaş & Kirpik - Bakım', 'Kendi kirpiklerinize doğal kıvrım ve uzunluk verme.', 60, 'expand_less', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000', v_kas_kirpik_id),
('İpek Kirpik (Klasik)', 'Kaş & Kirpik - İpek Kirpik', 'Tekli ipek kirpik ekleme ile doğal maskara efekti.', 90, 'star', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000', v_kas_kirpik_id),
('İpek Kirpik (Volüm)', 'Kaş & Kirpik - İpek Kirpik', 'Daha yoğun ve belirgin ipek kirpik uygulaması.', 120, 'auto_awesome', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000', v_kas_kirpik_id),

-- ESTETİK & MAKYAJ
('Medikal Cilt Bakımı', 'Estetik - Uygulama', 'Uzman kontrolünde yapılan tıbbi cilt temizliği.', 75, 'medical_services', 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?q=80&w=1000', v_estetik_id),
('Microblading', 'Makyaj - Kalıcı', 'Kalıcı kaş kıl tekniği ile doğal kaş formu.', 120, 'edit', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000', v_estetik_id),
('Dudak Renklendirme', 'Makyaj - Kalıcı', 'Dudakların doğal tonunu belirginleştirme seansı.', 120, 'history_edu', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000', v_estetik_id),
('Günlük Makyaj', 'Makyaj - Uygulama', 'Hafif ve taze günlük makyaj uygulaması.', 30, 'brush', 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?q=80&w=1000', v_estetik_id),
('Gece Makyajı', 'Makyaj - Uygulama', 'Özel gün ve davetler için daha yoğun makyaj.', 60, 'auto_fix_high', 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=1000', v_estetik_id),

-- GÜZELLİK SALONU ÖZEL
('Ekspres Cilt Bakımı', 'Güzellik Salonu - Genel', 'Zamanı kısıtlı olanlar için 30 dakikalık canlandırma.', 30, 'flash_on', 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=1000', v_guzellik_id),
('Yabancı Dil Destekli Servis', 'Güzellik Salonu - Genel', 'Yabancı misafirler için tercüman eşliğinde hizmet.', 30, 'translate', 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=1000', v_guzellik_id),
('Gelin Paket (Saç+Makyaj+Tırnak)', 'Güzellik Salonu - Paket', 'Düğün günü için komple hazırlık paketi.', 360, 'celebration', 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1000', v_guzellik_id),
('Yenilenme Günü Paketi', 'Güzellik Salonu - Paket', 'Cilt bakımı, manikür ve fön içeren canlandırma günü.', 180, 'auto_awesome', 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=1000', v_guzellik_id),

-- MEDİKAL AYAK BAKIMI
('Medikal Ayak Bakımı (Podoloji)', 'Ayak Bakım - Medikal', 'Ayak sağlığı uzmanı tarafından yapılan genel bakım.', 60, 'medical_services', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000', v_ayak_id),
('Nasır Temizliği', 'Ayak Bakım - Medikal', 'Ağrılı nasırların profesyonel cihazla temizlenmesi.', 30, 'healing', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000', v_ayak_id),
('Batık Tırnak Tedavisi', 'Ayak Bakım - Medikal', 'Ameliyatsız batık tırnak düzeltme (Tel/Orca sistemi).', 45, 'medical_information', 'https://images.unsplash.com/photo-1616394158624-a2ba99a79e58?q=80&w=1000', v_ayak_id),
('Diyabetik Ayak Bakımı', 'Ayak Bakım - Medikal', 'Diyabet hastaları için özel hassas ayak bakımı.', 60, 'self_care', 'https://images.unsplash.com/photo-1519415510236-855909a04bc6?q=80&w=1000', v_ayak_id);

-- 3. Örnek İşletmelere Bazı Hizmetleri Bağla
INSERT INTO public.venue_services (venue_id, service_category_id, custom_price, custom_duration_minutes)
SELECT '11111111-1111-1111-1111-111111111111', id, 500, 45 FROM service_categories WHERE name = 'Saç Kesimi (Kadın)' LIMIT 1;
INSERT INTO public.venue_services (venue_id, service_category_id, custom_price, custom_duration_minutes)
SELECT '11111111-1111-1111-1111-111111111111', id, 250, 30 FROM service_categories WHERE name = 'Fön (Düz/Dalgalı)' LIMIT 1;

INSERT INTO public.venue_services (venue_id, service_category_id, custom_price, custom_duration_minutes)
SELECT '22222222-2222-2222-2222-222222222222', id, 1500, 60 FROM service_categories WHERE name = 'Hydrafacial' LIMIT 1;

INSERT INTO public.venue_services (venue_id, service_category_id, custom_price, custom_duration_minutes)
SELECT '33333333-3333-3333-3333-333333333333', id, 800, 90 FROM service_categories WHERE name = 'Protez Tırnak (Jel)' LIMIT 1;

END $$;
