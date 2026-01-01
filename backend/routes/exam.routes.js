const express = require('express');
const router = express.Router();
const examController = require('../controllers/exam.controller');
const auth = require('../middleware/auth.middleware');
const { checkFullAccess } = require('../middleware/access.middleware');

// All exam routes require authentication
router.use(auth);

// Get random 30 questions for exam (requires full access)
router.get('/questions', checkFullAccess, examController.getExamQuestions);

// Start new exam session (requires full access)
router.post('/start', checkFullAccess, examController.startExam);

// Submit exam answers (requires full access)
router.post('/submit', checkFullAccess, examController.submitExam);

// Get student's exam history
router.get('/history', examController.getStudentExams);

// Get specific exam details with answers
router.get('/:examId', examController.getExamDetails);

module.exports = router;
