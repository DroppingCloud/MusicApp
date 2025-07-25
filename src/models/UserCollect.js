const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 用户收藏歌单模型
 */
const UserCollect = sequelize.define('UserCollect', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '用户ID'
  },
  playlist_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '歌单ID'
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'user_collect',
  underscored: true,
  timestamps: false
})

module.exports = UserCollect 