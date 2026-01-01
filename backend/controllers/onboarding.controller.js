const pool = require('../config/db');
const { calculateStudentAccess, canChangeAccessMethod } = require('../utils/accessControl');

/**
 * POST /api/students/onboarding/choose-method
 * Student chooses access method (independent or school_linked)
 */
async function chooseAccessMethod(req, res) {
  try {
    const userId = req.user.id;
    const { access_method } = req.body;

    // Validate access method
    if (!['independent', 'school_linked'].includes(access_method)) {
      return res.status(400).json({ 
        error: 'Invalid access method',
        message: 'Must be "independent" or "school_linked"'
      });
    }

    // Get current student state
    const studentResult = await pool.query(
      'SELECT * FROM students WHERE user_id = $1',
      [userId]
    );

    if (studentResult.rowCount === 0) {
      return res.status(404).json({ error: 'Student profile not found' });
    }

    const student = studentResult.rows[0];

    // Check if student can change method
    if (student.onboarding_complete && !canChangeAccessMethod(student)) {
      return res.status(400).json({
        error: 'Cannot change access method',
        message: 'You cannot change your access method at this time'
      });
    }

    // Update student record with student_type based on choice
    const studentType = access_method === 'independent' ? 'independent' : 'attached_to_school';
    
    await pool.query(
      `
      UPDATE students
      SET 
        access_method = $1,
        student_type = $2,
        onboarding_complete = FALSE
      WHERE user_id = $3
      `,
      [access_method, studentType, userId]
    );

    res.json({
      message: 'Access method selected',
      access_method,
      student_type: studentType,
      next_step: access_method === 'independent' ? 'payment' : 'school_selection'
    });
  } catch (err) {
    console.error('Choose access method error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

/**
 * POST /api/students/onboarding/link-school
 * Student selects a school to link with
 */
async function linkSchool(req, res) {
  try {
    const userId = req.user.id;
    const { school_id, school_name } = req.body;

    if (!school_name) {
      return res.status(400).json({ error: 'School name is required' });
    }

    // Get student
    const studentResult = await pool.query(
      'SELECT id, access_method FROM students WHERE user_id = $1',
      [userId]
    );

    if (studentResult.rowCount === 0) {
      return res.status(404).json({ error: 'Student profile not found' });
    }

    const student = studentResult.rows[0];

    if (student.access_method !== 'school_linked') {
      return res.status(400).json({ 
        error: 'Invalid access method',
        message: 'You must choose school-linked access first'
      });
    }

    // Update student with school info - automatically approved and activated
    await pool.query(
      `
      UPDATE students
      SET 
        school_id = $1,
        school_approval_status = 'approved',
        school_attached_at = CURRENT_TIMESTAMP,
        school_approved_at = CURRENT_TIMESTAMP,
        onboarding_complete = TRUE,
        is_active = TRUE,
        access_level = 'full',
        student_type = 'attached_to_school'
      WHERE user_id = $2
      `,
      [school_id || null, userId]
    );

    // Create request record with school name (automatically approved)
    await pool.query(
      `
      INSERT INTO school_student_requests (student_id, school_id, school_name, status, reviewed_at)
      VALUES ($1, $2, $3, 'approved', CURRENT_TIMESTAMP)
      `,
      [student.id, school_id || null, school_name]
    );

    // TODO: Send notification to school admin

    res.json({
      message: 'School linked successfully',
      school_id,
      school_name,
      status: 'approved',
      student_type: 'attached_to_school',
      access_level: 'full',
      info: 'You are now linked to the school and have full access to the platform.'
    });
  } catch (err) {
    console.error('Link school error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

/**
 * POST /api/students/onboarding/complete-payment
 * Student completes payment for independent access
 */
async function completePayment(req, res) {
  try {
    const userId = req.user.id;
    const { payment_id, subscription_type } = req.body;

    if (!payment_id || !subscription_type) {
      return res.status(400).json({ error: 'Missing payment information' });
    }

    // Validate subscription type
    const validTypes = ['monthly', 'yearly', 'lifetime'];
    if (!validTypes.includes(subscription_type)) {
      return res.status(400).json({ error: 'Invalid subscription type' });
    }

    // Get student
    const studentResult = await pool.query(
      'SELECT access_method FROM students WHERE user_id = $1',
      [userId]
    );

    if (studentResult.rowCount === 0) {
      return res.status(404).json({ error: 'Student profile not found' });
    }

    const student = studentResult.rows[0];

    if (student.access_method !== 'independent') {
      return res.status(400).json({ 
        error: 'Invalid access method',
        message: 'You must choose independent access first'
      });
    }

    // Calculate subscription dates
    const startDate = new Date();
    let endDate = null;

    if (subscription_type === 'monthly') {
      endDate = new Date(startDate);
      endDate.setMonth(endDate.getMonth() + 1);
    } else if (subscription_type === 'yearly') {
      endDate = new Date(startDate);
      endDate.setFullYear(endDate.getFullYear() + 1);
    }
    // lifetime has no end date

    // Update student with payment info
    await pool.query(
      `
      UPDATE students
      SET 
        payment_verified = TRUE,
        subscription_status = 'active',
        student_type = $1,
        subscription_start = $2,
        subscription_end = $3,
        onboarding_complete = TRUE,
        is_active = TRUE,
        access_level = 'full'
      WHERE user_id = $4
      `,
      [subscription_type, startDate, endDate, userId]
    );

    // TODO: Store payment record in payments table

    res.json({
      message: 'Payment successful',
      subscription_type,
      subscription_start: startDate,
      subscription_end: endDate,
      access_level: 'full',
      info: 'You now have full access to all content'
    });
  } catch (err) {
    console.error('Complete payment error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

/**
 * GET /api/students/me/access
 * Get current access status and permissions
 */
async function getAccessStatus(req, res) {
  try {
    const userId = req.user.id;

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
      return res.status(404).json({ error: 'Student profile not found' });
    }

    const student = result.rows[0];
    const access = calculateStudentAccess(student);

    res.json({
      student: {
        id: student.id,
        onboarding_complete: student.onboarding_complete,
        access_method: student.access_method,
        subscription_type: student.student_type,
        subscription_status: student.subscription_status,
        school_approval_status: student.school_approval_status
      },
      access
    });
  } catch (err) {
    console.error('Get access status error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

/**
 * GET /api/students/me/school-request-status
 * Get school approval request status
 */
async function getSchoolRequestStatus(req, res) {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `
      SELECT 
        s.school_id,
        s.school_approval_status,
        s.school_attached_at,
        s.school_approved_at,
        sr.rejection_reason
      FROM students s
      LEFT JOIN school_student_requests sr ON s.id = sr.student_id AND s.school_id = sr.school_id
      WHERE s.user_id = $1 AND s.access_method = 'school_linked'
      `,
      [userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ 
        error: 'No school request found',
        message: 'You have not requested school access'
      });
    }

    const data = result.rows[0];

    res.json({
      school_id: data.school_id,
      status: data.school_approval_status,
      requested_at: data.school_attached_at,
      approved_at: data.school_approved_at,
      rejection_reason: data.rejection_reason
    });
  } catch (err) {
    console.error('Get school request status error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

/**
 * POST /api/students/change-access-method
 * Change access method (if allowed)
 */
async function changeAccessMethod(req, res) {
  try {
    const userId = req.user.id;
    const { new_method } = req.body;

    if (!['independent', 'school_linked'].includes(new_method)) {
      return res.status(400).json({ error: 'Invalid access method' });
    }

    // Get current student state
    const result = await pool.query(
      'SELECT * FROM students WHERE user_id = $1',
      [userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Student profile not found' });
    }

    const student = result.rows[0];

    // Check if change is allowed
    if (!canChangeAccessMethod(student)) {
      return res.status(400).json({
        error: 'Cannot change access method',
        message: 'You cannot change your access method while you have active access',
        current_method: student.access_method,
        current_status: student.school_approval_status || student.subscription_status
      });
    }

    // Reset relevant fields based on new method
    if (new_method === 'independent') {
      await pool.query(
        `
        UPDATE students
        SET 
          access_method = 'independent',
          school_id = NULL,
          school_approval_status = NULL,
          school_attached_at = NULL,
          school_approved_at = NULL,
          onboarding_complete = FALSE,
          access_level = 'none',
          is_active = FALSE
        WHERE user_id = $1
        `,
        [userId]
      );
    } else {
      await pool.query(
        `
        UPDATE students
        SET 
          access_method = 'school_linked',
          payment_verified = FALSE,
          subscription_status = NULL,
          subscription_start = NULL,
          subscription_end = NULL,
          onboarding_complete = FALSE,
          access_level = 'none',
          is_active = FALSE
        WHERE user_id = $1
        `,
        [userId]
      );
    }

    res.json({
      message: 'Access method changed successfully',
      new_method,
      next_step: new_method === 'independent' ? 'payment' : 'school_selection'
    });
  } catch (err) {
    console.error('Change access method error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

module.exports = {
  chooseAccessMethod,
  linkSchool,
  completePayment,
  getAccessStatus,
  getSchoolRequestStatus,
  changeAccessMethod
};
