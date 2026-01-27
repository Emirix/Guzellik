-- Migration: Create Appointments System
-- Description: Adds appointment management with multi-service support and specialist-based conflict checking
-- Date: 2026-01-27

-- DROP EXISTING TABLES IF THEY EXIST (Cleaning up old or incomplete schema)
DROP TABLE IF EXISTS public.appointment_services CASCADE;
DROP TABLE IF EXISTS public.appointments CASCADE;

-- ============================================================================
-- 1. CREATE APPOINTMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Relations
  venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE NOT NULL,
  customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE NOT NULL,
  specialist_id UUID REFERENCES public.specialists(id) ON DELETE SET NULL,
  
  -- Appointment info
  appointment_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  total_duration_minutes INTEGER NOT NULL,
  
  -- Status
  status TEXT NOT NULL DEFAULT 'pending',
  
  -- Pricing
  total_price DECIMAL(10,2),
  
  -- Notes
  notes TEXT,
  cancellation_reason TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  cancelled_at TIMESTAMPTZ,
  
  -- Constraints
  CONSTRAINT valid_time_range CHECK (end_time > start_time),
  CONSTRAINT valid_duration CHECK (total_duration_minutes > 0),
  CONSTRAINT valid_status CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'no_show'))
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_appointments_venue_id ON public.appointments(venue_id);
CREATE INDEX IF NOT EXISTS idx_appointments_customer_id ON public.appointments(customer_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON public.appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON public.appointments(status);
CREATE INDEX IF NOT EXISTS idx_appointments_specialist_id ON public.appointments(specialist_id) WHERE specialist_id IS NOT NULL;

-- Specialist-based conflict checking index
CREATE INDEX IF NOT EXISTS idx_appointments_specialist_schedule 
  ON public.appointments(specialist_id, appointment_date, start_time, end_time) 
  WHERE status NOT IN ('cancelled', 'no_show') AND specialist_id IS NOT NULL;

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_appointments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_appointments_updated_at ON public.appointments;
CREATE TRIGGER set_appointments_updated_at
  BEFORE UPDATE ON public.appointments
  FOR EACH ROW
  EXECUTE FUNCTION update_appointments_updated_at();

-- ============================================================================
-- 2. CREATE APPOINTMENT_SERVICES TABLE (Junction for multi-service support)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.appointment_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID REFERENCES public.appointments(id) ON DELETE CASCADE NOT NULL,
  service_id UUID REFERENCES public.venue_services(id) ON DELETE CASCADE NOT NULL,
  
  -- Service order (for multiple services)
  sort_order INTEGER NOT NULL DEFAULT 0,
  
  -- Service snapshot (values at time of booking)
  service_name TEXT NOT NULL,
  service_price DECIMAL(10,2),
  service_duration_minutes INTEGER,
  
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  -- Unique constraint: Same service can't be added twice to same appointment
  CONSTRAINT unique_appointment_service UNIQUE (appointment_id, service_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_appointment_services_appointment_id ON public.appointment_services(appointment_id);
CREATE INDEX IF NOT EXISTS idx_appointment_services_service_id ON public.appointment_services(service_id);

-- ============================================================================
-- 3. ROW LEVEL SECURITY POLICIES
-- ============================================================================

-- Enable RLS
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointment_services ENABLE ROW LEVEL SECURITY;

-- Appointments policies
DROP POLICY IF EXISTS "Venue owners can view their appointments" ON public.appointments;
CREATE POLICY "Venue owners can view their appointments"
  ON public.appointments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.venues 
      WHERE venues.id = appointments.venue_id 
      AND venues.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Venue owners can create appointments" ON public.appointments;
CREATE POLICY "Venue owners can create appointments"
  ON public.appointments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.venues 
      WHERE venues.id = appointments.venue_id 
      AND venues.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Venue owners can update their appointments" ON public.appointments;
CREATE POLICY "Venue owners can update their appointments"
  ON public.appointments FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.venues 
      WHERE venues.id = appointments.venue_id 
      AND venues.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Venue owners can delete their appointments" ON public.appointments;
CREATE POLICY "Venue owners can delete their appointments"
  ON public.appointments FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.venues 
      WHERE venues.id = appointments.venue_id 
      AND venues.owner_id = auth.uid()
    )
  );

-- Appointment services policies
DROP POLICY IF EXISTS "Venue owners can view appointment services" ON public.appointment_services;
CREATE POLICY "Venue owners can view appointment services"
  ON public.appointment_services FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.appointments a
      JOIN public.venues v ON v.id = a.venue_id
      WHERE a.id = appointment_services.appointment_id
      AND v.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Venue owners can create appointment services" ON public.appointment_services;
CREATE POLICY "Venue owners can create appointment services"
  ON public.appointment_services FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.appointments a
      JOIN public.venues v ON v.id = a.venue_id
      WHERE a.id = appointment_services.appointment_id
      AND v.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Venue owners can update appointment services" ON public.appointment_services;
CREATE POLICY "Venue owners can update appointment services"
  ON public.appointment_services FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.appointments a
      JOIN public.venues v ON v.id = a.venue_id
      WHERE a.id = appointment_services.appointment_id
      AND v.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Venue owners can delete appointment services" ON public.appointment_services;
CREATE POLICY "Venue owners can delete appointment services"
  ON public.appointment_services FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.appointments a
      JOIN public.venues v ON v.id = a.venue_id
      WHERE a.id = appointment_services.appointment_id
      AND v.owner_id = auth.uid()
    )
  );

