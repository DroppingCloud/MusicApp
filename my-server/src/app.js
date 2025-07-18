const Koa = require('koa')                 // Koa2 框架主对象
const bodyParser = require('koa-bodyparser') // 请求体解析（JSON, 表单等）
const cors = require('koa-cors')             // 跨域资源共享支持
const helmet = require('koa-helmet')         // 各类HTTP安全头
const logger = require('koa-logger')         // 控制台请求日志
const koaStatic = require('koa-static')      // 静态资源服务
const path = require('path')                 // 路径工具

// 导入配置
const config = require('./config')
const { logger: appLogger } = require('./utils/logger')
const { initDatabase } = require('./models')

// 导入自定义中间件
const errorHandler = require('./middleware/error-handler')
const authMiddleware = require('./middleware/auth')
const { baseRateLimit } = require('./middleware/rate-limit')

// 导入路由
const routes = require('./routes')

const app = new Koa()

// 全局错误处理
app.use(errorHandler)

// 安全中间件
app.use(helmet())

// CORS跨域配置
app.use(cors({
  origin: config.env === 'development' ? true : config.cors.origin, // 开发环境允许所有origin
  credentials: true
}))

// 请求日志
if (config.env !== 'test') {
  app.use(logger())
}

// 速率限制 (开发环境已禁用)
// app.use(baseRateLimit)

// 请求体解析 - 排除文件上传路由
app.use(bodyParser({
  jsonLimit: '10mb',
  textLimit: '10mb',
  enableTypes: ['json', 'form', 'text'],
  extendTypes: {
    json: ['application/x-javascript'] // 将 application/x-javascript 视为 json
  },
  // 排除文件上传路由，避免与 multer 冲突
  detectJSON: function(ctx) {
    return !ctx.path.includes('/avatar') && 
           !ctx.path.includes('/upload-image') &&
           !ctx.path.includes('/note/create') &&
           !ctx.path.includes('/note/update') &&
           !ctx.path.includes('/register')
  }
}))

// 静态文件服务
app.use(koaStatic(path.join(__dirname, '../uploads')))

// 路由
app.use(routes.routes())
app.use(routes.allowedMethods())

// 启动服务器
const PORT = config.port || 3000

// 启动应用
const startApp = async () => {
  try {
    // 初始化数据库
    appLogger.info('正在初始化数据库...')
    const dbInitialized = await initDatabase()
    
    if (!dbInitialized) {
      appLogger.error('数据库初始化失败，应用无法启动')
      process.exit(1)
    }
    
    // 启动服务器
    app.listen(PORT, () => {
      appLogger.info(`音乐API服务启动成功`)
      appLogger.info(`服务运行在端口: ${PORT}`)
      appLogger.info(`环境: ${config.env}`)
      appLogger.info(`数据库连接状态: 已连接`)
    })
  } catch (error) {
    appLogger.error('应用启动失败:', error)
    process.exit(1)
  }
}

if (require.main === module) {
  startApp()
}

module.exports = app 