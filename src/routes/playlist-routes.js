const Router = require('koa-router')
const PlaylistController = require('../controllers/playlist-controller')
const { auth, optionalAuth } = require('../middleware/auth')

const router = new Router()

/**
 * 歌单相关路由
 */

// 获取歌单列表
router.get('/list', optionalAuth, PlaylistController.getPlaylistList)

// 获取歌单详情
router.get('/detail/:id', optionalAuth, PlaylistController.getPlaylistById)

// 创建歌单
router.post('/create', auth, PlaylistController.createPlaylist)

// 更新歌单信息
router.post('/update/:id', auth, PlaylistController.updatePlaylist)

// 删除歌单
router.post('/remove/:id', auth, PlaylistController.deletePlaylist)

// 获取歌单中的歌曲
router.get('/songs/:id', optionalAuth, PlaylistController.getPlaylistSongs)

// 添加歌曲到歌单
router.post('/add-song/:id/:songId', auth, PlaylistController.addSongToPlaylist)

// 从歌单移除歌曲
router.post('/remove-song/:id/:songId', auth, PlaylistController.removeSongFromPlaylist)

// 收藏歌单
router.post('/collect/:id', auth, PlaylistController.collectPlaylist)

// 取消收藏歌单
router.post('/uncollect/:id', auth, PlaylistController.uncollectPlaylist)

// 获取收藏的歌单
router.get('/collected', auth, PlaylistController.getCollectedPlaylists)

// 获取用户创建的歌单
router.get('/user/:userId', optionalAuth, PlaylistController.getUserPlaylists)

module.exports = router 