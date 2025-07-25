const NoteService = require('../services/note-service')
const { success, list } = require('../utils/response')
const { AppError } = require('../middleware/error-handler')

/**
 * 笔记控制器
 */
class NoteController {
  /**
   * 获取笔记列表
   */
  static async getNoteList(ctx) {
    const { page = 1, limit = 20 } = ctx.query
    const userId = ctx.state.user ? ctx.state.user.id : null // 获取当前用户ID（可能为null）
    const result = await NoteService.getNoteList(page, limit, userId)
    
    list(ctx, result.list, page, limit, result.total, '获取笔记列表成功')
  }

  /**
   * 根据ID获取笔记详情
   */
  static async getNoteById(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user ? ctx.state.user.id : null // 获取当前用户ID（可能为null）
    const note = await NoteService.getNoteById(id, userId)
    
    if (!note) {
      throw new AppError('笔记不存在', 404, 'NOTE_NOT_FOUND')
    }

    success(ctx, note, '获取笔记详情成功')
  }

  /**
   * 创建笔记
   */
  static async createNote(ctx) {
    const userId = ctx.state.user.id
    const { title, content, song_id } = ctx.request.body
    const files = ctx.files || [] // 上传的图片文件数组
    
    const noteData = {
      user_id: userId,
      title,
      content,
      song_id: song_id ? parseInt(song_id) : null,
      images: files // 传递文件而不是URL
    }
    
    const note = await NoteService.createNote(noteData)
    success(ctx, note, '创建笔记成功', 201)
  }

  /**
   * 更新笔记
   */
  static async updateNote(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    const { title, content } = ctx.request.body
    const files = ctx.files || [] // 上传的图片文件数组
    
    const updateData = {
      title,
      content,
      images: files // 传递文件而不是URL
    }
    
    const note = await NoteService.updateNote(id, userId, updateData)
    success(ctx, note, '更新笔记成功')
  }

  /**
   * 删除笔记
   */
  static async deleteNote(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    
    await NoteService.deleteNote(id, userId)
    success(ctx, null, '删除笔记成功')
  }

  /**
   * 点赞笔记
   */
  static async likeNote(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    
    await NoteService.likeNote(id, userId)
    success(ctx, null, '点赞成功')
  }

  /**
   * 取消点赞笔记
   */
  static async unlikeNote(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    
    await NoteService.unlikeNote(id, userId)
    success(ctx, null, '取消点赞成功')
  }

  /**
   * 获取笔记评论
   */
  static async getNoteComments(ctx) {
    const { id } = ctx.params
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await NoteService.getNoteComments(id, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取笔记评论成功')
  }

  /**
   * 添加笔记评论
   */
  static async addNoteComment(ctx) {
    const { id } = ctx.params
    const userId = ctx.state.user.id
    const { content } = ctx.request.body
    
    const comment = await NoteService.addNoteComment(id, userId, content)
    success(ctx, comment, '添加评论成功', 201)
  }

  /**
   * 获取我的笔记
   */
  static async getMyNotes(ctx) {
    const userId = ctx.state.user.id
    const { page = 1, limit = 20 } = ctx.query
    
    const result = await NoteService.getMyNotes(userId, page, limit)
    list(ctx, result.list, page, limit, result.total, '获取我的笔记成功')
  }

  /**
   * 上传笔记图片
   */
  static async uploadNoteImage(ctx) {
    const file = ctx.file
    
    if (!file) {
      throw new AppError('请选择要上传的图片', 400, 'NO_FILE_SELECTED')
    }

    const imageUrl = await NoteService.uploadNoteImage(file)
    success(ctx, { imageUrl }, '上传图片成功', 201)
  }
}

module.exports = NoteController 