const pool = require('../config/db');
const PaginationHelper = require('../utils/pagination');

/**
 * GET /api/schools/:schoolId/pending-students
 * Get all pending student requests for a school
 */
async function getPendingStudents(req, res) {
  try {
    const { schoolId } = req.params;

    // TODO: Verify that the logged-in user is admin of this school

    // Get pagination parameters
    const { page, limit, offset } = PaginationHelper.getPaginationParams(req.query);

    // Count total pending students
    const countResult = await pool.query(
      `
      SELECT COUNT(*) as total
      FROM school_student_requests sr
      WHERE sr.school_id = $1 AND sr.status = 'pending'
      `,
      [schoolId]
    );
    const totalCount = parseInt(countResult.rows[0].total);

    // Get paginated results
    const result = await pool.query(
      `
      SELECT 
        s.id,
        u.name,
        u.identifier as email,
        sr.requested_at,
        sr.id as request_id
      FROM school_student_requests sr
      JOIN students s ON sr.student_id = s.id
      JOIN users u ON s.user_id = u.id
      WHERE sr.school_id = $1 AND sr.status = 'pending'
      ORDER BY sr.requested_at DESC
      LIMIT $2 OFFSET $3
      `,
      [schoolId, limit, offset]
    );

    const response = PaginationHelper.formatResponse(result.rows, totalCount, page, limit);

    res.json({
      pending_count: totalCount,
      students: response.data,
      pagination: response.pagination
    });
  } catch (err) {
    console.error('Get pending students error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

/**
 * POST /api/schools/:schoolId/approve-student
 * Approve a student's request to join the school
 */
async function approveStudent(req, res) {
  const client = await pool.connect();
  
  try {
    const { schoolId } = req.params;
    const { student_id } = req.body;

    if (!student_id) {
      return res.status(400).json({ error: 'Student ID is required' });
    }

    // TODO: Verify that the logged-in user is admin of this school

    await client.query('BEGIN');

    // Update student record
    const updateResult = await client.query(
      `
      UPDATE students
      SET 
        student_type = 'attached_to_school',
        school_approval_status = 'approved',
        school_approved_at = CURRENT_TIMESTAMP,
        is_active = TRUE,
        access_level = 'full'
      WHERE id = $1 AND school_id = $2 AND school_approval_status = 'pending'
      RETURNING id, user_id
      `,
      [student_id, schoolId]
    );

    if (updateResult.rowCount === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ 
        error: 'Student request not found or already processed'
      });
    }

    // Update request record
    await client.query(
      `
      UPDATE school_student_requests
      SET 
        status = 'approved',
        reviewed_at = CURRENT_TIMESTAMP,
        reviewed_by = $1
      WHERE student_id = $2 AND school_id = $3 AND status = 'pending'
      `,
      [req.user.id, student_id, schoolId]
    );

    // Track revenue: 20 TND for school, 30 TND for platform
    await client.query(
      `
      INSERT INTO revenue_tracking (
        student_id,
        school_id,
        school_revenue,
        platform_revenue,
        total_amount,
        created_at
      ) VALUES ($1, $2, 20.00, 30.00, 50.00, CURRENT_TIMESTAMP)
      `,
      [student_id, schoolId]
    );

    await client.query('COMMIT');

    // TODO: Send notification to student (email + push)

    res.json({
      message: 'Student approved successfully! Revenue tracked: 20 TND for school, 30 TND for platform.',
      student_id,
      status: 'approved',
      revenue: {
        school: '20 TND',
        platform: '30 TND',
        total: '50 TND'
      }
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Approve student error:', err);
    res.status(500).json({ error: 'Server error' });
  } finally {
    client.release();
  }
}

/**
 * POST /api/schools/:schoolId/reject-student
 * Reject a student's request to join the school
 */
async function rejectStudent(req, res) {
  const client = await pool.connect();
  
  try {
    const { schoolId } = req.params;
    const { student_id, reason } = req.body;

    if (!student_id) {
      return res.status(400).json({ error: 'Student ID is required' });
    }

    // TODO: Verify that the logged-in user is admin of this school

    await client.query('BEGIN');

    // Update student record
    const updateResult = await client.query(
      `
      UPDATE students
      SET 
        school_approval_status = 'rejected',
        is_active = FALSE,
        access_level = 'none'
      WHERE id = $1 AND school_id = $2 AND school_approval_status = 'pending'
      RETURNING id, user_id
      `,
      [student_id, schoolId]
    );

    if (updateResult.rowCount === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ 
        error: 'Student request not found or already processed'
      });
    }

    // Update request record
    await client.query(
      `
      UPDATE school_student_requests
      SET 
        status = 'rejected',
        reviewed_at = CURRENT_TIMESTAMP,
        reviewed_by = $1,
        rejection_reason = $2
      WHERE student_id = $3 AND school_id = $4 AND status = 'pending'
      `,
      [req.user.id, reason, student_id, schoolId]
    );

    await client.query('COMMIT');

    // TODO: Send notification to student (email + push)

    res.json({
      message: 'Student request rejected',
      student_id,
      status: 'rejected',
      reason
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Reject student error:', err);
    res.status(500).json({ error: 'Server error' });
  } finally {
    client.release();
  }
}

/**
 * GET /api/schools/:schoolId/approved-students
 * Get all approved students for a school
 */
async function getApprovedStudents(req, res) {
  try {
    const { schoolId } = req.params;

    // TODO: Verify that the logged-in user is admin of this school

    // Get pagination parameters
    const { page, limit, offset } = PaginationHelper.getPaginationParams(req.query);

    // Count total approved students
    const countResult = await pool.query(
      `
      SELECT COUNT(*) as total
      FROM students s
      WHERE s.school_id = $1 AND s.school_approval_status = 'approved'
      `,
      [schoolId]
    );
    const totalCount = parseInt(countResult.rows[0].total);

    // Get paginated results
    const result = await pool.query(
      `
      SELECT 
        s.id,
        u.name,
        u.identifier as email,
        s.school_approved_at,
        s.is_active
      FROM students s
      JOIN users u ON s.user_id = u.id
      WHERE s.school_id = $1 AND s.school_approval_status = 'approved'
      ORDER BY s.school_approved_at DESC
      LIMIT $2 OFFSET $3
      `,
      [schoolId, limit, offset]
    );

    const response = PaginationHelper.formatResponse(result.rows, totalCount, page, limit);

    res.json({
      approved_count: totalCount,
      students: response.data,
      pagination: response.pagination
    });
  } catch (err) {
    console.error('Get approved students error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

/**
 * POST /api/schools/:schoolId/revoke-student-access
 * Revoke a student's access (remove from school)
 */
async function revokeStudentAccess(req, res) {
  try {
    const { schoolId } = req.params;
    const { student_id, reason } = req.body;

    if (!student_id) {
      return res.status(400).json({ error: 'Student ID is required' });
    }

    // TODO: Verify that the logged-in user is admin of this school

    const result = await pool.query(
      `
      UPDATE students
      SET 
        school_id = NULL,
        school_approval_status = 'rejected',
        is_active = FALSE,
        access_level = 'none'
      WHERE id = $1 AND school_id = $2
      RETURNING id, user_id
      `,
      [student_id, schoolId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ 
        error: 'Student not found in this school'
      });
    }

    // TODO: Send notification to student

    res.json({
      message: 'Student access revoked',
      student_id,
      reason
    });
  } catch (err) {
    console.error('Revoke student access error:', err);
    res.status(500).json({ error: 'Server error' });
  }
}

module.exports = {
  getPendingStudents,
  approveStudent,
  rejectStudent,
  getApprovedStudents,
  revokeStudentAccess
};
