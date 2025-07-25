const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 歌单模型
 */
const Playlist = sequelize.define('Playlist', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
    comment: '歌单ID'
  },
  title: {
    type: DataTypes.STRING(128),
    allowNull: false,
    comment: '歌单名',
    validate: {
      notEmpty: true,
      len: [1, 128]
    }
  },
  user_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '创建者用户ID'
  },
  cover_url: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '封面URL'
  },
  description: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: '描述'
  },
  create_time: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    comment: '创建时间'
  }
}, {
  tableName: 'playlist',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_playlist_user',
      fields: ['user_id']
    },
    {
      name: 'idx_playlist_title',
      fields: ['title']
    }
  ]
})

module.exports = Playlist 