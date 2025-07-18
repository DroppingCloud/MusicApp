const config = {
  // 应用配置
  env: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 3000, // 端口
  apiPrefix: process.env.API_PREFIX || '/api/v1', // 接口前缀

  // JWT配置
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key', // JWT密钥
    expiresIn: process.env.JWT_EXPIRES_IN || '7d', // 令牌过期时间
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' // 刷新令牌过期时间
  },

  // 数据库配置
  database: {
    host: process.env.DB_HOST || 'localhost', // 数据库主机
    port: process.env.DB_PORT || 3306, // 数据库端口
    user: process.env.DB_USER || 'root', // 数据库用户
    password: process.env.DB_PASSWORD || 'ctq150690', // 数据库密码
    database: process.env.DB_NAME || 'my_app',
    connectionLimit: process.env.DB_CONNECTION_LIMIT || 10,
    acquireTimeout: process.env.DB_ACQUIRE_TIMEOUT || 60000,
    timeout: process.env.DB_TIMEOUT || 60000
  },

  // Redis配置
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379,
    password: process.env.REDIS_PASSWORD || '',
    db: process.env.REDIS_DB || 0
  },

  // 文件上传配置
  upload: {
    path: process.env.UPLOAD_PATH || 'uploads',
    maxFileSize: process.env.MAX_FILE_SIZE || '50MB',
    allowedAudioTypes: (process.env.ALLOWED_AUDIO_TYPES || 'audio/mpeg,audio/wav,audio/flac').split(','),
    allowedImageTypes: (process.env.ALLOWED_IMAGE_TYPES || 'image/jpeg,image/png,image/gif').split(',')
  },

  // 日志配置
  log: {
    level: process.env.LOG_LEVEL || 'info',
    filePath: process.env.LOG_FILE_PATH || 'logs'
  },

  // 安全配置
  security: {
    bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS) || 12,
    rateLimitMax: parseInt(process.env.RATE_LIMIT_MAX) || 100,
    rateLimitDuration: parseInt(process.env.RATE_LIMIT_DURATION) || 900000 // 15分钟
  },

  // CORS配置
  cors: {
    origin: process.env.CORS_ORIGIN || ['http://localhost:8080', 'http://10.136.74.177:8080']
  },

  // 第三方服务配置
  qiniu: {
    accessKey: process.env.QINIU_ACCESS_KEY || '',
    secretKey: process.env.QINIU_SECRET_KEY || '',
    bucket: process.env.QINIU_BUCKET || ''
  }
}

module.exports = config 