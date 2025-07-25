const { Playlist, Song, Artist, Album, User, UserCollect, PlaylistSong, sequelize } = require('../models')
const { AppError } = require('../middleware/error-handler')
const { Op } = require('sequelize')

/**
 * 歌单业务逻辑服务
 */
class PlaylistService {
  /**
   * 获取歌单列表
   */
  static async getPlaylistList(page, limit, keyword) {
    const offset = (page - 1) * limit
    
    const whereClause = {}
    if (keyword) {
      whereClause.title = {
        [Op.like]: `%${keyword}%`
      }
    }
    
    const { count, rows } = await Playlist.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: User,
          as: 'creator',
          attributes: ['id', 'username', 'avatar']
        }
      ],
      offset,
      limit: parseInt(limit),
      order: [['create_time', 'DESC']]
    })
    
    // 获取每个歌单的歌曲数量
    const playlistsWithCount = await Promise.all(
      rows.map(async (playlist) => {
        const songCount = await PlaylistSong.count({
          where: { playlist_id: playlist.id }
        })
        
        return {
          ...playlist.toJSON(),
          song_count: songCount
        }
      })
    )
    
    return {
      list: playlistsWithCount,
      total: count
    }
  }

  /**
   * 根据ID获取歌单详情
   */
  static async getPlaylistById(id) {
    const playlist = await Playlist.findByPk(id, {
      include: [
        {
          model: User,
          as: 'creator',
          attributes: ['id', 'username', 'avatar']
        }
      ]
    })
    
    if (!playlist) {
      return null
    }
    
    // 获取歌单中的歌曲数量
    const songCount = await PlaylistSong.count({
      where: { playlist_id: id }
    })
    
    // 获取收藏数量
    const collectCount = await UserCollect.count({
      where: { playlist_id: id }
    })
    
    return {
      ...playlist.toJSON(),
      song_count: songCount,
      collect_count: collectCount
    }
  }

  /**
   * 创建歌单
   */
  static async createPlaylist(playlistData) {
    const playlist = await Playlist.create(playlistData)
    return await this.getPlaylistById(playlist.id)
  }

  /**
   * 更新歌单信息
   */
  static async updatePlaylist(id, userId, updateData) {
    const playlist = await Playlist.findByPk(id)
    
    if (!playlist) {
      throw new AppError('歌单不存在', 404, 'PLAYLIST_NOT_FOUND')
    }
    
    // 检查权限
    if (playlist.user_id !== userId) {
      throw new AppError('没有权限修改此歌单', 403, 'PERMISSION_DENIED')
    }
    
    await playlist.update(updateData)
    return await this.getPlaylistById(id)
  }

  /**
   * 删除歌单
   */
  static async deletePlaylist(id, userId) {
    const transaction = await sequelize.transaction()
    
    try {
      const playlist = await Playlist.findByPk(id)
      
      if (!playlist) {
        throw new AppError('歌单不存在', 404, 'PLAYLIST_NOT_FOUND')
      }
      
      // 检查权限
      if (playlist.user_id !== userId) {
        throw new AppError('没有权限删除此歌单', 403, 'PERMISSION_DENIED')
      }
      
      // 删除相关数据
      await PlaylistSong.destroy({ where: { playlist_id: id }, transaction })
      await UserCollect.destroy({ where: { playlist_id: id }, transaction })
      
      // 删除歌单
      await playlist.destroy({ transaction })
      
      await transaction.commit()
      
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 获取歌单中的歌曲
   */
  static async getPlaylistSongs(playlistId, page, limit) {
    const offset = (page - 1) * limit
    
    // 验证歌单是否存在
    const playlist = await Playlist.findByPk(playlistId)
    if (!playlist) {
      throw new AppError('歌单不存在', 404, 'PLAYLIST_NOT_FOUND')
    }
    
    const { count, rows } = await PlaylistSong.findAndCountAll({
      where: { playlist_id: playlistId },
      include: [
        {
          model: Song,
          as: 'song',
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
            }
          ]
        }
      ],
      offset,
      limit: parseInt(limit),
      order: [['order_index', 'ASC'], ['id', 'ASC']]
    })
    
    return {
      list: rows,
      total: count
    }
  }

  /**
   * 添加歌曲到歌单
   */
  static async addSongToPlaylist(playlistId, songId, userId) {
    const transaction = await sequelize.transaction()
    
    try {
      // 验证歌单是否存在并检查权限
      const playlist = await Playlist.findByPk(playlistId)
      if (!playlist) {
        throw new AppError('歌单不存在', 404, 'PLAYLIST_NOT_FOUND')
      }
      
      if (playlist.user_id !== userId) {
        throw new AppError('没有权限修改此歌单', 403, 'PERMISSION_DENIED')
      }
      
      // 验证歌曲是否存在
      const song = await Song.findByPk(songId)
      if (!song) {
        throw new AppError('歌曲不存在', 404, 'SONG_NOT_FOUND')
      }
      
      // 检查歌曲是否已在歌单中
      const existingPlaylistSong = await PlaylistSong.findOne({
        where: { playlist_id: playlistId, song_id: songId }
      })
      
      if (existingPlaylistSong) {
        throw new AppError('歌曲已在歌单中', 400, 'SONG_ALREADY_IN_PLAYLIST')
      }
      
      // 获取下一个排序号
      const maxOrderIndex = await PlaylistSong.max('order_index', {
        where: { playlist_id: playlistId }
      })
      
      const nextOrderIndex = (maxOrderIndex || 0) + 1
      
      // 添加歌曲到歌单
      await PlaylistSong.create({
        playlist_id: playlistId,
        song_id: songId,
        order_index: nextOrderIndex
      }, { transaction })
      
      await transaction.commit()
      
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 从歌单移除歌曲
   */
  static async removeSongFromPlaylist(playlistId, songId, userId) {
    const transaction = await sequelize.transaction()
    
    try {
      // 验证歌单是否存在并检查权限
      const playlist = await Playlist.findByPk(playlistId)
      if (!playlist) {
        throw new AppError('歌单不存在', 404, 'PLAYLIST_NOT_FOUND')
      }
      
      if (playlist.user_id !== userId) {
        throw new AppError('没有权限修改此歌单', 403, 'PERMISSION_DENIED')
      }
      
      // 查找要删除的歌曲
      const playlistSong = await PlaylistSong.findOne({
        where: { playlist_id: playlistId, song_id: songId }
      })
      
      if (!playlistSong) {
        throw new AppError('歌曲不在歌单中', 404, 'SONG_NOT_IN_PLAYLIST')
      }
      
      // 删除歌曲
      await playlistSong.destroy({ transaction })
      
      // 重新整理排序
      await PlaylistSong.update(
        { order_index: sequelize.literal('order_index - 1') },
        {
          where: {
            playlist_id: playlistId,
            order_index: { [Op.gt]: playlistSong.order_index }
          },
          transaction
        }
      )
      
      await transaction.commit()
      
      return true
    } catch (error) {
      await transaction.rollback()
      throw error
    }
  }

  /**
   * 收藏歌单
   */
  static async collectPlaylist(playlistId, userId) {
    // 验证歌单是否存在
    const playlist = await Playlist.findByPk(playlistId)
    if (!playlist) {
      throw new AppError('歌单不存在', 404, 'PLAYLIST_NOT_FOUND')
    }
    
    // 不能收藏自己的歌单
    if (playlist.user_id === userId) {
      throw new AppError('不能收藏自己的歌单', 400, 'CANNOT_COLLECT_OWN_PLAYLIST')
    }
    
    // 检查是否已收藏
    const existingCollection = await UserCollect.findOne({
      where: { user_id: userId, playlist_id: playlistId }
    })
    
    if (existingCollection) {
      throw new AppError('已收藏该歌单', 400, 'PLAYLIST_ALREADY_COLLECTED')
    }
    
    // 添加收藏
    await UserCollect.create({
      user_id: userId,
      playlist_id: playlistId
    })
    
    return true
  }

  /**
   * 取消收藏歌单
   */
  static async uncollectPlaylist(playlistId, userId) {
    // 验证歌单是否存在
    const playlist = await Playlist.findByPk(playlistId)
    if (!playlist) {
      throw new AppError('歌单不存在', 404, 'PLAYLIST_NOT_FOUND')
    }
    
    // 查找收藏记录
    const collection = await UserCollect.findOne({
      where: { user_id: userId, playlist_id: playlistId }
    })
    
    if (!collection) {
      throw new AppError('未收藏该歌单', 400, 'PLAYLIST_NOT_COLLECTED')
    }
    
    // 取消收藏
    await collection.destroy()
    
    return true
  }

  /**
   * 获取收藏的歌单
   */
  static async getCollectedPlaylists(userId, page, limit) {
    const offset = (page - 1) * limit
    
    const { count, rows } = await UserCollect.findAndCountAll({
      where: { user_id: userId },
      include: [
        {
          model: Playlist,
          as: 'playlist',
          include: [
            {
              model: User,
              as: 'creator',
              attributes: ['id', 'username', 'avatar']
            }
          ]
        }
      ],
      offset,
      limit: parseInt(limit),
      order: [['created_at', 'DESC']]
    })
    
    // 获取每个歌单的歌曲数量
    const playlistsWithCount = await Promise.all(
      rows.map(async (collection) => {
        const songCount = await PlaylistSong.count({
          where: { playlist_id: collection.playlist.id }
        })
        
        return {
          ...collection.toJSON(),
          playlist: {
            ...collection.playlist.toJSON(),
            song_count: songCount
          }
        }
      })
    )
    
    return {
      list: playlistsWithCount,
      total: count
    }
  }

  /**
   * 获取用户创建的歌单
   */
  static async getUserPlaylists(userId, page, limit) {
    const offset = (page - 1) * limit
    
    const { count, rows } = await Playlist.findAndCountAll({
      where: { user_id: userId },
      include: [
        {
          model: User,
          as: 'creator',
          attributes: ['id', 'username', 'avatar']
        }
      ],
      offset,
      limit: parseInt(limit),
      order: [['create_time', 'DESC']]
    })
    
    // 获取每个歌单的歌曲数量
    const playlistsWithCount = await Promise.all(
      rows.map(async (playlist) => {
        const songCount = await PlaylistSong.count({
          where: { playlist_id: playlist.id }
        })
        
        return {
          ...playlist.toJSON(),
          song_count: songCount
        }
      })
    )
    
    return {
      list: playlistsWithCount,
      total: count
    }
  }
}

module.exports = PlaylistService 