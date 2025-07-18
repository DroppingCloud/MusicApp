const searchService = require('../services/search-service')
const { success, error } = require('../utils/response')
const { AppError } = require('../middleware/error-handler')

/**
 * 搜索控制器
 */
class SearchController {

  /**
   * 综合搜索
   * GET /search
   */
  async search(ctx) {
    try {
      const { keyword, page = 1, limit = 20, type = 'all' } = ctx.query
      const userId = ctx.state.user?.id || null

      // 参数验证
      if (!keyword || keyword.trim() === '') {
        throw new AppError('搜索关键词不能为空', 400, 'KEYWORD_REQUIRED')
      }

      const result = await searchService.search(
        keyword.trim(), 
        userId, 
        parseInt(page), 
        parseInt(limit), 
        type
      )

      success(ctx, result, '搜索成功')
    } catch (err) {
      console.error('综合搜索失败:', err)
      throw err
    }
  }

  /**
   * 搜索歌曲
   * GET /search/songs
   */
  async searchSongs(ctx) {
    try {
      const { keyword, page = 1, limit = 20 } = ctx.query
      const userId = ctx.state.user?.id || null

      // 参数验证
      if (!keyword || keyword.trim() === '') {
        throw new AppError('搜索关键词不能为空', 400, 'KEYWORD_REQUIRED')
      }

      const offset = (parseInt(page) - 1) * parseInt(limit)
      const result = await searchService.searchSongs(keyword.trim(), parseInt(limit), offset)

      // 记录搜索历史
      if (userId) {
        await searchService.recordSearch(keyword.trim(), userId)
      }

      success(ctx, result, '搜索歌曲成功')
    } catch (err) {
      console.error('搜索歌曲失败:', err)
      throw err
    }
  }

  /**
   * 搜索艺术家
   * GET /search/artists
   */
  async searchArtists(ctx) {
    try {
      const { keyword, page = 1, limit = 20 } = ctx.query
      const userId = ctx.state.user?.id || null

      // 参数验证
      if (!keyword || keyword.trim() === '') {
        throw new AppError('搜索关键词不能为空', 400, 'KEYWORD_REQUIRED')
      }

      const offset = (parseInt(page) - 1) * parseInt(limit)
      const result = await searchService.searchArtists(keyword.trim(), parseInt(limit), offset)

      // 记录搜索历史
      if (userId) {
        await searchService.recordSearch(keyword.trim(), userId)
      }

      success(ctx, result, '搜索艺术家成功')
    } catch (err) {
      console.error('搜索艺术家失败:', err)
      throw err
    }
  }

  /**
   * 搜索专辑
   * GET /search/albums
   */
  async searchAlbums(ctx) {
    try {
      const { keyword, page = 1, limit = 20 } = ctx.query
      const userId = ctx.state.user?.id || null

      // 参数验证
      if (!keyword || keyword.trim() === '') {
        throw new AppError('搜索关键词不能为空', 400, 'KEYWORD_REQUIRED')
      }

      const offset = (parseInt(page) - 1) * parseInt(limit)
      const result = await searchService.searchAlbums(keyword.trim(), parseInt(limit), offset)

      // 记录搜索历史
      if (userId) {
        await searchService.recordSearch(keyword.trim(), userId)
      }

      success(ctx, result, '搜索专辑成功')
    } catch (err) {
      console.error('搜索专辑失败:', err)
      throw err
    }
  }

  /**
   * 搜索歌单
   * GET /search/playlists
   */
  async searchPlaylists(ctx) {
    try {
      const { keyword, page = 1, limit = 20 } = ctx.query
      const userId = ctx.state.user?.id || null

      // 参数验证
      if (!keyword || keyword.trim() === '') {
        throw new AppError('搜索关键词不能为空', 400, 'KEYWORD_REQUIRED')
      }

      const offset = (parseInt(page) - 1) * parseInt(limit)
      const result = await searchService.searchPlaylists(keyword.trim(), parseInt(limit), offset)

      // 记录搜索历史
      if (userId) {
        await searchService.recordSearch(keyword.trim(), userId)
      }

      success(ctx, result, '搜索歌单成功')
    } catch (err) {
      console.error('搜索歌单失败:', err)
      throw err
    }
  }

