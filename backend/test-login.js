// Test Login for User: 23156890
const bcrypt = require('bcrypt');
const pool = require('./config/db');

async function testLogin() {
  try {
    console.log('🔍 Testing login for identifier: 23156890\n');

    // Step 1: Check if user exists
    console.log('Step 1: Checking if user exists...');
    const result = await pool.query(
      'SELECT * FROM users WHERE identifier = $1',
      ['23156890']
    );

    if (result.rowCount === 0) {
      console.log('❌ User NOT found in database!');
      console.log('   Need to register this user first.');
      pool.end();
      return;
    }

    console.log('✅ User found!');
    const user = result.rows[0];
    console.log(`   - ID: ${user.id}`);
    console.log(`   - Name: ${user.name}`);
    console.log(`   - Role: ${user.role}`);
    console.log(`   - Identifier: ${user.identifier}`);

    // Step 2: Test password
    console.log('\nStep 2: Testing password "123456"...');
    const testPassword = '123456';
    const match = await bcrypt.compare(testPassword, user.password_hash);

    if (!match) {
      console.log('❌ Password does NOT match!');
      console.log('   The password in database is different.');
    } else {
      console.log('✅ Password matches!');
    }

    // Step 3: Check student profile
    console.log('\nStep 3: Checking student profile...');
    const studentResult = await pool.query(
      'SELECT * FROM students WHERE user_id = $1',
      [user.id]
    );

    if (studentResult.rowCount === 0) {
      console.log('⚠️  No student profile found');
    } else {
      const student = studentResult.rows[0];
      console.log('✅ Student profile exists');
      console.log(`   - Type: ${student.student_type || 'N/A'}`);
      console.log(`   - Access Method: ${student.access_method || 'N/A'}`);
      console.log(`   - Onboarding Complete: ${student.onboarding_complete}`);
      console.log(`   - Active: ${student.is_active}`);
      console.log(`   - Access Level: ${student.access_level || 'N/A'}`);
    }

    // Final result
    console.log('\n' + '='.repeat(50));
    if (match) {
      console.log('🎉 LOGIN SHOULD WORK!');
      console.log('   Credentials: 23156890 / 123456');
    } else {
      console.log('❌ LOGIN WILL FAIL - Password incorrect');
    }
    console.log('='.repeat(50));

    pool.end();

  } catch (error) {
    console.error('❌ Error:', error.message);
    pool.end();
  }
}

testLogin();
