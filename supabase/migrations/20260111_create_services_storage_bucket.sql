-- Create venue-services bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'venue-services',
  'venue-services',
  true,
  2097152, -- 2MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- RLS Policies for venue-services
DROP POLICY IF EXISTS "Anyone can view venue services photos" ON storage.objects;
CREATE POLICY "Anyone can view venue services photos"
  ON storage.objects FOR SELECT USING (bucket_id = 'venue-services');

DROP POLICY IF EXISTS "Owners can manage their venue services photos" ON storage.objects;
CREATE POLICY "Owners can manage their venue services photos"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'venue-services' 
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  )
  WITH CHECK (
    bucket_id = 'venue-services' 
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );
