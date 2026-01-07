CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  rating NUMERIC NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS Policies
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reviews are viewable by everyone." ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Users can create reviews." ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
-- Setup simple update/delete policies for owner
CREATE POLICY "Users can update own reviews." ON public.reviews FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own reviews." ON public.reviews FOR DELETE USING (auth.uid() = user_id);
