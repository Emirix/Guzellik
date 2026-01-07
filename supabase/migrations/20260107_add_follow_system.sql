-- Migration: Add Follow System Support
-- Description: Add FCM token storage and venue notification support

-- 1. Add FCM token columns to profiles table
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS fcm_token TEXT,
  ADD COLUMN IF NOT EXISTS fcm_token_updated_at TIMESTAMPTZ;

-- 2. Add venue_id to notifications table for venue-sent notifications
ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS venue_id UUID REFERENCES venues(id) ON DELETE SET NULL;

-- 3. Ensure follows table has proper indexes
CREATE INDEX IF NOT EXISTS idx_follows_user_venue ON follows(user_id, venue_id);
CREATE INDEX IF NOT EXISTS idx_follows_venue ON follows(venue_id);
CREATE INDEX IF NOT EXISTS idx_follows_created_at ON follows(created_at DESC);

-- 4. Add index on notifications for venue queries
CREATE INDEX IF NOT EXISTS idx_notifications_venue_id ON notifications(venue_id) WHERE venue_id IS NOT NULL;

-- Comments for documentation
COMMENT ON COLUMN profiles.fcm_token IS 'Firebase Cloud Messaging token for push notifications';
COMMENT ON COLUMN profiles.fcm_token_updated_at IS 'Last time FCM token was refreshed';
COMMENT ON COLUMN notifications.venue_id IS 'Reference to venue that sent the notification (if applicable)';
