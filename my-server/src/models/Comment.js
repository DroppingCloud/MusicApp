const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 评论模型（支持多对象）
 */
const Comment = sequelize.define('Comment', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '评论用户ID'
  },
  type: {
    type: DataTypes.STRING(32),
    allowNull: false,
    comment: '评论对象类型:song/note/playlist'
  },
  target_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '评论对象ID'
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
    comment: '评论内容'
  },
  parent_id: {
    type: DataTypes.BIGINT,
    allowNull: true,
    comment: '父评论ID'
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'comment',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_comment_target',
      fields: ['type', 'target_id']
    },
    {
      name: 'idx_comment_user',
      fields: ['user_id']
    }
  ]
})

module.exports = Comment 