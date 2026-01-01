const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const pool = require('../config/db');

router.get('/me', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `
      SELECT 
        id, 
        student_type, 
        subscription_start, 
        subscription_end,
        COALESCE(onboarding_complete, false) as onboarding_complete,
        access_method,
        COALESCE(payment_verified, false) as payment_verified,
        subscription_type,
        subscription_status,
        school_id,
        school_approval_status,
        COALESCE(is_active, true) as is_active,
        COALESCE(access_level, 'trial') as access_level
      FROM students
      WHERE user_id = $1
      `,
      [userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Student profile not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error in /students/me:', err);
    res.status(500).json({ 
      message: 'Server error',
      error: err.message 
    });
  }
});

// GET /students/events - Get my calendar events
router.get('/events', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get student ID from user ID
    const studentResult = await pool.query(
      'SELECT id FROM students WHERE user_id = $1',
      [userId]
    );

    if (studentResult.rowCount === 0) {
      return res.status(404).json({ message: 'Student profile not found' });
    }

    const studentId = studentResult.rows[0].id;

    // Get all events for this student
    const eventsResult = await pool.query(
      `
      SELECT id, title, starts_at, ends_at, location, notes
      FROM student_events
      WHERE student_id = $1
      ORDER BY starts_at DESC
      `,
      [studentId]
    );

    res.json(eventsResult.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Failed to load events', error: err.message });
  }
});

module.exports = router;

