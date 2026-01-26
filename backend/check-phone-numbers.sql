-- Check if phone numbers are being saved in the students table
-- Run this in Railway PostgreSQL query console

-- Get the most recent students with their phone numbers
SELECT 
    s.id,
    u.name,
    u.identifier,
    s.phone,
    s.created_at
FROM students s
JOIN users u ON u.id = s.user_id
ORDER BY s.created_at DESC
LIMIT 10;

-- Or check a specific student by identifier
SELECT 
    s.id,
    u.name,
    u.identifier,
    s.phone,
    s.student_type
FROM students s
JOIN users u ON u.id = s.user_id
WHERE u.identifier = 'YOUR_STUDENT_IDENTIFIER_HERE';
