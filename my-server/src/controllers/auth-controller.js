const UserService = require('../services/user-service')
const { generateToken, generateRefreshToken } = require('../middleware/auth')
const { success } = require('../utils/response')
const { AppError } = require('../middleware/error-handler')
const Joi = require('joi')

/**
 * 认证控制器
 */
class AuthController {
  /**
   * 用户注册
   */
  static async register(ctx) {
    // 获取表单数据和上传的文件
    const formData = ctx.request.body
    const avatarFile = ctx.file // 上传的头像文件（可选）
    
    // 参数验证
    const schema = Joi.object({
      username: Joi.string().min(3).max(50).required().messages({
        'string.min': '用户名至少3个字符',
        'string.max': '用户名最多50个字符',
        'any.required': '用户名不能为空'
      }),
      password: Joi.string().min(6).max(20).required().messages({
        'string.min': '密码至少6个字符',
        'string.max': '密码最多20个字符',
        'any.required': '密码不能为空'
      }),
      email: Joi.string().email().allow('').messages({
        'string.email': '邮箱格式不正确'
      }),
      background: Joi.string().uri().allow('').messages({
        'string.uri': '背景图片链接格式不正确'
      })
    })

    const { error, value } = schema.validate(formData)
    if (error) {
      throw new AppError(error.details[0].message, 422, 'VALIDATION_ERROR')
    }

    // 处理头像文件
    if (avatarFile) {
      value.avatar = `/avatars/${avatarFile.filename}`
    }

    // 创建用户
    const user = await UserService.createUser(value)

    // 生成令牌
    const tokenPayload = {
      id: user.id,
      username: user.username,
      email: user.email
    }
    
    const token = generateToken(tokenPayload)
    const refreshToken = generateRefreshToken(tokenPayload)

    success(ctx, {
      user,
      token,
      refreshToken
    }, '注册成功', 201)
  }

  /**
   * 用户登录
   */
  static async login(ctx) {
    // 参数验证 - 支持用户名或邮箱登录
    const schema = Joi.object({
      loginField: Joi.string().required().messages({
        'any.required': '用户名或邮箱不能为空'
      }),
      password: Joi.string().required().messages({
        'any.required': '密码不能为空'
      })
    })

    const { error, value } = schema.validate(ctx.request.body)
    if (error) {
      throw new AppError(error.details[0].message, 422, 'VALIDATION_ERROR')
    }

    // 验证用户 - 支持用户名或邮箱登录
    const user = await UserService.validateUser(value.loginField, value.password)

    // 生成令牌
    const tokenPayload = {
      id: user.id,
      username: user.username,
      email: user.email
    }
    
    const token = generateToken(tokenPayload)
    const refreshToken = generateRefreshToken(tokenPayload)

    success(ctx, {
      user,
      token,
      refreshToken
    }, '登录成功')
  }

  /**
   * 刷新令牌
   */
  static async refreshToken(ctx) {
    const schema = Joi.object({
      refreshToken: Joi.string().required().messages({
        'any.required': '刷新令牌不能为空'
      })
    })

    const { error, value } = schema.validate(ctx.request.body)
    if (error) {
      throw new AppError(error.details[0].message, 422, 'VALIDATION_ERROR')
    }

    try {
      const jwt = require('jsonwebtoken')
      const config = require('../config')
      
      // 验证刷新令牌
      const decoded = jwt.verify(value.refreshToken, config.jwt.secret)
      
      // 检查用户是否存在
      const user = await UserService.getUserById(decoded.id)
      if (!user) {
        throw new AppError('用户不存在', 404, 'USER_NOT_FOUND')
      }

      // 生成新的令牌
      const tokenPayload = {
        id: user.id,
        username: user.username,
        email: user.email
      }
      
      const newToken = generateToken(tokenPayload)
      const newRefreshToken = generateRefreshToken(tokenPayload)

      success(ctx, {
        token: newToken,
        refreshToken: newRefreshToken
      }, '令牌刷新成功')
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new AppError('刷新令牌已过期，请重新登录', 401, 'REFRESH_TOKEN_EXPIRED')
      } else if (error.name === 'JsonWebTokenError') {
        throw new AppError('无效的刷新令牌', 401, 'INVALID_REFRESH_TOKEN')
      } else {
        throw error
      }
    }
  }

  /**
   * 退出登录
   */
  static async logout(ctx) {
    // 在实际应用中，可以将token加入黑名单
    // 这里简单返回成功消息
    success(ctx, null, '退出登录成功')
  }

  /**
   * 获取当前登录用户信息
   */
  static async me(ctx) {
    const userId = ctx.state.user.id
    const user = await UserService.getUserById(userId)
    
    if (!user) {
      throw new AppError('用户不存在', 404, 'USER_NOT_FOUND')
    }

    success(ctx, user, '获取用户信息成功')
  }
}

module.exports = AuthController 