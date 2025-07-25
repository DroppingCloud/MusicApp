const { Like, Comment, Chat, Message, User, Song, Note, SongStat, Playlist } = require('../models')
const { Op } = require('sequelize')
const { sequelize } = require('../config/sequelize')
const { AppError } = require('../middleware/error-handler')

/**
 * 社交业务逻辑服务
 */
class SocialService {
  /**
   * 点赞功能
   */
  static async addLike(userId, type, targetId) {
    // 验证type的有效性
    const validTypes = ['note', 'comment']
    if (!validTypes.includes(type)) {
      throw new AppError('无效的点赞类型', 400)
    }

    // 检查目标对象是否存在
    if (type === 'note') {
      const note = await Note.findByPk(targetId)
      if (!note) {
        throw new AppError('笔记不存在', 404)
      }
    } else if (type === 'comment') {
      const comment = await Comment.findByPk(targetId)
      if (!comment) {
        throw new AppError('评论不存在', 404)
      }
    }

    // 检查是否已经点赞
    const existingLike = await Like.findOne({
      where: {
        user_id: userId,
        type,
        target_id: targetId
      }
    })

    if (existingLike) {
      throw new AppError('已经点赞过了', 400)
    }

    // 开启事务
    const transaction = await sequelize.transaction()

    try {
      // 创建点赞记录
      await Like.create({
        user_id: userId,
        type,
        target_id: targetId
      }, { transaction })

      await transaction.commit()
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 取消点赞
   */
  static async removeLike(userId, type, targetId) {
    const validTypes = ['note', 'comment']
    if (!validTypes.includes(type)) {
      throw new AppError('无效的点赞类型', 400)
    }

    // 检查目标对象是否存在
    if (type === 'note') {
      const note = await Note.findByPk(targetId)
      if (!note) {
        throw new AppError('笔记不存在', 404)
      }
    } else if (type === 'comment') {
      const comment = await Comment.findByPk(targetId)
      if (!comment) {
        throw new AppError('评论不存在', 404)
      }
    }

    // 查找点赞记录
    const like = await Like.findOne({
      where: {
        user_id: userId,
        type,
        target_id: targetId
      }
    })

    if (!like) {
      throw new AppError('未点赞过', 400)
    }

    // 开启事务
    const transaction = await sequelize.transaction()

    try {
      // 删除点赞记录
      await like.destroy({ transaction })

      await transaction.commit()
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 获取用户点赞列表
   */
  static async getUserLikes(userId, type, page, limit) {
    const offset = (page - 1) * limit
    const where = { user_id: userId }
    
    if (type) {
      where.type = type
    }

    const result = await Like.findAndCountAll({
      where,
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: result.rows,
      total: result.count
    }
  }

  /**
   * 获取评论列表
   */
  static async getCommentList(type, targetId, page, limit) {
    const validTypes = ['song', 'note', 'playlist']
    if (!validTypes.includes(type)) {
      throw new AppError('无效的评论类型', 400)
    }

    // 检查目标对象是否存在
    if (type === 'song') {
      const song = await Song.findByPk(targetId)
      if (!song) {
        throw new AppError('歌曲不存在', 404)
      }
    } else if (type === 'note') {
      const note = await Note.findByPk(targetId)
      if (!note) {
        throw new AppError('笔记不存在', 404)
      }
    } else if (type === 'playlist') {
      const playlist = await Playlist.findByPk(targetId)
      if (!playlist) {
        throw new AppError('歌单不存在', 404)
      }
    }

    const offset = (page - 1) * limit

    const result = await Comment.findAndCountAll({
      where: {
        type,
        target_id: targetId,
        parent_id: null // 只获取顶级评论
      },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'avatar']
        },
        {
          model: Comment,
          as: 'replies',
          include: [
            {
              model: User,
              as: 'user',
              attributes: ['id', 'username', 'avatar']
            }
          ],
          limit: 3, // 每个评论最多显示3条回复
          order: [['created_at', 'ASC']]
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: result.rows,
      total: result.count
    }
  }

  /**
   * 添加评论
   */
  static async addComment(userId, type, targetId, content, parentId = null) {
    const validTypes = ['song', 'note', 'playlist']
    if (!validTypes.includes(type)) {
      throw new AppError('无效的评论类型', 400)
    }

    if (!content || content.trim().length === 0) {
      throw new AppError('评论内容不能为空', 400)
    }

    // 检查目标对象是否存在
    if (type === 'song') {
      const song = await Song.findByPk(targetId)
      if (!song) {
        throw new AppError('歌曲不存在', 404)
      }
    } else if (type === 'note') {
      const note = await Note.findByPk(targetId)
      if (!note) {
        throw new AppError('笔记不存在', 404)
      }
    } else if (type === 'playlist') {
      const playlist = await Playlist.findByPk(targetId)
      if (!playlist) {
        throw new AppError('歌单不存在', 404)
      }
    }

    // 如果是回复评论，检查父评论是否存在
    if (parentId) {
      const parentComment = await Comment.findByPk(parentId)
      if (!parentComment) {
        throw new AppError('父评论不存在', 404)
      }
      // 确保父评论和当前评论是同一个目标对象
      if (parentComment.type !== type || parentComment.target_id != targetId) {
        throw new AppError('回复评论的目标不匹配', 400)
      }
    }

    // 开启事务
    const transaction = await sequelize.transaction()

    try {
      // 创建评论
      const comment = await Comment.create({
        user_id: userId,
        type,
        target_id: targetId,
        content: content.trim(),
        parent_id: parentId
      }, { transaction })

      // 如果是歌曲评论，更新歌曲统计
      if (type === 'song' && !parentId) { // 只有顶级评论才更新统计
        const [songStat] = await SongStat.findOrCreate({
          where: { song_id: targetId },
          defaults: { 
            song_id: targetId, 
            play_count: 0, 
            like_count: 0, 
            comment_count: 0 
          },
          transaction
        })
        
        await songStat.increment('comment_count', { transaction })
      }

      await transaction.commit()

      // 返回评论详情（包含用户信息）
      const commentWithUser = await Comment.findByPk(comment.id, {
        include: [
          {
            model: User,
            as: 'user',
            attributes: ['id', 'username', 'avatar']
          }
        ]
      })

      return commentWithUser
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 删除评论
   */
  static async deleteComment(commentId, userId) {
    const comment = await Comment.findByPk(commentId)
    
    if (!comment) {
      throw new AppError('评论不存在', 404)
    }

    // 检查权限（只能删除自己的评论）
    if (comment.user_id !== userId) {
      throw new AppError('无权限删除此评论', 403)
    }

    // 开启事务
    const transaction = await sequelize.transaction()

    try {
      // 删除所有回复
      await Comment.destroy({
        where: { parent_id: commentId },
        transaction
      })

      // 删除评论本身
      await comment.destroy({ transaction })

      // 如果是歌曲评论，更新统计
      if (comment.type === 'song' && !comment.parent_id) {
        const songStat = await SongStat.findOne({
          where: { song_id: comment.target_id },
          transaction
        })
        
        if (songStat && songStat.comment_count > 0) {
          await songStat.decrement('comment_count', { transaction })
        }
      }

      await transaction.commit()
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 获取聊天会话列表
   */
  static async getChatList(userId, page, limit) {
    const offset = (page - 1) * limit

    const result = await Chat.findAndCountAll({
      where: {
        [Op.or]: [
          { user1_id: userId },
          { user2_id: userId }
        ]
      },
      include: [
        {
          model: User,
          as: 'user1',
          attributes: ['id', 'username', 'avatar']
        },
        {
          model: User,
          as: 'user2',
          attributes: ['id', 'username', 'avatar']
        }
      ],
      order: [['last_time', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    // 处理返回数据，确定对话对象
    const list = result.rows.map(chat => {
      const isUser1 = chat.user1_id === userId
      const otherUser = isUser1 ? chat.user2 : chat.user1
      
      return {
        id: chat.id,
        other_user: otherUser,
        last_msg: chat.last_msg,
        last_time: chat.last_time
      }
    })

    return {
      list,
      total: result.count
    }
  }

  /**
   * 获取聊天消息
   */
  static async getChatMessages(userId1, userId2, page, limit) {
    const offset = (page - 1) * limit

    // 查找或创建聊天会话
    let chat = await Chat.findOne({
      where: {
        [Op.or]: [
          { user1_id: userId1, user2_id: userId2 },
          { user1_id: userId2, user2_id: userId1 }
        ]
      }
    })

    if (!chat) {
      // 创建新的聊天会话
      chat = await Chat.create({
        user1_id: userId1,
        user2_id: userId2
      })
    }

    // 获取消息列表
    const result = await Message.findAndCountAll({
      where: {
        chat_id: chat.id
      },
      include: [
        {
          model: User,
          as: 'sender',
          attributes: ['id', 'username', 'avatar']
        }
      ],
      order: [['send_time', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    return {
      list: result.rows.reverse(), // 消息按时间正序显示
      total: result.count,
      chat_id: chat.id
    }
  }

  /**
   * 发送消息
   */
  static async sendMessage(senderId, receiverId, content) {
    if (!content || content.trim().length === 0) {
      throw new AppError('消息内容不能为空', 400)
    }

    if (senderId === receiverId) {
      throw new AppError('不能给自己发消息', 400)
    }

    // 检查接收者是否存在
    const receiver = await User.findByPk(receiverId)
    if (!receiver) {
      throw new AppError('接收者不存在', 404)
    }

    // 查找或创建聊天会话
    let chat = await Chat.findOne({
      where: {
        [Op.or]: [
          { user1_id: senderId, user2_id: receiverId },
          { user1_id: receiverId, user2_id: senderId }
        ]
      }
    })

    if (!chat) {
      chat = await Chat.create({
        user1_id: senderId,
        user2_id: receiverId
      })
    }

    // 开启事务
    const transaction = await sequelize.transaction()

    try {
      // 创建消息
      const message = await Message.create({
        chat_id: chat.id,
        sender_id: senderId,
        content: content.trim()
      }, { transaction })

      // 更新聊天会话的最后消息信息
      await chat.update({
        last_msg: content.length > 50 ? content.substring(0, 50) + '...' : content,
        last_time: new Date()
      }, { transaction })

      await transaction.commit()

      // 返回消息详情
      const messageWithSender = await Message.findByPk(message.id, {
        include: [
          {
            model: User,
            as: 'sender',
            attributes: ['id', 'username', 'avatar']
          }
        ]
      })

      return messageWithSender
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 获取对象点赞统计
   */
  static async getLikeStats(type, targetIds) {
    const likes = await Like.findAll({
      where: {
        type,
        target_id: {
          [Op.in]: targetIds
        }
      },
      attributes: [
        'target_id',
        [sequelize.fn('COUNT', sequelize.col('id')), 'like_count']
      ],
      group: ['target_id']
    })

    const stats = {}
    likes.forEach(like => {
      stats[like.target_id] = parseInt(like.dataValues.like_count)
    })

    // 确保所有targetIds都有统计数据
    targetIds.forEach(id => {
      if (!stats[id]) {
        stats[id] = 0
      }
    })

    return stats
  }

  /**
   * 批量检查点赞状态
   */
  static async batchCheckLiked(userId, type, targetIds) {
    const likes = await Like.findAll({
      where: {
        user_id: userId,
        type,
        target_id: {
          [Op.in]: targetIds
        }
      },
      attributes: ['target_id']
    })

    const likedSet = new Set(likes.map(like => like.target_id))
    
    return targetIds.reduce((result, targetId) => {
      result[targetId] = likedSet.has(targetId)
      return result
    }, {})
  }
}

module.exports = SocialService 