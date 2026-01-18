-- Migration: Add credit system for business features
-- Description: Creates tables for credit packages and transactions, and updates venues_subscription balance

-- Add credits balance to venues_subscription
ALTER TABLE public.venues_subscription
ADD COLUMN IF NOT EXISTS credits_balance INTEGER DEFAULT 0;

-- Create credit packages table
CREATE TABLE IF NOT EXISTS public.credit_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    credits INTEGER NOT NULL,
    price_cents INTEGER NOT NULL, -- Price in cents/kurus
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create credit transactions table
CREATE TABLE IF NOT EXISTS public.credit_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE,
    profile_id UUID REFERENCES public.profiles(id),
    amount INTEGER NOT NULL, -- Positive for purchase, negative for usage
    transaction_type TEXT NOT NULL, -- 'purchase', 'usage', 'refund', 'bonus'
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS for credit packages (Public Read)
ALTER TABLE public.credit_packages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active credit packages"
ON public.credit_packages FOR SELECT
USING (is_active = true);

-- RLS for credit transactions (Owner Read)
ALTER TABLE public.credit_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Venues can view their own credit transactions"
ON public.credit_transactions FOR SELECT
USING (auth.uid() = profile_id OR EXISTS (
    SELECT 1 FROM public.venues v WHERE v.id = venue_id AND v.owner_id = auth.uid()
));

-- Trigger to update updated_at on credit_packages
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_credit_packages_updated_at
    BEFORE UPDATE ON public.credit_packages
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Insert some default packages
INSERT INTO public.credit_packages (name, description, credits, price_cents)
VALUES 
('Küçük Paket', 'Temel özellikler için 100 kredi', 100, 4900),
('Orta Paket', 'Daha fazla kampanya ve öne çıkarma için 500 kredi', 500, 19900),
('Büyük Paket', 'Tüm işletme ihtiyaçları için 1500 kredi', 1500, 49900)
ON CONFLICT DO NOTHING;

-- RPC function to increment/decrement venue credits atomically
CREATE OR REPLACE FUNCTION public.increment_venue_credits(p_venue_id UUID, p_amount INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE public.venues_subscription
    SET credits_balance = credits_balance + p_amount
    WHERE venue_id = p_venue_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

