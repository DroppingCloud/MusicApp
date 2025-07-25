const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 用户喜欢的歌曲模型
 */
const UserFavorite = sequelize.define('UserFavorite', {
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
  song_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '歌曲ID'
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'user_favorite',
  underscored: true,
  timestamps: false
})

module.exports = UserFavorite 