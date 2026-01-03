const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth.middleware');
const pool = require('../config/db');
const schoolController = require('../controllers/school.controller');
const examController = require('../controllers/exam.controller');

async function requireSchool(req, res) {
  const userId = req.user.id;
  const schoolRes = await pool.query('SELECT id, name FROM schools WHERE user_id = $1', [userId]);
  if (!schoolRes.rowCount) {
    res.status(403).json({ message: 'Not a school account' });
    return null;
  }
  return schoolRes.rows[0];
}

/**
 * GET /schools/me
 * School dashboard data with live statistics
 */
router.get('/me', auth, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get school basic info
    const schoolResult = await pool.query(
      'SELECT id, name, is_active FROM schools WHERE user_id = $1',
      [userId]
    );

    if (!schoolResult.rowCount) {
      return res.status(404).json({ message: 'School not found' });
    }

    const school = schoolResult.rows[0];

    // Calculate live statistics
    const statsResult = await pool.query(
      `
      SELECT 
        (SELECT COUNT(*) FROM students WHERE school_id = $1)::integer as total_students,
        COALESCE((SELECT SUM(amount) FROM revenue_tracking WHERE school_id = $1 AND status = 'earned'), 0)::integer as total_earned,
        COALESCE((SELECT SUM(amount) FROM revenue_tracking WHERE school_id = $1 AND status = 'owed_to_platform'), 0)::integer as total_owed_to_platform
      `,
      [school.id]
    );

    const stats = statsResult.rows[0];

    // Combine school info with live stats
    res.json({
      id: school.id,
      name: school.name,
      is_active: school.is_active,
      total_students: stats.total_students || 0,
      total_earned: stats.total_earned || 0,
      total_owed_to_platform: stats.total_owed_to_platform || 0,
    });
  } catch (err) {
    console.error('Error loading school profile:', err);
    console.error('Error details:', {
      message: err.message,
      stack: err.stack,
      userId: req.user?.id
    });
    res.status(500).json({ 
      message: 'Failed to load school profile',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
});

/**
 * POST /schools/students/activate
 * School activates a student (cash payment)
 */
router.post('/students/activate', auth, async (req, res) => {
  try {
    const { studentId } = req.body;
    const userId = req.user.id;

    // 1️⃣ Verify this user is a school
    const schoolResult = await pool.query(
      'SELECT id FROM schools WHERE user_id = $1',
      [userId]
    );

    if (!schoolResult.rowCount) {
      return res.status(403).json({ message: 'Not a school account' });
    }

    const schoolId = schoolResult.rows[0].id;

    // 2️⃣ Check if student is school-linked (not independent)
    const studentCheck = await pool.query(
      'SELECT student_type, school_id FROM students WHERE id = $1',
      [studentId]
    );

    if (!studentCheck.rowCount) {
      return res.status(404).json({ message: 'Student not found' });
    }

    const student = studentCheck.rows[0];

    // Schools cannot activate independent students
    if (student.student_type === 'independent') {
      return res.status(403).json({ 
        message: 'Cannot activate independent students. They must pay online.' 
      });
    }

    // Verify student belongs to this school
    if (student.school_id !== schoolId) {
      return res.status(403).json({ 
        message: 'Student does not belong to your school' 
      });
    }

    // 3️⃣ Activate subscription (30 days)
    const start = new Date();
    const end = new Date();
    end.setDate(end.getDate() + 30);

    await pool.query(
      `
      UPDATE students
      SET subscription_start = $1,
          subscription_end = $2
      WHERE id = $3
      `,
      [start, end, studentId]
    );

    // 4️⃣ Update school finance
    await pool.query(
      `
      UPDATE schools
      SET total_students = total_students + 1,
          total_earned = total_earned + 20,
          total_owed_to_platform = total_owed_to_platform + 30
      WHERE id = $1
      `,
      [schoolId]
    );

    res.json({ message: 'Student activated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Activation failed' });
  }
});

/**
 * GET /schools/students
 * List students attached to the logged-in school
 */
router.get('/students', auth, async (req, res) => {
  try {
    const school = await requireSchool(req, res);
    if (!school) return;

    const sql = `
      SELECT
        st.id,
        u.name,
        st.student_type,
        st.subscription_start,
        st.subscription_end
      FROM students st
      JOIN users u ON u.id = st.user_id
      WHERE st.school_id = $1
      ORDER BY u.name;
    `;

    const { rows } = await pool.query(sql, [school.id]);
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to load students', error: e.message });
  }
});

/**
 * POST /schools/students/attach
 * Attach an existing student to this school (Option 1B)
 * body: { studentId }
 */
router.post('/students/attach', auth, async (req, res) => {
  try {
    const { studentId } = req.body;
    if (!studentId) return res.status(400).json({ message: 'studentId is required' });

    const school = await requireSchool(req, res);
    if (!school) return;

    const update = await pool.query(
      'UPDATE students SET school_id = $1 WHERE id = $2 RETURNING id',
      [school.id, studentId]
    );

    if (!update.rowCount) {
      return res.status(404).json({ message: 'Student not found' });
    }

    res.json({ message: 'Student attached to school', studentId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to attach student', error: e.message });
  }
});

/**
 * POST /schools/students/:id/detach
 * Detach student from this school
 */
router.post('/students/:id/detach', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const school = await requireSchool(req, res);
    if (!school) return;

    const update = await pool.query(
      'UPDATE students SET school_id = NULL WHERE id = $1 AND school_id = $2 RETURNING id',
      [id, school.id]
    );

    if (!update.rowCount) {
      return res.status(404).json({ message: 'Student not found or not attached to this school' });
    }

    res.json({ message: 'Student detached', studentId: id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to detach student', error: e.message });
  }
});

/**
 * Calendar events per student
 * NOTE: requires DB table `student_events`
 */

// GET /schools/students/:id/events
router.get('/students/:id/events', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const school = await requireSchool(req, res);
    if (!school) return;

    // Ensure student belongs to this school
    const ownership = await pool.query('SELECT id FROM students WHERE id = $1 AND school_id = $2', [id, school.id]);
    if (!ownership.rowCount) {
      return res.status(404).json({ message: 'Student not found or not attached to this school' });
    }

    const { rows } = await pool.query(
      `
      SELECT id, title, starts_at, ends_at, location, notes
      FROM student_events
      WHERE student_id = $1
      ORDER BY starts_at;
      `,
      [id]
    );

    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to load events', error: e.message });
  }
});

// POST /schools/students/:id/events
router.post('/students/:id/events', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, starts_at, ends_at, location, notes } = req.body;
    if (!title || !starts_at) {
      return res.status(400).json({ message: 'title and starts_at are required' });
    }

    const school = await requireSchool(req, res);
    if (!school) return;

    const ownership = await pool.query('SELECT id FROM students WHERE id = $1 AND school_id = $2', [id, school.id]);
    if (!ownership.rowCount) {
      return res.status(404).json({ message: 'Student not found or not attached to this school' });
    }

    const insert = await pool.query(
      `
      INSERT INTO student_events (student_id, title, starts_at, ends_at, location, notes)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id;
      `,
      [id, title, starts_at, ends_at ?? null, location ?? null, notes ?? null]
    );

    res.status(201).json({ message: 'Event created', id: insert.rows[0].id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to create event', error: e.message });
  }
});

