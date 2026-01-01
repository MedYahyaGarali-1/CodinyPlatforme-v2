const express = require('express');
const bcrypt = require('bcrypt');
const router = express.Router();
const auth = require('../middleware/auth.middleware');
const pool = require('../config/db');
const examController = require('../controllers/exam.controller');

// 🔒 ADMIN GUARD
function adminOnly(req, res, next) {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Forbidden' });
  }
  next();
}

// ==========================
// 📊 EXAM STATISTICS (NEW)
// ==========================
router.get('/exam-stats', auth, adminOnly, examController.getExamStats);

// ==========================
// 🏫 CREATE SCHOOL (FIXED)
// ==========================
router.post('/create-school', auth, adminOnly, async (req, res) => {
  const { name, identifier, password } = req.body;

  if (!name || !identifier || !password) {
    return res.status(400).json({ message: 'Missing fields' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 🔐 HASH PASSWORD
    const passwordHash = await bcrypt.hash(password, 10);

    // (optional but recommended) avoid duplicate identifier
    const exists = await client.query(
      'SELECT id FROM users WHERE identifier = $1',
      [identifier.trim().toLowerCase()]
    );
    if (exists.rowCount > 0) {
      await client.query('ROLLBACK');
      return res.status(409).json({ message: 'Identifier already exists' });
    }

    // 👤 CREATE SCHOOL USER
    const userResult = await client.query(
      `
      INSERT INTO users (name, identifier, password_hash, role)
      VALUES ($1, $2, $3, 'school')
      RETURNING id
      `,
      [name.trim(), identifier.trim().toLowerCase(), passwordHash]
    );

    const userId = userResult.rows[0].id;

    // 🏫 CREATE SCHOOL PROFILE  ✅ include name column
    await client.query(
      `
      INSERT INTO schools (
        user_id,
        name,
        total_students,
        total_earned,
        total_owed_to_platform,
        active
      )
      VALUES ($1, $2, 0, 0, 0, true)
      `,
      [userId, name.trim()]
    );

    await client.query('COMMIT');
    res.status(201).json({ message: 'School created successfully' });
  } catch (e) {
    await client.query('ROLLBACK');
    console.error(e);
    res.status(500).json({
      message: 'Failed to create school',
      error: e.message,
    });
  } finally {
    client.release();
  }
});

// ==========================
// 📋 GET ALL SCHOOLS
// ==========================
router.get('/schools', auth, adminOnly, async (req, res) => {
  try {
    const sql = `
      SELECT
        s.id,
        s.name,
        s.total_students AS students,
        s.total_earned AS earned,
        s.total_owed_to_platform AS owed,
        s.active
      FROM schools s
      ORDER BY s.name;
    `;

    const result = await pool.query(sql);
    res.json(result.rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to load schools', error: e.message });
  }
});

// ==========================
// 🔍 GET SCHOOL DETAILS
// ==========================
router.get('/schools/:id', auth, adminOnly, async (req, res) => {
  const { id } = req.params;

  const result = await pool.query(
    `
    SELECT 
      s.id,
      u.name,
      s.total_students AS students,
      s.total_earned AS earned,
      s.total_owed_to_platform AS owed,
      s.active
    FROM schools s
    JOIN users u ON u.id = s.user_id
    WHERE s.id = $1
    `,
    [id]
  );

  if (result.rows.length === 0) {
    return res.status(404).json({ message: 'School not found' });
  }

  res.json(result.rows[0]);
});

// ==========================
// 🚫 BLOCK SCHOOL
// ==========================
router.post('/schools/:id/block', auth, adminOnly, async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      'UPDATE schools SET active = false WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'School not found' });
    }

    res.json({ message: 'School blocked' });
  } catch (e) {
    // Handle invalid uuid and other query errors
    console.error(e);
    return res.status(400).json({ message: e.message });
  }
});

// ==========================
// ✅ UNBLOCK SCHOOL
// ==========================
router.post('/schools/:id/unblock', auth, adminOnly, async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      'UPDATE schools SET active = true WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'School not found' });
    }

    res.json({ message: 'School unblocked' });
  } catch (e) {
    console.error(e);
    return res.status(400).json({ message: e.message });
  }
});

