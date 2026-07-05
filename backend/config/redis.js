const redis = require('redis');
const dotenv = require('dotenv');
const { logger } = require('../utils/logger');

dotenv.config();

let client;

const initializeRedis = async () => {
  try {
    client = redis.createClient({
      host: process.env.REDIS_HOST || 'localhost',
      port: process.env.REDIS_PORT || 6379,
      password: process.env.REDIS_PASSWORD,
      db: process.env.REDIS_DB || 0,
    });

    client.on('error', (err) => {
      logger.error('Redis Client Error', { error: err });
    });

    client.on('connect', () => {
      logger.info('Redis connected successfully');
    });

    await client.connect();
    return client;
  } catch (error) {
    logger.error('Redis initialization failed', { error });
    throw error;
  }
};

module.exports = {
  client,
  initializeRedis,
};