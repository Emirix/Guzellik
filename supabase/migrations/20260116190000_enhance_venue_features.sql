-- 1. Add new features
INSERT INTO public.venue_features (name, slug, icon, category, description, display_order) VALUES
('VIP Oda', 'vip-oda', 'star', 'comfort', 'Özel hizmetler için VIP oda seçeneği', 30),
('Bahçe/Teras', 'bahce-teras', 'deck', 'comfort', 'Açık hava kullanım alanı', 31),
('Bebek Bakım Odası', 'bebek-bakim-odası', 'child_care', 'comfort', 'Bebekli misafirler için özel bakım odası', 32),
('Mescid', 'mescid', 'temple_hindu', 'comfort', 'İbadet alanı mevcut', 33),
('Kadınlara Özel Seans', 'kadinlara-ozel-seans', 'woman', 'service', 'Belirli saatlerde sadece kadınlara özel seanslar', 34),
('Evcil Hayvan Dostu', 'evcil-hayvan-dostu', 'pets', 'comfort', 'Küçük evcil hayvanlar kabul edilir', 35),
('İngilizce Bilen Personel', 'ingilizce-bilen-personel', 'translate', 'communication', 'English speaking staff available', 36),
('Arapça Bilen Personel', 'arapca-bilen-personel', 'translate', 'communication', 'Arapça bilen personel mevcut', 37)
ON CONFLICT (slug) DO NOTHING;

-- 2. Create sync trigger
CREATE OR REPLACE FUNCTION public.sync_venue_features_to_array()
RETURNS TRIGGER AS $$
BEGIN
  -- We use NEW for INSERT and UPDATE, OLD for DELETE.
  -- COALESCE handles all cases.
  UPDATE public.venues
  SET features = (
    SELECT COALESCE(jsonb_agg(vf.slug), '[]'::jsonb)
    FROM public.venue_selected_features vsf
    JOIN public.venue_features vf ON vf.id = vsf.feature_id
    WHERE vsf.venue_id = COALESCE(NEW.venue_id, OLD.venue_id)
  )
  WHERE id = COALESCE(NEW.venue_id, OLD.venue_id);
  
  RETURN NULL; -- result is ignored since this is an AFTER trigger
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_venue_features ON public.venue_selected_features;

CREATE TRIGGER trg_sync_venue_features
AFTER INSERT OR UPDATE OR DELETE ON public.venue_selected_features
FOR EACH ROW EXECUTE FUNCTION public.sync_venue_features_to_array();
