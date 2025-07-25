const { Song, Artist, Album, SongStat, Tag, SongTag, PlaylistSong, UserFavorite, UserHistory, sequelize } = require('../models')
const { AppError } = require('../middleware/error-handler')
const { Op } = require('sequelize')

/**
 * 歌曲业务逻辑服务
 */
class SongService {
  /**
   * 获取歌曲列表
   */
  static async getSongList(page, limit, filters) {
    const { keyword = '', genre = '', artist = '' } = filters
    const offset = (page - 1) * limit
    
    const whereClause = {}
    const includeClause = [
      {
        model: Artist,
        as: 'artist',
        attributes: ['id', 'name', 'avatar']
      },
      {
        model: Album,
        as: 'album',
        attributes: ['id', 'title', 'cover_url'],
        required: false
      },
      {
        model: SongStat,
        as: 'stat',
        attributes: ['play_count', 'like_count', 'comment_count'],
        required: false
      },
      {
        model: Tag,
        as: 'tags',
        attributes: ['id', 'name', 'type'],
        through: { attributes: [] },
        required: false
      }
    ]
    
    // 关键词搜索
    if (keyword) {
      whereClause.title = {
        [Op.like]: `%${keyword}%`
      }
    }
    
    // 艺术家筛选
    if (artist) {
      includeClause[0].where = {
        name: {
          [Op.like]: `%${artist}%`
        }
      }
    }
    
    // 风格筛选
    if (genre) {
      includeClause[3].where = {
        name: genre
      }
      includeClause[3].required = true
    }
    
    const { count, rows } = await Song.findAndCountAll({
      where: whereClause,
      include: includeClause,
      offset,
      limit: parseInt(limit),
      order: [['id', 'DESC']],
      distinct: true
    })
    
    return {
      list: rows,
      total: count
    }
  }

  /**
   * 根据ID获取歌曲详情
   */
  static async getSongById(id) {
    const song = await Song.findByPk(id, {
      include: [
        {
          model: Artist,
          as: 'artist',
          attributes: ['id', 'name', 'avatar', 'bio']
        },
        {
          model: Album,
          as: 'album',
          attributes: ['id', 'title', 'cover_url', 'publish_time'],
          required: false
        },
        {
          model: SongStat,
          as: 'stat',
          attributes: ['play_count', 'like_count', 'comment_count'],
          required: false
        },
        {
          model: Tag,
          as: 'tags',
          attributes: ['id', 'name', 'type'],
          through: { attributes: [] },
          required: false
        }
      ]
    })
    
    return song
  }

