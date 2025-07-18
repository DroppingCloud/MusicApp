const { Sequelize } = require('sequelize')
const config = require('./index')
const { logger } = require('../utils/logger')

// 创建Sequelize实例
const sequelize = new Sequelize(
  config.database.database,
  config.database.user,
  config.database.password,
  {
    host: config.database.host,
    port: config.database.port,
    dialect: 'mysql',
    dialectOptions: {
      charset: 'utf8mb4'
    },
    pool: {
      max: config.database.connectionLimit,
      min: 0,
      acquire: config.database.acquireTimeout,
      idle: 10000
    },
    logging: config.env === 'development' ? (sql) => logger.debug(sql) : false,
    timezone: '+08:00'
  }
)

// 测试数据库连接
const testConnection = async () => {
  try {
    await sequelize.authenticate()
    logger.info('Sequelize数据库连接成功')
    return true
  } catch (error) {
    logger.error('Sequelize数据库连接失败:', error.message)
    return false
  }
}

// 同步数据库
const syncDatabase = async (force = false) => {
  try {
    await sequelize.sync({ force, alter: !force })
    logger.info(`数据库同步成功 (force: ${force})`)
  } catch (error) {
    logger.error('数据库同步失败:', error.message)
    throw error
  }
}

module.exports = {
  sequelize,
  testConnection,
  syncDatabase
} 