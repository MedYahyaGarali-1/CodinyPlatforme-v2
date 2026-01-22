-- Add refresh_token column to users table
-- This stores hashed refresh tokens for secure token rotation

ALTER TABLE users 
ADD COLUMN refresh_token TEXT,
ADD COLUMN refresh_token_expires_at TIMESTAMP;

COMMENT ON COLUMN users.refresh_token IS 'Hashed refresh token for token rotation';
COMMENT ON COLUMN users.refresh_token_expires_at IS 'Expiry timestamp for refresh token';

-- Verify columns were added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name IN ('refresh_token', 'refresh_token_expires_at');