// ==========================
// 📊 ADMIN OVERVIEW (DASHBOARD KPIs)
// ==========================
router.get('/overview', auth, adminOnly, async (req, res) => {
  try {
    // total students
    const studentsRes = await pool.query('SELECT COUNT(*)::int AS total_students FROM students');

    // total schools
    const schoolsRes = await pool.query('SELECT COUNT(*)::int AS total_schools FROM schools');

    // owed by schools (sum total_owed_to_platform)
    const owedRes = await pool.query(
      'SELECT COALESCE(SUM(total_owed_to_platform), 0)::int AS owed_by_schools FROM schools'
    );

    // monthly revenue: placeholder (your schema doesn’t have payments table yet)
    // You can replace this later with real calculation from subscriptions/payments.
    const monthlyRevenue = 0;

    res.json({
      totalStudents: studentsRes.rows[0].total_students,
      totalSchools: schoolsRes.rows[0].total_schools,
      monthlyRevenue,
      owedBySchools: owedRes.rows[0].owed_by_schools,
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to load admin overview', error: e.message });
  }
});

// ==========================
// 👥 GET ALL STUDENTS (ADMIN)
// ==========================
router.get('/students', auth, adminOnly, async (req, res) => {
  try {
    // Schema (from user screenshot):
    // students: id (uuid), user_id (uuid), student_type (text), school_id (uuid, nullable), subscription_start, subscription_end

    const sql = `
      SELECT
        st.id,
        u.name AS name,
        st.student_type,
        st.subscription_start,
        st.subscription_end,
        sc.name AS school_name
      FROM students st
      JOIN users u ON u.id = st.user_id
      LEFT JOIN schools sc ON sc.id = st.school_id
      ORDER BY u.name;
    `;

    const { rows } = await pool.query(sql);

    const now = new Date();

    const mapped = rows.map((r) => {
      const end = r.subscription_end ? new Date(r.subscription_end) : null;
      const isActive = end ? end > now : false;
      const daysLeft = end ? Math.max(0, Math.ceil((end - now) / (1000 * 60 * 60 * 24))) : 0;

      return {
        id: r.id,
        name: r.name,
        type: r.student_type,
        school: r.school_name,
        status: isActive ? 'Active' : 'Expired',
        daysLeft,
      };
    });

    res.json(mapped);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Failed to load students', error: e.message });
  }
});

// ==========================
// 🔍 GET STUDENT DETAILS (ADMIN)
// ==========================
router.get('/students/:id', auth, adminOnly, async (req, res) => {
  const { id } = req.params;

  try {
    const sql = `
      SELECT
        st.id,
        u.name AS name,
        st.student_type,
        st.subscription_start,
        st.subscription_end,
        sc.name AS school_name
      FROM students st
      JOIN users u ON u.id = st.user_id
      LEFT JOIN schools sc ON sc.id = st.school_id
      WHERE st.id = $1
      LIMIT 1;
    `;

    const { rows } = await pool.query(sql, [id]);
    if (!rows.length) {
      return res.status(404).json({ message: 'Student not found' });
    }

    const r = rows[0];
    const now = new Date();
    const end = r.subscription_end ? new Date(r.subscription_end) : null;
    const isActive = end ? end > now : false;
    const daysLeft = end ? Math.max(0, Math.ceil((end - now) / (1000 * 60 * 60 * 24))) : 0;

    return res.json({
      id: r.id,
      name: r.name,
      type: r.student_type,
      school: r.school_name,
      status: isActive ? 'Active' : 'Expired',
      daysLeft,
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Failed to load student details', error: e.message });
  }
});

// ==========================
// 💰 GET PLATFORM REVENUE STATS (ADMIN)
// ==========================
router.get('/revenue/stats', auth, adminOnly, async (req, res) => {
  try {
    // Total platform revenue
    const totalResult = await pool.query(`
      SELECT 
        SUM(platform_revenue) as total_platform_revenue,
        SUM(school_revenue) as total_school_revenue,
        SUM(total_amount) as total_revenue,
        COUNT(*) as total_transactions
      FROM revenue_tracking
    `);

    // Revenue by month
    const monthlyResult = await pool.query(`
      SELECT 
        DATE_TRUNC('month', created_at) as month,
        SUM(platform_revenue) as platform_revenue,
        SUM(school_revenue) as school_revenue,
        COUNT(*) as transactions
      FROM revenue_tracking
      GROUP BY DATE_TRUNC('month', created_at)
      ORDER BY month DESC
      LIMIT 12
    `);

    // Recent transactions
    const recentResult = await pool.query(`
      SELECT 
        rt.id,
        rt.platform_revenue,
        rt.school_revenue,
        rt.total_amount,
        rt.created_at,
        u.name as student_name,
        s.name as school_name
      FROM revenue_tracking rt
      JOIN students st ON rt.student_id = st.id
      JOIN users u ON st.user_id = u.id
      LEFT JOIN schools s ON rt.school_id = s.id
      ORDER BY rt.created_at DESC
      LIMIT 50
    `);

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

module.exports = router;


