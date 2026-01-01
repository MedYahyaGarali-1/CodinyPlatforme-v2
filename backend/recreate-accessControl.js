const fs = require('fs');

const content = `/**
 * Student Access Control Logic
 * Centralized access calculation based on student state
 */

function calculateStudentAccess(student) {
  if (!student.onboarding_complete) {
    return {
      access_level: 'none',
      is_active: false,
      can_access_courses: false,
      can_access_qcm: false,
      can_access_videos: false,
      can_access_exams: false,
      redirect_to: 'onboarding',
      message: null,
      reason: 'onboarding_incomplete'
    };
  }

  if (student.access_method === 'independent') {
    const hasPaidSubscription = 
      student.payment_verified && 
      student.subscription_status === 'active' &&
      (!student.subscription_end || new Date(student.subscription_end) > new Date());

    return {
      access_level: hasPaidSubscription ? 'full' : 'limited',
      is_active: hasPaidSubscription,
      can_access_courses: hasPaidSubscription,
      can_access_qcm: hasPaidSubscription,
      can_access_videos: hasPaidSubscription,
      can_access_exams: hasPaidSubscription,
      redirect_to: hasPaidSubscription ? null : 'payment',
      message: hasPaidSubscription ? null : 'Subscribe to access premium content',
      reason: hasPaidSubscription ? 'paid_active' : 'unpaid'
    };
  }

  if (student.access_method === 'school_linked') {
    switch (student.school_approval_status) {
      case 'pending':
        return {
          access_level: 'limited',
          is_active: false,
          can_access_courses: false,
          can_access_qcm: false,
          can_access_videos: false,
          can_access_exams: false,
          redirect_to: null,
          message: 'Waiting for school approval. You will be notified once approved.',
          reason: 'school_pending'
        };

      case 'approved':
        return {
          access_level: 'full',
          is_active: true,
          can_access_courses: true,
          can_access_qcm: true,
          can_access_videos: true,
          can_access_exams: true,
          redirect_to: null,
          message: null,
          reason: 'school_approved'
        };

      case 'rejected':
        return {
          access_level: 'none',
          is_active: false,
          can_access_courses: false,
          can_access_qcm: false,
          can_access_videos: false,
          can_access_exams: false,
          redirect_to: 'onboarding',
          message: 'Your request was rejected. Please choose another access method.',
          reason: 'school_rejected'
        };
    }
  }

  return {
    access_level: 'none',
    is_active: false,
    can_access_courses: false,
    can_access_qcm: false,
    can_access_videos: false,
    can_access_exams: false,
    redirect_to: 'onboarding',
    message: 'Please complete your account setup',
    reason: 'unknown_state'
  };
}

function isSubscriptionExpired(student) {
  if (student.access_method !== 'independent') return false;
  if (!student.subscription_end) return false;
  return new Date(student.subscription_end) <= new Date();
}

function canChangeAccessMethod(student) {
  if (!student.onboarding_complete) return true;

  if (student.access_method === 'school_linked') {
    return student.school_approval_status === 'pending' || 
           student.school_approval_status === 'rejected';
  }

  if (student.access_method === 'independent') {
    return isSubscriptionExpired(student);
  }

  return false;
}

module.exports = {
  calculateStudentAccess,
  isSubscriptionExpired,
  canChangeAccessMethod
};
`;

fs.writeFileSync('./utils/accessControl.js', content, 'utf8');
console.log('✅ accessControl.js created successfully!');
console.log('File size:', fs.statSync('./utils/accessControl.js').size, 'bytes');
