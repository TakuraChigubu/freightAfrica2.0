const { Pool } = require('pg');
const dotenv = require('dotenv');
const { logger } = require('../utils/logger');

dotenv.config();

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'freightlink_dev',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
  max: process.env.DB_POOL_SIZE || 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
  logger.error('Unexpected error on idle client', { error: err });
  process.exit(-1);
});

pool.on('connect', () => {
  logger.debug('New database connection established');
});

const initializeDatabase = async () => {
  try {
    const result = await pool.query('SELECT NOW()');
    logger.info('Database connection successful', {
      timestamp: result.rows[0].now,
    });
    return true;
  } catch (error) {
    logger.error('Database connection failed', { error });
    throw error;
  }
};

const query = async (text, params) => {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    
    if (duration > 1000) {
      logger.warn('Slow query detected', {
        duration,
        query: text.substring(0, 100),
      });
    }

    return result;
  } catch (error) {
    logger.error('Database query error', {
      error,
      query: text.substring(0, 100),
      params,
    });
    throw error;
  }
};

module.exports = {
  pool,
  query,
  initializeDatabase,
};