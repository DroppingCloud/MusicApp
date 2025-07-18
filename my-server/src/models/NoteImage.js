const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 笔记图片模型
 */
const NoteImage = sequelize.define('NoteImage', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true
  },
  note_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '所属笔记ID'
  },
  image_url: {
    type: DataTypes.STRING(255),
    allowNull: false,
    comment: '图片URL'
  },
  order_index: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    comment: '顺序'
  }
}, {
  tableName: 'note_image',
  underscored: true,
  timestamps: false
})

module.exports = NoteImage 