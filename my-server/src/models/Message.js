const { DataTypes } = require('sequelize')
const { sequelize } = require('../config/sequelize')

/**
 * 消息模型
 */
const Message = sequelize.define('Message', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true
  },
  chat_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '会话ID'
  },
  sender_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '发送者ID'
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
    comment: '消息内容'
  },
  send_time: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    comment: '发送时间'
  }
}, {
  tableName: 'message',
  underscored: true,
  timestamps: false
})

module.exports = Message 