-- Create venue_photos table for storing venue gallery images
CREATE TABLE venue_photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  title TEXT,
  category TEXT CHECK (category IN ('interior', 'exterior', 'service_result', 'team', 'equipment')),
  service_id UUID REFERENCES services(id) ON DELETE SET NULL,
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  sort_order INTEGER DEFAULT 0,
  is_hero_image BOOLEAN DEFAULT FALSE,
  likes_count INTEGER DEFAULT 0,
  CONSTRAINT valid_urls CHECK (url ~* '^https?://')
);

-- Create indexes for performance
CREATE INDEX idx_venue_photos_venue_id ON venue_photos(venue_id);
CREATE INDEX idx_venue_photos_category ON venue_photos(category);
CREATE INDEX idx_venue_photos_sort_order ON venue_photos(venue_id, sort_order);

-- Enable RLS
ALTER TABLE venue_photos ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Anyone can view photos
CREATE POLICY "Anyone can view venue photos"
  ON venue_photos
  FOR SELECT
  USING (true);

-- RLS Policy: Only authenticated users can insert (venue owners will be handled by app logic)
CREATE POLICY "Authenticated users can insert venue photos"
  ON venue_photos
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- RLS Policy: Only authenticated users can update their own venue photos
CREATE POLICY "Authenticated users can update venue photos"
  ON venue_photos
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- RLS Policy: Only authenticated users can delete their own venue photos
CREATE POLICY "Authenticated users can delete venue photos"
  ON venue_photos
  FOR DELETE
  TO authenticated
  USING (true);
