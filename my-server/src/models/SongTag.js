const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 歌曲-标签关联模型
 */
const SongTag = sequelize.define('SongTag', {
  song_id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    comment: '歌曲ID'
  },
  tag_id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    comment: '标签ID'
  }
}, {
  tableName: 'song_tag',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_song_tag_song',
      fields: ['song_id']
    },
    {
      name: 'idx_song_tag_tag',
      fields: ['tag_id']
    }
  ]
})

module.exports = SongTag 