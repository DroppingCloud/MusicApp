const config = {
  // 应用配置
  env: process.env.NODE_ENV || 'development',                         // 运行环境
  port: process.env.PORT || 3000,                                     // 服务监听端口
  apiPrefix: process.env.API_PREFIX || '/api/v1',                     // Api 路由接口前缀

  // JWT配置
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key',              // JWT密钥
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',                    // 令牌过期时间
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d'     // 刷新令牌过期时间
  },

  // 数据库配置
  database: {
    host: process.env.DB_HOST || 'localhost',                         // 数据库服务器地址
    port: process.env.DB_PORT || 3306,                                // 数据库端口
    user: process.env.DB_USER || 'root',                              // 数据库用户
    password: process.env.DB_PASSWORD || 'ctq150690',                 // 数据库密码
    database: process.env.DB_NAME || 'my_app',                        // 数据库名称
    connectionLimit: process.env.DB_CONNECTION_LIMIT || 10,           // 数据库连接池最大连接数
    acquireTimeout: process.env.DB_ACQUIRE_TIMEOUT || 60000,          // 数据库连接池获取连接超时时间
    timeout: process.env.DB_TIMEOUT || 60000                          // 数据库查询超时时间
  },

  // Redis配置
  redis: {
    host: process.env.REDIS_HOST || 'localhost',                      // 服务器地址
    port: process.env.REDIS_PORT || 6379,                             // 服务器端口
    password: process.env.REDIS_PASSWORD || '',                       // 密码
    db: process.env.REDIS_DB || 0                                     // 数据库选择索引
  },

  // 文件上传配置
  upload: {
    path: process.env.UPLOAD_PATH || 'uploads',                       // 上传文件本地存储路径
    maxFileSize: process.env.MAX_FILE_SIZE || '50MB',                 // 最大上传文件大小
    allowedAudioTypes: (process.env.ALLOWED_AUDIO_TYPES || 'audio/mpeg,audio/wav,audio/flac').split(','),   // 允许的音频类型
    allowedImageTypes: (process.env.ALLOWED_IMAGE_TYPES || 'image/jpeg,image/png,image/gif').split(',')     // 允许的图片类型
  },

  // 日志配置
  log: {
    level: process.env.LOG_LEVEL || 'info',                           // 日志级别
    filePath: process.env.LOG_FILE_PATH || 'logs'                     // 日志文件路径
  },

  // 安全配置
  security: {
    bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS) || 12,                    // 密码哈希迭代次数
    rateLimitMax: parseInt(process.env.RATE_LIMIT_MAX) || 100,                  // 最大请求限制
    rateLimitDuration: parseInt(process.env.RATE_LIMIT_DURATION) || 900000      // 限流时间窗口15分钟
  },

  // CORS配置 (跨域资源共享)
  cors: {
    origin: process.env.CORS_ORIGIN || ['http://localhost:8080', 'http://10.136.74.177:8080'] // 允许跨域的域名列表 
  },

  // 第三方服务配置
  qiniu: {
    accessKey: process.env.QINIU_ACCESS_KEY || '',                        // 七牛云 AccessKey
    secretKey: process.env.QINIU_SECRET_KEY || '',                        // 七牛云 SecretKey
    bucket: process.env.QINIU_BUCKET || ''                                // 七牛云 存储空间名称
  }
}

module.exports = config 