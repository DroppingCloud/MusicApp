const jwt = require('jsonwebtoken')
const config = require('../config')
const { AppError } = require('./error-handler')

/**
 * JWT认证中间件
 */
const auth = async (ctx, next) => {
  try {
    const authHeader = ctx.get('Authorization')
    
    if (!authHeader) {
      throw new AppError('缺少访问令牌', 401, 'MISSING_TOKEN')
    }

    const token = authHeader.startsWith('Bearer ') 
      ? authHeader.slice(7) 
      : authHeader

    if (!token) {
      throw new AppError('无效的令牌格式', 401, 'INVALID_TOKEN_FORMAT')
    }

    // 验证JWT令牌
    const decoded = jwt.verify(token, config.jwt.secret)
    
    // 将用户信息添加到上下文
    ctx.state.user = {
      id: decoded.id,
      username: decoded.username,
      email: decoded.email
    }

    await next()
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      throw new AppError('无效的访问令牌', 401, 'INVALID_TOKEN')
    } else if (error instanceof jwt.TokenExpiredError) {
      throw new AppError('访问令牌已过期', 401, 'TOKEN_EXPIRED')
    } else {
      throw error
    }
  }
}

/**
 * 可选认证中间件（不强制要求登录）
 */
const optionalAuth = async (ctx, next) => {
  try {
    const authHeader = ctx.get('Authorization')
    
    if (authHeader) {
      const token = authHeader.startsWith('Bearer ') 
        ? authHeader.slice(7) 
        : authHeader

      if (token) {
        try {
          const decoded = jwt.verify(token, config.jwt.secret)
          ctx.state.user = {
            id: decoded.id,
            username: decoded.username,
            email: decoded.email
          }
        } catch (error) {
          // 忽略token验证失败，继续执行
        }
      }
    }

    await next()
  } catch (error) {
    throw error
  }
}

/**
 * 生成JWT令牌
 */
const generateToken = (payload) => {
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn
  })
}

/**
 * 生成刷新令牌
 */
const generateRefreshToken = (payload) => {
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.refreshExpiresIn
  })
}

module.exports = {
  auth,
  optionalAuth,
  generateToken,
  generateRefreshToken
} 