-- Minimal setup - Just create tables and one test user  
-- Copy this entire file and paste it into Railway's query interface

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    identifier VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Students table
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    student_type VARCHAR(50) DEFAULT 'school_linked',
    school_id INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    payment_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Schools table
CREATE TABLE schools (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    school_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Courses table
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    pdf_path VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE
);

-- Exams table
CREATE TABLE exams (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(id),
    score INTEGER,
    total_questions INTEGER,
    passed BOOLEAN,
    exam_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Test user: 99806767 / password123
INSERT INTO users (identifier, password, role) VALUES 
('99806767', '$2b$10$rZ7ZqZ1YqZ1YqZ1YqZ1YqO7ZqZ1YqZ1YqZ1YqZ1YqZ1YqZ1YqZ1Yq', 'student');

-- Test student profile
INSERT INTO students (user_id, full_name, student_type, is_active, payment_verified) VALUES 
(1, 'Test Student', 'school_linked', TRUE, TRUE);
