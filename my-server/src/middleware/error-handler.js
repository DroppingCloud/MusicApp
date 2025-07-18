const { logger } = require('../utils/logger')
const { error } = require('../utils/response')

/**
 * 自定义错误类
 */
class AppError extends Error {
  constructor(message, statusCode = 500, errorCode = null) {
    super(message)
    this.statusCode = statusCode
    this.errorCode = errorCode
    this.isOperational = true
    Error.captureStackTrace(this, this.constructor)
  }
}

/**
 * 全局错误处理中间件
 */
const errorHandler = async (ctx, next) => {
  try {
    await next()
  } catch (err) {
    logger.error('请求处理错误:', {
      error: err.message,
      stack: err.stack,
      url: ctx.url,
      method: ctx.method,
      ip: ctx.ip,
      userAgent: ctx.get('User-Agent')
    })

    // 处理不同类型的错误
    if (err instanceof AppError) {
      // 业务逻辑错误
      error(ctx, err.message, err.statusCode, err.errorCode)
    } else if (err.name === 'ValidationError') {
      // Joi验证错误
      const errors = err.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }))
      error(ctx, '参数验证失败', 422, 'VALIDATION_ERROR', errors)
    } else if (err.code === 'ER_DUP_ENTRY') {
      // MySQL重复键错误
      error(ctx, '数据已存在', 409, 'DUPLICATE_ENTRY')
    } else if (err.code === 'ER_NO_REFERENCED_ROW_2') {
      // MySQL外键约束错误
      error(ctx, '关联数据不存在', 400, 'FOREIGN_KEY_ERROR')
    } else if (err.name === 'JsonWebTokenError') {
      // JWT错误
      error(ctx, '无效的访问令牌', 401, 'INVALID_TOKEN')
    } else if (err.name === 'TokenExpiredError') {
      // JWT过期错误
      error(ctx, '访问令牌已过期', 401, 'TOKEN_EXPIRED')
    } else if (err.status === 413) {
      // 文件过大错误
      error(ctx, '上传文件过大', 413, 'FILE_TOO_LARGE')
    } else if (err.code === 'LIMIT_FILE_SIZE') {
      // multer 文件过大错误
      error(ctx, '上传文件过大', 413, 'FILE_TOO_LARGE')
    } else if (err.code === 'LIMIT_UNEXPECTED_FILE') {
      // multer 意外文件错误
      error(ctx, '上传文件字段名不正确', 400, 'UNEXPECTED_FILE')
    } else if (err.message === 'Unexpected field') {
      // multer 字段名错误
      error(ctx, '上传文件字段名不正确，请使用正确的字段名', 400, 'UNEXPECTED_FIELD')
    } else {
      // 未知错误
      error(ctx, 
        process.env.NODE_ENV === 'production' ? '服务器内部错误' : err.message, 
        500, 
        'INTERNAL_ERROR'
      )
    }
  }
}

module.exports = errorHandler
module.exports.AppError = AppError 