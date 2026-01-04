console.log('🔧 Loading auth.service.js...');

try {
  var bcrypt = require('bcrypt');
  console.log('✅ bcrypt loaded');
} catch (e) {
  console.error('❌ Error loading bcrypt:', e.message);
}

try {
  var jwt = require('jsonwebtoken');
  console.log('✅ jwt loaded');
} catch (e) {
  console.error('❌ Error loading jwt:', e.message);
}

try {
  var pool = require('../config/db');
  console.log('✅ pool loaded');
} catch (e) {
  console.error('❌ Error loading pool:', e.message);
}

try {
  var jwtConfig = require('../config/jwt');
  console.log('✅ jwtConfig loaded');
} catch (e) {
  console.error('❌ Error loading jwtConfig:', e.message);
}

console.log('✅ All dependencies loaded');

async function register({ name, identifier, password }) {
  // check if user exists
  const existing = await pool.query(
    'SELECT id FROM users WHERE identifier = $1',
    [identifier]
  );

  if (existing.rowCount > 0) {  
    throw new Error('User already exists');
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const userResult = await pool.query(
    `INSERT INTO users (name, identifier, password_hash, role)
     VALUES ($1, $2, $3, 'student')
     RETURNING id, name, role`,
    [name, identifier, passwordHash]
  );

  const user = userResult.rows[0];

  // Create student profile - inactive until school activates or permit chosen
  await pool.query(
    `INSERT INTO students (
      user_id, 
      student_type,
      onboarding_complete,
      is_active,
      access_level
    ) VALUES ($1, 'independent', false, false, 'none')`,
    [user.id]
  );

  return user;
}

async function login({ identifier, password }) {
  console.log('🔍 Login attempt:', { identifier, passwordLength: password?.length });
  
  const result = await pool.query(
    'SELECT * FROM users WHERE identifier = $1',
    [identifier]
  );

  console.log('📊 Users found:', result.rowCount);
  
  if (result.rowCount === 0) {
    console.log('❌ No user found with identifier:', identifier);
    throw new Error('Invalid credentials');
  }

  const user = result.rows[0];

  console.log('👤 User found:', { id: user.id, identifier: user.identifier, role: user.role });
  console.log('🔐 Testing password...');
  
  const match = await bcrypt.compare(password, user.password_hash);
  
  console.log('✅ Password match:', match);
  
  if (!match) {
    console.log('❌ Password does not match for user:', identifier);
    throw new Error('Invalid credentials');
  }

  const token = jwt.sign(
    { id: user.id, role: user.role },
    jwtConfig.secret,
    { expiresIn: jwtConfig.expiresIn }
  );

  return {
    token,
    user: {
      id: user.id,
      name: user.name,
      role: user.role,
    },
  };
}

console.log('✅ Functions defined: register =', typeof register, ', login =', typeof login);

module.exports = {
  register,
  login
};

console.log('✅ Module exported:', module.exports);
