const PlaylistService = require('../services/playlist-service')
const { success, list } = require('../utils/response')
const { AppError } = require('../middleware/error-handler')

/**
 * 歌单控制器
 */
class PlaylistController {
  /**
   * 获取歌单列表
   */
  static async getPlaylistList(ctx) {
    const { page = 1, limit = 20, keyword = '' } = ctx.query
    const result = await PlaylistService.getPlaylistList(page, limit, keyword)
    
    list(ctx, result.list, page, limit, result.total, '获取歌单列表成功')
  }

  /**
   * 根据ID获取歌单详情
   */
  static async getPlaylistById(ctx) {
    const { id } = ctx.params
    const playlist = await PlaylistService.getPlaylistById(id)
    
    if (!playlist) {
      throw new AppError('歌单不存在', 404, 'PLAYLIST_NOT_FOUND')
    }

    success(ctx, playlist, '获取歌单详情成功')
  }

  /**
   * 创建歌单
   */
  static async createPlaylist(ctx) {
    const userId = ctx.state.user.id
    const playlistData = { ...ctx.request.body, user_id: userId }
    
    const playlist = await PlaylistService.createPlaylist(playlistData)
    success(ctx, playlist, '创建歌单成功', 201)
  }

  /**
   * 更新歌单信息
   */
  static async updatePlaylist(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    const updateData = ctx.request.body
    
    const playlist = await PlaylistService.updatePlaylist(id, userId, updateData)
    success(ctx, playlist, '更新歌单成功')
  }

  /**
   * 删除歌单
   */
  static async deletePlaylist(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    
    await PlaylistService.deletePlaylist(id, userId)
    success(ctx, null, '删除歌单成功')
  }

  /**
   * 获取歌单中的歌曲
   */
  static async getPlaylistSongs(ctx) {
    const { id } = ctx.params
    const { page = 1, limit = 50 } = ctx.query
    
    const result = await PlaylistService.getPlaylistSongs(id, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取歌单歌曲成功')
  }

  /**
   * 添加歌曲到歌单
   */
  static async addSongToPlaylist(ctx) {
    const { id, songId } = ctx.params
    const userId = ctx.state.user.id
    
    await PlaylistService.addSongToPlaylist(id, songId, userId)
    success(ctx, null, '添加歌曲到歌单成功')
  }

  /**
   * 从歌单移除歌曲
   */
  static async removeSongFromPlaylist(ctx) {
    const { id, songId } = ctx.params
    const userId = ctx.state.user.id
    
    await PlaylistService.removeSongFromPlaylist(id, songId, userId)
    success(ctx, null, '从歌单移除歌曲成功')
  }

  /**
   * 收藏歌单
   */
  static async collectPlaylist(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    
    await PlaylistService.collectPlaylist(id, userId)
    success(ctx, null, '收藏歌单成功')
  }

  /**
   * 取消收藏歌单
   */
  static async uncollectPlaylist(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    
    await PlaylistService.uncollectPlaylist(id, userId)
    success(ctx, null, '取消收藏歌单成功')
  }

  /**
   * 获取收藏的歌单
   */
  static async getCollectedPlaylists(ctx) {
    const userId = ctx.state.user.id
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await PlaylistService.getCollectedPlaylists(userId, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取收藏歌单成功')
  }

  /**
   * 获取用户创建的歌单
   */
  static async getUserPlaylists(ctx) {
    const { userId } = ctx.params
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await PlaylistService.getUserPlaylists(userId, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取用户歌单成功')
  }
}

module.exports = PlaylistController 