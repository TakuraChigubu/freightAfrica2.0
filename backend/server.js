const app = require('./app');
const { logger } = require('./utils/logger');
const { initializeDatabase } = require('./config/database');
const { initializeRedis } = require('./config/redis');

const PORT = process.env.PORT || 5000;

let server;

const gracefulShutdown = async () => {
  logger.info('Graceful shutdown initiated...');

  if (server) {
    server.close(() => {
      logger.info('Server closed');
    });
  }

  const db = require('./config/database');
  if (db.pool) {
    await db.pool.end();
    logger.info('Database connections closed');
  }

  const redis = require('./config/redis');
  if (redis.client) {
    await redis.client.quit();
    logger.info('Redis connection closed');
  }

  process.exit(0);
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

const startServer = async () => {
  try {
    logger.info('Initializing database...');
    await initializeDatabase();
    logger.info('Database initialized successfully');

    logger.info('Initializing Redis...');
    await initializeRedis();
    logger.info('Redis initialized successfully');

    server = app.listen(PORT, () => {
      logger.info(`Server running on port ${PORT}`, {
        environment: process.env.NODE_ENV || 'development',
      });
    });
  } catch (error) {
    logger.error('Failed to start server', { error });
    process.exit(1);
  }
};

startServer();

module.exports = server;