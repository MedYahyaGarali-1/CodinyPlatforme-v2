const dotenv = require('dotenv');
dotenv.config();

const pool = require('./config/db');
const fs = require('fs');

async function importQuestions() {
  try {
    console.log('📂 Reading questions.json file...');
    const questionsPath = 'c:\\Users\\yahya\\OneDrive\\Desktop\\tests\\questions.json';
    const rawData = fs.readFileSync(questionsPath, 'utf8');
    const questionsData = JSON.parse(rawData);
    const questions = questionsData.value;

    console.log(`📊 Found ${questions.length} questions to import`);

    // Check if questions already exist
    const existingCheck = await pool.query('SELECT COUNT(*) FROM exam_questions');
    const existingCount = parseInt(existingCheck.rows[0].count);
    
    if (existingCount > 0) {
      console.log(`⚠️  Found ${existingCount} existing questions. Clearing table...`);
      await pool.query('DELETE FROM exam_questions');
    }

    console.log('🔄 Importing questions...');
    let imported = 0;
    
    for (let i = 0; i < questions.length; i++) {
      const q = questions[i];
      
      // Map answer index to letter (0=A, 1=B, 2=C)
      const correctAnswer = ['A', 'B', 'C'][q.a];
      
      // Insert question
      await pool.query(`
        INSERT INTO exam_questions (
          question_number,
          question_text,
          image_url,
          option_a,
          option_b,
          option_c,
          correct_answer,
          is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      `, [
        i + 1,                    // question_number (1-based)
        q.q,                      // question_text (Arabic)
        q.img || null,            // image_url
        q.opts[0],                // option_a
        q.opts[1],                // option_b
        q.opts[2],                // option_c
        correctAnswer,            // correct_answer (A/B/C)
        true                      // is_active
      ]);
      
      imported++;
      
      if ((i + 1) % 20 === 0) {
        console.log(`   ✓ Imported ${i + 1}/${questions.length} questions...`);
      }
    }

    console.log(`✅ Successfully imported ${imported} questions!`);
    
    // Verify import
    const verifyResult = await pool.query(`
      SELECT COUNT(*) as total,
             COUNT(CASE WHEN image_url IS NOT NULL THEN 1 END) as with_images,
             COUNT(CASE WHEN correct_answer = 'A' THEN 1 END) as answer_a,
             COUNT(CASE WHEN correct_answer = 'B' THEN 1 END) as answer_b,
             COUNT(CASE WHEN correct_answer = 'C' THEN 1 END) as answer_c
      FROM exam_questions
    `);
    
    const stats = verifyResult.rows[0];
    console.log('\n📊 Import Statistics:');
    console.log(`   Total questions: ${stats.total}`);
    console.log(`   Questions with images: ${stats.with_images}`);
    console.log(`   Answer distribution: A=${stats.answer_a}, B=${stats.answer_b}, C=${stats.answer_c}`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Import failed:', error.message);
    console.error(error);
    process.exit(1);
  }
}

importQuestions();
