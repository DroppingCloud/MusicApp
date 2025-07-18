const Router = require('koa-router')
const AuthController = require('../controllers/auth-controller')
const { auth } = require('../middleware/auth')
const { authRateLimit } = require('../middleware/rate-limit')
const { avatarUpload } = require('../middleware/upload')

const router = new Router()

/**
 * 认证相关路由
 */

// 用户注册（支持头像上传）
router.post('/register', /* authRateLimit, */ avatarUpload, AuthController.register)

// 用户登录
router.post('/login', /* authRateLimit, */ AuthController.login)

// 刷新令牌
router.post('/refresh', AuthController.refreshToken)

// 退出登录
router.post('/logout', auth, AuthController.logout)

// 获取当前用户信息
router.get('/me', auth, AuthController.me)

module.exports = router 