const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 歌曲统计模型
 */
const SongStat = sequelize.define('SongStat', {
  song_id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    comment: '歌曲ID'
  },
  play_count: {
    type: DataTypes.BIGINT,
    allowNull: false,
    defaultValue: 0,
    comment: '播放次数'
  },
  like_count: {
    type: DataTypes.BIGINT,
    allowNull: false,
    defaultValue: 0,
    comment: '点赞次数'
  },
  comment_count: {
    type: DataTypes.BIGINT,
    allowNull: false,
    defaultValue: 0,
    comment: '评论数'
  }
}, {
  tableName: 'song_stat',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_song_stat_play_count',
      fields: ['play_count']
    },
    {
      name: 'idx_song_stat_like_count',
      fields: ['like_count']
    }
  ]
})

module.exports = SongStat 