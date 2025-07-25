const Router = require('koa-router')
const config = require('../config')

// 导入各模块路由
const authRoutes = require('./auth-routes')
const userRoutes = require('./user-routes')
const songRoutes = require('./song-routes')
const playlistRoutes = require('./playlist-routes')
const searchRoutes = require('./search-routes')
const noteRoutes = require('./note-routes')
const socialRoutes = require('./social-routes')

const router = new Router({
  prefix: config.apiPrefix
})

// 健康检查端点
router.get('/health', async (ctx) => {
  ctx.body = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    service: '网易云音乐API'
  }
})

// API文档端点
router.get('/docs', async (ctx) => {
  ctx.body = {
    message: '网易云音乐API文档',
    version: '1.0.0',
    endpoints: {
      auth: '认证相关接口',
      user: '用户管理接口',
      song: '歌曲管理接口',
      playlist: '歌单管理接口',
      search: '搜索相关接口',
      note: '笔记相关接口',
      social: '社交相关接口'
    },
    baseUrl: config.apiPrefix
  }
})

// 注册各模块路由
router.use('/auth', authRoutes.routes(), authRoutes.allowedMethods())
router.use('/user', userRoutes.routes(), userRoutes.allowedMethods())
router.use('/song', songRoutes.routes(), songRoutes.allowedMethods())
router.use('/playlist', playlistRoutes.routes(), playlistRoutes.allowedMethods())
router.use('/search', searchRoutes.routes(), searchRoutes.allowedMethods())
router.use('/note', noteRoutes.routes(), noteRoutes.allowedMethods())
router.use('/social', socialRoutes.routes(), socialRoutes.allowedMethods())

module.exports = router 