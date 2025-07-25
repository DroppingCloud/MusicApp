# 用户模块API测试文档

## 目录
- [认证相关接口](#认证相关接口)
  - [用户注册](#用户注册)
  - [用户登录](#用户登录)
  - [刷新令牌](#刷新令牌)
  - [退出登录](#退出登录)
  - [获取当前用户信息](#获取当前用户信息)
- [用户管理接口](#用户管理接口)
  - [获取用户信息](#获取用户信息)
  - [获取用户公开信息](#获取用户公开信息)
  - [更新用户信息](#更新用户信息)
  - [获取用户列表](#获取用户列表)
- [用户行为接口](#用户行为接口)
  - [播放历史](#播放历史)
  - [喜欢歌曲](#喜欢歌曲)
  - [收藏歌单](#收藏歌单)
  - [用户关注](#用户关注)
- [其他接口](#其他接口)
  - [头像上传](#头像上传)
  - [用户设置](#用户设置)

## 基础信息

### 接口基础URL
```
http://localhost:3000/api/v1
```

### 认证说明
- 大部分接口需要JWT Token认证
- 请求头中需要包含：`Authorization: Bearer <token>`
- Token有效期为7天，刷新Token有效期为30天

### 通用响应格式
```json
{
  "success": true,
  "code": 200,
  "message": "操作成功",
  "data": {},
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## 认证相关接口

### 用户注册 ✅

**接口地址**: `POST /auth/register`

**请求格式**: `multipart/form-data`

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名（3-50字符） |
| password | string | 是 | 密码（6-20字符） |
| email | string | 否 | 邮箱地址 |
| background | string | 否 | 背景图片URL |
| avatar | file | 否 | 头像图片文件 |

**头像文件要求**:
- 支持格式：JPEG、PNG、GIF
- 文件大小：最大5MB
- 字段名：`avatar`

**成功响应**:
```json
{
  "success": true,
  "code": 201,
  "message": "注册成功",
  "data": {
    "user": {
      "id": 1,
      "username": "testuser",
      "email": "test@example.com",
      "avatar": "/avatars/avatar_uuid.jpg",
      "background": null,
      "created_at": "2024-01-01T00:00:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**测试用例**:
```bash
# 带头像的注册
curl -X POST "http://localhost:3000/api/v1/auth/register" \
  -F "username=testuser" \
  -F "password=123456" \
  -F "email=test@example.com" \
  -F "avatar=@/path/to/avatar.jpg"

# 不带头像的注册
curl -X POST "http://localhost:3000/api/v1/auth/register" \
  -F "username=testuser2" \
  -F "password=123456" \
  -F "email=test2@example.com"

# 用户名已存在
curl -X POST "http://localhost:3000/api/v1/auth/register" \
  -F "username=testuser" \
  -F "password=123456"

# 参数验证失败
curl -X POST "http://localhost:3000/api/v1/auth/register" \
  -F "username=ab" \
  -F "password=123"
```

### 用户登录 ✅

**接口地址**: `POST /auth/login`

**请求参数**:
```json
{
  "loginField": "testuser",
  "password": "123456"
}
```

**参数说明**:
- `loginField` (必填): 用户名或邮箱
- `password` (必填): 密码

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "登录成功",
  "data": {
    "user": {
      "id": 1,
      "username": "testuser",
      "email": "test@example.com",
      "avatar": "https://example.com/avatar.jpg",
      "background": "https://example.com/bg.jpg",
      "created_at": "2024-01-01T00:00:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**测试用例**:
```bash
# 用户名登录
curl -X POST "http://localhost:3000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "loginField": "testuser",
    "password": "123456"
  }'

# 邮箱登录
curl -X POST "http://localhost:3000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "loginField": "test@example.com",
    "password": "123456"
  }'

# 登录失败
curl -X POST "http://localhost:3000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "loginField": "testuser",
    "password": "wrongpassword"
  }'
```

### 刷新令牌 ✅

**接口地址**: `POST /auth/refresh`

**请求参数**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "令牌刷新成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

### 退出登录 ✅

**接口地址**: `POST /auth/logout`

**请求头**: `Authorization: Bearer <token>`

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "退出成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/auth/logout" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 获取当前用户信息 ✅

**接口地址**: `GET /auth/me`

**请求头**: `Authorization: Bearer <token>`

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取用户信息成功",
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "avatar": "https://example.com/avatar.jpg",
    "background": "https://example.com/bg.jpg",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/auth/me" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## 用户管理接口

### 获取用户信息 ✅ (效果同 ```GET /auth/me``` 一致)

**接口地址**: `GET /user/info`

**请求头**: `Authorization: Bearer <token>`

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取用户信息成功",
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "avatar": "https://example.com/avatar.jpg",
    "background": "https://example.com/bg.jpg",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/user/info" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 获取用户公开信息 ✅

**接口地址**: `GET /user/profile/:id`

**路径参数**:
- `id`: 用户ID

**请求头**: `Authorization: Bearer <token>` (可选)

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取用户信息成功",
  "data": {
    "id": 1,
    "username": "testuser",
    "avatar": "https://example.com/avatar.jpg",
    "background": "https://example.com/bg.jpg",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

**测试用例**:
```bash
# 不需要认证
curl -X GET "http://localhost:3000/api/v1/user/profile/1"

# 带认证
curl -X GET "http://localhost:3000/api/v1/user/profile/1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 更新用户信息 ✅

**接口地址**: `POST /user/update`

**请求头**: `Authorization: Bearer <token>`

**请求参数**:
```json
{
  "username": "newusername",
  "email": "newemail@example.com",
  "background": "https://example.com/new-bg.jpg"
}
```

**注意**: 头像现在通过专门的头像上传接口处理，不在此接口中更新。

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "更新用户信息成功",
  "data": {
    "id": 1,
    "username": "newusername",
    "email": "newemail@example.com",
    "avatar": "/avatars/avatar_existing_uuid.jpg",
    "background": "https://example.com/new-bg.jpg",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/user/update" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newusername",
    "email": "newemail@example.com"
  }'
```

### 获取用户列表 ✅

**接口地址**: `GET /user/list`

**请求头**: `Authorization: Bearer <token>`

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20，最大100
- `keyword`: 搜索关键词
- `orderBy`: 排序字段，可选值：created_at, username
- `order`: 排序方式，可选值：ASC, DESC

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取用户列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "username": "testuser",
        "email": "test@example.com",
        "avatar": "/avatars/avatar_uuid.jpg",
        "background": "https://example.com/bg.jpg",
        "created_at": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
# 获取第一页
curl -X GET "http://localhost:3000/api/v1/user/list?page=1&limit=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 搜索用户
curl -X GET "http://localhost:3000/api/v1/user/list?keyword=test" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## 用户行为接口

### 播放历史

#### 获取播放历史 ✅

**接口地址**: `GET /user/history`

**请求头**: `Authorization: Bearer <token>`

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取播放历史成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "song_id": 101,
        "play_time": "2024-01-01T00:00:00.000Z",
        "created_at": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

### 喜欢歌曲

#### 获取喜欢的歌曲 ✅

**接口地址**: `GET /user/favorites`

**请求头**: `Authorization: Bearer <token>`

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取喜欢的歌曲成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "song_id": 101,
        "created_at": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

#### 添加歌曲到喜欢列表

**接口地址**: `POST /user/like-song`

**请求头**: `Authorization: Bearer <token>`

**请求参数**:
```json
{
  "songId": 101
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "添加到喜欢列表成功",
  "data": null
}
```

#### 从喜欢列表移除歌曲

**接口地址**: `POST /user/unlike-song`

**请求头**: `Authorization: Bearer <token>`

**请求参数**:
```json
{
  "songId": 101
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "从喜欢列表移除成功",
  "data": null
}
```

### 收藏歌单

#### 获取收藏的歌单

**接口地址**: `GET /user/collected`

**请求头**: `Authorization: Bearer <token>`

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取收藏的歌单成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "playlist_id": 201,
        "created_at": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

### 用户关注

#### 关注用户 ✅

**接口地址**: `POST /user/follow`

**请求头**: `Authorization: Bearer <token>`

**请求参数**:
```json
{
  "userId": 2
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "关注成功",
  "data": null
}
```

#### 取消关注用户 ✅

**接口地址**: `POST /user/unfollow`

**请求头**: `Authorization: Bearer <token>`

**请求参数**:
```json
{
  "userId": 2
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "取消关注成功",
  "data": null
}
```

#### 获取关注列表 ✅

**接口地址**: `GET /user/following`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取关注列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "follower_id": 1,
        "followed_id": 2,
        "created_at": "2024-01-01T00:00:00.000Z",
        "followed": {
          "id": 2,
          "username": "user2",
          "avatar": "/avatars/avatar_uuid2.jpg"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

#### 获取粉丝列表 ✅

**接口地址**: `GET /user/followers`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取粉丝列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "follower_id": 2,
        "followed_id": 1,
        "created_at": "2024-01-01T00:00:00.000Z",
        "follower": {
          "id": 2,
          "username": "user2",
          "avatar": "/avatars/avatar_uuid2.jpg"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

## 其他接口

### 头像上传 ✅

**接口地址**: `POST /user/avatar`

**请求头**: `Authorization: Bearer <token>`

**请求格式**: `multipart/form-data`

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| avatar | file | 是 | 头像图片文件 |

**头像文件要求**:
- 支持格式：JPEG、PNG、GIF
- 文件大小：最大5MB
- 字段名：`avatar`

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "头像上传成功",
  "data": {
    "user": {
      "id": 1,
      "username": "testuser",
      "email": "test@example.com",
      "avatar": "/avatars/avatar_123e4567-e89b-12d3-a456-426614174000.jpg",
      "background": "https://example.com/bg.jpg",
      "created_at": "2024-01-01T00:00:00.000Z"
    },
    "avatar": "/avatars/avatar_123e4567-e89b-12d3-a456-426614174000.jpg"
  }
}
```

**错误响应**:
```json
{
  "success": false,
  "code": 400,
  "message": "请选择要上传的头像图片",
  "errorCode": "NO_FILE_SELECTED"
}
```

**测试用例**:
```bash
# 1. 先登录获取 token
TOKEN=$(curl -s -X POST "http://localhost:3000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"loginField":"testuser","password":"123456"}' | jq -r .data.token)

# 2. 使用 token 上传头像
curl -X POST "http://localhost:3000/api/v1/user/avatar" \
  -H "Authorization: Bearer $TOKEN" \
  -F "avatar=@/path/to/avatar.png"

# 3. 验证头像是否上传成功
curl -s "http://localhost:3000/api/v1/user/info" \
  -H "Authorization: Bearer $TOKEN" | jq .data.avatar
```

**完整测试示例**:
```bash
# 创建测试图片
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==" | base64 -d > test-avatar.png

# 获取 token 并上传头像
TOKEN=$(curl -s -X POST "http://localhost:3000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"loginField":"testuser","password":"123456"}' | jq -r .data.token)

curl -X POST "http://localhost:3000/api/v1/user/avatar" \
  -H "Authorization: Bearer $TOKEN" \
  -F "avatar=@test-avatar.png"

# 清理测试文件
rm test-avatar.png
```

" 待办
### 用户设置

#### 获取用户设置

**接口地址**: `GET /user/settings`

**请求头**: `Authorization: Bearer <token>`

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取用户设置成功",
  "data": {
    "id": 1,
    "user_id": 1,
    "privacy_level": 0,
    "allow_message": true,
    "allow_comment": true,
    "notification_enabled": true,
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### 更新用户设置

**接口地址**: `POST /user/settings`

**请求头**: `Authorization: Bearer <token>`

**请求参数**:
```json
{
  "privacy_level": 1,
  "allow_message": false,
  "allow_comment": true,
  "notification_enabled": false
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "更新用户设置成功",
  "data": {
    "id": 1,
    "user_id": 1,
    "privacy_level": 1,
    "allow_message": false,
    "allow_comment": true,
    "notification_enabled": false,
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

## 错误码说明

### 通用错误码
- `400`: 请求参数错误
- `401`: 未认证或认证失败
- `403`: 权限不足
- `404`: 资源不存在
- `409`: 资源冲突
- `422`: 参数验证失败
- `500`: 服务器内部错误

### 业务错误码
- `USERNAME_EXISTS`: 用户名已存在
- `EMAIL_EXISTS`: 邮箱已存在
- `USER_NOT_FOUND`: 用户不存在
- `INVALID_CREDENTIALS`: 用户名或密码错误
- `INVALID_TOKEN`: 无效的令牌
- `TOKEN_EXPIRED`: 令牌已过期
- `SONG_ALREADY_LIKED`: 歌曲已在喜欢列表中
- `SONG_NOT_LIKED`: 歌曲不在喜欢列表中
- `ALREADY_FOLLOWING`: 已经关注该用户
- `NOT_FOLLOWING`: 未关注该用户
- `CANNOT_FOLLOW_SELF`: 不能关注自己
- `NO_FILE_SELECTED`: 未选择文件
- `INVALID_FILE_TYPE`: 不支持的文件类型
- `FILE_TOO_LARGE`: 文件过大

## 测试环境

### 环境配置
- 服务器地址: `http://localhost:3000`
- 数据库: MySQL 8.0
- 测试工具: curl, Postman, 或其他HTTP客户端

### 测试数据
建议创建以下测试用户：
1. 管理员用户: `admin` / `password`
2. 普通用户1: `user1` / `123456`
3. 普通用户2: `user2` / `123456`

### 测试流程
1. 注册/登录获取Token
2. 使用Token访问需要认证的接口
3. 测试各种边界情况和错误处理
4. 验证响应数据格式和内容

---

**更新日期**: 2025-07-14
**版本**: v1.1.0
**维护者**: 开发团队 