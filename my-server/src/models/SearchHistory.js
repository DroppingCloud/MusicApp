const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 搜索历史模型
 */
const SearchHistory = sequelize.define('SearchHistory', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
    comment: '搜索历史ID'
  },
  user_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '用户ID'
  },
  keyword: {
    type: DataTypes.STRING(128),
    allowNull: false,
    comment: '搜索关键字',
    validate: {
      notEmpty: true,
      len: [1, 128]
    }
  },
  search_time: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    comment: '搜索时间'
  }
}, {
  tableName: 'search_history',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_search_user_time',
      fields: ['user_id', 'search_time']
    },
    {
      name: 'idx_search_keyword',
      fields: ['keyword']
    }
  ]
})

module.exports = SearchHistory 