-- ============================================================================
-- 4. RPC FUNCTIONS
-- ============================================================================

-- 4.1. Specialist-based conflict checking
CREATE OR REPLACE FUNCTION public.check_appointment_conflict(
  p_venue_id UUID,
  p_specialist_id UUID,
  p_date DATE,
  p_start_time TIME,
  p_end_time TIME,
  p_exclude_appointment_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_conflict_count INTEGER;
BEGIN
  -- IMPORTANT: Conflict check is ONLY for the same specialist
  -- Different specialists CAN have appointments at the same time
  
  IF p_specialist_id IS NULL THEN
    -- No specialist selected: venue-level check (legacy behavior)
    SELECT COUNT(*) INTO v_conflict_count
    FROM public.appointments
    WHERE venue_id = p_venue_id
      AND specialist_id IS NULL
      AND appointment_date = p_date
      AND status NOT IN ('cancelled', 'no_show')
      AND (p_exclude_appointment_id IS NULL OR id != p_exclude_appointment_id)
      AND (start_time, end_time) OVERLAPS (p_start_time, p_end_time);
  ELSE
    -- Specialist selected: specialist-specific check
    SELECT COUNT(*) INTO v_conflict_count
    FROM public.appointments
    WHERE specialist_id = p_specialist_id
      AND appointment_date = p_date
      AND status NOT IN ('cancelled', 'no_show')
      AND (p_exclude_appointment_id IS NULL OR id != p_exclude_appointment_id)
      AND (start_time, end_time) OVERLAPS (p_start_time, p_end_time);
  END IF;
  
  RETURN v_conflict_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4.2. Get daily appointments with services
CREATE OR REPLACE FUNCTION public.get_daily_appointments(
  p_venue_id UUID, 
  p_date DATE
)
RETURNS TABLE (
  appointment_id UUID,
  customer_name TEXT,
  customer_phone TEXT,
  services JSONB,
  specialist_name TEXT,
  start_time TIME,
  end_time TIME,
  total_duration_minutes INTEGER,
  total_price DECIMAL,
  status TEXT,
  notes TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id as appointment_id,
    c.name as customer_name,
    c.phone as customer_phone,
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id', aps.service_id,
          'name', aps.service_name,
          'price', aps.service_price,
          'duration', aps.service_duration_minutes,
          'order', aps.sort_order
        ) ORDER BY aps.sort_order
      )
      FROM public.appointment_services aps
      WHERE aps.appointment_id = a.id
    ) as services,
    sp.name as specialist_name,
    a.start_time,
    a.end_time,
    a.total_duration_minutes,
    a.total_price,
    a.status,
    a.notes
  FROM public.appointments a
  INNER JOIN public.customers c ON c.id = a.customer_id
  LEFT JOIN public.specialists sp ON sp.id = a.specialist_id
  WHERE a.venue_id = p_venue_id
    AND a.appointment_date = p_date
  ORDER BY a.start_time ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4.3. Get appointment statistics
CREATE OR REPLACE FUNCTION public.get_appointment_stats(
  p_venue_id UUID, 
  p_date_from DATE, 
  p_date_to DATE
)
RETURNS TABLE (
  total_appointments BIGINT,
  pending_count BIGINT,
  confirmed_count BIGINT,
  completed_count BIGINT,
  cancelled_count BIGINT,
  no_show_count BIGINT,
  total_revenue DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) as total_appointments,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_count,
    COUNT(*) FILTER (WHERE status = 'confirmed') as confirmed_count,
    COUNT(*) FILTER (WHERE status = 'completed') as completed_count,
    COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_count,
    COUNT(*) FILTER (WHERE status = 'no_show') as no_show_count,
    COALESCE(SUM(total_price) FILTER (WHERE status = 'completed'), 0) as total_revenue
  FROM public.appointments
  WHERE venue_id = p_venue_id
    AND appointment_date BETWEEN p_date_from AND p_date_to;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4.4. Get specialist availability
CREATE OR REPLACE FUNCTION public.get_specialist_availability(
  p_specialist_id UUID,
  p_date DATE,
  p_start_hour INTEGER DEFAULT 9,
  p_end_hour INTEGER DEFAULT 18
)
RETURNS TABLE (
  time_slot TIME,
  is_available BOOLEAN,
  appointment_id UUID
) AS $$
BEGIN
  RETURN QUERY
  WITH time_slots AS (
    -- Generate 30-minute time slots
    SELECT (p_start_hour * INTERVAL '1 hour' + n * INTERVAL '30 minutes')::TIME as slot
    FROM generate_series(0, (p_end_hour - p_start_hour) * 2 - 1) n
  )
  SELECT 
    ts.slot,
    NOT EXISTS (
      SELECT 1 FROM public.appointments a
      WHERE a.specialist_id = p_specialist_id
        AND a.appointment_date = p_date
        AND a.status NOT IN ('cancelled', 'no_show')
        AND (a.start_time, a.end_time) OVERLAPS (ts.slot, ts.slot + INTERVAL '30 minutes')
    ) as is_available,
    (
      SELECT a.id FROM public.appointments a
      WHERE a.specialist_id = p_specialist_id
        AND a.appointment_date = p_date
        AND a.status NOT IN ('cancelled', 'no_show')
        AND (a.start_time, a.end_time) OVERLAPS (ts.slot, ts.slot + INTERVAL '30 minutes')
      LIMIT 1
    ) as appointment_id
  FROM time_slots ts
  ORDER BY ts.slot;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
