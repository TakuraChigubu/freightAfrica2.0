const { logger } = require('./logger');

class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    Error.captureStackTrace(this, this.constructor);
  }
}

const errorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.message = err.message || 'Internal Server Error';

  if (err.name === 'CastError') {
    const message = `Resource not found. Invalid: ${err.path}`;
    err = new AppError(message, 400);
  }

  if (err.name === 'JsonWebTokenError') {
    const message = `JSON Web Token is invalid, try again`;
    err = new AppError(message, 400);
  }

  if (err.name === 'TokenExpiredError') {
    const message = `JSON Web Token is expired, try again`;
    err = new AppError(message, 400);
  }

  if (err.code === '23505') {
    const field = err.detail?.match(/Key \((.+?)\)/)?.[1] || 'field';
    const message = `${field} already exists`;
    err = new AppError(message, 409);
  }

  logger.error(`${err.statusCode} - ${err.message}`, {
    error: err,
    path: req.path,
    method: req.method,
  });

  res.status(err.statusCode).json({
    success: false,
    error: {
      message: err.message,
      statusCode: err.statusCode,
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    },
  });
};

module.exports = {
  AppError,
  errorHandler,
};