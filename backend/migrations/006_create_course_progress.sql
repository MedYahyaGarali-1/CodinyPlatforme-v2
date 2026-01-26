-- Course Progress Table
-- Tracks student's reading progress in courses

CREATE TABLE IF NOT EXISTS course_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    course_id VARCHAR(50) NOT NULL,
    current_page INTEGER DEFAULT 0,
    total_pages INTEGER DEFAULT 0,
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Unique constraint: one progress record per student per course
    UNIQUE(student_id, course_id)
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_course_progress_student ON course_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_course_progress_course ON course_progress(course_id);
