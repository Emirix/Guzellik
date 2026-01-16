-- Migration: Add is_featured column to specialists
-- Description: Adds a boolean flag to mark featured/highlighted specialists
-- Date: 2026-01-16

-- Add is_featured column with default false
ALTER TABLE specialists 
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false NOT NULL;

-- Create index for faster queries filtering by featured status
CREATE INDEX IF NOT EXISTS idx_specialists_is_featured 
ON specialists(venue_id, is_featured, sort_order);

-- Add comment
COMMENT ON COLUMN specialists.is_featured IS 'Flag to mark featured/highlighted specialists for special UI treatment';
