const { DataTypes, Op } = require('sequelize')
const bcrypt = require('bcryptjs')
const { sequelize } = require('../config/sequelize')

/**
 * 用户模型
 */
const User = sequelize.define('User', {
  id: {
    type: DataTypes.BIGINT,
    primaryKey: true,
    autoIncrement: true,
    comment: '用户ID'
  },
  username: {
    type: DataTypes.STRING(64),
    allowNull: false,
    unique: true,
    comment: '用户名',
    validate: {
      len: [2, 64],
      notEmpty: true
    }
  },
  password: {
    type: DataTypes.STRING(128),
    allowNull: false,
    comment: '密码',
    validate: {
      len: [6, 128],
      notEmpty: true
    }
  },
  email: {
    type: DataTypes.STRING(128),
    allowNull: true,
    unique: true,
    comment: '邮箱',
    validate: {
      isEmail: true
    }
  },
  avatar: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: '头像URL'
  },
  background: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: '背景图片URL'
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    comment: '注册时间'
  }
}, {
  tableName: 'user',
  underscored: true,
  timestamps: false, 
  indexes: [
    {
      name: 'idx_user_username',
      fields: ['username']
    },
    {
      name: 'idx_user_email',
      fields: ['email']
    }
  ],
  hooks: {
    // 创建前加密密码
    beforeCreate: async (user) => {
      if (user.password) {
        user.password = await bcrypt.hash(user.password, 12)
      }
    },
    // 更新前加密密码
    beforeUpdate: async (user) => {
      if (user.changed('password')) {
        user.password = await bcrypt.hash(user.password, 12)
      }
    }
  }
})

// 密码比较
User.prototype.comparePassword = async function(password) {
  return await bcrypt.compare(password, this.password)
}

// 重写 toJSON 方法，自动排除敏感字段
User.prototype.toJSON = function() {
  const values = Object.assign({}, this.get())
  delete values.password
  return values
}

module.exports = User 