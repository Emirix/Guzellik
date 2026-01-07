-- Create functions for photo likes management

-- Function to increment photo likes
CREATE OR REPLACE FUNCTION increment_photo_likes(photo_id UUID)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE venue_photos
  SET likes_count = likes_count + 1
  WHERE id = photo_id;
END;
$$;

-- Function to decrement photo likes (with minimum of 0)
CREATE OR REPLACE FUNCTION decrement_photo_likes(photo_id UUID)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE venue_photos
  SET likes_count = GREATEST(0, likes_count - 1)
  WHERE id = photo_id;
END;
$$;
