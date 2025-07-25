const mysql = require('mysql2/promise')
const config = require('./index')
const { logger } = require('../utils/logger')

// 创建数据库连接池
const pool = mysql.createPool({
  host: config.database.host,
  port: config.database.port,
  user: config.database.user,
  password: config.database.password,
  database: config.database.database,
  waitForConnections: true,
  connectionLimit: config.database.connectionLimit,
  queueLimit: 0,
  acquireTimeout: config.database.acquireTimeout,
  timeout: config.database.timeout,
  charset: 'utf8mb4'
})

// 测试数据库连接
const testConnection = async () => {
  try {
    const connection = await pool.getConnection()
    logger.info('数据库连接成功')
    connection.release()
    return true
  } catch (error) {
    logger.error('数据库连接失败:', error.message)
    return false
  }
}

// 执行查询
const query = async (sql, params = []) => {
  try {
    const [rows] = await pool.execute(sql, params)
    return rows
  } catch (error) {
    logger.error('数据库查询错误:', error.message)
    throw error
  }
}

// 执行事务
const transaction = async (callback) => {
  const connection = await pool.getConnection()
  try {
    await connection.beginTransaction()
    const result = await callback(connection)
    await connection.commit()
    return result
  } catch (error) {
    await connection.rollback()
    throw error
  } finally {
    connection.release()
  }
}

module.exports = {
  pool,
  query,
  transaction,
  testConnection
} 