// POST /schools/events/:eventId/delete
router.post('/events/:eventId/delete', auth, async (req, res) => {
  try {
    const { eventId } = req.params;
    const school = await requireSchool(req, res);
    if (!school) return;

    const del = await pool.query(
      `
      DELETE FROM student_events e
      USING students st
      WHERE e.id = $1
        AND e.student_id = st.id
        AND st.school_id = $2
      RETURNING e.id;
      `,
      [eventId, school.id]
    );

    if (!del.rowCount) {
      return res.status(404).json({ message: 'Event not found' });
    }

    res.json({ message: 'Event deleted', id: eventId });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to delete event', error: e.message });
  }
});

/**
 * Student approval routes
 */
router.get('/:schoolId/pending-students', auth, schoolController.getPendingStudents);
router.post('/:schoolId/approve-student', auth, schoolController.approveStudent);
router.post('/:schoolId/reject-student', auth, schoolController.rejectStudent);
router.get('/:schoolId/approved-students', auth, schoolController.getApprovedStudents);
router.post('/:schoolId/revoke-student-access', auth, schoolController.revokeStudentAccess);

/**
 * GET /schools/:schoolId/revenue
 * Get revenue stats for a school
 */
router.get('/:schoolId/revenue', auth, async (req, res) => {
  try {
    const { schoolId } = req.params;

    // Total school revenue
    const totalResult = await pool.query(`
      SELECT 
        SUM(school_revenue) as total_revenue,
        COUNT(*) as total_students_approved
      FROM revenue_tracking
      WHERE school_id = $1
    `, [schoolId]);

    // Monthly revenue
    const monthlyResult = await pool.query(`
      SELECT 
        DATE_TRUNC('month', created_at) as month,
        SUM(school_revenue) as revenue,
        COUNT(*) as students_approved
      FROM revenue_tracking
      WHERE school_id = $1
      GROUP BY DATE_TRUNC('month', created_at)
      ORDER BY month DESC
      LIMIT 12
    `, [schoolId]);

    // Recent revenue transactions
    const recentResult = await pool.query(`
      SELECT 
        rt.id,
        rt.school_revenue,
        rt.created_at,
        u.name as student_name
      FROM revenue_tracking rt
      JOIN students st ON rt.student_id = st.id
      JOIN users u ON st.user_id = u.id
      WHERE rt.school_id = $1
      ORDER BY rt.created_at DESC
      LIMIT 20
    `, [schoolId]);

    res.json({
      totals: totalResult.rows[0],
      monthly: monthlyResult.rows,
      recent_transactions: recentResult.rows
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to load revenue stats', error: e.message });
  }
});

// ==========================
// 📊 SCHOOL EXAM STATISTICS (NEW)
// ==========================
router.get('/:schoolId/exam-stats', auth, examController.getSchoolExamStats);

module.exports = router;


