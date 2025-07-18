const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 歌曲模型
 */
const Song = sequelize.define('Song', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
    comment: '歌曲ID'
  },
  title: {
    type: DataTypes.STRING(128),
    allowNull: false,
    comment: '歌曲名',
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
  album_id: {
    type: DataTypes.BIGINT,
    allowNull: true,
    comment: '专辑ID'
  },
  audio_url: {
    type: DataTypes.STRING(255),
    allowNull: false,
    comment: '音频文件URL',
    validate: {
      notEmpty: true,
      len: [1, 255]
    }
  },
  cover_url: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '封面URL'
  },
  duration: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: '时长（秒）',
    validate: {
      min: 0
    }
  },
  release_date: {
    type: DataTypes.DATEONLY,
    allowNull: true,
    comment: '发行日期'
  }
}, {
  tableName: 'song',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_song_artist',
      fields: ['artist_id']
    },
    {
      name: 'idx_song_album',
      fields: ['album_id']
    },
    {
      name: 'idx_song_title',
      fields: ['title']
    }
  ]
})

module.exports = Song 