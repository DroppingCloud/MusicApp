/**
 * API响应统一格式化工具
 */

/**
 * 成功响应格式
 * @param {Object} ctx - Koa上下文
 * @param {*} data - 响应数据
 * @param {string} message - 响应消息
 * @param {number} code - 状态码
 * @param {Object} pagination - 分页信息
 */
const success = (ctx, data = null, message = '操作成功', code = 200, pagination = null) => {
  const response = {
    success: true,
    code,
    message,
    data,
    timestamp: new Date().toISOString()
  }

  if (pagination) {
    response.pagination = pagination
  }

  ctx.status = code
  ctx.body = response
}

/**
 * 错误响应格式
 * @param {Object} ctx - Koa上下文
 * @param {string} message - 错误消息
 * @param {number} code - 错误状态码
 * @param {string} errorCode - 错误代码
 * @param {Array} errors - 详细错误信息
 */
const error = (ctx, message = '操作失败', code = 400, errorCode = null, errors = null) => {
  const response = {
    success: false,
    code,
    message,
    timestamp: new Date().toISOString()
  }

  if (errorCode) {
    response.errorCode = errorCode
  }

  if (errors) {
    response.errors = errors
  }

  ctx.status = code
  ctx.body = response
}

/**
 * 分页信息格式化
 * @param {number} page - 当前页码
 * @param {number} limit - 每页数量
 * @param {number} total - 总记录数
 */
const pagination = (page, limit, total) => {
  const totalPages = Math.ceil(total / limit)
  return {
    page: parseInt(page),
    limit: parseInt(limit),
    total: parseInt(total),
    totalPages,
    hasNext: page < totalPages,
    hasPrev: page > 1
  }
}

/**
 * 列表响应（带分页）
 * @param {Object} ctx - Koa上下文
 * @param {Array} list - 数据列表
 * @param {number} page - 当前页码
 * @param {number} limit - 每页数量
 * @param {number} total - 总记录数
 * @param {string} message - 响应消息
 */
const list = (ctx, list, page, limit, total, message = '获取列表成功') => {
  const paginationInfo = pagination(page, limit, total)
  success(ctx, list, message, 200, paginationInfo)
}

module.exports = {
  success,
  error,
  pagination,
  list
} 