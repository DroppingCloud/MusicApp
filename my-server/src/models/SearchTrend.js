const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 搜索趋势模型
 */
const SearchTrend = sequelize.define('SearchTrend', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
    comment: '趋势ID'
  },
  keyword: {
    type: DataTypes.STRING(128),
    allowNull: false,
    comment: '热词',
    validate: {
      notEmpty: true,
      len: [1, 128]
    }
  },
  count: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    comment: '出现次数',
    validate: {
      min: 0
    }
  },
  updated_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    comment: '更新时间'
  }
}, {
  tableName: 'search_trend',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_search_trend_keyword',
      fields: ['keyword']
    },
    {
      name: 'idx_search_trend_count',
      fields: ['count']
    },
    {
      name: 'idx_search_trend_updated',
      fields: ['updated_at']
    }
  ]
})

module.exports = SearchTrend 