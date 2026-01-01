const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const pool = require('../config/db');

router.post('/activate', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    // 1️⃣ Get student
    const studentResult = await pool.query(
      `
      SELECT id, student_type, school_id
      FROM students
      WHERE user_id = $1
      `,
      [userId]
    );

    if (studentResult.rowCount === 0) {
      return res.status(404).json({ message: 'Student not found' });
    }

    const student = studentResult.rows[0];

    // 2️⃣ Calculate dates
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + 30);

    // 3️⃣ Revenue split
    let platformCut = 0;
    let schoolCut = 0;

    if (student.student_type === 'independent') {
      platformCut = 50;
    } else {
      platformCut = 30;
      schoolCut = 20;
    }

    // 4️⃣ Update student subscription
    await pool.query(
      `
      UPDATE students
      SET subscription_start = $1,
          subscription_end = $2
      WHERE id = $3
      `,
      [startDate, endDate, student.id]
    );

    // 5️⃣ Update school earnings if needed
    if (student.student_type === 'school') {
      await pool.query(
        `
        UPDATE schools
        SET total_earned = total_earned + $1,
            total_owed_to_platform = total_owed_to_platform + $2
        WHERE id = $3
        `,
        [schoolCut, platformCut, student.school_id]
      );
    }

    res.json({
      subscription_start: startDate,
      subscription_end: endDate,
      platform_cut: platformCut,
      school_cut: schoolCut,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Subscription activation failed' });
  }
});

module.exports = router;
