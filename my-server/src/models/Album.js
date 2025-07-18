const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 专辑模型
 */
const Album = sequelize.define('Album', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
    comment: '专辑ID'
  },
  title: {
    type: DataTypes.STRING(128),
    allowNull: false,
    comment: '专辑名',
    validate: {
      notEmpty: true,
      len: [1, 128]
    }
  },
  artist_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '歌手ID'
  },
  cover_url: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '封面URL'
  },
  publish_time: {
    type: DataTypes.DATEONLY,
    allowNull: true,
    comment: '发行时间'
  }
}, {
  tableName: 'album',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_album_artist',
      fields: ['artist_id']
    },
    {
      name: 'idx_album_title',
      fields: ['title']
    }
  ]
})

module.exports = Album 