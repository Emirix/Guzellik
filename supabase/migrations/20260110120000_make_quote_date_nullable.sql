-- Migration: Make preferred_date nullable in quote_requests
-- Description: Allows users to select "Farketmez" for the date

ALTER TABLE public.quote_requests ALTER COLUMN preferred_date DROP NOT NULL;
