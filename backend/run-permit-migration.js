// Run this migration on Railway after deployment
// Railway CLI: railway run node run-permit-migration.js

const pool = require('./config/db');

async function runMigration() {
  console.log('🚀 Running permit_type migration on Railway...');
  
  try {
    // Check if column exists
    console.log('1️⃣ Checking if permit_type column exists...');
    const checkColumn = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'students' 
      AND column_name = 'permit_type'
    `);

    if (checkColumn.rows.length > 0) {
      console.log('✅ permit_type column already exists');
    } else {
      console.log('2️⃣ Adding permit_type column...');
      await pool.query(`
        ALTER TABLE students 
        ADD COLUMN permit_type VARCHAR(10) CHECK (permit_type IN ('A', 'B', 'C'))
      `);
      console.log('✅ permit_type column added successfully');
    }

    // Set default value 'B' for existing students
    console.log('3️⃣ Setting default permit type B for existing students...');
    const updateResult = await pool.query(`
      UPDATE students 
      SET permit_type = 'B' 
      WHERE permit_type IS NULL
    `);
    console.log(`✅ Updated ${updateResult.rowCount} students to permit type 'B'`);

    // Verify
    console.log('4️⃣ Verifying migration...');
    const verify = await pool.query(`
      SELECT 
        COUNT(*) as total_students,
        COUNT(permit_type) as students_with_permit,
        permit_type
      FROM students
      GROUP BY permit_type
    `);
    
    console.log('\n📊 Current permit distribution:');
    console.table(verify.rows);

    console.log('\n✅ Migration completed successfully on Railway!');
    console.log('\n🎯 Next steps:');
    console.log('   1. Railway will auto-deploy the new backend code');
    console.log('   2. Wait ~2 minutes for deployment to complete');
    console.log('   3. Test the app - you should see "Choose Your Permit 🚗"');
    
  } catch (error) {
    console.error('❌ Migration error:', error.message);
    console.error('Full error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

runMigration();
