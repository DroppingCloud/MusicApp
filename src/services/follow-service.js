const { Follow, User } = require('../models')
const { Op } = require('sequelize')
const { AppError } = require('../middleware/error-handler')

/**
 * 关注业务逻辑服务
 */
class FollowService {
  /**
   * 关注用户
   */
  static async followUser(followerId, followedId) {
    if (followerId === followedId) {
      throw new AppError('不能关注自己', 400)
    }

    // 检查被关注用户是否存在
    const targetUser = await User.findByPk(followedId)
    if (!targetUser) {
      throw new AppError('用户不存在', 404)
    }

    // 检查是否已经关注
    const existingFollow = await Follow.findOne({
      where: {
        follower_id: followerId,
        followed_id: followedId
      }
    })

    if (existingFollow) {
      throw new AppError('已经关注过该用户', 400)
    }

    // 创建关注关系
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
    if (followerId === followedId) {
      throw new AppError('不能取消关注自己', 400)
    }

    // 查找关注关系
    const follow = await Follow.findOne({
      where: {
        follower_id: followerId,
        followed_id: followedId
      }
    })

    if (!follow) {
      throw new AppError('未关注该用户', 400)
    }

    // 删除关注关系
    await follow.destroy()

    return true
  }

  /**
   * 获取用户关注列表
   */
  static async getFollowingList(userId, page, limit) {
    const offset = (page - 1) * limit

    const result = await Follow.findAndCountAll({
      where: {
        follower_id: userId
      },
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
      list: result.rows.map(follow => ({
        id: follow.id,
        followed_id: follow.followed_id,
        created_at: follow.created_at,
        user: follow.followed
      })),
      total: result.count
    }
  }

  /**
   * 获取用户粉丝列表
   */
  static async getFollowersList(userId, page, limit) {
    const offset = (page - 1) * limit

    const result = await Follow.findAndCountAll({
      where: {
        followed_id: userId
      },
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
      list: result.rows.map(follow => ({
        id: follow.id,
        follower_id: follow.follower_id,
        created_at: follow.created_at,
        user: follow.follower
      })),
      total: result.count
    }
  }

  /**
   * 检查是否关注了某用户
   */
  static async isFollowing(followerId, followedId) {
    const follow = await Follow.findOne({
      where: {
        follower_id: followerId,
        followed_id: followedId
      }
    })

    return !!follow
  }

  /**
   * 获取用户关注统计
   */
  static async getUserFollowStats(userId) {
    const [followingCount, followersCount] = await Promise.all([
      Follow.count({
        where: {
          follower_id: userId
        }
      }),
      Follow.count({
        where: {
          followed_id: userId
        }
      })
    ])

    return {
      following_count: followingCount,
      followers_count: followersCount
    }
  }

  /**
   * 批量检查关注状态
   */
  static async batchCheckFollowing(followerId, userIds) {
    const follows = await Follow.findAll({
      where: {
        follower_id: followerId,
        followed_id: {
          [Op.in]: userIds
        }
      },
      attributes: ['followed_id']
    })

    const followingSet = new Set(follows.map(f => f.followed_id))
    
    return userIds.reduce((result, userId) => {
      result[userId] = followingSet.has(userId)
      return result
    }, {})
  }

  /**
   * 获取互相关注的好友列表
   */
  static async getMutualFriends(userId, page, limit) {
    const offset = (page - 1) * limit

    // 查找我关注的人，并且他们也关注了我
    const mutualFollows = await Follow.findAndCountAll({
      where: {
        follower_id: userId
      },
      include: [
        {
          model: User,
          as: 'followed',
          attributes: ['id', 'username', 'avatar'],
          include: [
            {
              model: Follow,
              as: 'following',
              where: {
                followed_id: userId
              },
              required: true,
              attributes: []
            }
          ]
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: mutualFollows.rows.map(follow => ({
        id: follow.id,
        user_id: follow.followed_id,
        created_at: follow.created_at,
        user: follow.followed
      })),
      total: mutualFollows.count
    }
  }
}

module.exports = FollowService 