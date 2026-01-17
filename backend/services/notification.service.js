/**
 * Notification Service
 * Handles sending push notifications via Firebase Cloud Messaging
 */

const admin = require('firebase-admin');
const pool = require('../config/db');

// Initialize Firebase Admin (only once)
let firebaseInitialized = false;

function initializeFirebase() {
  if (firebaseInitialized) return;

  try {
    // Check if Firebase service account credentials are provided
    const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    
    if (!serviceAccount) {
      console.warn('⚠️  FIREBASE_SERVICE_ACCOUNT_JSON not set. Push notifications disabled.');
      return;
    }

    admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(serviceAccount))
    });

    firebaseInitialized = true;
    console.log('✅ Firebase Admin initialized for push notifications');
  } catch (error) {
    console.error('❌ Failed to initialize Firebase Admin:', error.message);
  }
}

// Initialize on module load
initializeFirebase();

/**
 * Send push notification to a student
 * @param {string} studentId - UUID of the student
 * @param {object} notification - { title, body, data }
 */
async function sendNotificationToStudent(studentId, notification) {
  try {
    if (!firebaseInitialized) {
      console.log('Push notifications disabled - skipping notification');
      return { success: false, error: 'Firebase not initialized' };
    }

    // Get student's FCM token
    const result = await pool.query(
      'SELECT fcm_token FROM students WHERE id = $1',
      [studentId]
    );

    if (result.rowCount === 0 || !result.rows[0].fcm_token) {
      console.log(`Student ${studentId} has no FCM token - skipping notification`);
      return { success: false, error: 'No FCM token' };
    }

    const fcmToken = result.rows[0].fcm_token;

    // Prepare FCM message
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data || {},
      token: fcmToken,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'events',
        }
      }
    };

    // Send the notification
    const response = await admin.messaging().send(message);
    console.log(`✅ Notification sent to student ${studentId}:`, response);

    return { success: true, messageId: response };
  } catch (error) {
    console.error('❌ Error sending notification:', error);

    // If token is invalid, clear it from database
    if (error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered') {
      await pool.query(
        'UPDATE students SET fcm_token = NULL WHERE id = $1',
        [studentId]
      );
      console.log(`Cleared invalid FCM token for student ${studentId}`);
    }

    return { success: false, error: error.message };
  }
}

/**
 * Send notification to multiple students
 * @param {string[]} studentIds - Array of student UUIDs
 * @param {object} notification - { title, body, data }
 */
async function sendNotificationToMultipleStudents(studentIds, notification) {
  const results = await Promise.allSettled(
    studentIds.map(studentId => sendNotificationToStudent(studentId, notification))
  );

  const successful = results.filter(r => r.status === 'fulfilled' && r.value.success).length;
  const failed = results.length - successful;

  console.log(`📊 Notification batch: ${successful} sent, ${failed} failed`);
  
  return { successful, failed, total: results.length };
}

/**
 * Save FCM token for a student
 * @param {string} studentId - UUID of the student
 * @param {string} fcmToken - FCM device token
 */
async function saveFCMToken(studentId, fcmToken) {
  try {
    await pool.query(
      'UPDATE students SET fcm_token = $1 WHERE id = $2',
      [fcmToken, studentId]
    );
    console.log(`✅ FCM token saved for student ${studentId}`);
    return { success: true };
  } catch (error) {
    console.error('❌ Error saving FCM token:', error);
    return { success: false, error: error.message };
  }
}

module.exports = {
  sendNotificationToStudent,
  sendNotificationToMultipleStudents,
  saveFCMToken
};
