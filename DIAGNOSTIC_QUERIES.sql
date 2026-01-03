-- =====================================================
-- DIAGNOSTIC SCRIPT FOR ISSUES #3 AND #4
-- Run these queries in Railway PostgreSQL Query Tool
-- =====================================================

-- =====================================================
-- ISSUE #3: Dashboard Numbers Not Showing
-- =====================================================

-- 1. Check if school exists and has data
SELECT 
  id,
  name,
  total_students,
  total_earned,
  total_owed_to_platform,
  created_at
FROM schools
ORDER BY created_at DESC
LIMIT 5;

-- Expected: Should show your school with numbers
-- If total_students, total_earned, total_owed_to_platform are NULL or 0,
-- that's why the dashboard shows no numbers!

-- 2. Check how many students are actually linked to each school
SELECT 
  s.id as school_id,
  s.name as school_name,
  COUNT(st.id) as actual_student_count
FROM schools s
LEFT JOIN students st ON st.school_id = s.id
GROUP BY s.id, s.name
ORDER BY s.created_at DESC;

-- This shows the ACTUAL count vs what's stored in total_students

-- 3. Check if there are any revenue records
SELECT 
  school_id,
  COUNT(*) as transaction_count,
  SUM(amount) as total_amount,
  SUM(CASE WHEN status = 'owed_to_platform' THEN amount ELSE 0 END) as owed,
  SUM(CASE WHEN status = 'earned' THEN amount ELSE 0 END) as earned
FROM revenue_tracking
GROUP BY school_id;

-- This shows actual earnings vs what's stored in the schools table


-- =====================================================
-- ISSUE #4: Student Calendar - No Events Showing
-- =====================================================

-- 1. Check if any events exist in the database
SELECT 
  COUNT(*) as total_events,
  COUNT(DISTINCT student_id) as students_with_events
FROM student_events;

-- If count is 0, no events have been created yet!

-- 2. Check students and their school linkage
SELECT 
  st.id as student_id,
  st.email as student_email,
  st.school_id,
  s.name as school_name,
  COUNT(se.id) as event_count
FROM students st
LEFT JOIN schools s ON st.school_id = s.id
LEFT JOIN student_events se ON se.student_id = st.id
GROUP BY st.id, st.email, st.school_id, s.name
ORDER BY st.created_at DESC
LIMIT 10;

-- Check if:
-- - school_id is NULL (student not linked to any school)
-- - event_count is 0 (no events created for this student)

-- 3. List all events to see what exists
SELECT 
  se.id,
  se.title,
  se.starts_at,
  se.ends_at,
  se.location,
  st.email as student_email,
  s.name as school_name
FROM student_events se
JOIN students st ON se.student_id = st.id
LEFT JOIN schools s ON st.school_id = s.id
ORDER BY se.starts_at DESC
LIMIT 20;

-- This shows all events with student and school info

-- 4. Check specific student's events (REPLACE with your student ID)
SELECT *
FROM student_events
WHERE student_id = 'YOUR_STUDENT_ID_HERE'
ORDER BY starts_at DESC;


-- =====================================================
-- FIX SCRIPTS (Only run if needed after diagnosis)
-- =====================================================

-- FIX #3A: Update school statistics based on actual data
-- WARNING: This will overwrite the values in schools table
/*
UPDATE schools
SET 
  total_students = (
    SELECT COUNT(*) 
    FROM students 
    WHERE students.school_id = schools.id
  ),
  total_earned = COALESCE((
    SELECT SUM(amount)
    FROM revenue_tracking
    WHERE revenue_tracking.school_id = schools.id
    AND status = 'earned'
  ), 0),
  total_owed_to_platform = COALESCE((
    SELECT SUM(amount)
    FROM revenue_tracking
    WHERE revenue_tracking.school_id = schools.id
    AND status = 'owed_to_platform'
  ), 0)
WHERE id IN (
  SELECT id FROM schools
);

-- Verify the fix
SELECT id, name, total_students, total_earned, total_owed_to_platform
FROM schools;
*/

-- FIX #4A: Link student to school (if school_id is NULL)
-- REPLACE with actual student_id and school_id
/*
UPDATE students
SET school_id = 'YOUR_SCHOOL_ID_HERE'
WHERE id = 'YOUR_STUDENT_ID_HERE'
AND school_id IS NULL;
*/

-- FIX #4B: Create test event for student
-- REPLACE with actual student_id
/*
INSERT INTO student_events (
  id,
  student_id,
  title,
  starts_at,
  ends_at,
  location,
  notes,
  created_at
) VALUES (
  gen_random_uuid(),
  'YOUR_STUDENT_ID_HERE',
  'Driving Lesson - City Routes',
  NOW() + INTERVAL '2 days',
  NOW() + INTERVAL '2 days 2 hours',
  'City Center Practice Area',
  'Focus on parallel parking and traffic navigation',
  NOW()
);

-- Verify the event was created
SELECT * FROM student_events WHERE student_id = 'YOUR_STUDENT_ID_HERE';
*/


-- =====================================================
-- USEFUL QUERIES FOR MONITORING
-- =====================================================

-- Get overview of entire system
SELECT 
  (SELECT COUNT(*) FROM schools) as total_schools,
  (SELECT COUNT(*) FROM students) as total_students,
  (SELECT COUNT(*) FROM student_events) as total_events,
  (SELECT COUNT(*) FROM exam_sessions WHERE completed_at IS NOT NULL) as completed_exams,
  (SELECT COUNT(*) FROM exam_questions) as total_questions;

-- Get school performance summary
SELECT 
  s.name as school_name,
  COUNT(DISTINCT st.id) as students,
  COUNT(DISTINCT se.id) as events_created,
  COUNT(DISTINCT es.id) as exams_taken
FROM schools s
LEFT JOIN students st ON st.school_id = s.id
LEFT JOIN student_events se ON se.student_id = st.id
LEFT JOIN exam_sessions es ON es.student_id = st.id
GROUP BY s.id, s.name
ORDER BY students DESC;
