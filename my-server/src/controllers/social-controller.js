const SocialService = require('../services/social-service')
const FollowService = require('../services/follow-service')
const { success, list } = require('../utils/response')
const { AppError } = require('../middleware/error-handler')

/**
 * 社交控制器
 */
class SocialController {
  /**
   * 关注用户
   */
  static async followUser(ctx) {
    const { userId } = ctx.params
    const followerId = ctx.state.user.id
    
    await FollowService.followUser(followerId, parseInt(userId))
    success(ctx, null, '关注成功')
  }

  /**
   * 取消关注用户
   */
  static async unfollowUser(ctx) {
    const { userId } = ctx.params
    const followerId = ctx.state.user.id
    
    await FollowService.unfollowUser(followerId, parseInt(userId))
    success(ctx, null, '取消关注成功')
  }

  /**
   * 获取关注列表
   */
  static async getFollowingList(ctx) {
    const { userId } = ctx.params
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await FollowService.getFollowingList(userId, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取关注列表成功')
  }

  /**
   * 获取粉丝列表
   */
  static async getFollowersList(ctx) {
    const { userId } = ctx.params
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await FollowService.getFollowersList(userId, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取粉丝列表成功')
  }

  /**
   * 获取用户关注统计
   */
  static async getUserFollowStats(ctx) {
    const { userId } = ctx.params
    
    const stats = await FollowService.getUserFollowStats(userId)
    success(ctx, stats, '获取关注统计成功')
  }

  /**
   * 检查是否关注了某用户
   */
  static async checkFollowing(ctx) {
    const { userId } = ctx.params
    const followerId = ctx.state.user.id
    
    const isFollowing = await FollowService.isFollowing(followerId, parseInt(userId))
    success(ctx, { is_following: isFollowing }, '检查关注状态成功')
  }

  /**
   * 获取互相关注的好友列表
   */
  static async getMutualFriends(ctx) {
    const userId = ctx.state.user.id
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await FollowService.getMutualFriends(userId, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取好友列表成功')
  }

  /**
   * 点赞
   */
  static async addLike(ctx) {
    const userId = ctx.state.user.id
    const { type, targetId } = ctx.request.body
    
    await SocialService.addLike(userId, type, targetId)
    success(ctx, null, '点赞成功')
  }

  /**
   * 取消点赞
   */
  static async removeLike(ctx) {
    const userId = ctx.state.user.id
    const { type, targetId } = ctx.request.body
    
    await SocialService.removeLike(userId, type, targetId)
    success(ctx, null, '取消点赞成功')
  }

  /**
   * 获取用户点赞列表
   */
  static async getUserLikes(ctx) {
    const userId = ctx.state.user.id
    const { type, page = 1, limit = 20 } = ctx.query
    
    const result = await SocialService.getUserLikes(userId, type, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取点赞列表成功')
  }

  /**
   * 获取评论列表
   */
  static async getCommentList(ctx) {
    const { type, targetId, page = 1, limit = 20 } = ctx.query
    
    const result = await SocialService.getCommentList(type, targetId, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取评论列表成功')
  }

  /**
   * 添加评论
   */
  static async addComment(ctx) {
    const userId = ctx.state.user.id
    const { type, targetId, content, parentId } = ctx.request.body
    
    const comment = await SocialService.addComment(userId, type, targetId, content, parentId)
    success(ctx, comment, '添加评论成功', 201)
  }

  /**
   * 删除评论
   */
  static async deleteComment(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    
    await SocialService.deleteComment(id, userId)
    success(ctx, null, '删除评论成功')
  }

  /**
   * 获取聊天会话列表
   */
  static async getChatList(ctx) {
    const userId = ctx.state.user.id
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await SocialService.getChatList(userId, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取聊天列表成功')
  }

  /**
   * 获取聊天消息
   */
  static async getChatMessages(ctx) {
    const { userId: targetUserId } = ctx.params
    const currentUserId = ctx.state.user.id
    const { page = 1, limit = 50 } = ctx.query
    
    const result = await SocialService.getChatMessages(currentUserId, targetUserId, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取聊天记录成功')
  }

  /**
   * 发送消息
   */
  static async sendMessage(ctx) {
    const { userId: targetUserId } = ctx.params
    const senderId = ctx.state.user.id
    const { content } = ctx.request.body
    
    const message = await SocialService.sendMessage(senderId, targetUserId, content)
    success(ctx, message, '发送消息成功', 201)
  }

  /**
   * 批量检查点赞状态
   */
  static async batchCheckLiked(ctx) {
    const userId = ctx.state.user.id
    const { type, targetIds } = ctx.request.body
    
    if (!Array.isArray(targetIds)) {
      throw new AppError('targetIds必须是数组', 400)
    }
    
    const result = await SocialService.batchCheckLiked(userId, type, targetIds)
    success(ctx, result, '批量检查点赞状态成功')
  }

  /**
   * 获取对象点赞统计
   */
  static async getLikeStats(ctx) {
    const { type, targetIds } = ctx.request.body
    
    if (!Array.isArray(targetIds)) {
      throw new AppError('targetIds必须是数组', 400)
    }
    
    const stats = await SocialService.getLikeStats(type, targetIds)
    success(ctx, stats, '获取点赞统计成功')
  }
}

module.exports = SocialController 