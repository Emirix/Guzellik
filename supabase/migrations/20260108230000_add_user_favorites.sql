-- Migration: Add User Favorites Table
-- Description: Create user_favorites table for bookmark functionality

-- 1. Create user_favorites table
CREATE TABLE IF NOT EXISTS public.user_favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(user_id, venue_id)
);

-- 2. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_favorites_user ON public.user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_venue ON public.user_favorites(venue_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_created ON public.user_favorites(created_at DESC);

-- 3. Enable RLS
ALTER TABLE public.user_favorites ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS policies
CREATE POLICY "Users can view own favorites" 
  ON public.user_favorites FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own favorites" 
  ON public.user_favorites FOR ALL 
  USING (auth.uid() = user_id);

-- 5. Add comments for documentation
COMMENT ON TABLE public.user_favorites IS 'Stores user favorite venues (bookmarks)';
COMMENT ON COLUMN public.user_favorites.user_id IS 'Reference to the user who favorited the venue';
COMMENT ON COLUMN public.user_favorites.venue_id IS 'Reference to the favorited venue';
COMMENT ON COLUMN public.user_favorites.created_at IS 'Timestamp when the venue was added to favorites';
