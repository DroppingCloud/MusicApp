const Router = require('koa-router')
const UserController = require('../controllers/user-controller')
const { auth, optionalAuth } = require('../middleware/auth')
const { uploadRateLimit } = require('../middleware/rate-limit')
const { avatarUpload } = require('../middleware/upload')

const router = new Router()

/**
 * 用户相关路由
 */

// 获取当前用户信息
router.get('/info', auth, UserController.getCurrentUser)

// 根据ID获取用户信息
router.get('/profile/:id', optionalAuth, UserController.getUserProfile)

// 更新用户信息
router.post('/update', auth, UserController.updateUser)

// 更新用户密码
router.post('/change-password', auth, UserController.changePassword)

// 获取用户列表
router.get('/list', auth, UserController.getUserList)

// 获取用户播放历史
router.get('/history', auth, UserController.getPlayHistory)

// 获取用户喜欢的歌曲
router.get('/favorites', auth, UserController.getFavoriteSongs)

// 添加歌曲到喜欢列表
router.post('/like-song', auth, UserController.likeSong)

// 从喜欢列表移除歌曲
router.post('/unlike-song', auth, UserController.unlikeSong)

// 获取用户收藏的歌单
router.get('/collected', auth, UserController.getCollectedPlaylists)

// 关注用户
router.post('/follow', auth, UserController.followUser)

// 取消关注用户
router.post('/unfollow', auth, UserController.unfollowUser)

// 获取用户的关注列表
router.get('/following', optionalAuth, UserController.getFollowing)

// 获取用户的粉丝列表
router.get('/followers', optionalAuth, UserController.getFollowers)

// 上传头像
router.post('/avatar', auth, /* uploadRateLimit, */ avatarUpload, UserController.uploadAvatar)

/* 用户设置功能待实现 */
// // 获取用户设置
// router.get('/settings', auth, UserController.getSettings)

// // 更新用户设置
// router.post('/settings', auth, UserController.updateSettings)

module.exports = router 