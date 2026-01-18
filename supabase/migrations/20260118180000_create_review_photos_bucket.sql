-- Create review-photos bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'review-photos',
  'review-photos',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Policies for review-photos
-- Anyone can view
CREATE POLICY "Anyone can view review photos"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'review-photos');

-- Authenticated users can upload (folder structure: user_id/filename)
CREATE POLICY "Authenticated users can upload review photos"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'review-photos'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Users can delete their own
CREATE POLICY "Users can delete their own review photos"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'review-photos'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
