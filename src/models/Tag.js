const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 标签模型
 */
const Tag = sequelize.define('Tag', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
    comment: '标签ID'
  },
  name: {
    type: DataTypes.STRING(64),
    allowNull: false,
    unique: true,
    comment: '标签名，如流行、摇滚',
    validate: {
      notEmpty: true,
      len: [1, 64]
    }
  },
  type: {
    type: DataTypes.STRING(32),
    allowNull: false,
    defaultValue: 'genre',
    comment: '标签类型: genre/scene/mood',
    validate: {
      isIn: [['genre', 'scene', 'mood']]
    }
  }
}, {
  tableName: 'tag',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_tag_name',
      fields: ['name']
    },
    {
      name: 'idx_tag_type',
      fields: ['type']
    }
  ]
})

module.exports = Tag 