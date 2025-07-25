const UserService = require('../services/user-service')   // 业务逻辑服务层
const { success, list } = require('../utils/response')    // 响应工具（统一接口返回格式）
const { AppError } = require('../middleware/error-handler') // 统一错误类
const Joi = require('joi')

/**
 * 用户控制器
 */
class UserController {
  /**
   * 获取当前用户信息
   */
  static async getCurrentUser(ctx) {
    const userId = ctx.state.user.id
    const user = await UserService.getUserById(userId)
    success(ctx, user, '获取用户信息成功')
  }

  /**
   * 根据ID获取用户公开信息
   */
  static async getUserProfile(ctx) {
    const { id } = ctx.params
    
    // 验证参数
    const { error } = Joi.object({
      id: Joi.number().integer().min(1).required()
    }).validate({ id: parseInt(id) })
    
    if (error) {
      throw new AppError('用户ID格式错误', 400, 'INVALID_USER_ID')
    }

    const user = await UserService.getUserProfile(id)
    success(ctx, user, '获取用户信息成功')
  }

  /**
   * 更新用户信息
   */
  static async updateUser(ctx) {
    const userId = ctx.state.user.id
    const updateData = ctx.request.body

    // 验证更新数据
    const schema = Joi.object({
      username: Joi.string().min(2).max(64).optional(),
      email: Joi.string().email().optional(),
      background: Joi.string().uri().optional()
    })

    const { error } = schema.validate(updateData)
    if (error) {
      throw new AppError(error.details[0].message, 400, 'INVALID_INPUT')
    }

    const user = await UserService.updateUser(userId, updateData)
    success(ctx, user, '更新用户信息成功')
  }

  /**
   * 修改密码
   */
  static async changePassword(ctx) {
    const userId = ctx.state.user.id
    // const { oldPassword, newPassword } = ctx.request.body
    const { newPassword } = ctx.request.body

    // 验证输入
    const schema = Joi.object({
      // oldPassword: Joi.string().required(),
      newPassword: Joi.string().min(6).max(50).required()
    })

    const oldPassword = ''

    const { error } = schema.validate({ newPassword })
    if (error) {
      throw new AppError(error.details[0].message, 400, 'INVALID_INPUT')
    }

    await UserService.changePassword(userId, oldPassword, newPassword)
    success(ctx, null, '密码修改成功')
  }

  /**
   * 上传头像
   */
  static async uploadAvatar(ctx) {
    const userId = ctx.state.user.id
    const file = ctx.file 

    if (!file) {
      throw new AppError('请选择要上传的头像图片', 400, 'NO_FILE_SELECTED')
    }

    // 生成头像访问URL
    const avatarUrl = `/avatars/${file.filename}`

    // 更新用户头像
    const user = await UserService.updateUser(userId, { avatar: avatarUrl })
    
    success(ctx, { 
      user,
      avatar: avatarUrl 
    }, '头像上传成功')
  }

  // /**
  //  * 获取用户设置
  //  */
  // static async getSettings(ctx) {
  //   const userId = ctx.state.user.id
  //   const user = await UserService.getUserById(userId)
    
  //   // 返回用户设置相关信息
  //   const settings = {
  //     username: user.username,
  //     email: user.email,
  //     avatar: user.avatar,
  //     background: user.background
  //   }
    
  //   success(ctx, settings, '获取用户设置成功')
  // }

  // /**
  //  * 更新用户设置
  //  */
  // static async updateSettings(ctx) {
  //   const userId = ctx.state.user.id
  //   const updateData = ctx.request.body

  //   // 验证设置数据
  //   const schema = Joi.object({
  //     username: Joi.string().min(2).max(64).optional(),
  //     email: Joi.string().email().optional(),
  //     avatar: Joi.string().uri().optional(),
  //     background: Joi.string().uri().optional()
  //   })

  //   const { error } = schema.validate(updateData)
  //   if (error) {
  //     throw new AppError(error.details[0].message, 400, 'INVALID_INPUT')
  //   }

  //   const user = await UserService.updateUser(userId, updateData)
  //   success(ctx, user, '更新设置成功')
  // }