  /**
   * 创建歌曲
   */
  static async createSong(songData) {
    const transaction = await sequelize.transaction()
    
    try {
      // 验证艺术家是否存在
      const artist = await Artist.findByPk(songData.artist_id)
      if (!artist) {
        throw new AppError('艺术家不存在', 400, 'ARTIST_NOT_FOUND')
      }
      
      // 验证专辑是否存在（如果提供了专辑ID）
      if (songData.album_id) {
        const album = await Album.findByPk(songData.album_id)
        if (!album) {
          throw new AppError('专辑不存在', 400, 'ALBUM_NOT_FOUND')
        }
      }
      
      // 创建歌曲
      const song = await Song.create(songData, { transaction })
      
      // 创建统计记录
      await SongStat.create({
        song_id: song.id,
        play_count: 0,
        like_count: 0,
        comment_count: 0
      }, { transaction })
      
      // 处理标签
      if (songData.tags && songData.tags.length > 0) {
        for (const tagName of songData.tags) {
          const [tag] = await Tag.findOrCreate({
            where: { name: tagName },
            defaults: { name: tagName, type: 'genre' },
            transaction
          })
          await song.addTag(tag, { transaction })
        }
      }
      
      await transaction.commit()
      
      // 返回完整的歌曲信息
      return await this.getSongById(song.id)
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 更新歌曲信息
   */
  static async updateSong(id, updateData) {
    const transaction = await sequelize.transaction()
    
    try {
      const song = await Song.findByPk(id)
      if (!song) {
        throw new AppError('歌曲不存在', 404, 'SONG_NOT_FOUND')
      }
      
      // 验证艺术家是否存在
      if (updateData.artist_id) {
        const artist = await Artist.findByPk(updateData.artist_id)
        if (!artist) {
          throw new AppError('艺术家不存在', 400, 'ARTIST_NOT_FOUND')
        }
      }
      
      // 验证专辑是否存在
      if (updateData.album_id) {
        const album = await Album.findByPk(updateData.album_id)
        if (!album) {
          throw new AppError('专辑不存在', 400, 'ALBUM_NOT_FOUND')
        }
      }
      
      // 更新歌曲信息
      await song.update(updateData, { transaction })
      
      // 处理标签更新
      if (updateData.tags) {
        // 清除原有标签
        await song.setTags([], { transaction })
        
        // 添加新标签
        for (const tagName of updateData.tags) {
          const [tag] = await Tag.findOrCreate({
            where: { name: tagName },
            defaults: { name: tagName, type: 'genre' },
            transaction
          })
          await song.addTag(tag, { transaction })
        }
      }
      
      await transaction.commit()
      
      return await this.getSongById(id)
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 删除歌曲
   */
  static async deleteSong(id) {
    const transaction = await sequelize.transaction()
    
    try {
      const song = await Song.findByPk(id)
      if (!song) {
        throw new AppError('歌曲不存在', 404, 'SONG_NOT_FOUND')
      }
      
      // 删除相关数据
      await SongStat.destroy({ where: { song_id: id }, transaction })
      await SongTag.destroy({ where: { song_id: id }, transaction })
      await PlaylistSong.destroy({ where: { song_id: id }, transaction })
      await UserFavorite.destroy({ where: { song_id: id }, transaction })
      await UserHistory.destroy({ where: { song_id: id }, transaction })
      
      // 删除歌曲
      await song.destroy({ transaction })
      
      await transaction.commit()
      
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 播放歌曲（记录播放历史）
   */
  static async playSong(songId, userId) {
    const transaction = await sequelize.transaction()
    
    try {
      // 验证歌曲是否存在
      const song = await Song.findByPk(songId)
      if (!song) {
        throw new AppError('歌曲不存在', 404, 'SONG_NOT_FOUND')
      }
      
      // 记录播放历史
      if (userId) {
        await UserHistory.create({
          user_id: userId,
          song_id: songId,
          play_time: new Date()
        }, { transaction })
      }
      
      // 更新播放统计
      const [songStat] = await SongStat.findOrCreate({
        where: { song_id: songId },
        defaults: { song_id: songId, play_count: 0, like_count: 0, comment_count: 0 },
        transaction
      })
      
      await songStat.increment('play_count', { transaction })
      
      await transaction.commit()
      
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 获取热门歌曲
   */
  static async getHotSongs(limit) {
    const songs = await Song.findAll({
      include: [
        {
          model: Artist,
          as: 'artist',
          attributes: ['id', 'name', 'avatar']
        },
        {
          model: Album,
          as: 'album',
          attributes: ['id', 'title', 'cover_url'],
          required: false
        },
        {
          model: SongStat,
          as: 'stat',
          attributes: ['play_count', 'like_count', 'comment_count'],
          required: false
        }
      ],
      order: [
        [{ model: SongStat, as: 'stat' }, 'play_count', 'DESC'],
        [{ model: SongStat, as: 'stat' }, 'like_count', 'DESC']
      ],
      limit: parseInt(limit)
    })
    
    return songs
  }

  /**
   * 获取推荐歌曲
   */
  static async getRecommendedSongs(userId, limit) {
    // 简单的推荐算法：基于用户喜欢的歌曲的艺术家和标签
    if (userId) {
      // 获取用户喜欢的歌曲
      const userFavorites = await UserFavorite.findAll({
        where: { user_id: userId },
        include: [
          {
            model: Song,
            as: 'song',
            include: [
              {
                model: Artist,
                as: 'artist',
                attributes: ['id']
              },
              {
                model: Tag,
                as: 'tags',
                attributes: ['id'],
                through: { attributes: [] }
              }
            ]
          }
        ],
        limit: 10
      })
      
      if (userFavorites.length > 0) {
        const artistIds = [...new Set(userFavorites.map(f => f.song.artist_id))]
        const favoritesSongIds = userFavorites.map(f => f.song_id)
        
        const recommendedSongs = await Song.findAll({
          where: {
            id: { [Op.notIn]: favoritesSongIds },
            artist_id: { [Op.in]: artistIds }
          },
          include: [
            {
              model: Artist,
              as: 'artist',
              attributes: ['id', 'name', 'avatar']
            },
            {
              model: Album,
              as: 'album',
              attributes: ['id', 'title', 'cover_url'],
              required: false
            },
            {
              model: SongStat,
              as: 'stat',
              attributes: ['play_count', 'like_count', 'comment_count'],
              required: false
            }
          ],
          order: [
            [{ model: SongStat, as: 'stat' }, 'play_count', 'DESC']
          ],
          limit: parseInt(limit)
        })
        
        if (recommendedSongs.length > 0) {
          return recommendedSongs
        }
      }
    }
    
    // 如果用户没有喜欢的歌曲或没有登录，返回热门歌曲
    return await this.getHotSongs(limit)
  }

  /**
   * 喜欢歌曲
   */
  static async likeSong(songId, userId) {
    const transaction = await sequelize.transaction()
    
    try {
      // 验证歌曲是否存在
      const song = await Song.findByPk(songId)
      if (!song) {
        throw new AppError('歌曲不存在', 404, 'SONG_NOT_FOUND')
      }
      
      // 检查是否已经喜欢
      const existingFavorite = await UserFavorite.findOne({
        where: { user_id: userId, song_id: songId }
      })
      
      if (existingFavorite) {
        throw new AppError('已经喜欢该歌曲', 400, 'SONG_ALREADY_LIKED')
      }
      
      // 添加到喜欢列表
      await UserFavorite.create({
        user_id: userId,
        song_id: songId
      }, { transaction })
      
      // 更新统计
      const [songStat] = await SongStat.findOrCreate({
        where: { song_id: songId },
        defaults: { song_id: songId, play_count: 0, like_count: 0, comment_count: 0 },
        transaction
      })
      
      await songStat.increment('like_count', { transaction })
      
      await transaction.commit()
      
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 取消喜欢歌曲
   */
  static async unlikeSong(songId, userId) {
    const transaction = await sequelize.transaction()
    
    try {
      // 验证歌曲是否存在
      const song = await Song.findByPk(songId)
      if (!song) {
        throw new AppError('歌曲不存在', 404, 'SONG_NOT_FOUND')
      }
      
      // 检查是否已经喜欢
      const existingFavorite = await UserFavorite.findOne({
        where: { user_id: userId, song_id: songId }
      })
      
      if (!existingFavorite) {
        throw new AppError('未喜欢该歌曲', 400, 'SONG_NOT_LIKED')
      }
      
      // 从喜欢列表移除
      await existingFavorite.destroy({ transaction })
      
      // 更新统计
      const songStat = await SongStat.findOne({
        where: { song_id: songId }
      })
      
      if (songStat && songStat.like_count > 0) {
        await songStat.decrement('like_count', { transaction })
      }
      
      await transaction.commit()
      
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }
}

module.exports = SongService 