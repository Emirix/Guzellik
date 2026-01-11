-- Migration: Audit Logging System
-- Description: Implements audit_logs table for tracking sensitive data changes

-- Create audit_logs table
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data JSONB,
    new_data JSONB,
    changed_fields TEXT[], -- Array of field names that changed
    actor_id UUID REFERENCES auth.users(id),
    actor_email TEXT, -- Denormalized for easier querying
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_record ON public.audit_logs(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON public.audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_action ON public.audit_logs(table_name, action);

-- Enable RLS
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Only admins can view audit logs (for now, we'll use a simple check)
-- In production, you might want to create an admin role
CREATE POLICY "Admins can view audit logs"
    ON public.audit_logs FOR SELECT
    TO authenticated
    USING (
        -- For now, allow venue owners to see their own venue's audit logs
        EXISTS (
            SELECT 1 FROM public.venues v
            WHERE v.id = record_id
            AND v.owner_id = auth.uid()
            AND table_name = 'venues'
        )
        -- TODO: Add proper admin role check here
    );

-- No one can insert/update/delete audit logs directly (only via triggers)
CREATE POLICY "Audit logs are insert-only via triggers"
    ON public.audit_logs FOR INSERT
    WITH CHECK (false);

CREATE POLICY "Audit logs cannot be updated"
    ON public.audit_logs FOR UPDATE
    USING (false);

CREATE POLICY "Audit logs cannot be deleted"
    ON public.audit_logs FOR DELETE
    USING (false);

-- ========================================
-- Generic Audit Trigger Function
-- ========================================
CREATE OR REPLACE FUNCTION public.audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
    v_changed_fields TEXT[];
    v_actor_id UUID;
    v_actor_email TEXT;
BEGIN
    -- Get actor information from current session
    BEGIN
        v_actor_id := auth.uid();
        v_actor_email := (SELECT email FROM auth.users WHERE id = v_actor_id);
    EXCEPTION WHEN OTHERS THEN
        v_actor_id := NULL;
        v_actor_email := NULL;
    END;
    
    -- Prepare data based on operation
    IF (TG_OP = 'DELETE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := NULL;
        v_changed_fields := NULL;
        
        INSERT INTO public.audit_logs (
            table_name,
            record_id,
            action,
            old_data,
            new_data,
            changed_fields,
            actor_id,
            actor_email
        ) VALUES (
            TG_TABLE_NAME,
            OLD.id,
            TG_OP,
            v_old_data,
            v_new_data,
            v_changed_fields,
            v_actor_id,
            v_actor_email
        );
        
        RETURN OLD;
        
    ELSIF (TG_OP = 'UPDATE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
        
        -- Identify changed fields
        SELECT array_agg(key)
        INTO v_changed_fields
        FROM jsonb_each(v_new_data)
        WHERE v_new_data->key IS DISTINCT FROM v_old_data->key;
        
        -- Only log if there are actual changes
        IF v_changed_fields IS NOT NULL AND array_length(v_changed_fields, 1) > 0 THEN
            INSERT INTO public.audit_logs (
                table_name,
                record_id,
                action,
                old_data,
                new_data,
                changed_fields,
                actor_id,
                actor_email
            ) VALUES (
                TG_TABLE_NAME,
                NEW.id,
                TG_OP,
                v_old_data,
                v_new_data,
                v_changed_fields,
                v_actor_id,
                v_actor_email
            );
        END IF;
        
        RETURN NEW;
        
    ELSIF (TG_OP = 'INSERT') THEN
        v_old_data := NULL;
        v_new_data := to_jsonb(NEW);
        v_changed_fields := NULL;
        
        INSERT INTO public.audit_logs (
            table_name,
            record_id,
            action,
            old_data,
            new_data,
            changed_fields,
            actor_id,
            actor_email
        ) VALUES (
            TG_TABLE_NAME,
            NEW.id,
            TG_OP,
            v_old_data,
            v_new_data,
            v_changed_fields,
            v_actor_id,
            v_actor_email
        );
        
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- Helper Functions for Querying Audit Logs
-- ========================================

-- Get audit history for a specific record
CREATE OR REPLACE FUNCTION public.get_audit_history(
    p_table_name TEXT,
    p_record_id UUID,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    action TEXT,
    changed_fields TEXT[],
    actor_email TEXT,
    created_at TIMESTAMPTZ,
    old_data JSONB,
    new_data JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.id,
        al.action,
        al.changed_fields,
        al.actor_email,
        al.created_at,
        al.old_data,
        al.new_data
    FROM public.audit_logs al
    WHERE al.table_name = p_table_name
    AND al.record_id = p_record_id
    ORDER BY al.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get recent audit logs for a table
CREATE OR REPLACE FUNCTION public.get_recent_audits(
    p_table_name TEXT,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    id UUID,
    record_id UUID,
    action TEXT,
    changed_fields TEXT[],
    actor_email TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.id,
        al.record_id,
        al.action,
        al.changed_fields,
        al.actor_email,
        al.created_at
    FROM public.audit_logs al
    WHERE al.table_name = p_table_name
    ORDER BY al.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Grant permissions
GRANT SELECT ON public.audit_logs TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_audit_history(TEXT, UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_recent_audits(TEXT, INTEGER) TO authenticated;

-- Add helpful comments
COMMENT ON TABLE public.audit_logs IS 'Audit trail for sensitive data changes across the platform';
COMMENT ON COLUMN public.audit_logs.changed_fields IS 'Array of field names that were modified in an UPDATE operation';
COMMENT ON FUNCTION public.audit_trigger_function() IS 'Generic trigger function for auditing INSERT, UPDATE, DELETE operations';
COMMENT ON FUNCTION public.get_audit_history(TEXT, UUID, INTEGER) IS 'Get complete audit history for a specific record';
COMMENT ON FUNCTION public.get_recent_audits(TEXT, INTEGER) IS 'Get recent audit logs for a table';
