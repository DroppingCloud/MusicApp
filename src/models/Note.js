const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 音乐笔记模型
 */
const Note = sequelize.define('Note', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '发布者ID'
  },
  title: {
    type: DataTypes.STRING(128),
    allowNull: true,
    comment: '笔记标题'
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '正文内容'
  },
  song_id: {
    type: DataTypes.BIGINT,
    allowNull: true,
    comment: '关联音乐ID'
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'note',
  underscored: true,
  timestamps: false
})

module.exports = Note 