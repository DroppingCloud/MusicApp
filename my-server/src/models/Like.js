const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 点赞模型（支持多对象）
 */
const Like = sequelize.define('Like', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '点赞用户ID'
  },
  type: {
    type: DataTypes.STRING(32),
    allowNull: false,
    comment: '点赞对象类型:note/comment'
  },
  target_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '被点赞对象ID'
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'like',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_like_target',
      fields: ['type', 'target_id']
    },
    {
      name: 'idx_like_user',
      fields: ['user_id']
    }
  ]
})

module.exports = Like 