require('dotenv').config();
const pool = require('./config/db');
const fs = require('fs');

async function runMigration() {
  try {
    console.log('📂 Reading migration file...');
    const sql = fs.readFileSync('./migrations/003_create_exam_system.sql', 'utf8');
    
    console.log('🔄 Running exam system migration...');
    await pool.query(sql);
    
    console.log('✅ Exam system tables created successfully!');
    
    // Verify tables were created
    const result = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_name IN ('exam_questions', 'exam_sessions', 'exam_answers')
      ORDER BY table_name;
    `);
    
    console.log('📊 Created tables:', result.rows.map(r => r.table_name).join(', '));
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    process.exit(1);
  }
}

runMigration();
