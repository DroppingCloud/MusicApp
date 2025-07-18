const Router = require('koa-router')
const searchController = require('../controllers/search-controller')
const { optionalAuth, auth } = require('../middleware/auth')

const router = new Router()

/**
 * 搜索相关路由
 */

// 综合搜索（支持未登录用户）
router.get('/', optionalAuth, searchController.search)

// 分类搜索（支持未登录用户）
router.get('/songs', optionalAuth, searchController.searchSongs)
router.get('/artists', optionalAuth, searchController.searchArtists)
router.get('/albums', optionalAuth, searchController.searchAlbums)
router.get('/playlists', optionalAuth, searchController.searchPlaylists)
router.get('/users', optionalAuth, searchController.searchUsers)

// 搜索建议（不需要登录）
router.get('/suggestions', searchController.getSearchSuggestions)
router.get('/smart-suggestions', searchController.getSmartSuggestions)

// 热门搜索词（不需要登录）
router.get('/hot-keywords', searchController.getHotKeywords)

// 搜索历史管理（需要登录）
router.get('/history', auth, searchController.getSearchHistory)
router.post('/history/delete', auth, searchController.deleteSearchHistory)

module.exports = router 