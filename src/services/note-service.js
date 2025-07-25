const { Note, NoteImage, User, Song, Artist, Album, Comment, Like } = require('../models')
const { Op } = require('sequelize')
const { sequelize } = require('../config/sequelize')
const { AppError } = require('../middleware/error-handler')
const SocialService = require('./social-service')

/**
 * 笔记业务逻辑服务
 */
class NoteService {
  /**
   * 获取笔记列表
   */
  static async getNoteList(page, limit, userId = null) {
    const offset = (page - 1) * limit

    const result = await Note.findAndCountAll({
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'avatar']
        },
        {
          model: Song,
          as: 'song',
          required: false,
          attributes: ['id', 'title', 'cover_url'],
          include: [
            {
              model: Artist,
              as: 'artist',
              attributes: ['id', 'name']
            }
          ]
        },
        {
          model: NoteImage,
          as: 'images',
          attributes: ['id', 'image_url', 'order_index'],
          order: [['order_index', 'ASC']]
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    // 如果用户已登录，检查点赞状态
    let likedStatus = {}
    if (userId) {
      const noteIds = result.rows.map(note => note.id)
      likedStatus = await SocialService.batchCheckLiked(userId, 'note', noteIds)
    }

    const list = result.rows.map(note => ({
      ...note.toJSON(),
      is_liked: userId ? likedStatus[note.id] || false : false
    }))

    return {
      list,
      total: result.count
    }
  }

  /**
   * 根据ID获取笔记详情
   */
  static async getNoteById(id, userId = null) {
    // 确保ID为数字类型
    const noteId = parseInt(id)
    
    const note = await Note.findByPk(noteId, {
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'avatar']
        },
        {
          model: Song,
          as: 'song',
          required: false,
          attributes: ['id', 'title', 'cover_url', 'duration'],
          include: [
            {
              model: Artist,
              as: 'artist',
              attributes: ['id', 'name']
            },
            {
              model: Album,
              as: 'album',
              required: false,
              attributes: ['id', 'title', 'cover_url']
            }
          ]
        },
        {
          model: NoteImage,
          as: 'images',
          attributes: ['id', 'image_url', 'order_index'],
          order: [['order_index', 'ASC']]
        }
      ]
    })

    if (!note) {
      throw new AppError('笔记不存在', 404)
    }

    // 获取笔记统计信息
    const [likeCount, commentCount] = await Promise.all([
      Like.count({ where: { type: 'note', target_id: noteId } }),
      Comment.count({ where: { type: 'note', target_id: noteId, parent_id: null } })
    ])

    // 检查用户是否已点赞
    let isLiked = false
    if (userId) {
      isLiked = await SocialService.batchCheckLiked(userId, 'note', [noteId]).then(result => result[noteId] || false)
    }

    return {
      ...note.toJSON(),
      like_count: likeCount,
      comment_count: commentCount,
      is_liked: isLiked
    }
  }

  /**
   * 创建笔记
   */
  static async createNote(noteData) {
    const { user_id, title, content, song_id, images } = noteData

    // 验证必要字段
    if (!user_id) {
      throw new AppError('用户ID不能为空', 400)
    }

    if (!title && !content) {
      throw new AppError('标题和内容不能同时为空', 400)
    }

    // 如果指定了歌曲ID，检查歌曲是否存在
    if (song_id) {
      const song = await Song.findByPk(song_id)
      if (!song) {
        throw new AppError('指定的歌曲不存在', 404)
      }
    }

    // 验证上传的图片文件
    const imageUrls = []
    if (images && images.length > 0) {
      for (const file of images) {
        // 验证文件类型
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
        if (!allowedTypes.includes(file.mimetype)) {
          throw new AppError('不支持的图片格式，只支持 JPEG、PNG、GIF', 400)
        }

        // 验证文件大小（5MB）
        const maxSize = 5 * 1024 * 1024
        if (file.size > maxSize) {
          throw new AppError('图片文件过大，最大支持5MB', 400)
        }

        // 生成图片访问URL
        imageUrls.push(`/uploads/notes/${file.filename}`)
      }
    }

    // 开启事务
    const transaction = await sequelize.transaction()

    try {
      // 创建笔记
      const note = await Note.create({
        user_id,
        title: title ? title.trim() : null,
        content: content ? content.trim() : null,
        song_id: song_id || null
      }, { transaction })

      // 如果有图片，创建图片记录
      if (imageUrls.length > 0) {
        const imageRecords = imageUrls.map((imageUrl, index) => ({
          note_id: note.id,
          image_url: imageUrl,
          order_index: index
        }))

        await NoteImage.bulkCreate(imageRecords, { transaction })
      }

      await transaction.commit()

      // 返回完整的笔记信息
      return await this.getNoteById(note.id)
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 更新笔记
   */
  static async updateNote(id, userId, updateData) {
    const { title, content, song_id, images } = updateData
    
    // 确保ID为数字类型
    const noteId = parseInt(id)

    const note = await Note.findByPk(noteId)
    if (!note) {
      throw new AppError('笔记不存在', 404)
    }

    // 检查权限
    if (note.user_id !== userId) {
      throw new AppError('无权限修改此笔记', 403)
    }

    // 验证字段
    if (title !== undefined && content !== undefined && !title && !content) {
      throw new AppError('标题和内容不能同时为空', 400)
    }

    // 如果指定了歌曲ID，检查歌曲是否存在
    if (song_id) {
      const song = await Song.findByPk(song_id)
      if (!song) {
        throw new AppError('指定的歌曲不存在', 404)
      }
    }

    // 开启事务
    const transaction = await sequelize.transaction()

    try {
      // 更新笔记基本信息
      const updateFields = {}
      if (title !== undefined) updateFields.title = title ? title.trim() : null
      if (content !== undefined) updateFields.content = content ? content.trim() : null
      if (song_id !== undefined) updateFields.song_id = song_id || null

      if (Object.keys(updateFields).length > 0) {
        await note.update(updateFields, { transaction })
      }

      // 如果传入了图片文件，更新图片
      if (images !== undefined) {
        // 验证上传的图片文件
        const imageUrls = []
        if (images.length > 0) {
          for (const file of images) {
            // 验证文件类型
            const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
            if (!allowedTypes.includes(file.mimetype)) {
              throw new AppError('不支持的图片格式，只支持 JPEG、PNG、GIF', 400)
            }

            // 验证文件大小（5MB）
            const maxSize = 5 * 1024 * 1024
            if (file.size > maxSize) {
              throw new AppError('图片文件过大，最大支持5MB', 400)
            }

            // 生成图片访问URL
            imageUrls.push(`/uploads/notes/${file.filename}`)
          }
        }

        // 删除原有图片
        await NoteImage.destroy({
          where: { note_id: noteId },
          transaction
        })

        // 创建新图片记录
        if (imageUrls.length > 0) {
          const imageRecords = imageUrls.map((imageUrl, index) => ({
            note_id: noteId,
            image_url: imageUrl,
            order_index: index
          }))

          await NoteImage.bulkCreate(imageRecords, { transaction })
        }
      }

      await transaction.commit()

      // 返回更新后的笔记信息
      return await this.getNoteById(noteId, userId)
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 删除笔记
   */
  static async deleteNote(id, userId) {
    // 确保ID为数字类型
    const noteId = parseInt(id)
    
    const note = await Note.findByPk(noteId)
    if (!note) {
      throw new AppError('笔记不存在', 404)
    }

    // 检查权限
    if (note.user_id !== userId) {
      throw new AppError('无权限删除此笔记', 403)
    }

    // 开启事务
    const transaction = await sequelize.transaction()

    try {
      // 删除相关的图片
      await NoteImage.destroy({
        where: { note_id: noteId },
        transaction
      })

      // 删除相关的评论
      await Comment.destroy({
        where: { type: 'note', target_id: noteId },
        transaction
      })

      // 删除相关的点赞
      await Like.destroy({
        where: { type: 'note', target_id: noteId },
        transaction
      })

      // 删除笔记本身
      await note.destroy({ transaction })

      await transaction.commit()
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 点赞笔记
   */
  static async likeNote(noteId, userId) {
    // 检查笔记是否存在
    const note = await Note.findByPk(noteId)
    if (!note) {
      throw new AppError('笔记不存在', 404)
    }

    return await SocialService.addLike(userId, 'note', noteId)
  }

  /**
   * 取消点赞笔记
   */
  static async unlikeNote(noteId, userId) {
    // 检查笔记是否存在
    const note = await Note.findByPk(noteId)
    if (!note) {
      throw new AppError('笔记不存在', 404)
    }

    return await SocialService.removeLike(userId, 'note', noteId)
  }

  /**
   * 获取笔记评论
   */
  static async getNoteComments(noteId, page, limit) {
    // 检查笔记是否存在
    const note = await Note.findByPk(noteId)
    if (!note) {
      throw new AppError('笔记不存在', 404)
    }

    return await SocialService.getCommentList('note', noteId, page, limit)
  }

  /**
   * 添加笔记评论
   */
  static async addNoteComment(noteId, userId, content) {
    // 检查笔记是否存在
    const note = await Note.findByPk(noteId)
    if (!note) {
      throw new AppError('笔记不存在', 404)
    }

    return await SocialService.addComment(userId, 'note', noteId, content)
  }

  /**
   * 获取我的笔记
   */
  static async getMyNotes(userId, page, limit) {
    const offset = (page - 1) * limit

    const result = await Note.findAndCountAll({
      where: { user_id: userId },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'avatar']
        },
        {
          model: Song,
          as: 'song',
          required: false,
          attributes: ['id', 'title', 'cover_url'],
          include: [
            {
              model: Artist,
              as: 'artist',
              attributes: ['id', 'name']
            }
          ]
        },
        {
          model: NoteImage,
          as: 'images',
          attributes: ['id', 'image_url', 'order_index'],
          order: [['order_index', 'ASC']]
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    // 获取统计信息
    const noteIds = result.rows.map(note => note.id)
    const [likeStats, commentStats, likedStatus] = await Promise.all([
      SocialService.getLikeStats('note', noteIds),
      this.getCommentStats(noteIds),
      SocialService.batchCheckLiked(userId, 'note', noteIds)
    ])

    const list = result.rows.map(note => ({
      ...note.toJSON(),
      like_count: likeStats[note.id] || 0,
      comment_count: commentStats[note.id] || 0,
      is_liked: likedStatus[note.id] || false
    }))

    return {
      list,
      total: result.count
    }
  }

  /**
   * 根据歌曲获取笔记
   */
  static async getNotesBySong(songId, page, limit, userId = null) {
    const offset = (page - 1) * limit

    const result = await Note.findAndCountAll({
      where: { song_id: songId },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'avatar']
        },
        {
          model: NoteImage,
          as: 'images',
          attributes: ['id', 'image_url', 'order_index'],
          order: [['order_index', 'ASC']]
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    })

    // 如果用户已登录，检查点赞状态
    let likedStatus = {}
    if (userId) {
      const noteIds = result.rows.map(note => note.id)
      likedStatus = await SocialService.batchCheckLiked(userId, 'note', noteIds)
    }

    const list = result.rows.map(note => ({
      ...note.toJSON(),
      is_liked: userId ? likedStatus[note.id] || false : false
    }))

    return {
      list,
      total: result.count
    }
  }

  /**
   * 获取评论统计
   */
  static async getCommentStats(noteIds) {
    if (noteIds.length === 0) return {}

    const comments = await Comment.findAll({
      where: {
        type: 'note',
        target_id: { [Op.in]: noteIds },
        parent_id: null
      },
      attributes: [
        'target_id',
        [sequelize.fn('COUNT', sequelize.col('id')), 'comment_count']
      ],
      group: ['target_id']
    })

    const stats = {}
    comments.forEach(comment => {
      stats[comment.target_id] = parseInt(comment.dataValues.comment_count)
    })

    return stats
  }

  /**
   * 上传笔记图片
   */
  static async uploadNoteImage(file) {
    if (!file) {
      throw new AppError('没有上传文件', 400)
    }

    // 验证文件类型
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
    if (!allowedTypes.includes(file.mimetype)) {
      throw new AppError('不支持的图片格式', 400)
    }

    // 验证文件大小（5MB）
    const maxSize = 5 * 1024 * 1024
    if (file.size > maxSize) {
      throw new AppError('图片文件过大，最大支持5MB', 400)
    }

    // 返回图片访问路径
    return `/uploads/notes/${file.filename}`
  }
}

module.exports = NoteService 