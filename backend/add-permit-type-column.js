const pool = require('./config/db');

async function addPermitTypeColumn() {
  console.log('🚀 Starting permit_type column migration...');
  
  try {
    // Check if column exists
    const checkColumn = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'students' 
      AND column_name = 'permit_type'
    `);

    if (checkColumn.rows.length > 0) {
      console.log('✅ permit_type column already exists');
    } else {
      // Add the column
      await pool.query(`
        ALTER TABLE students 
        ADD COLUMN permit_type VARCHAR(10) CHECK (permit_type IN ('A', 'B', 'C'))
      `);
      console.log('✅ permit_type column added successfully');
    }

    // Set default value 'B' for existing students
    const updateResult = await pool.query(`
      UPDATE students 
      SET permit_type = 'B' 
      WHERE permit_type IS NULL
    `);
    console.log(`✅ Updated ${updateResult.rowCount} existing students to permit type 'B'`);

    // Verify the column
    const verify = await pool.query(`
      SELECT 
        COUNT(*) as total,
        COUNT(permit_type) as with_permit,
        permit_type
      FROM students
      GROUP BY permit_type
    `);
    console.log('📊 Current permit distribution:');
    console.table(verify.rows);

    console.log('✅ Migration completed successfully!');
  } catch (error) {
    console.error('❌ Migration error:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

addPermitTypeColumn();
