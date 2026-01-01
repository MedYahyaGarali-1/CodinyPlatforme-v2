const pool = require('../config/db');
const { calculateStudentAccess } = require('../utils/accessControl');

/**
 * Middleware to require active access for protected routes
 * Use this on routes that need full access (courses, videos, etc.)
 */
async function requireAccess(req, res, next) {
  try {
    const userId = req.user.id;

    // Get student record
    const result = await pool.query(
      `
      SELECT 
        id, user_id, student_type, 
        onboarding_complete, access_method, 
        payment_verified, subscription_status, subscription_start, subscription_end,
        school_id, school_approval_status, school_attached_at, school_approved_at,
        is_active, access_level
      FROM students
      WHERE user_id = $1
      `,
      [userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ 
        error: 'Student profile not found',
        message: 'Please complete your profile setup'
      });
    }

    const student = result.rows[0];
    const access = calculateStudentAccess(student);

    // Attach access info to request for use in controllers
    req.studentAccess = access;
    req.student = student;

    // If not active, deny access
    if (!access.is_active) {
      return res.status(403).json({
        error: 'Access denied',
        message: access.message,
        redirect_to: access.redirect_to,
        reason: access.reason,
        access_level: access.access_level
      });
    }

    next();
  } catch (err) {
    console.error('Access control error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

/**
 * Middleware to check onboarding status
 * Use this to enforce onboarding completion
 */
async function requireOnboarding(req, res, next) {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      'SELECT onboarding_complete FROM students WHERE user_id = $1',
      [userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ 
        error: 'Student profile not found' 
      });
    }

    const student = result.rows[0];

    if (!student.onboarding_complete) {
      return res.status(403).json({
        error: 'Onboarding required',
        message: 'Please complete your account setup',
        redirect_to: 'onboarding'
      });
    }

    next();
  } catch (err) {
    console.error('Onboarding check error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

/**
 * Middleware to check if student has FULL access
 * Use this for premium features like exams
 */
async function checkFullAccess(req, res, next) {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT id, access_level, is_active FROM students WHERE user_id = $1`,
      [userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ 
        error: 'Student profile not found' 
      });
    }

    const student = result.rows[0];

    // Check if student is active and has full access
    if (!student.is_active || student.access_level !== 'full') {
      return res.status(403).json({
        error: 'Full access required',
        message: 'This feature requires full access. Please complete payment or get school approval.',
        access_level: student.access_level,
        redirect_to: 'upgrade'
      });
    }

    req.student = student;
    next();
  } catch (err) {
    console.error('Full access check error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

module.exports = {
  requireAccess,
  requireOnboarding,
  checkFullAccess
};