  /**
   * 获取用户列表
   */
  static async getUserList(ctx) {
    const { page = 1, limit = 20, keyword = '', orderBy = 'created_at', order = 'DESC' } = ctx.query
    
    // 验证参数
    const schema = Joi.object({
      page: Joi.number().integer().min(1),
      limit: Joi.number().integer().min(1).max(100),
      keyword: Joi.string().optional(),
      orderBy: Joi.string().valid('created_at', 'username').optional(),
      order: Joi.string().valid('ASC', 'DESC').optional()
    })

    const { error } = schema.validate({ page: parseInt(page), limit: parseInt(limit), keyword, orderBy, order })
    if (error) {
      throw new AppError(error.details[0].message, 400, 'INVALID_INPUT')
    }

    const result = await UserService.getUserList({ page, limit, keyword, orderBy, order })
    list(ctx, result.list, result.page, result.limit, result.total, '获取用户列表成功')
  }

  /**
   * 喜欢歌曲
   */
  static async likeSong(ctx) {
    const userId = ctx.state.user.id
    const { songId } = ctx.request.body
    
    // 验证参数
    const { error } = Joi.object({
      songId: Joi.number().integer().min(1).required()
    }).validate({ songId: parseInt(songId) })
    
    if (error) {
      throw new AppError('歌曲ID格式错误', 400, 'INVALID_SONG_ID')
    }

    await UserService.addFavoriteSong(userId, songId)
    success(ctx, null, '添加到喜欢列表成功')
  }

  /**
   * 取消喜欢歌曲
   */
  static async unlikeSong(ctx) {
    const userId = ctx.state.user.id
    const { songId } = ctx.request.body
    
    // 验证参数
    const { error } = Joi.object({
      songId: Joi.number().integer().min(1).required()
    }).validate({ songId: parseInt(songId) })
    
    if (error) {
      throw new AppError('歌曲ID格式错误', 400, 'INVALID_SONG_ID')
    }

    await UserService.removeFavoriteSong(userId, songId)
    success(ctx, null, '从喜欢列表移除成功')
  }

  /**
   * 获取用户喜欢的歌曲
   */
  static async getFavoriteSongs(ctx) {
    const userId = ctx.state.user.id
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await UserService.getFavoriteSongs(userId, page, limit)
    list(ctx, result.list, result.page, result.limit, result.total, '获取喜欢的歌曲成功')
  }

  /**
   * 获取用户播放历史
   */
  static async getPlayHistory(ctx) {
    const userId = ctx.state.user.id
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await UserService.getPlayHistory(userId, page, limit)
    list(ctx, result.list, result.page, result.limit, result.total, '获取播放历史成功')
  }

  /**
   * 获取用户收藏的歌单
   */
  static async getCollectedPlaylists(ctx) {
    const userId = ctx.state.user.id
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await UserService.getCollectedPlaylists(userId, page, limit)
    list(ctx, result.list, result.page, result.limit, result.total, '获取收藏歌单成功')
  }

  /**
   * 关注用户
   */
  static async followUser(ctx) {
    const followerId = ctx.state.user.id
    const { userId } = ctx.request.body
    
    // 验证参数
    const { error } = Joi.object({
      userId: Joi.number().integer().min(1).required()
    }).validate({ userId: parseInt(userId) })
    
    if (error) {
      throw new AppError('用户ID格式错误', 400, 'INVALID_USER_ID')
    }

    await UserService.followUser(followerId, userId)
    success(ctx, null, '关注成功')
  }

  /**
   * 取消关注用户
   */
  static async unfollowUser(ctx) {
    const followerId = ctx.state.user.id
    const { userId } = ctx.request.body
    
    // 验证参数
    const { error } = Joi.object({
      userId: Joi.number().integer().min(1).required()
    }).validate({ userId: parseInt(userId) })
    
    if (error) {
      throw new AppError('用户ID格式错误', 400, 'INVALID_USER_ID')
    }

    await UserService.unfollowUser(followerId, userId)
    success(ctx, null, '取消关注成功')
  }

  /**
   * 获取用户的关注列表
   */
  static async getFollowing(ctx) {
    const userId = ctx.params.userId || ctx.state.user.id
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await UserService.getFollowing(userId, page, limit)
    list(ctx, result.list, result.page, result.limit, result.total, '获取关注列表成功')
  }

  /**
   * 获取用户的粉丝列表
   */
  static async getFollowers(ctx) {
    const userId = ctx.params.userId || ctx.state.user.id
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await UserService.getFollowers(userId, page, limit)
    list(ctx, result.list, result.page, result.limit, result.total, '获取粉丝列表成功')
  }
}

module.exports = UserController 