const pool = require('../config/db');
const PaginationHelper = require('../utils/pagination');

// Helper function to get student ID from user ID
async function getStudentId(userId) {
  const result = await pool.query(
    'SELECT id FROM students WHERE user_id = $1',
    [userId]
  );
  
  if (result.rowCount === 0) {
    throw new Error('Student profile not found');
  }
  
  return result.rows[0].id;
}

// Get random 30 questions for a new exam
exports.getExamQuestions = async (req, res) => {
  try {
    // Get 30 random active questions
    const result = await pool.query(`
      SELECT id, question_number, question_text, image_url, option_a, option_b, option_c
      FROM exam_questions
      WHERE is_active = true
      ORDER BY RANDOM()
      LIMIT 30
    `);

    res.json({
      success: true,
      questions: result.rows,
      total_questions: result.rows.length,
      time_limit_minutes: 45,
      passing_score: 23
    });
  } catch (error) {
    console.error('Error fetching exam questions:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch exam questions'
    });
  }
};

// Start a new exam session
exports.startExam = async (req, res) => {
  try {
    const userId = req.user.id;

    // Get the student record using user_id
    const studentResult = await pool.query(
      'SELECT id FROM students WHERE user_id = $1',
      [userId]
    );

    if (studentResult.rowCount === 0) {
      return res.status(404).json({
        success: false,
        error: 'Student profile not found'
      });
    }

    const studentId = studentResult.rows[0].id;

    const result = await pool.query(`
      INSERT INTO exam_sessions (student_id, total_questions)
      VALUES ($1, 30)
      RETURNING id, started_at, total_questions
    `, [studentId]);

    res.json({
      success: true,
      session: result.rows[0]
    });
  } catch (error) {
    console.error('Error starting exam:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to start exam session'
    });
  }
};

// Submit exam answers and calculate score
exports.submitExam = async (req, res) => {
  const client = await pool.connect();
  
  try {
    const userId = req.user.id;
    const { session_id, answers, time_taken_seconds } = req.body;

    console.log('Submit exam request:', { 
      userId, 
      session_id, 
      answersCount: answers?.length, 
      time_taken_seconds 
    });

    // Validate inputs
    if (!session_id) {
      return res.status(400).json({
        success: false,
        error: 'Session ID is required'
      });
    }

    if (!answers || !Array.isArray(answers)) {
      return res.status(400).json({
        success: false,
        error: 'Answers must be provided as an array'
      });
    }

    // Get student ID from user ID
    const studentId = await getStudentId(userId);

    await client.query('BEGIN');

    // Verify session belongs to student
    const sessionCheck = await client.query(
      'SELECT id FROM exam_sessions WHERE id = $1 AND student_id = $2 AND completed_at IS NULL',
      [session_id, studentId]
    );

    if (sessionCheck.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        error: 'Invalid or already completed exam session'
      });
    }

    let correctCount = 0;
    let wrongCount = 0;
    let unansweredCount = 0;

    // Process each answer
    for (const answer of answers) {
      const { question_id, student_answer } = answer;

      // Skip if no question_id
      if (!question_id) continue;

      // Get correct answer
      const questionResult = await client.query(
        'SELECT correct_answer FROM exam_questions WHERE id = $1',
        [question_id]
      );

      if (questionResult.rows.length === 0) continue;

      const correctAnswer = questionResult.rows[0].correct_answer;
      
      // Handle unanswered questions (empty string or null)
      const isUnanswered = !student_answer || student_answer.trim() === '';
      const isCorrect = !isUnanswered && student_answer === correctAnswer;

      if (isUnanswered) {
        unansweredCount++;
        wrongCount++; // Unanswered counts as wrong
      } else if (isCorrect) {
        correctCount++;
      } else {
        wrongCount++;
      }

      // Store answer (store empty string for unanswered)
      await client.query(`
        INSERT INTO exam_answers (exam_session_id, question_id, student_answer, is_correct)
        VALUES ($1, $2, $3, $4)
      `, [session_id, question_id, student_answer || '', isCorrect]);
    }

    // Calculate score and pass/fail (based on 30 questions total)
    const totalQuestions = 30;
    const score = (correctCount / totalQuestions) * 100;
    const passed = correctCount >= 23;

    // Update exam session
    await client.query(`
      UPDATE exam_sessions
      SET completed_at = CURRENT_TIMESTAMP,
          correct_answers = $1,
          wrong_answers = $2,
          score = $3,
          passed = $4,
          time_taken_seconds = $5
      WHERE id = $6
    `, [correctCount, wrongCount, score, passed, time_taken_seconds, session_id]);

    await client.query('COMMIT');

    console.log('Exam submitted successfully:', {
      session_id,
      correctCount,
      wrongCount,
      unansweredCount,
      score: score.toFixed(2),
      passed
    });

    res.json({
      success: true,
      result: {
        correct_answers: correctCount,
        wrong_answers: wrongCount,
        unanswered: unansweredCount,
        score: score.toFixed(2),
        passed,
        passing_score: 23,
        time_taken_seconds: time_taken_seconds || 0
      }
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error submitting exam:', error.message, error.stack);
    res.status(500).json({
      success: false,
      error: `Failed to submit exam: ${error.message}`
    });
  } finally {
    client.release();
  }
};

