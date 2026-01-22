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

  // Generate access token (1 hour)
  const accessToken = jwt.sign(
    { id: user.id, role: user.role, type: 'access' },
    jwtConfig.secret,
    { expiresIn: jwtConfig.accessTokenExpiry }
  );

  // Generate refresh token (30 days)
  const refreshToken = jwt.sign(
    { id: user.id, role: user.role, type: 'refresh' },
    jwtConfig.secret,
    { expiresIn: jwtConfig.refreshTokenExpiry }
  );

  // Hash and store refresh token in database
  const hashedRefreshToken = await bcrypt.hash(refreshToken, 10);
  const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

  await pool.query(
    'UPDATE users SET refresh_token = $1, refresh_token_expires_at = $2 WHERE id = $3',
    [hashedRefreshToken, expiresAt, user.id]
  );

  console.log('✅ Tokens generated for user:', user.id);

  return {
    accessToken,
    refreshToken,
    user: {
      id: user.id,
      name: user.name,
      role: user.role,
    },
  };
}

console.log('✅ Functions defined: register =', typeof register, ', login =', typeof login);

/**
 * Refresh access token using refresh token
 */
async function refreshAccessToken(refreshToken) {
  try {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, jwtConfig.secret);
    
    if (decoded.type !== 'refresh') {
      throw new Error('Invalid token type');
    }

    // Get user and their stored refresh token
    const result = await pool.query(
      'SELECT id, role, refresh_token, refresh_token_expires_at FROM users WHERE id = $1',
      [decoded.id]
    );

    if (result.rowCount === 0) {
      throw new Error('User not found');
    }

    const user = result.rows[0];

    // Check if refresh token expired
    if (new Date() > new Date(user.refresh_token_expires_at)) {
      throw new Error('Refresh token expired');
    }

    // Verify refresh token matches stored hash
    const match = await bcrypt.compare(refreshToken, user.refresh_token);
    
    if (!match) {
      throw new Error('Invalid refresh token');
    }

    // Generate new access token
    const newAccessToken = jwt.sign(
      { id: user.id, role: user.role, type: 'access' },
      jwtConfig.secret,
      { expiresIn: jwtConfig.accessTokenExpiry }
    );

    // Generate new refresh token (token rotation)
    const newRefreshToken = jwt.sign(
      { id: user.id, role: user.role, type: 'refresh' },
      jwtConfig.secret,
      { expiresIn: jwtConfig.refreshTokenExpiry }
    );

    // Hash and update refresh token in database
    const hashedRefreshToken = await bcrypt.hash(newRefreshToken, 10);
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await pool.query(
      'UPDATE users SET refresh_token = $1, refresh_token_expires_at = $2 WHERE id = $3',
      [hashedRefreshToken, expiresAt, user.id]
    );

    console.log('✅ Tokens refreshed for user:', user.id);

    return {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken
    };
  } catch (error) {
    console.error('❌ Token refresh failed:', error.message);
    throw new Error('Invalid or expired refresh token');
  }
}

module.exports = {
  register,
  login,
  refreshAccessToken
};

console.log('✅ Module exported:', module.exports);
