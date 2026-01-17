-- Add FCM token column to students table for push notifications
-- Run this on Railway database

ALTER TABLE students 
ADD COLUMN fcm_token TEXT;

COMMENT ON COLUMN students.fcm_token IS 'Firebase Cloud Messaging token for push notifications';

-- Verify the column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'students' AND column_name = 'fcm_token';
