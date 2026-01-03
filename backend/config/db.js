const { Pool } = require('pg');

// Support both individual connection params and DATABASE_URL
const pool = new Pool(
  process.env.DATABASE_URL
    ? {
        connectionString: process.env.DATABASE_URL,
        ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
        connectionTimeoutMillis: 10000,
        idleTimeoutMillis: 30000,
        max: 20
      }
    : {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        database: process.env.DB_NAME,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
      }
);

// Set UTF-8 encoding on every connection
pool.on('connect', (client) => {
  client.query('SET CLIENT_ENCODING TO UTF8');
  console.log('🟢 Connected to PostgreSQL with UTF-8 encoding');
});

pool.on('error', (err) => {
  console.error('🔴 PostgreSQL error:', err);
  // Don't exit process on connection errors - let it retry
});

module.exports = pool;
