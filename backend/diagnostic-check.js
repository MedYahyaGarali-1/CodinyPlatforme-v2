const pool = require('./config/db');

/**
 * Comprehensive System Diagnostics - Run this to see everything!
 * 
 * Usage: node backend/diagnostic-check.js
 */

async function runDiagnostics() {
  console.log('\n🔍 ==============================================');
  console.log('   CODINY PLATFORM - SYSTEM DIAGNOSTICS');
  console.log('   Date:', new Date().toISOString());
  console.log('==============================================\n');

  try {
    // ========================================
    // 1. DATABASE CONNECTION CHECK
    // ========================================
    console.log('📊 1. DATABASE CONNECTION');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    try {
      const connectionTest = await pool.query('SELECT NOW() as current_time, version() as postgres_version');
      console.log('✅ Database Connected Successfully!');
      console.log('   Time:', connectionTest.rows[0].current_time);
      console.log('   Version:', connectionTest.rows[0].postgres_version.split(' ')[0], connectionTest.rows[0].postgres_version.split(' ')[1]);
    } catch (err) {
      console.log('❌ Database Connection FAILED:', err.message);
      return;
    }

    console.log('\n');

    // ========================================
    // 2. USERS TABLE CHECK
    // ========================================
    console.log('👥 2. USERS TABLE ANALYSIS');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    const usersCount = await pool.query('SELECT COUNT(*) as total FROM users');
    console.log(`📈 Total Users: ${usersCount.rows[0].total}`);
    
    const usersByRole = await pool.query(`
      SELECT role, COUNT(*) as count 
      FROM users 
      GROUP BY role 
      ORDER BY count DESC
    `);
    console.log('\n👤 Users by Role:');
    usersByRole.rows.forEach(row => {
      console.log(`   ${row.role}: ${row.count}`);
    });

    // Check for users with missing names
    const usersWithoutNames = await pool.query(`
      SELECT COUNT(*) as count 
      FROM users 
      WHERE name IS NULL OR name = ''
    `);
    console.log(`\n⚠️  Users with missing names: ${usersWithoutNames.rows[0].count}`);

    // Show recent users
    console.log('\n📋 Recent 5 Users:');
    const recentUsers = await pool.query(`
      SELECT id, name, identifier, role, created_at 
      FROM users 
      ORDER BY created_at DESC 
      LIMIT 5
    `);
    console.table(recentUsers.rows.map(u => ({
      ID: u.id.substring(0, 8) + '...',
      Name: u.name || '❌ NULL',
      Email: u.identifier,
      Role: u.role,
      Created: new Date(u.created_at).toLocaleDateString()
    })));

    console.log('\n');

    // ========================================
    // 3. STUDENTS TABLE CHECK
    // ========================================
    console.log('🎓 3. STUDENTS TABLE ANALYSIS');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    const studentsCount = await pool.query('SELECT COUNT(*) as total FROM students');
    console.log(`📈 Total Students: ${studentsCount.rows[0].total}`);

    // Check permit_type column exists
    const permitColumnCheck = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'students' AND column_name = 'permit_type'
    `);
    
    if (permitColumnCheck.rows.length > 0) {
      console.log('✅ permit_type column exists');
      
      // Permit type distribution
      const permitStats = await pool.query(`
        SELECT 
          permit_type,
          COUNT(*) as count
        FROM students
        GROUP BY permit_type
        ORDER BY count DESC
      `);
      console.log('\n🚗 Permit Type Distribution:');
      permitStats.rows.forEach(row => {
        const permitName = row.permit_type || 'Not Selected';
        console.log(`   Permit ${row.permit_type || 'NULL'}: ${row.count}`);
      });
    } else {
      console.log('❌ permit_type column MISSING! Need to run migration.');
    }

    // Student type distribution
    const studentTypeStats = await pool.query(`
      SELECT 
        student_type,
        COUNT(*) as count
      FROM students
      GROUP BY student_type
      ORDER BY count DESC
    `);
    console.log('\n📊 Student Type Distribution:');
    studentTypeStats.rows.forEach(row => {
      console.log(`   ${row.student_type}: ${row.count}`);
    });

    // Active vs Inactive
    const activeStats = await pool.query(`
      SELECT 
        is_active,
        COUNT(*) as count
      FROM students
      GROUP BY is_active
    `);
    console.log('\n🔓 Activation Status:');
    activeStats.rows.forEach(row => {
      const status = row.is_active ? '✅ Active' : '❌ Inactive';
      console.log(`   ${status}: ${row.count}`);
    });

    // Approval status
    const approvalStats = await pool.query(`
      SELECT 
        school_approval_status,
        COUNT(*) as count
      FROM students
      GROUP BY school_approval_status
    `);
    console.log('\n🏫 School Approval Status:');
    approvalStats.rows.forEach(row => {
      const status = row.school_approval_status || 'No School Linked';
      console.log(`   ${status}: ${row.count}`);
    });

    // Recent students detailed view
    console.log('\n📋 Recent 5 Students (Detailed):');
    const recentStudents = await pool.query(`
      SELECT 
        s.id,
        u.name as user_name,
        u.identifier,
        s.student_type,
        s.permit_type,
        s.is_active,
        s.school_approval_status,
        s.onboarding_complete
      FROM students s
      JOIN users u ON s.user_id = u.id
      ORDER BY s.created_at DESC
      LIMIT 5
    `);
    console.table(recentStudents.rows.map(s => ({
      ID: s.id.substring(0, 8) + '...',
      Name: s.user_name || '❌ NULL',
      Email: s.identifier,
      Type: s.student_type,
      Permit: s.permit_type || 'None',
      Active: s.is_active ? '✅' : '❌',
      Status: s.school_approval_status || 'None',
      Onboarded: s.onboarding_complete ? '✅' : '❌'
    })));

    console.log('\n');

    // ========================================
    // 4. SCHOOLS TABLE CHECK
    // ========================================
    console.log('🏫 4. SCHOOLS TABLE ANALYSIS');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    const schoolsCount = await pool.query('SELECT COUNT(*) as total FROM schools');
    console.log(`📈 Total Schools: ${schoolsCount.rows[0].total}`);

    if (parseInt(schoolsCount.rows[0].total) > 0) {
      const recentSchools = await pool.query(`
        SELECT 
          s.id,
          u.name as school_name,
          u.identifier,
          (SELECT COUNT(*) FROM students WHERE school_id = s.id) as student_count,
          (SELECT COUNT(*) FROM students WHERE school_id = s.id AND school_approval_status = 'approved') as approved_count
        FROM schools s
        JOIN users u ON s.user_id = u.id
        ORDER BY s.created_at DESC
        LIMIT 5
      `);
      
      console.log('\n📋 Recent Schools:');
      console.table(recentSchools.rows.map(sch => ({
        ID: sch.id.substring(0, 8) + '...',
        Name: sch.school_name,
        Email: sch.identifier,
        Students: sch.student_count,
        Approved: sch.approved_count
      })));
    }

    console.log('\n');

    // ========================================
    // 5. ISSUES DETECTION
    // ========================================
    console.log('🚨 5. ISSUES DETECTION');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    let issuesFound = 0;

    // Issue 1: Users with no name
    const noNameUsers = await pool.query(`
      SELECT id, identifier, role 
      FROM users 
      WHERE name IS NULL OR name = ''
      LIMIT 5
    `);
    if (noNameUsers.rows.length > 0) {
      issuesFound++;
      console.log(`❌ Issue 1: ${noNameUsers.rows.length} users have no name`);
      console.log('   Users affected:');
      noNameUsers.rows.forEach(u => {
        console.log(`   - ${u.identifier} (${u.role})`);
      });
      console.log('   Fix: UPDATE users SET name = \'User Name\' WHERE id = \'...\'\n');
    } else {
      console.log('✅ No users with missing names\n');
    }

    // Issue 2: Students with type=independent but active
    const wrongTypeStudents = await pool.query(`
      SELECT COUNT(*) as count
      FROM students
      WHERE student_type = 'independent' AND is_active = true
    `);
    if (parseInt(wrongTypeStudents.rows[0].count) > 0) {
      issuesFound++;
      console.log(`⚠️  Issue 2: ${wrongTypeStudents.rows[0].count} students are active but still type='independent'`);
      console.log('   Expected: When active, should be \'attached_to_school\'');
      console.log('   This might be from old data before the fix\n');
    } else {
      console.log('✅ No students with incorrect type/active combination\n');
    }

    // Issue 3: Students with no permit_type
    if (permitColumnCheck.rows.length > 0) {
      const noPermitStudents = await pool.query(`
        SELECT COUNT(*) as count
        FROM students
        WHERE permit_type IS NULL AND onboarding_complete = true
      `);
      if (parseInt(noPermitStudents.rows[0].count) > 0) {
        issuesFound++;
        console.log(`⚠️  Issue 3: ${noPermitStudents.rows[0].count} students completed onboarding but have no permit_type`);
        console.log('   Fix: UPDATE students SET permit_type = \'B\' WHERE permit_type IS NULL\n');
      } else {
        console.log('✅ All onboarded students have permit types\n');
      }
    }

    // Issue 4: Students approved but not active
    const approvedButInactive = await pool.query(`
      SELECT COUNT(*) as count
      FROM students
      WHERE school_approval_status = 'approved' AND is_active = false
    `);
    if (parseInt(approvedButInactive.rows[0].count) > 0) {
      issuesFound++;
      console.log(`❌ Issue 4: ${approvedButInactive.rows[0].count} students are approved but NOT active!`);
      console.log('   This is critical - approved students should be active');
      console.log('   Fix: UPDATE students SET is_active = true WHERE school_approval_status = \'approved\'\n');
    } else {
      console.log('✅ All approved students are active\n');
    }

    if (issuesFound === 0) {
      console.log('🎉 No issues detected! System is healthy!\n');
    } else {
      console.log(`\n⚠️  Found ${issuesFound} issue(s) that need attention\n`);
    }

    // ========================================
    // 6. ROUTES CHECK
    // ========================================
    console.log('🛣️  6. API ROUTES VERIFICATION');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    console.log('Expected Routes:');
    const expectedRoutes = [
      { method: 'POST', path: '/api/auth/register', status: '✅ Should exist' },
      { method: 'POST', path: '/api/auth/login', status: '✅ Should exist' },
      { method: 'POST', path: '/api/students/onboarding/choose-permit', status: '✅ NEW (Permit System)' },
      { method: 'GET', path: '/api/students/me', status: '✅ Should exist' },
      { method: 'POST', path: '/api/schools/:id/approve-student', status: '✅ Should exist' },
    ];

    console.table(expectedRoutes);

    console.log('\n💡 To verify routes are working:');
    console.log('   Check Railway logs during app usage');
    console.log('   Look for: "🟢 Route called" or "404 Not Found"\n');

    // ========================================
    // 7. ENVIRONMENT CHECK
    // ========================================
    console.log('⚙️  7. ENVIRONMENT CONFIGURATION');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    console.log('Environment Variables:');
    console.log(`   NODE_ENV: ${process.env.NODE_ENV || 'not set'}`);
    console.log(`   PORT: ${process.env.PORT || 'not set'}`);
    console.log(`   DATABASE_URL: ${process.env.DATABASE_URL ? '✅ Set' : '❌ Not set'}`);
    console.log(`   JWT_SECRET: ${process.env.JWT_SECRET ? '✅ Set' : '❌ Not set'}`);

    console.log('\n');

    // ========================================
    // SUMMARY
    // ========================================
    console.log('📊 SUMMARY');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    console.log(`   Total Users: ${usersCount.rows[0].total}`);
    console.log(`   Total Students: ${studentsCount.rows[0].total}`);
    console.log(`   Total Schools: ${schoolsCount.rows[0].total}`);
    console.log(`   Permit System: ${permitColumnCheck.rows.length > 0 ? '✅ Enabled' : '❌ Disabled'}`);
    console.log(`   Issues Found: ${issuesFound}`);
    console.log(`   Overall Health: ${issuesFound === 0 ? '✅ HEALTHY' : '⚠️  NEEDS ATTENTION'}\n`);

    console.log('🎯 NEXT STEPS');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    if (issuesFound > 0) {
      console.log('   1. Review issues above');
      console.log('   2. Run suggested SQL fixes in Railway Query Tool');
      console.log('   3. Run this diagnostic again to verify fixes');
    } else {
      console.log('   ✅ System is healthy!');
      console.log('   ✅ Ready for production use');
      console.log('   ✅ Test the app on device');
    }

    console.log('\n==============================================');
    console.log('   DIAGNOSTICS COMPLETE');
    console.log('==============================================\n');

  } catch (error) {
    console.error('\n❌ DIAGNOSTIC ERROR:', error.message);
    console.error('Stack:', error.stack);
  } finally {
    await pool.end();
    process.exit(0);
  }
}

// Run diagnostics
console.log('\n🚀 Starting System Diagnostics...\n');
runDiagnostics();
