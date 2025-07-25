const Router = require('koa-router')
const NoteController = require('../controllers/note-controller')
const { auth, optionalAuth } = require('../middleware/auth')
const { uploadRateLimit } = require('../middleware/rate-limit')
const { imageUpload, singleImageUpload } = require('../middleware/upload')

const router = new Router()

/**
 * 笔记相关路由
 */

// 获取笔记列表
router.get('/list', optionalAuth, NoteController.getNoteList)

// 获取笔记详情
router.get('/detail/:id', optionalAuth, NoteController.getNoteById)

// 创建笔记
router.post('/create', auth, /* uploadRateLimit, */ imageUpload, NoteController.createNote)

// 更新笔记
router.post('/update/:id', auth, /* uploadRateLimit, */ imageUpload, NoteController.updateNote)

// 删除笔记
router.post('/remove/:id', auth, NoteController.deleteNote)

// 获取我的笔记
router.get('/my', auth, NoteController.getMyNotes)

// 上传笔记图片
router.post('/upload-image', auth, /* uploadRateLimit, */ singleImageUpload, NoteController.uploadNoteImage)

module.exports = router 