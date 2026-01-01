const { Pool } = require('pg');

// Support both individual connection params and DATABASE_URL
const pool = new Pool(
  process.env.DATABASE_URL
    ? {
        connectionString: process.env.DATABASE_URL,
        ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
      }
    : {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        database: process.env.DB_NAME,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
      }
);

pool.on('connect', () => {
  console.log('🟢 Connected to PostgreSQL');
});

pool.on('error', (err) => {
  console.error('🔴 PostgreSQL error:', err);
  process.exit(1);
});

module.exports = pool;
