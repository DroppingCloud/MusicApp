const rateLimit = require('koa-ratelimit')
const config = require('../config')

// 使用内存存储

/**
 * 基础限流配置
 */
const baseRateLimit = rateLimit({
  driver: 'memory',
  db: new Map(),
  duration: config.security.rateLimitDuration, // 15分钟
  errorMessage: '请求过于频繁，请稍后再试',
  id: (ctx) => ctx.ip,
  headers: {
    remaining: 'Rate-Limit-Remaining',
    reset: 'Rate-Limit-Reset',
    total: 'Rate-Limit-Total'
  },
  max: config.security.rateLimitMax, // 默认100次/15分钟
  disableHeader: false
})

/**
 * 登录接口限流
 */
const authRateLimit = rateLimit({
  driver: 'memory',
  db: new Map(),
  duration: 1000, // 1秒钟
  errorMessage: '登录尝试过于频繁，请1秒后再试',
  id: (ctx) => ctx.ip,
  max: 5, // 5次/1秒
  disableHeader: false
})

/**
 * 上传接口限流
 */
const uploadRateLimit = rateLimit({
  driver: 'memory',
  db: new Map(),
  duration: 60 * 1000, // 1分钟
  errorMessage: '上传过于频繁，请稍后再试',
  id: (ctx) => ctx.ip,
  max: 10, // 10次/1分钟
  disableHeader: false
})

/**
 * 搜索接口限流
 */
const searchRateLimit = rateLimit({
  driver: 'memory',
  db: new Map(),
  duration: 60 * 1000, // 1分钟
  errorMessage: '搜索过于频繁，请稍后再试',
  id: (ctx) => ctx.ip,
  max: 30, // 30次/1分钟
  disableHeader: false
})

module.exports = {
  baseRateLimit,
  authRateLimit,
  uploadRateLimit,
  searchRateLimit
} 