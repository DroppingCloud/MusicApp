const SongService = require('../services/song-service')
const { success, list } = require('../utils/response')
const { AppError } = require('../middleware/error-handler')

/**
 * 歌曲控制器
 */
class SongController {
  /**
   * 获取歌曲列表
   */
  static async getSongList(ctx) {
    const { page = 1, limit = 20, keyword = '', genre = '', artist = '' } = ctx.query
    const result = await SongService.getSongList(page, limit, { keyword, genre, artist })
    
    list(ctx, result.list, page, limit, result.total, '获取歌曲列表成功')
  }

  /**
   * 根据ID获取歌曲详情
   */
  static async getSongById(ctx) {
    const { id } = ctx.params
    const song = await SongService.getSongById(id)
    
    if (!song) {
      throw new AppError('歌曲不存在', 404, 'SONG_NOT_FOUND')
    }

    success(ctx, song, '获取歌曲详情成功')
  }

  /**
   * 创建歌曲
   */
  static async createSong(ctx) {
    const songData = ctx.request.body
    const song = await SongService.createSong(songData)
    
    success(ctx, song, '创建歌曲成功', 201)
  }

  /**
   * 更新歌曲信息
   */
  static async updateSong(ctx) {
    const { id } = ctx.params
    const updateData = ctx.request.body
    
    const song = await SongService.updateSong(id, updateData)
    success(ctx, song, '更新歌曲成功')
  }

  /**
   * 删除歌曲
   */
  static async deleteSong(ctx) {
    const { id } = ctx.params
    await SongService.deleteSong(id)
    
    success(ctx, null, '删除歌曲成功')
  }

  /**
   * 播放歌曲（记录播放历史）
   */
  static async playSong(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user?.id
    
    await SongService.playSong(id, userId)
    success(ctx, null, '播放歌曲成功')
  }

  /**
   * 获取热门歌曲
   */
  static async getHotSongs(ctx) {
    const { limit = 50 } = ctx.query
    const songs = await SongService.getHotSongs(limit)
    
    success(ctx, songs, '获取热门歌曲成功')
  }

  /**
   * 获取推荐歌曲
   */
  static async getRecommendedSongs(ctx) {
    const userId = ctx.state.user?.id
    const { limit = 20 } = ctx.query
    
    const songs = await SongService.getRecommendedSongs(userId, limit)
    success(ctx, songs, '获取推荐歌曲成功')
  }

  /**
   * 喜欢歌曲
   */
  static async likeSong(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    
    await SongService.likeSong(id, userId)
    success(ctx, null, '喜欢歌曲成功')
  }

  /**
   * 取消喜欢歌曲
   */
  static async unlikeSong(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    
    await SongService.unlikeSong(id, userId)
    success(ctx, null, '取消喜欢歌曲成功')
  }
}

module.exports = SongController 