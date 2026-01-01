require('dotenv').config();
const pool = require('./config/db');
const fs = require('fs');
const path = require('path');

async function applyIndexesMigration() {
  const client = await pool.connect();
  
  try {
    console.log('🔄 Starting migration 003: Adding performance indexes...\n');
    
    // Read the migration file
    const migrationPath = path.join(__dirname, 'migrations', '003_add_performance_indexes.sql');
    const sqlContent = fs.readFileSync(migrationPath, 'utf8');
    
    // Split by lines and parse CREATE INDEX statements
    const lines = sqlContent.split('\n');
    const statements = [];
    let currentStatement = '';
    
    for (const line of lines) {
      const trimmed = line.trim();
      
      // Skip comments and empty lines
      if (trimmed.startsWith('--') || trimmed.length === 0) {
        continue;
      }
      
      // Accumulate the statement
      currentStatement += ' ' + trimmed;
      
      // If line ends with semicolon, we have a complete statement
      if (trimmed.endsWith(';')) {
        statements.push(currentStatement.trim().slice(0, -1)); // Remove trailing semicolon
        currentStatement = '';
      }
    }
    
    console.log(`📝 Found ${statements.length} CREATE INDEX statements\n`);
    
    let successCount = 0;
    let skipCount = 0;
    
    for (const statement of statements) {
      // Extract index name
      const indexMatch = statement.match(/CREATE INDEX\s+IF NOT EXISTS\s+(\w+)/i);
      const indexName = indexMatch ? indexMatch[1] : 'unknown';
      
      try {
        await client.query(statement);
        console.log(`✅ ${indexName}`);
        successCount++;
      } catch (err) {
        if (err.message.includes('already exists')) {
          console.log(`⚠️  ${indexName} (already exists)`);
          skipCount++;
        } else {
          console.error(`❌ ${indexName}: ${err.message}`);
        }
      }
    }
    
    console.log('\n' + '='.repeat(60));
    console.log(`✅ Migration complete!`);
    console.log(`   Created: ${successCount} indexes`);
    console.log(`   Skipped: ${skipCount} indexes (already existed)`);
    console.log('='.repeat(60));
    
    // Verify indexes were created
    const result = await client.query(`
      SELECT COUNT(*) as total
      FROM pg_indexes
      WHERE schemaname = 'public'
      AND indexname LIKE 'idx_%'
    `);
    
    console.log(`\n📊 Total indexes in database: ${result.rows[0].total}`);
    
    // List all created indexes
    const indexList = await client.query(`
      SELECT indexname, tablename
      FROM pg_indexes
      WHERE schemaname = 'public'
      AND indexname LIKE 'idx_%'
      ORDER BY tablename, indexname
    `);
    
    console.log('\n📋 All indexes in database:');
    let currentTable = '';
    for (const idx of indexList.rows) {
      if (idx.tablename !== currentTable) {
        console.log(`\n  ${idx.tablename}:`);
        currentTable = idx.tablename;
      }
      console.log(`    - ${idx.indexname}`);
    }
    
    process.exit(0);
  } catch (err) {
    console.error('\n❌ Migration failed:', err);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

applyIndexesMigration();
