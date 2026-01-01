-- Performance Optimization: Add Database Indexes
-- These indexes improve query performance and prevent timeouts

-- ============================================
-- USERS TABLE INDEXES
-- ============================================

-- Index for login (identifier lookup)
CREATE INDEX IF NOT EXISTS idx_users_identifier ON users(identifier);

-- Index for role-based queries
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Index for created_at (for sorting and filtering)
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- ============================================
-- STUDENTS TABLE INDEXES
-- ============================================

-- Index for user_id (foreign key lookup)
CREATE INDEX IF NOT EXISTS idx_students_user_id ON students(user_id);

-- Index for student_type (filtering by type)
CREATE INDEX IF NOT EXISTS idx_students_type ON students(student_type);

-- Index for access_method (filtering by access method)
CREATE INDEX IF NOT EXISTS idx_students_access_method ON students(access_method);

-- Index for school_id (filtering students by school)
CREATE INDEX IF NOT EXISTS idx_students_school_id ON students(school_id);

-- Index for subscription_status (active/expired filtering)
CREATE INDEX IF NOT EXISTS idx_students_subscription_status ON students(subscription_status);

-- Index for payment_verified (filtering verified students)
CREATE INDEX IF NOT EXISTS idx_students_payment_verified ON students(payment_verified);

-- Index for school_approval_status (filtering approved students)
CREATE INDEX IF NOT EXISTS idx_students_school_approval_status ON students(school_approval_status);

-- Composite index for common query patterns
CREATE INDEX IF NOT EXISTS idx_students_school_status ON students(school_id, school_approval_status);

-- Index for onboarding_complete
CREATE INDEX IF NOT EXISTS idx_students_onboarding ON students(onboarding_complete);

-- ============================================
-- EXAM_SESSIONS TABLE INDEXES
-- ============================================

-- Index for student_id (student's exam history)
CREATE INDEX IF NOT EXISTS idx_exam_sessions_student ON exam_sessions(student_id);

-- Index for completed_at (filtering completed exams)
CREATE INDEX IF NOT EXISTS idx_exam_sessions_completed ON exam_sessions(completed_at);

-- Index for started_at (sorting by date)
CREATE INDEX IF NOT EXISTS idx_exam_sessions_started ON exam_sessions(started_at DESC);

-- Index for passed status (filtering by result)
CREATE INDEX IF NOT EXISTS idx_exam_sessions_passed ON exam_sessions(passed);

-- Composite index for student exam history with completed status
CREATE INDEX IF NOT EXISTS idx_exam_sessions_student_completed ON exam_sessions(student_id, completed_at DESC);

-- Index for score (for statistics)
CREATE INDEX IF NOT EXISTS idx_exam_sessions_score ON exam_sessions(score);

-- ============================================
-- EXAM_QUESTIONS TABLE INDEXES
-- ============================================

-- Index for category (filtering questions by category)
CREATE INDEX IF NOT EXISTS idx_exam_questions_category ON exam_questions(category);

-- Index for difficulty (filtering by difficulty)
CREATE INDEX IF NOT EXISTS idx_exam_questions_difficulty ON exam_questions(difficulty);

-- Index for created_at (sorting questions)
CREATE INDEX IF NOT EXISTS idx_exam_questions_created ON exam_questions(created_at);

-- ============================================
-- EXAM_ANSWERS TABLE INDEXES
-- ============================================

-- Index for session_id (retrieving answers for a session)
CREATE INDEX IF NOT EXISTS idx_exam_answers_session ON exam_answers(session_id);

-- Index for question_id (question statistics)
CREATE INDEX IF NOT EXISTS idx_exam_answers_question ON exam_answers(question_id);

-- Index for is_correct (statistics)
CREATE INDEX IF NOT EXISTS idx_exam_answers_correct ON exam_answers(is_correct);

-- Composite index for session answers
CREATE INDEX IF NOT EXISTS idx_exam_answers_session_question ON exam_answers(session_id, question_id);

-- ============================================
-- SCHOOLS TABLE INDEXES
-- ============================================

-- Index for admin_id (school administrator lookup)
CREATE INDEX IF NOT EXISTS idx_schools_admin_id ON schools(admin_id);

-- Index for created_at (sorting schools)
CREATE INDEX IF NOT EXISTS idx_schools_created ON schools(created_at);

-- Index for school name (text search optimization)
CREATE INDEX IF NOT EXISTS idx_schools_name ON schools(name);

-- ============================================
-- REVENUE_TRACKING TABLE INDEXES (Already exists in migration 002)
-- ============================================
-- idx_revenue_school
-- idx_revenue_student  
-- idx_revenue_created

-- ============================================
-- PAYMENT_HISTORY TABLE INDEXES (if exists)
-- ============================================

-- Note: These will only be created if payment_history table exists
-- Run these manually if needed:
-- CREATE INDEX IF NOT EXISTS idx_payment_history_student ON payment_history(student_id);
-- CREATE INDEX IF NOT EXISTS idx_payment_history_created ON payment_history(created_at);

-- ============================================
-- ANALYZE TABLES FOR QUERY PLANNER
-- ============================================
-- Run these commands separately in PostgreSQL to update statistics
-- ANALYZE users;
-- ANALYZE students;
-- ANALYZE exam_sessions;
-- ANALYZE exam_questions;
-- ANALYZE exam_answers;
-- ANALYZE schools;
-- ANALYZE revenue_tracking;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Database indexes created successfully for performance optimization';
END $$;
