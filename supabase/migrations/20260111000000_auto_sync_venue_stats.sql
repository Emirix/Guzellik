-- Migration: Auto Sync Venue Stats
-- Description: Ensures ratings, review counts and follower counts are always in sync via triggers

-- 1. Kolonun eksik olma ihtimaline karşı ekleyelim
ALTER TABLE venues ADD COLUMN IF NOT EXISTS follower_count INTEGER DEFAULT 0;

-- 2. İlk seferlik senkronizasyon (Mevcut verileri düzeltmek için)
UPDATE venues v SET
  rating = COALESCE((SELECT AVG(r.rating) FROM reviews r WHERE r.venue_id = v.id), 0),
  review_count = (SELECT COUNT(*) FROM reviews r WHERE r.venue_id = v.id),
  follower_count = (SELECT COUNT(*) FROM follows f WHERE f.venue_id = v.id);

-- 3. Rating & Review Count için Fonksiyon ve Trigger
CREATE OR REPLACE FUNCTION update_venue_rating_stats()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE venues
  SET
    rating = (SELECT COALESCE(AVG(rating), 0) FROM reviews WHERE venue_id = COALESCE(NEW.venue_id, OLD.venue_id)),
    review_count = (SELECT COUNT(*) FROM reviews WHERE venue_id = COALESCE(NEW.venue_id, OLD.venue_id))
  WHERE id = COALESCE(NEW.venue_id, OLD.venue_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_update_venue_rating_stats ON reviews;
CREATE TRIGGER trigger_update_venue_rating_stats
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_venue_rating_stats();

-- 4. Takipçi Sayısı için Fonksiyon ve Trigger
CREATE OR REPLACE FUNCTION update_venue_follower_stats()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE venues
  SET follower_count = (SELECT COUNT(*) FROM follows WHERE venue_id = COALESCE(NEW.venue_id, OLD.venue_id))
  WHERE id = COALESCE(NEW.venue_id, OLD.venue_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_update_venue_follower_stats ON follows;
CREATE TRIGGER trigger_update_venue_follower_stats
  AFTER INSERT OR DELETE ON follows
  FOR EACH ROW EXECUTE FUNCTION update_venue_follower_stats();
