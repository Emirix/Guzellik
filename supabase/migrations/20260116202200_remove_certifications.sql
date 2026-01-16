-- Remove certifications column from venues table
ALTER TABLE venues DROP COLUMN IF EXISTS certifications;
