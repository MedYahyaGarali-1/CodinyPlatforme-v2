-- Fix incorrect answers for questions 103 and 105
-- Question 103: بعد هذه العلامة سوف يعترضني (After this sign I will encounter)
-- Question 105: أنعطف إلى اليمين (Turn right)

-- Update question 103: Change correct answer from B to A
UPDATE exam_questions 
SET correct_answer = 'A'
WHERE question_number = 103;

-- Update question 105: Change correct answer from B to A
UPDATE exam_questions 
SET correct_answer = 'A'
WHERE question_number = 105;

-- Verify the changes
SELECT question_number, correct_answer, option_a, option_b, option_c
FROM exam_questions
WHERE question_number IN (103, 105)
ORDER BY question_number;
