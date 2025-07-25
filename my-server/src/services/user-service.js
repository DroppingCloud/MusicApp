const { User, UserFavorite, UserCollect, UserHistory, Follow, Like } = require('../models')
const { AppError } = require('../middleware/error-handler')
const { Op } = require('sequelize')
const config = require('../config')

/**
 * 用户业务逻辑服务
 */
class UserService {
  
  /**
   * 根据用户名查找用户
   */
  static async findByUsername(username) {
    return await User.findOne({ where: { username } })
  }

  /**
   * 根据邮箱查找用户
   */
  static async findByEmail(email) {
    return await User.findOne({ where: { email } })
  }

  /**
   * 根据登录字段查找用户
   */
  static async findByLoginField(loginField) {
    return await User.findOne({
      where: {
        [Op.or]: [
          { username: loginField },
          { email: loginField }
        ]
      }
    })
  }

  /**
   * 获取用户公开信息
   */
  static async getPublicProfile(user) {
    return {
      id: user.id,
      username: user.username,
      avatar: user.avatar,
      background: user.background,
      created_at: user.created_at
    }
  }

  // ==================== 核心业务方法 ====================
  /**
   * 根据ID获取用户信息
   */
  static async getUserById(id) {
    const user = await User.findByPk(id, {
      attributes: { exclude: ['password'] }
    })
    if (!user) {
      throw new AppError('用户不存在', 404, 'USER_NOT_FOUND')
    }
    return user
  }

  /**
   * 获取用户公开信息
   */
  static async getUserProfile(id) {
    const user = await User.findByPk(id)
    if (!user) {
      throw new AppError('用户不存在', 404, 'USER_NOT_FOUND')
    }
    return this.getPublicProfile(user)
  }

  /**
   * 创建新用户
   */
  static async createUser(userData) {
    const { username, password, email } = userData

    // 检查用户名是否已存在
    const existingUser = await this.findByUsername(username)
    if (existingUser) {
      throw new AppError('用户名已存在', 409, 'USERNAME_EXISTS')
    }

    // 检查邮箱是否已存在
    if (email) {
      const existingEmail = await this.findByEmail(email)
      if (existingEmail) {
        throw new AppError('邮箱已存在', 409, 'EMAIL_EXISTS')
      }
    }

    // 创建用户
    const user = await User.create(userData)
    
    // 返回用户信息
    return user.toJSON()
  }

  /**
   * 更新用户信息
   */
  static async updateUser(id, updateData) {
    const user = await User.findByPk(id)
    if (!user) {
      throw new AppError('用户不存在', 404, 'USER_NOT_FOUND')
    }

    // 如果要更新用户名，检查是否已存在
    if (updateData.username && updateData.username !== user.username) {
      const existingUser = await this.findByUsername(updateData.username)
      if (existingUser) {
        throw new AppError('用户名已存在', 409, 'USERNAME_EXISTS')
      }
    }

    // 如果要更新邮箱，检查是否已存在
    if (updateData.email && updateData.email !== user.email) {
      const existingEmail = await this.findByEmail(updateData.email)
      if (existingEmail) {
        throw new AppError('邮箱已存在', 409, 'EMAIL_EXISTS')
      }
    }

    // 更新用户信息
    await user.update(updateData)
    
    // 返回更新后的用户信息
    return user.toJSON()
  }

  /**
   * 删除用户
   */
  static async deleteUser(id) {
    const user = await User.findByPk(id)
    if (!user) {
      throw new AppError('用户不存在', 404, 'USER_NOT_FOUND')
    }

    await user.destroy()
    return true
  }

