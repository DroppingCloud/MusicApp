const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 聊天会话模型
 */
const Chat = sequelize.define('Chat', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true
  },
  user1_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '用户1'
  },
  user2_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '用户2'
  },
  last_msg: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: '最后一条消息摘要'
  },
  last_time: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '最后消息时间'
  }
}, {
  tableName: 'chat',
  underscored: true,
  timestamps: false
})

module.exports = Chat 