const { Op } = require('sequelize')
const { 
  Song, 
  Artist, 
  Album, 
  Playlist, 
  User, 
  SearchHistory, 
  SearchTrend,
  SongStat,
  Tag,
  UserCollect,
  PlaylistSong,
  sequelize 
} = require('../models')

/**
 * 搜索服务
 */
class SearchService {
  
  /**
   * 综合搜索
   * @param {string} keyword - 搜索关键词
   * @param {number} userId - 用户ID（可选）
   * @param {number} page - 页码
   * @param {number} limit - 每页数量
   * @param {string} type - 搜索类型（可选：song/artist/album/playlist/user/all）
   * @returns {Object} 搜索结果
   */
  async search(keyword, userId = null, page = 1, limit = 20, type = 'all') {
    // 参数验证
    if (!keyword || keyword.trim() === '') {
      throw new Error('搜索关键词不能为空')
    }

    keyword = keyword.trim()
    const offset = (page - 1) * limit

    // 记录搜索历史和统计
    await this.recordSearch(keyword, userId)

    const results = {}

    // 根据搜索类型返回相应结果
    if (type === 'all' || type === 'song') {
      results.songs = await this.searchSongs(keyword, limit, offset)
    }
    
    if (type === 'all' || type === 'artist') {
      results.artists = await this.searchArtists(keyword, limit, offset)
    }
    
    if (type === 'all' || type === 'album') {
      results.albums = await this.searchAlbums(keyword, limit, offset)
    }
    
    if (type === 'all' || type === 'playlist') {
      results.playlists = await this.searchPlaylists(keyword, limit, offset)
    }
    
    if (type === 'all' || type === 'user') {
      results.users = await this.searchUsers(keyword, limit, offset)
    }

    return {
      keyword,
      results,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit)
      }
    }
  }

  /**
   * 搜索歌曲
   * @param {string} keyword - 搜索关键词
   * @param {number} limit - 限制数量
   * @param {number} offset - 偏移量
   * @returns {Array} 歌曲列表
   */
  async searchSongs(keyword, limit, offset) {
    const { count, rows } = await Song.findAndCountAll({
      where: {
        title: {
          [Op.like]: `%${keyword}%`
        }
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
          attributes: ['id', 'title', 'cover_url']
        },
        {
          model: SongStat,
          as: 'stat',
          attributes: ['play_count', 'like_count', 'comment_count']
        },
        {
          model: Tag,
          as: 'tags',
          attributes: ['id', 'name', 'type'],
          through: { attributes: [] }
        }
      ],
      limit,
      offset,
      order: [['id', 'DESC']]
    })

    return {
      list: rows,
      total: count,
      pagination: {
        limit,
        offset,
        totalPages: Math.ceil(count / limit)
      }
    }
  }

  /**
   * 搜索艺术家
   * @param {string} keyword - 搜索关键词
   * @param {number} limit - 限制数量
   * @param {number} offset - 偏移量
   * @returns {Array} 艺术家列表
   */
  async searchArtists(keyword, limit, offset) {
    const { count, rows } = await Artist.findAndCountAll({
      where: {
        name: {
          [Op.like]: `%${keyword}%`
        }
      },
      attributes: ['id', 'name', 'avatar', 'bio'],
      limit,
      offset,
      order: [['id', 'DESC']]
    })

    // 为每个艺术家添加歌曲数量统计
    const artistsWithStats = await Promise.all(rows.map(async (artist) => {
      const songCount = await Song.count({
        where: { artist_id: artist.id }
      })
      
      const albumCount = await Album.count({
        where: { artist_id: artist.id }
      })

      return {
        ...artist.toJSON(),
        song_count: songCount,
        album_count: albumCount
      }
    }))

    return {
      list: artistsWithStats,
      total: count,
      pagination: {
        limit,
        offset,
        totalPages: Math.ceil(count / limit)
      }
    }
  }

  /**
   * 搜索专辑
   * @param {string} keyword - 搜索关键词
   * @param {number} limit - 限制数量
   * @param {number} offset - 偏移量
   * @returns {Array} 专辑列表
   */
  async searchAlbums(keyword, limit, offset) {
    const { count, rows } = await Album.findAndCountAll({
      where: {
        title: {
          [Op.like]: `%${keyword}%`
        }
      },
      include: [
        {
          model: Artist,
          as: 'artist',
          attributes: ['id', 'name', 'avatar']
        }
      ],
      limit,
      offset,
      order: [['id', 'DESC']]
    })

    // 为每个专辑添加歌曲数量统计
    const albumsWithStats = await Promise.all(rows.map(async (album) => {
      const songCount = await Song.count({
        where: { album_id: album.id }
      })

      return {
        ...album.toJSON(),
        song_count: songCount
      }
    }))

    return {
      list: albumsWithStats,
      total: count,
      pagination: {
        limit,
        offset,
        totalPages: Math.ceil(count / limit)
      }
    }
  }

  /**
   * 搜索歌单
   * @param {string} keyword - 搜索关键词
   * @param {number} limit - 限制数量
   * @param {number} offset - 偏移量
   * @returns {Array} 歌单列表
   */
  async searchPlaylists(keyword, limit, offset) {
    const { count, rows } = await Playlist.findAndCountAll({
      where: {
        [Op.or]: [
          {
            title: {
              [Op.like]: `%${keyword}%`
            }
          },
          {
            description: {
              [Op.like]: `%${keyword}%`
            }
          }
        ]
      },
      include: [
        {
          model: User,
          as: 'creator',
          attributes: ['id', 'username', 'avatar']
        }
      ],
      limit,
      offset,
      order: [['create_time', 'DESC']]
    })

    // 为每个歌单添加统计信息
    const playlistsWithStats = await Promise.all(rows.map(async (playlist) => {
      const songCount = await PlaylistSong.count({
        where: { playlist_id: playlist.id }
      })
      
      const collectCount = await UserCollect.count({
        where: { playlist_id: playlist.id }
      })

      return {
        ...playlist.toJSON(),
        song_count: songCount,
        collect_count: collectCount
      }
    }))

    return {
      list: playlistsWithStats,
      total: count,
      pagination: {
        limit,
        offset,
        totalPages: Math.ceil(count / limit)
      }
    }
  }

  /**
   * 搜索用户
   * @param {string} keyword - 搜索关键词
   * @param {number} limit - 限制数量
   * @param {number} offset - 偏移量
   * @returns {Array} 用户列表
   */
  async searchUsers(keyword, limit, offset) {
    const { count, rows } = await User.findAndCountAll({
      where: {
        username: {
          [Op.like]: `%${keyword}%`
        }
      },
      attributes: ['id', 'username', 'avatar', 'created_at'],
      limit,
      offset,
      order: [['created_at', 'DESC']]
    })

    return {
      list: rows,
      total: count,
      pagination: {
        limit,
        offset,
        totalPages: Math.ceil(count / limit)
      }
    }
  }

  /**
   * 记录搜索历史和统计
   * @param {string} keyword - 搜索关键词
   * @param {number} userId - 用户ID（可选）
   */
  async recordSearch(keyword, userId = null) {
    const transaction = await sequelize.transaction()
    
    try {
      // 记录用户搜索历史
      if (userId) {
        // 检查是否已存在相同的搜索记录
        const existingHistory = await SearchHistory.findOne({
          where: {
            user_id: userId,
            keyword: keyword
          },
          transaction
        })

        if (existingHistory) {
          // 更新搜索时间
          await existingHistory.update({
            search_time: new Date()
          }, { transaction })
        } else {
          // 创建新的搜索历史记录
          await SearchHistory.create({
            user_id: userId,
            keyword: keyword
          }, { transaction })
        }
      }

      // 更新搜索趋势统计
      const existingTrend = await SearchTrend.findOne({
        where: { keyword },
        transaction
      })

      if (existingTrend) {
        // 增加搜索次数
        await existingTrend.update({
          count: existingTrend.count + 1,
          updated_at: new Date()
        }, { transaction })
      } else {
        // 创建新的趋势记录
        await SearchTrend.create({
          keyword: keyword,
          count: 1
        }, { transaction })
      }

      await transaction.commit()
    } catch (error) {
      await transaction.rollback()
      console.error('记录搜索历史失败:', error)
      // 搜索历史记录失败不影响搜索结果，继续执行
    }
  }

  /**
   * 获取用户搜索历史
   * @param {number} userId - 用户ID
   * @param {number} page - 页码
   * @param {number} limit - 每页数量
   * @returns {Object} 搜索历史
   */
  async getSearchHistory(userId, page = 1, limit = 20) {
    const offset = (page - 1) * limit

    const { count, rows } = await SearchHistory.findAndCountAll({
      where: { user_id: userId },
      attributes: ['id', 'keyword', 'search_time'],
      limit,
      offset,
      order: [['search_time', 'DESC']]
    })

    return {
      list: rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        totalPages: Math.ceil(count / limit)
      }
    }
  }

  /**
   * 删除用户搜索历史
   * @param {number} userId - 用户ID
   * @param {number} historyId - 搜索历史ID（可选，不传则删除全部）
   */
  async deleteSearchHistory(userId, historyId = null) {
    const whereCondition = { user_id: userId }
    
    if (historyId) {
      whereCondition.id = historyId
    }

    const deletedCount = await SearchHistory.destroy({
      where: whereCondition
    })

    return deletedCount
  }

  /**
   * 获取热门搜索词
   * @param {number} limit - 返回数量
   * @returns {Array} 热门搜索词列表
   */
  async getHotSearchKeywords(limit = 10) {
    const hotKeywords = await SearchTrend.findAll({
      attributes: ['keyword', 'count'],
      limit,
      order: [['count', 'DESC'], ['updated_at', 'DESC']]
    })

    return hotKeywords
  }

  /**
   * 获取搜索建议
   * @param {string} keyword - 关键词前缀
   * @param {number} limit - 返回数量
   * @returns {Array} 搜索建议列表
   */
  async getSearchSuggestions(keyword, limit = 10) {
    if (!keyword || keyword.trim() === '') {
      return []
    }

    keyword = keyword.trim()

    // 从搜索趋势中查找相似的关键词
    const suggestions = await SearchTrend.findAll({
      where: {
        keyword: {
          [Op.like]: `%${keyword}%`
        }
      },
      attributes: ['keyword', 'count'],
      limit,
      order: [['count', 'DESC']]
    })

    return suggestions.map(item => ({
      keyword: item.keyword,
      count: item.count
    }))
  }

  /**
   * 搜索建议（智能提示）
   * @param {string} keyword - 关键词前缀
   * @param {number} limit - 返回数量
   * @returns {Object} 多类型搜索建议
   */
  async getSmartSuggestions(keyword, limit = 5) {
    if (!keyword || keyword.trim() === '') {
      return {
        songs: [],
        artists: [],
        albums: [],
        playlists: []
      }
    }

    keyword = keyword.trim()

    const [songs, artists, albums, playlists] = await Promise.all([
      // 歌曲建议
      Song.findAll({
        where: {
          title: {
            [Op.like]: `${keyword}%`
          }
        },
        include: [
          {
            model: Artist,
            as: 'artist',
            attributes: ['name']
          }
        ],
        attributes: ['id', 'title'],
        limit,
        order: [['title', 'ASC']]
      }),

      // 艺术家建议
      Artist.findAll({
        where: {
          name: {
            [Op.like]: `${keyword}%`
          }
        },
        attributes: ['id', 'name'],
        limit,
        order: [['name', 'ASC']]
      }),

      // 专辑建议
      Album.findAll({
        where: {
          title: {
            [Op.like]: `${keyword}%`
          }
        },
        include: [
          {
            model: Artist,
            as: 'artist',
            attributes: ['name']
          }
        ],
        attributes: ['id', 'title'],
        limit,
        order: [['title', 'ASC']]
      }),

      // 歌单建议
      Playlist.findAll({
        where: {
          title: {
            [Op.like]: `${keyword}%`
          }
        },
        attributes: ['id', 'title'],
        limit,
        order: [['title', 'ASC']]
      })
    ])

    return {
      songs: songs.map(song => ({
        id: song.id,
        title: song.title,
        artist: song.artist ? song.artist.name : ''
      })),
      artists: artists.map(artist => ({
        id: artist.id,
        name: artist.name
      })),
      albums: albums.map(album => ({
        id: album.id,
        title: album.title,
        artist: album.artist ? album.artist.name : ''
      })),
      playlists: playlists.map(playlist => ({
        id: playlist.id,
        title: playlist.title
      }))
    }
  }
}

module.exports = new SearchService() 