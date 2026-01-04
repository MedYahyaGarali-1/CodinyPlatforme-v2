const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const onboardingController = require('../controllers/onboarding.controller');

// Onboarding routes (require authentication)
router.post(
  '/onboarding/choose-method',
  authMiddleware,
  onboardingController.chooseAccessMethod
);

router.post(
  '/onboarding/link-school',
  authMiddleware,
  onboardingController.linkSchool
);

router.post(
  '/onboarding/complete-payment',
  authMiddleware,
  onboardingController.completePayment
);

router.post(
  '/onboarding/choose-permit',
  authMiddleware,
  onboardingController.choosePermitType
);

router.post(
  '/change-access-method',
  authMiddleware,
  onboardingController.changeAccessMethod
);

// Access status routes
router.get(
  '/me/access',
  authMiddleware,
  onboardingController.getAccessStatus
);

router.get(
  '/me/school-request-status',
  authMiddleware,
  onboardingController.getSchoolRequestStatus
);

module.exports = router;