  /**
   * 搜索用户
   * GET /search/users
   */
  async searchUsers(ctx) {
    try {
      const { keyword, page = 1, limit = 20 } = ctx.query
      const userId = ctx.state.user?.id || null

      // 参数验证
      if (!keyword || keyword.trim() === '') {
        throw new AppError('搜索关键词不能为空', 400, 'KEYWORD_REQUIRED')
      }

      const offset = (parseInt(page) - 1) * parseInt(limit)
      const result = await searchService.searchUsers(keyword.trim(), parseInt(limit), offset)

      // 记录搜索历史
      if (userId) {
        await searchService.recordSearch(keyword.trim(), userId)
      }

      success(ctx, result, '搜索用户成功')
    } catch (err) {
      console.error('搜索用户失败:', err)
      throw err
    }
  }

  /**
   * 获取搜索建议
   * GET /search/suggestions
   */
  async getSearchSuggestions(ctx) {
    try {
      const { keyword, limit = 10 } = ctx.query

      // 参数验证
      if (!keyword || keyword.trim() === '') {
        success(ctx, [], '获取搜索建议成功')
        return
      }

      const suggestions = await searchService.getSearchSuggestions(keyword.trim(), parseInt(limit))

      success(ctx, suggestions, '获取搜索建议成功')
    } catch (err) {
      console.error('获取搜索建议失败:', err)
      throw err
    }
  }

  /**
   * 获取智能搜索建议
   * GET /search/smart-suggestions
   */
  async getSmartSuggestions(ctx) {
    try {
      const { keyword, limit = 5 } = ctx.query

      // 参数验证
      if (!keyword || keyword.trim() === '') {
        success(ctx, {
          songs: [],
          artists: [],
          albums: [],
          playlists: []
        }, '获取智能建议成功')
        return
      }

      const suggestions = await searchService.getSmartSuggestions(keyword.trim(), parseInt(limit))

      success(ctx, suggestions, '获取智能建议成功')
    } catch (err) {
      console.error('获取智能建议失败:', err)
      throw err
    }
  }

  /**
   * 获取热门搜索词
   * GET /search/hot-keywords
   */
  async getHotKeywords(ctx) {
    try {
      const { limit = 10 } = ctx.query

      const hotKeywords = await searchService.getHotSearchKeywords(parseInt(limit))

      success(ctx, hotKeywords, '获取热门搜索词成功')
    } catch (err) {
      console.error('获取热门搜索词失败:', err)
      throw err
    }
  }

  /**
   * 获取用户搜索历史
   * GET /search/history
   */
  async getSearchHistory(ctx) {
    try {
      const { page = 1, limit = 20 } = ctx.query
      const userId = ctx.state.user?.id

      if (!userId) {
        throw new AppError('用户未登录', 401, 'UNAUTHORIZED')
      }

      const result = await searchService.getSearchHistory(userId, parseInt(page), parseInt(limit))

      success(ctx, result, '获取搜索历史成功')
    } catch (err) {
      console.error('获取搜索历史失败:', err)
      throw err
    }
  }

  /**
   * 删除搜索历史
   * POST /search/history/delete
   */
  async deleteSearchHistory(ctx) {
    try {
      const { historyId } = ctx.request.body
      const userId = ctx.state.user?.id

      if (!userId) {
        throw new AppError('用户未登录', 401, 'UNAUTHORIZED')
      }

      const deletedCount = await searchService.deleteSearchHistory(userId, historyId)

      if (deletedCount > 0) {
        const message = historyId ? '删除搜索记录成功' : '清空搜索历史成功'
        success(ctx, { deletedCount }, message)
      } else {
        throw new AppError('搜索记录不存在或已被删除', 404, 'SEARCH_HISTORY_NOT_FOUND')
      }
    } catch (err) {
      console.error('删除搜索历史失败:', err)
      throw err
    }
  }
}

module.exports = new SearchController() 