  /**
   * 获取用户列表
   */
  static async getUserList(options = {}) {
    const { page = 1, limit = 20, keyword = '', orderBy = 'created_at', order = 'DESC' } = options
    const offset = (page - 1) * limit
    
    const whereClause = keyword ? {
      [Op.or]: [
        { username: { [Op.like]: `%${keyword}%` } },
        { email: { [Op.like]: `%${keyword}%` } }
      ]
    } : {}

    const result = await User.findAndCountAll({
      where: whereClause,
      attributes: { exclude: ['password'] },
      order: [[orderBy, order]],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: result.rows,
      total: result.count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(result.count / limit)
    }
  }

  /**
   * 验证用户登录
   */
  static async validateUser(loginField, password) {
    // 支持用户名、邮箱登录
    const user = await this.findByLoginField(loginField)
    if (!user) {
      throw new AppError('用户名或密码错误', 401, 'INVALID_CREDENTIALS')
    }

    const isValidPassword = await user.comparePassword(password)
    if (!isValidPassword) {
      throw new AppError('用户名或密码错误', 401, 'INVALID_CREDENTIALS')
    }

    // 返回用户信息
    return user.toJSON()
  }

  /**
   * 修改密码
   */
  static async changePassword(id, oldPassword, newPassword) {
    const user = await User.findByPk(id)
    if (!user) {
      throw new AppError('用户不存在', 404, 'USER_NOT_FOUND')
    }

    // const isValidPassword = await user.comparePassword(oldPassword)
    // if (!isValidPassword) {
    //   throw new AppError('原密码错误', 400, 'INVALID_OLD_PASSWORD')
    // }

    await user.update({ password: newPassword })
    return true
  }

  /**
   * 重置密码
   */
  static async resetPassword(id, newPassword) {
    const user = await User.findByPk(id)
    if (!user) {
      throw new AppError('用户不存在', 404, 'USER_NOT_FOUND')
    }

    await user.update({ password: newPassword })
    return true
  }

  /**
   * 获取用户播放历史
   */
  static async getPlayHistory(userId, page = 1, limit = 20) {
    const offset = (page - 1) * limit
    
    const result = await UserHistory.findAndCountAll({
      where: { user_id: userId },
      order: [['play_time', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: result.rows,
      total: result.count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(result.count / limit)
    }
  }

  /**
   * 获取用户喜欢的歌曲
   */
  static async getFavoriteSongs(userId, page = 1, limit = 20) {
    const offset = (page - 1) * limit
    
    const result = await UserFavorite.findAndCountAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: result.rows,
      total: result.count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(result.count / limit)
    }
  }

  /**
   * 添加歌曲到喜欢列表
   */
  static async addFavoriteSong(userId, songId) {
    // 检查是否已经喜欢过
    const existing = await UserFavorite.findOne({
      where: { user_id: userId, song_id: songId }
    })
    
    if (existing) {
      throw new AppError('歌曲已在喜欢列表中', 409, 'SONG_ALREADY_LIKED')
    }

    await UserFavorite.create({
      user_id: userId,
      song_id: songId
    })
    
    return true
  }

  /**
   * 从喜欢列表移除歌曲
   */
  static async removeFavoriteSong(userId, songId) {
    const result = await UserFavorite.destroy({
      where: { user_id: userId, song_id: songId }
    })
    
    if (result === 0) {
      throw new AppError('歌曲不在喜欢列表中', 404, 'SONG_NOT_LIKED')
    }
    
    return true
  }

  /**
   * 获取用户收藏的歌单
   */
  static async getCollectedPlaylists(userId, page = 1, limit = 20) {
    const offset = (page - 1) * limit
    
    const result = await UserCollect.findAndCountAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: result.rows,
      total: result.count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(result.count / limit)
    }
  }

  /**
   * 关注用户
   */
  static async followUser(followerId, followedId) {
    if (followerId === parseInt(followedId)) {
      throw new AppError('不能关注自己', 400, 'CANNOT_FOLLOW_SELF')
    }
    
    // 检查被关注用户是否存在
    const followedUser = await User.findByPk(followedId)
    if (!followedUser) {
      throw new AppError('用户不存在', 404, 'USER_NOT_FOUND')
    }
    
    // 检查是否已经关注
    const existing = await Follow.findOne({
      where: { follower_id: followerId, followed_id: followedId }
    })
    
    if (existing) {
      throw new AppError('已经关注该用户', 409, 'ALREADY_FOLLOWING')
    }
    
    await Follow.create({
      follower_id: followerId,
      followed_id: followedId
    })
    
    return true
  }

  /**
   * 取消关注用户
   */
  static async unfollowUser(followerId, followedId) {
    const result = await Follow.destroy({
      where: { follower_id: followerId, followed_id: followedId }
    })
    
    if (result === 0) {
      throw new AppError('未关注该用户', 404, 'NOT_FOLLOWING')
    }
    
    return true
  }

  /**
   * 获取用户关注列表
   */
  static async getFollowing(userId, page = 1, limit = 20) {
    const offset = (page - 1) * limit
    
    const result = await Follow.findAndCountAll({
      where: { follower_id: userId },
      include: [
        {
          model: User,
          as: 'followed',
          attributes: ['id', 'username', 'avatar']
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: result.rows,
      total: result.count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(result.count / limit)
    }
  }

  /**
   * 获取用户粉丝列表
   */
  static async getFollowers(userId, page = 1, limit = 20) {
    const offset = (page - 1) * limit
    
    const result = await Follow.findAndCountAll({
      where: { followed_id: userId },
      include: [
        {
          model: User,
          as: 'follower',
          attributes: ['id', 'username', 'avatar']
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: result.rows,
      total: result.count,
      page: parseInt(page),
      limit: parseInt(limit),
      pages: Math.ceil(result.count / limit)
    }
  }
}

module.exports = UserService 