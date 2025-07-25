const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 歌单-歌曲关联模型
 */
const PlaylistSong = sequelize.define('PlaylistSong', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
    comment: '关联ID'
  },
  playlist_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '歌单ID'
  },
  song_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '歌曲ID'
  },
  order_index: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    comment: '歌曲排序'
  }
}, {
  tableName: 'playlist_song',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_playlist_song_playlist',
      fields: ['playlist_id']
    },
    {
      name: 'idx_playlist_song_song',
      fields: ['song_id']
    },
    {
      name: 'idx_playlist_song_order',
      fields: ['playlist_id', 'order_index']
    }
  ]
})

module.exports = PlaylistSong 