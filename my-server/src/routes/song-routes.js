const Router = require('koa-router')
const SongController = require('../controllers/song-controller')
const { auth, optionalAuth } = require('../middleware/auth')
const { uploadRateLimit } = require('../middleware/rate-limit')

const router = new Router()

/**
 * 歌曲相关路由
 */

// 获取歌曲列表
router.get('/list', optionalAuth, SongController.getSongList)

// 获取歌曲详情
router.get('/detail/:id', optionalAuth, SongController.getSongById)

// 创建歌曲
router.post('/create', auth, /* uploadRateLimit, */ SongController.createSong)

// 更新歌曲信息
router.post('/update/:id', auth, SongController.updateSong)

// 删除歌曲
router.post('/remove/:id', auth, SongController.deleteSong)

// 播放歌曲
router.post('/play/:id', optionalAuth, SongController.playSong)

// 获取热门歌曲
router.get('/hot', optionalAuth, SongController.getHotSongs)

// 获取推荐歌曲
router.get('/recommend', optionalAuth, SongController.getRecommendedSongs)

// 喜欢歌曲
router.post('/like/:id', auth, SongController.likeSong)

// 取消喜欢歌曲
router.post('/unlike/:id', auth, SongController.unlikeSong)

module.exports = router 