// Get student's exam history with pagination
exports.getStudentExams = async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Get pagination parameters
    const { page, limit, offset } = PaginationHelper.getPaginationParams(req.query);
    
    // Get student ID from user ID
    const studentId = await getStudentId(userId);

    // Get total count
    const countResult = await pool.query(`
      SELECT COUNT(*) as total
      FROM exam_sessions
      WHERE student_id = $1
        AND completed_at IS NOT NULL
        AND score IS NOT NULL
    `, [studentId]);
    
    const totalCount = parseInt(countResult.rows[0].total);

    // Get paginated results
    const result = await pool.query(`
      SELECT 
        id,
        started_at,
        completed_at,
        total_questions,
        correct_answers,
        wrong_answers,
        score,
        passed,
        time_taken_seconds
      FROM exam_sessions
      WHERE student_id = $1
        AND completed_at IS NOT NULL
        AND score IS NOT NULL
      ORDER BY started_at DESC
      LIMIT $2 OFFSET $3
    `, [studentId, limit, offset]);

    // Format response with pagination
    const response = PaginationHelper.formatResponse(result.rows, totalCount, page, limit);

    res.json({
      success: true,
      exams: response.data,
      pagination: response.pagination
    });
  } catch (error) {
    console.error('Error fetching student exams:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch exam history'
    });
  }
};

// Get exam details with answers (for review)
exports.getExamDetails = async (req, res) => {
  try {
    const userId = req.user.id;
    const { examId } = req.params;

    // Get student ID from user ID
    const studentId = await getStudentId(userId);

    // Get exam session
    const sessionResult = await pool.query(`
      SELECT 
        id,
        started_at,
        completed_at,
        total_questions,
        correct_answers,
        wrong_answers,
        score,
        passed,
        time_taken_seconds
      FROM exam_sessions
      WHERE id = $1 AND student_id = $2
    `, [examId, studentId]);

    if (sessionResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Exam not found'
      });
    }

    // Get all answers with questions
    const answersResult = await pool.query(`
      SELECT 
        ea.id,
        ea.student_answer,
        ea.is_correct,
        ea.answered_at,
        eq.question_number,
        eq.question_text,
        eq.image_url,
        eq.option_a,
        eq.option_b,
        eq.option_c,
        eq.correct_answer
      FROM exam_answers ea
      JOIN exam_questions eq ON ea.question_id = eq.id
      WHERE ea.exam_session_id = $1
      ORDER BY eq.question_number
    `, [examId]);

    res.json({
      success: true,
      exam: sessionResult.rows[0],
      answers: answersResult.rows
    });
  } catch (error) {
    console.error('Error fetching exam details:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch exam details'
    });
  }
};

// Admin: Get exam statistics
exports.getExamStats = async (req, res) => {
  try {
    const stats = await pool.query(`
      SELECT 
        COUNT(DISTINCT student_id) as total_students,
        COUNT(*) as total_exams,
        COUNT(CASE WHEN passed = true THEN 1 END) as passed_exams,
        COUNT(CASE WHEN passed = false THEN 1 END) as failed_exams,
        ROUND(AVG(score), 2) as average_score,
        ROUND(AVG(time_taken_seconds) / 60, 2) as average_time_minutes
      FROM exam_sessions
      WHERE completed_at IS NOT NULL
    `);

    const recentExams = await pool.query(`
      SELECT 
        es.id,
        es.started_at,
        es.completed_at,
        es.score,
        es.passed,
        s.id as student_id,
        u.name as student_name
      FROM exam_sessions es
      JOIN students s ON es.student_id = s.id
      JOIN users u ON s.user_id = u.id
      WHERE es.completed_at IS NOT NULL
      ORDER BY es.completed_at DESC
      LIMIT 10
    `);

    res.json({
      success: true,
      statistics: stats.rows[0],
      recent_exams: recentExams.rows
    });
  } catch (error) {
    console.error('Error fetching exam stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch exam statistics'
    });
  }
};

// School: Get school student exam statistics
exports.getSchoolExamStats = async (req, res) => {
  try {
    const { schoolId } = req.params;

    const stats = await pool.query(`
      SELECT 
        COUNT(DISTINCT es.student_id) as total_students,
        COUNT(*) as total_exams,
        COUNT(CASE WHEN es.passed = true THEN 1 END) as passed_exams,
        COUNT(CASE WHEN es.passed = false THEN 1 END) as failed_exams,
        ROUND(AVG(es.score), 2) as average_score
      FROM exam_sessions es
      JOIN students s ON es.student_id = s.id
      WHERE s.school_id = $1 AND es.completed_at IS NOT NULL
    `, [schoolId]);

    const studentResults = await pool.query(`
      SELECT 
        s.id as student_id,
        u.name as student_name,
        COUNT(es.id) as total_attempts,
        COUNT(CASE WHEN es.passed = true THEN 1 END) as passed_attempts,
        MAX(es.score) as best_score,
        MAX(es.completed_at) as last_attempt
      FROM students s
      JOIN users u ON s.user_id = u.id
      LEFT JOIN exam_sessions es ON es.student_id = s.id AND es.completed_at IS NOT NULL
      WHERE s.school_id = $1
      GROUP BY s.id, u.name
      ORDER BY best_score DESC NULLS LAST
    `, [schoolId]);

    res.json({
      success: true,
      statistics: stats.rows[0],
      student_results: studentResults.rows
    });
  } catch (error) {
    console.error('Error fetching school exam stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch school exam statistics'
    });
  }
};
