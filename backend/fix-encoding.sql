-- Fix encoding for Arabic text in exam_questions table
-- Run this directly in Railway's PostgreSQL Query tab

-- Check current database encoding
SHOW SERVER_ENCODING;

-- If you need to convert data that was imported with wrong encoding:
-- This assumes data was imported as LATIN1 but should be UTF8

-- Update all text columns in exam_questions
UPDATE exam_questions 
SET 
    question_text = convert_from(convert_to(question_text, 'LATIN1'), 'UTF8'),
    option_a = convert_from(convert_to(option_a, 'LATIN1'), 'UTF8'),
    option_b = convert_from(convert_to(option_b, 'LATIN1'), 'UTF8'),
    option_c = convert_from(convert_to(option_c, 'LATIN1'), 'UTF8')
WHERE question_text IS NOT NULL;

-- Verify the fix by checking a sample question
SELECT id, question_text, option_a, option_b, option_c 
FROM exam_questions 
LIMIT 5;
