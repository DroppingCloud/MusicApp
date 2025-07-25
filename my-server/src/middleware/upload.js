const multer = require('@koa/multer')
const path = require('path')
const fs = require('fs')
const { v4: uuidv4 } = require('uuid')
const config = require('../config')

// 确保上传目录存在
const uploadsDir = path.join(__dirname, '../../uploads')
const avatarsDir = path.join(uploadsDir, 'avatars')
const imagesDir = path.join(uploadsDir, 'images')

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true })
}

if (!fs.existsSync(avatarsDir)) {
  fs.mkdirSync(avatarsDir, { recursive: true })
}

if (!fs.existsSync(imagesDir)) {
  fs.mkdirSync(imagesDir, { recursive: true })
}

// 文件过滤器
const fileFilter = (req, file, cb) => {
  // 检查文件类型
  if (config.upload.allowedImageTypes.includes(file.mimetype)) {
    cb(null, true)
  } else {
    cb(new Error('不支持的文件类型，仅支持: ' + config.upload.allowedImageTypes.join(', ')), false)
  }
}

// 头像上传配置
const avatarStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, avatarsDir)
  },
  filename: function (req, file, cb) {
    // 生成唯一文件名
    const uniqueSuffix = uuidv4()
    const ext = path.extname(file.originalname)
    cb(null, `avatar_${uniqueSuffix}${ext}`)
  }
})

// 普通图片上传配置
const imageStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, imagesDir)
  },
  filename: function (req, file, cb) {
    // 生成唯一文件名
    const uniqueSuffix = uuidv4()
    const ext = path.extname(file.originalname)
    cb(null, `image_${uniqueSuffix}${ext}`)
  }
})

// 头像上传中间件
const avatarUpload = multer({
  storage: avatarStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB
  }
}).single('avatar')

// 图片上传中间件（支持多张图片）
const imageUpload = multer({
  storage: imageStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB per file
    files: 9 // 最多9张图片
  }
}).array('images', 9)

// 单张图片上传中间件
const singleImageUpload = multer({
  storage: imageStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
}).single('image')

module.exports = {
  avatarUpload,
  imageUpload,
  singleImageUpload
} 