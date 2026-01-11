-- Migration: Create storage buckets for admin panel
-- Description: Creates storage buckets for venue gallery, specialists, and campaigns
-- Date: 2026-01-11

-- ============================================
-- Create Storage Buckets
-- ============================================

-- Create venue-gallery bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'venue-gallery',
  'venue-gallery',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Create specialists bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'specialists',
  'specialists',
  true,
  2097152, -- 2MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Create campaigns bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'campaigns',
  'campaigns',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Storage RLS Policies
-- ============================================

-- venue-gallery bucket policies
-- Policy: Anyone can view gallery photos
CREATE POLICY "Anyone can view venue gallery photos"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'venue-gallery');

-- Policy: Authenticated users can upload to their venue folder
CREATE POLICY "Owners can upload to their venue gallery"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'venue-gallery' 
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Policy: Owners can update their venue photos
CREATE POLICY "Owners can update their venue gallery photos"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'venue-gallery'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  )
  WITH CHECK (
    bucket_id = 'venue-gallery'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Policy: Owners can delete their venue photos
CREATE POLICY "Owners can delete their venue gallery photos"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'venue-gallery'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );

-- specialists bucket policies
-- Policy: Anyone can view specialist photos
CREATE POLICY "Anyone can view specialist photos"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'specialists');

-- Policy: Owners can upload specialist photos
CREATE POLICY "Owners can upload specialist photos"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'specialists'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Policy: Owners can update specialist photos
CREATE POLICY "Owners can update specialist photos"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'specialists'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  )
  WITH CHECK (
    bucket_id = 'specialists'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Policy: Owners can delete specialist photos
CREATE POLICY "Owners can delete specialist photos"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'specialists'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );

-- campaigns bucket policies
-- Policy: Anyone can view campaign images
CREATE POLICY "Anyone can view campaign images"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'campaigns');

-- Policy: Owners can upload campaign images
CREATE POLICY "Owners can upload campaign images"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'campaigns'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Policy: Owners can update campaign images
CREATE POLICY "Owners can update campaign images"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'campaigns'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  )
  WITH CHECK (
    bucket_id = 'campaigns'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );

-- Policy: Owners can delete campaign images
CREATE POLICY "Owners can delete campaign images"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'campaigns'
    AND (storage.foldername(name))[1] IN (
      SELECT id::text FROM venues WHERE owner_id = auth.uid()
    )
  );
