const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 用户播放历史模型
 */
const UserHistory = sequelize.define('UserHistory', {
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
  play_time: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    comment: '播放时间'
  }
}, {
  tableName: 'user_history',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_history_user_time',
      fields: ['user_id', 'play_time']
    },
    {
      name: 'idx_history_song',
      fields: ['song_id']
    }
  ]
})

module.exports = UserHistory 