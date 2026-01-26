const express = require('express');
const router = express.Router();

// ⚠️ Self-activation removed for security
// Students cannot activate their own subscriptions
// Schools activate students via POST /schools/students/activate
// Independent students activate via onboarding flow (admin-controlled)

module.exports = router;
