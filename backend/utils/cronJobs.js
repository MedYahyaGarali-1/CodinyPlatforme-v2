const pool = require('../config/db');

/**
 * Check and expire subscriptions
 * Run this as a daily cron job
 */
async function expireSubscriptions() {
  try {
    console.log('🕒 Checking for expired subscriptions...');

    const result = await pool.query(
      `
      UPDATE students
      SET 
        subscription_status = 'expired',
        access_level = 'limited',
        is_active = FALSE
      WHERE 
        access_method = 'independent' 
        AND subscription_end < NOW()
        AND subscription_status = 'active'
      RETURNING id, user_id
      `
    );

    if (result.rowCount > 0) {
      console.log(`✅ Expired ${result.rowCount} subscriptions`);
      
      // TODO: Send email notifications to students
      for (const student of result.rows) {
        console.log(`   - Student ID: ${student.id}`);
      }
    } else {
      console.log('✅ No subscriptions to expire');
    }

    return result.rowCount;
  } catch (err) {
    console.error('❌ Error expiring subscriptions:', err);
    throw err;
  }
}

/**
 * Send expiry warnings (3 days before expiry)
 */
async function sendExpiryWarnings() {
  try {
    console.log('📧 Checking for upcoming expirations...');

    const threeDaysFromNow = new Date();
    threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3);

    const result = await pool.query(
      `
      SELECT 
        s.id,
        s.user_id,
        u.name,
        u.identifier as email,
        s.subscription_end
      FROM students s
      JOIN users u ON s.user_id = u.id
      WHERE 
        s.access_method = 'independent'
        AND s.subscription_status = 'active'
        AND s.subscription_end <= $1
        AND s.subscription_end > NOW()
      `,
      [threeDaysFromNow]
    );

    if (result.rowCount > 0) {
      console.log(`📨 Sending ${result.rowCount} expiry warnings`);
      
      // TODO: Send email notifications
      for (const student of result.rows) {
        console.log(`   - ${student.name} (${student.email}) - Expires: ${student.subscription_end}`);
      }
    } else {
      console.log('✅ No upcoming expirations');
    }

    return result.rowCount;
  } catch (err) {
    console.error('❌ Error sending expiry warnings:', err);
    throw err;
  }
}

/**
 * Run all scheduled tasks
 */
async function runScheduledTasks() {
  console.log('\n═══════════════════════════════════════');
  console.log('🚀 Running scheduled tasks');
  console.log(`📅 ${new Date().toLocaleString()}`);
  console.log('═══════════════════════════════════════\n');

  try {
    await expireSubscriptions();
    await sendExpiryWarnings();
    
    console.log('\n✅ All tasks completed successfully\n');
  } catch (err) {
    console.error('\n❌ Tasks failed:', err, '\n');
  }
}

// If run directly (not imported)
if (require.main === module) {
  runScheduledTasks().then(() => {
    process.exit(0);
  }).catch(() => {
    process.exit(1);
  });
}

module.exports = {
  expireSubscriptions,
  sendExpiryWarnings,
  runScheduledTasks
};
