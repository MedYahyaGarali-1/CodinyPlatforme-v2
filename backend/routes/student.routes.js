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
        COALESCE(access_level, 'trial') as access_level,
        permit_type
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
    console.log('[STUDENT EVENTS] Request received from user:', req.user.id);
    const userId = req.user.id;

    // Get student ID from user ID
    const studentResult = await pool.query(
      'SELECT id FROM students WHERE user_id = $1',
      [userId]
    );

    console.log('[STUDENT EVENTS] Student query result:', studentResult.rowCount, studentResult.rows);

    if (studentResult.rowCount === 0) {
      console.log('[STUDENT EVENTS] No student found for user_id:', userId);
      return res.status(404).json({ message: 'Student profile not found' });
    }

    const studentId = studentResult.rows[0].id;
    console.log('[STUDENT EVENTS] Found student ID:', studentId);

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

    console.log('[STUDENT EVENTS] Found', eventsResult.rowCount, 'events');
    res.json(eventsResult.rows);
  } catch (err) {
    console.error('[STUDENT EVENTS] Error:', err);
    res.status(500).json({ message: 'Failed to load events', error: err.message });
  }
});

// POST /students/fcm-token - Save FCM token for push notifications
router.post('/fcm-token', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const { fcm_token } = req.body;

    if (!fcm_token) {
      return res.status(400).json({ message: 'fcm_token is required' });
    }

    // Get student ID
    const studentResult = await pool.query(
      'SELECT id FROM students WHERE user_id = $1',
      [userId]
    );

    if (studentResult.rowCount === 0) {
      return res.status(404).json({ message: 'Student profile not found' });
    }

    const studentId = studentResult.rows[0].id;

    // Save FCM token
    await pool.query(
      'UPDATE students SET fcm_token = $1 WHERE id = $2',
      [fcm_token, studentId]
    );

    console.log(`✅ FCM token saved for student ${studentId}`);
    res.json({ message: 'FCM token saved successfully' });
  } catch (err) {
    console.error('Error saving FCM token:', err);
    res.status(500).json({ message: 'Failed to save FCM token', error: err.message });
  }
});

module.exports = router;

