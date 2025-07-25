const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 艺术家模型
 */
const Artist = sequelize.define('Artist', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
    comment: '艺术家ID'
  },
  name: {
    type: DataTypes.STRING(64),
    allowNull: false,
    comment: '艺术家名',
    validate: {
      notEmpty: true,
      len: [1, 64]
    }
  },
  avatar: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: '头像URL'
  },
  bio: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '简介'
  }
}, {
  tableName: 'artist',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_artist_name',
      fields: ['name']
    }
  ]
})

module.exports = Artist 