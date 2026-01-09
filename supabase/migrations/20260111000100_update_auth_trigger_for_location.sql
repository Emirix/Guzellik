-- Migration: Update handle_new_user trigger
-- Description: Copies location data from auth metadata to profiles table

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    full_name, 
    avatar_url, 
    province_id, 
    district_id
  )
  VALUES (
    new.id, 
    new.raw_user_meta_data->>'full_name', 
    new.raw_user_meta_data->>'avatar_url',
    (new.raw_user_meta_data->>'province_id')::INTEGER,
    (new.raw_user_meta_data->>'district_id')::UUID
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
