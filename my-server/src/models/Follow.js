const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 用户关注关系模型
 */
const Follow = sequelize.define('Follow', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true
  },
  follower_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '粉丝ID（关注者）'
  },
  followed_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '被关注者ID'
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'follow',
  underscored: true,
  timestamps: false,
  indexes: [
    {
      name: 'idx_follow_follower',
      fields: ['follower_id']
    },
    {
      name: 'idx_follow_followed',
      fields: ['followed_id']
    }
  ]
})

module.exports = Follow 