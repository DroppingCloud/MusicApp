# 社交模块API测试文档

## 目录
- [关注相关接口](#关注相关接口)
  - [关注用户](#关注用户)
  - [取消关注用户](#取消关注用户)
  - [获取关注列表](#获取关注列表)
  - [获取粉丝列表](#获取粉丝列表)
  - [获取关注统计](#获取关注统计)
  - [检查关注状态](#检查关注状态)
  - [获取互相关注好友](#获取互相关注好友)
- [点赞相关接口](#点赞相关接口)
  - [点赞](#点赞)
  - [取消点赞](#取消点赞)
  - [获取用户点赞列表](#获取用户点赞列表)
  - [批量检查点赞状态](#批量检查点赞状态)
  - [获取点赞统计](#获取点赞统计)
- [评论相关接口](#评论相关接口)
  - [获取评论列表](#获取评论列表)
  - [添加评论](#添加评论)
  - [删除评论](#删除评论)
- [笔记相关接口](#笔记相关接口)
  - [获取笔记列表](#获取笔记列表)
  - [获取笔记详情](#获取笔记详情)
  - [创建笔记](#创建笔记)
  - [更新笔记](#更新笔记)
  - [删除笔记](#删除笔记)
  - [点赞笔记](#点赞笔记)
  - [取消点赞笔记](#取消点赞笔记)
  - [获取笔记评论](#获取笔记评论)
  - [添加笔记评论](#添加笔记评论)
  - [获取我的笔记](#获取我的笔记)
  - [根据歌曲获取笔记](#根据歌曲获取笔记)
  - [上传笔记图片](#上传笔记图片)
- [聊天相关接口](#聊天相关接口)
  - [获取聊天会话列表](#获取聊天会话列表)
  - [获取聊天消息](#获取聊天消息)
  - [发送消息](#发送消息)

## 基础信息

### 接口基础URL
```
http://localhost:3000/api/v1
```

### 认证说明
- 部分接口需要JWT Token认证
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

## 关注相关接口

### 关注用户 ✅

**接口地址**: `POST /social/follow/:userId`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `userId`: 被关注用户ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "关注成功",
  "data": null,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**错误响应**:
- `400`: 不能关注自己 / 已经关注过该用户
- `404`: 用户不存在

**测试用例**:
```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 关注用户ID为2的用户
curl -X POST "http://localhost:3000/api/v1/social/follow/2" \
  -H "Authorization: Bearer $TOKEN"
```

### 取消关注用户 ✅

**接口地址**: `POST /social/unfollow/:userId`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `userId`: 被取消关注用户ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "取消关注成功",
  "data": null,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/social/unfollow/2" \
  -H "Authorization: Bearer $TOKEN"
```

### 获取关注列表 ✅

**接口地址**: `GET /social/following/:userId`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `userId`: 用户ID

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
        "followed_id": 2,
        "created_at": "2024-01-01T00:00:00.000Z",
        "user": {
          "id": 2,
          "username": "被关注用户",
          "avatar": "http://example.com/avatar.jpg"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 5,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
# 获取用户1的关注列表
curl -X GET "http://localhost:3000/api/v1/social/following/1?page=1&limit=10"
```

### 获取粉丝列表 ✅

**接口地址**: `GET /social/followers/:userId`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `userId`: 用户ID

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
        "follower_id": 3,
        "created_at": "2024-01-01T00:00:00.000Z",
        "user": {
          "id": 3,
          "username": "粉丝用户",
          "avatar": "http://example.com/avatar.jpg"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 10,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/social/followers/1?page=1&limit=10"
```

### 获取关注统计 ✅ (不使用)

**接口地址**: `GET /social/follow-stats/:userId`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `userId`: 用户ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取关注统计成功",
  "data": {
    "following_count": 50,
    "followers_count": 100
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/social/follow-stats/1"
```

### 检查关注状态 ✅

**接口地址**: `GET /social/check-following/:userId`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `userId`: 被检查用户ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "检查关注状态成功",
  "data": {
    "is_following": true
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/social/check-following/2" \
  -H "Authorization: Bearer $TOKEN"
```

### 获取互相关注好友 ✅ (不使用)

**接口地址**: `GET /social/mutual-friends`

**请求头**: `Authorization: Bearer <token>` (必须)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取好友列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 2,
        "created_at": "2024-01-01T00:00:00.000Z",
        "user": {
          "id": 2,
          "username": "好友用户",
          "avatar": "http://example.com/avatar.jpg"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 5,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/social/mutual-friends?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

## 点赞相关接口

### 点赞 ✅

**接口地址**: `POST /social/like`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求参数**:
```json
{
  "type": "note",
  "targetId": 1
}
```

**参数说明**:
- `type`: 点赞类型，支持 `note`、`comment`
- `targetId`: 目标对象ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "点赞成功",
  "data": null
}
```

**测试用例**:
```bash
# 点赞笔记
curl -X POST "http://localhost:3000/api/v1/social/like" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "note",
    "targetId": 1
  }'

# 点赞评论
curl -X POST "http://localhost:3000/api/v1/social/like" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "comment",
    "targetId": 1
  }'
```

### 取消点赞 ✅

**接口地址**: `POST /social/unlike`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求参数**:
```json
{
  "type": "note",
  "targetId": 1
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "取消点赞成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/social/unlike" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "note",
    "targetId": 1
  }'
```

### 获取用户点赞列表 ✅

**接口地址**: `GET /social/likes`

**请求头**: `Authorization: Bearer <token>` (必须)

**查询参数**:
- `type`: 点赞类型过滤，可选
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取点赞列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "type": "note",
        "target_id": 1,
        "created_at": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "totalPages": 3
    }
  }
}
```

**测试用例**:
```bash
# 获取所有点赞
curl -X GET "http://localhost:3000/api/v1/social/likes?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"

# 只获取笔记点赞
curl -X GET "http://localhost:3000/api/v1/social/likes?type=note&page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### 批量检查点赞状态 ✅ (不使用)

**接口地址**: `POST /social/batch-check-liked`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求参数**:
```json
{
  "type": "note",
  "targetIds": [1, 2, 3, 4, 5]
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "批量检查点赞状态成功",
  "data": {
    "1": true,
    "2": false,
    "3": true,
    "4": false,
    "5": false
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/social/batch-check-liked" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "note",
    "targetIds": [1, 2, 3]
  }'
```

### 获取点赞统计 ✅ (不使用)

**接口地址**: `POST /social/like-stats`

**请求头**: `Authorization: Bearer <token>` (可选)

**请求参数**:
```json
{
  "type": "note",
  "targetIds": [1, 2, 3, 4, 5]
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取点赞统计成功",
  "data": {
    "1": 100,
    "2": 50,
    "3": 200,
    "4": 0,
    "5": 25
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/social/like-stats" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "note",
    "targetIds": [1, 2, 3]
  }'
```

## 评论相关接口

### 获取评论列表 ✅

**接口地址**: `GET /social/comments`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `type`: 评论类型，支持 `song`、`note`、`playlist` (必填)
- `targetId`: 目标对象ID (必填)
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取评论列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "type": "song",
        "target_id": 1,
        "content": "这首歌太好听了！",
        "parent_id": null,
        "created_at": "2024-01-01T00:00:00.000Z",
        "user": {
          "id": 1,
          "username": "用户名",
          "avatar": "http://example.com/avatar.jpg"
        },
        "replies": [
          {
            "id": 2,
            "user_id": 2,
            "content": "我也觉得！",
            "created_at": "2024-01-01T01:00:00.000Z",
            "user": {
              "id": 2,
              "username": "回复用户",
              "avatar": "http://example.com/avatar2.jpg"
            }
          }
        ]
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

**测试用例**:
```bash
# 获取歌曲评论
curl -X GET "http://localhost:3000/api/v1/social/comments?type=song&targetId=1&page=1&limit=10"

# 获取笔记评论
curl -X GET "http://localhost:3000/api/v1/social/comments?type=note&targetId=1&page=1&limit=10"
```

### 添加评论 ✅

**接口地址**: `POST /social/comment`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求参数**:
```json
{
  "type": "song",
  "targetId": 1,
  "content": "这首歌真的很棒！",
  "parentId": null
}
```

**参数说明**:
- `parentId`: 父评论ID，用于回复评论，可选

**成功响应**:
```json
{
  "success": true,
  "code": 201,
  "message": "添加评论成功",
  "data": {
    "id": 1,
    "user_id": 1,
    "type": "song",
    "target_id": 1,
    "content": "这首歌真的很棒！",
    "parent_id": null,
    "created_at": "2024-01-01T00:00:00.000Z",
    "user": {
      "id": 1,
      "username": "用户名",
      "avatar": "http://example.com/avatar.jpg"
    }
  }
}
```

**测试用例**:
```bash
# 添加评论
curl -X POST "http://localhost:3000/api/v1/social/comment" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "song",
    "targetId": 1,
    "content": "这首歌太棒了！"
  }'

# 回复评论
curl -X POST "http://localhost:3000/api/v1/social/comment" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "song",
    "targetId": 1,
    "content": "我也这么认为！",
    "parentId": 1
  }'
```

### 删除评论 ✅

**接口地址**: `POST /social/comment/delete/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 评论ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "删除评论成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/social/comment/delete/1" \
  -H "Authorization: Bearer $TOKEN"
```

## 笔记相关接口

### 获取笔记列表 ✅

**接口地址**: `GET /note/list`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取笔记列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "title": "我的音乐心得",
        "content": "今天听了一首很棒的歌...",
        "song_id": 1,
        "created_at": "2024-01-01T00:00:00.000Z",
        "is_liked": false,
        "user": {
          "id": 1,
          "username": "用户名",
          "avatar": "http://example.com/avatar.jpg"
        },
        "song": {
          "id": 1,
          "title": "歌曲名",
          "cover_url": "http://example.com/cover.jpg",
          "artist": {
            "id": 1,
            "name": "歌手名"
          }
        },
        "images": [
          {
            "id": 1,
            "image_url": "http://example.com/note1.jpg",
            "order_index": 0
          }
        ]
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "totalPages": 3
    }
  }
}
```

**测试用例**:
```bash
# 获取笔记列表
curl -X GET "http://localhost:3000/api/v1/note/list?page=1&limit=10"

# 登录用户获取（可查看点赞状态）
curl -X GET "http://localhost:3000/api/v1/note/list?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### 获取笔记详情 ✅

**接口地址**: `GET /note/detail/:id`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `id`: 笔记ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取笔记详情成功",
  "data": {
    "id": 1,
    "user_id": 1,
    "title": "我的音乐心得",
    "content": "今天听了一首很棒的歌，让我想到了很多...",
    "song_id": 1,
    "created_at": "2024-01-01T00:00:00.000Z",
    "like_count": 50,
    "comment_count": 20,
    "is_liked": false,
    "user": {
      "id": 1,
      "username": "用户名",
      "avatar": "http://example.com/avatar.jpg"
    },
    "song": {
      "id": 1,
      "title": "歌曲名",
      "cover_url": "http://example.com/cover.jpg",
      "duration": 240,
      "artist": {
        "id": 1,
        "name": "歌手名"
      },
      "album": {
        "id": 1,
        "title": "专辑名",
        "cover_url": "http://example.com/album.jpg"
      }
    },
    "images": [
      {
        "id": 1,
        "image_url": "http://example.com/note1.jpg",
        "order_index": 0
      }
    ]
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/note/detail/1"
```

### 创建笔记 ✅

**接口地址**: `POST /note/create`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求格式**: `multipart/form-data` (支持文件上传)

**请求参数**:
- `title`: 笔记标题，可选
- `content`: 笔记内容，可选
- `song_id`: 关联歌曲ID，可选
- `images`: 图片文件数组，可选（支持多张图片上传）

**参数说明**:
- 注意：title和content不能同时为空
- 支持的图片格式：JPEG、JPG、PNG、GIF
- 最大文件大小：5MB
- 最多支持多张图片同时上传

**成功响应**:
```json
{
  "success": true,
  "code": 201,
  "message": "创建笔记成功",
  "data": {
    "id": 1,
    "user_id": 1,
    "title": "我的音乐心得",
    "content": "今天听了一首很棒的歌...",
    "song_id": 1,
    "created_at": "2024-01-01T00:00:00.000Z",
    "like_count": 0,
    "comment_count": 0,
    "is_liked": false,
    "user": {
      "id": 1,
      "username": "用户名",
      "avatar": "http://example.com/avatar.jpg"
    },
    "song": {
      "id": 1,
      "title": "歌曲名",
      "cover_url": "http://example.com/cover.jpg"
    },
    "images": [
      {
        "id": 1,
        "image_url": "http://example.com/image1.jpg",
        "order_index": 0
      }
    ]
  }
}
```

**测试用例**:
```bash
# 创建不带图片的笔记
curl -X POST "http://localhost:3000/api/v1/note/create" \
  -H "Authorization: Bearer $TOKEN" \
  -F "title=我的音乐笔记" \
  -F "content=分享一下我最近听的音乐..." \
  -F "song_id=1"

# 创建带图片的笔记
curl -X POST "http://localhost:3000/api/v1/note/create" \
  -H "Authorization: Bearer $TOKEN" \
  -F "title=我的音乐笔记" \
  -F "content=分享一下我最近听的音乐..." \
  -F "song_id=1" \
  -F "images=@/path/to/image1.jpg" \
  -F "images=@/path/to/image2.jpg"
```

### 更新笔记 ✅

**接口地址**: `POST /note/update/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求格式**: `multipart/form-data` (支持文件上传)

**路径参数**:
- `id`: 笔记ID

**请求参数**:
- `title`: 更新后的标题，可选
- `content`: 更新后的内容，可选
- `images`: 新的图片文件数组，可选（会替换所有原有图片）

**参数说明**:
- 支持的图片格式：JPEG、JPG、PNG、GIF
- 最大文件大小：5MB
- 如果传入images参数，会删除所有原有图片并替换为新上传的图片

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "更新笔记成功",
  "data": {
    "id": 1,
    "title": "更新后的标题",
    "content": "更新后的内容",
    "song_id": 1,
    "created_at": "2024-01-01T00:00:00.000Z",
    "like_count": 10,
    "comment_count": 5,
    "is_liked": true,
    "user": {
      "id": 1,
      "username": "用户名",
      "avatar": "http://example.com/avatar.jpg"
    },
    "images": [
      {
        "id": 2,
        "image_url": "http://example.com/new_image.jpg",
        "order_index": 0
      }
    ]
  }
}
```

**测试用例**:
```bash
# 更新笔记内容（不更新图片）
curl -X POST "http://localhost:3000/api/v1/note/update/1" \
  -H "Authorization: Bearer $TOKEN" \
  -F "title=更新的笔记标题" \
  -F "content=更新的笔记内容"

# 更新笔记内容和图片
curl -X POST "http://localhost:3000/api/v1/note/update/1" \
  -H "Authorization: Bearer $TOKEN" \
  -F "title=更新的笔记标题" \
  -F "content=更新的笔记内容" \
  -F "images=@/path/to/new_image.jpg"
```

### 删除笔记 ✅

**接口地址**: `POST /note/remove/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 笔记ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "删除笔记成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/note/remove/1" \
  -H "Authorization: Bearer $TOKEN"
```

### 点赞笔记 ✅

**接口地址**: `POST /note/like/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 笔记ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "点赞成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/note/like/1" \
  -H "Authorization: Bearer $TOKEN"
```

### 取消点赞笔记 ✅

**接口地址**: `POST /note/unlike/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 笔记ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "取消点赞成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/note/unlike/1" \
  -H "Authorization: Bearer $TOKEN"
```

### 获取笔记评论 ✅

**接口地址**: `GET /note/comments/:id`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `id`: 笔记ID

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取评论列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "type": "note",
        "target_id": 1,
        "content": "写得很好！",
        "parent_id": null,
        "created_at": "2024-01-01T00:00:00.000Z",
        "user": {
          "id": 1,
          "username": "用户名",
          "avatar": "http://example.com/avatar.jpg"
        },
        "replies": []
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 10,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/note/comments/1?page=1&limit=10"
```

### 添加笔记评论 ✅

**接口地址**: `POST /note/comment/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 笔记ID

**请求参数**:
```json
{
  "content": "这篇笔记写得很好！"
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 201,
  "message": "添加评论成功",
  "data": {
    "id": 1,
    "user_id": 1,
    "type": "note",
    "target_id": 1,
    "content": "这篇笔记写得很好！",
    "parent_id": null,
    "created_at": "2024-01-01T00:00:00.000Z",
    "user": {
      "id": 1,
      "username": "用户名",
      "avatar": "http://example.com/avatar.jpg"
    }
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/note/comment/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "很棒的笔记！"
  }'
```

### 获取我的笔记 ✅

**接口地址**: `GET /note/my`

**请求头**: `Authorization: Bearer <token>` (必须)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取我的笔记成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "title": "我的音乐心得",
        "content": "今天听了一首很棒的歌...",
        "song_id": 1,
        "created_at": "2024-01-01T00:00:00.000Z",
        "like_count": 50,
        "comment_count": 20,
        "is_liked": false,
        "user": {
          "id": 1,
          "username": "用户名",
          "avatar": "http://example.com/avatar.jpg"
        },
        "song": {
          "id": 1,
          "title": "歌曲名",
          "cover_url": "http://example.com/cover.jpg",
          "artist": {
            "id": 1,
            "name": "歌手名"
          }
        },
        "images": []
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 5,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/note/my?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### 根据歌曲获取笔记 ✅ (不使用)

**接口地址**: `GET /note/song/:songId`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `songId`: 歌曲ID

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取歌曲笔记成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "title": "关于这首歌的感想",
        "content": "这首歌让我想起了...",
        "song_id": 1,
        "created_at": "2024-01-01T00:00:00.000Z",
        "is_liked": false,
        "user": {
          "id": 1,
          "username": "用户名",
          "avatar": "http://example.com/avatar.jpg"
        },
        "images": []
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 3,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/note/song/1?page=1&limit=10"
```

### 上传笔记图片 ✅ (不使用)

**接口地址**: `POST /note/upload-image`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求参数**: 
- 文件上传（multipart/form-data）
- 字段名：`image`

**支持的图片格式**: JPEG, JPG, PNG, GIF
**最大文件大小**: 5MB

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "上传成功",
  "data": {
    "image_url": "/uploads/notes/20240101_123456_image.jpg"
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/note/upload-image" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@/path/to/your/image.jpg"
```

# ============================================= 待办
## 聊天相关接口 

### 获取聊天会话列表 ✅

**接口地址**: `GET /social/chat/list`

**请求头**: `Authorization: Bearer <token>` (必须)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取聊天列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "other_user": {
          "id": 2,
          "username": "聊天对象",
          "avatar": "http://example.com/avatar.jpg"
        },
        "last_msg": "你好！",
        "last_time": "2024-01-01T12:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 5,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/social/chat/list?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### 获取聊天消息 ✅

**接口地址**: `GET /social/chat/:userId`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `userId`: 聊天对象用户ID

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认50

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取聊天记录成功",
  "data": {
    "list": [
      {
        "id": 1,
        "chat_id": 1,
        "sender_id": 1,
        "content": "你好！",
        "send_time": "2024-01-01T12:00:00.000Z",
        "sender": {
          "id": 1,
          "username": "发送者",
          "avatar": "http://example.com/avatar.jpg"
        }
      },
      {
        "id": 2,
        "chat_id": 1,
        "sender_id": 2,
        "content": "你好，很高兴认识你！",
        "send_time": "2024-01-01T12:01:00.000Z",
        "sender": {
          "id": 2,
          "username": "接收者",
          "avatar": "http://example.com/avatar2.jpg"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 50,
      "total": 2,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/social/chat/2?page=1&limit=20" \
  -H "Authorization: Bearer $TOKEN"
```

### 发送消息 ✅

**接口地址**: `POST /social/chat/:userId/send`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `userId`: 接收消息的用户ID

**请求参数**:
```json
{
  "content": "你好，很高兴认识你！"
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 201,
  "message": "发送消息成功",
  "data": {
    "id": 1,
    "chat_id": 1,
    "sender_id": 1,
    "content": "你好，很高兴认识你！",
    "send_time": "2024-01-01T12:00:00.000Z",
    "sender": {
      "id": 1,
      "username": "发送者",
      "avatar": "http://example.com/avatar.jpg"
    }
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/social/chat/2/send" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "你好，很高兴认识你！"
  }'
```

## 错误码说明

### 通用错误码
- `400`: 请求参数错误
- `401`: 未认证或认证失败
- `403`: 权限不足
- `404`: 资源不存在
- `500`: 服务器内部错误

### 业务错误码

#### 关注相关
- `CANNOT_FOLLOW_SELF`: 不能关注自己
- `ALREADY_FOLLOWING`: 已经关注过该用户
- `NOT_FOLLOWING`: 未关注该用户
- `USER_NOT_FOUND`: 用户不存在

#### 点赞相关
- `INVALID_LIKE_TYPE`: 无效的点赞类型
- `ALREADY_LIKED`: 已经点赞过了
- `NOT_LIKED`: 未点赞过
- `NOTE_NOT_FOUND`: 笔记不存在
- `COMMENT_NOT_FOUND`: 评论不存在

#### 评论相关
- `INVALID_COMMENT_TYPE`: 无效的评论类型
- `COMMENT_CONTENT_EMPTY`: 评论内容不能为空
- `COMMENT_NOT_FOUND`: 评论不存在
- `PERMISSION_DENIED`: 没有权限操作
- `PARENT_COMMENT_NOT_FOUND`: 父评论不存在
- `REPLY_TARGET_MISMATCH`: 回复评论的目标不匹配
- `SONG_NOT_FOUND`: 歌曲不存在
- `PLAYLIST_NOT_FOUND`: 歌单不存在

#### 笔记相关
- `NOTE_NOT_FOUND`: 笔记不存在
- `TITLE_CONTENT_EMPTY`: 标题和内容不能同时为空
- `SONG_NOT_FOUND`: 指定的歌曲不存在
- `INVALID_IMAGE_FORMAT`: 不支持的图片格式
- `IMAGE_TOO_LARGE`: 图片文件过大

#### 聊天相关
- `MESSAGE_CONTENT_EMPTY`: 消息内容不能为空
- `CANNOT_MESSAGE_SELF`: 不能给自己发消息
- `RECEIVER_NOT_FOUND`: 接收者不存在

## 完整测试流程

### 1. 准备测试环境
```bash
# 启动服务器
cd my-server
pnpm start

# 获取认证Token
TOKEN=$(curl -s -X POST "http://localhost:3000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"loginField":"testuser","password":"123456"}' | jq -r .data.token)

echo "Token: $TOKEN"
```

### 2. 关注功能测试
```bash
# 关注用户
curl -X POST "http://localhost:3000/api/v1/social/follow/2" \
  -H "Authorization: Bearer $TOKEN"

# 检查关注状态
curl -X GET "http://localhost:3000/api/v1/social/check-following/2" \
  -H "Authorization: Bearer $TOKEN"

# 获取关注列表
curl -X GET "http://localhost:3000/api/v1/social/following/1?page=1&limit=5"

# 获取关注统计
curl -X GET "http://localhost:3000/api/v1/social/follow-stats/1"
```

### 3. 点赞功能测试
```bash
# 点赞笔记
curl -X POST "http://localhost:3000/api/v1/social/like" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type": "note", "targetId": 1}'

# 批量检查点赞状态
curl -X POST "http://localhost:3000/api/v1/social/batch-check-liked" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type": "note", "targetIds": [1, 2, 3]}'

# 获取用户点赞列表
curl -X GET "http://localhost:3000/api/v1/social/likes?page=1&limit=5" \
  -H "Authorization: Bearer $TOKEN"
```

### 4. 评论功能测试
```bash
# 添加评论
curl -X POST "http://localhost:3000/api/v1/social/comment" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "song",
    "targetId": 1,
    "content": "这首歌太棒了！"
  }'

# 获取评论列表
curl -X GET "http://localhost:3000/api/v1/social/comments?type=song&targetId=1&page=1&limit=5"

# 回复评论
curl -X POST "http://localhost:3000/api/v1/social/comment" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "song",
    "targetId": 1,
    "content": "我也这么认为！",
    "parentId": 1
  }'
```

### 5. 笔记功能测试
```bash
# 创建笔记（带图片）
curl -X POST "http://localhost:3000/api/v1/note/create" \
  -H "Authorization: Bearer $TOKEN" \
  -F "title=我的音乐笔记" \
  -F "content=分享一下我最近听的音乐心得..." \
  -F "song_id=1" \
  -F "images=@/path/to/image.jpg"

# 获取笔记列表
curl -X GET "http://localhost:3000/api/v1/note/list?page=1&limit=5"

# 点赞笔记
curl -X POST "http://localhost:3000/api/v1/note/like/1" \
  -H "Authorization: Bearer $TOKEN"

# 获取我的笔记
curl -X GET "http://localhost:3000/api/v1/note/my?page=1&limit=5" \
  -H "Authorization: Bearer $TOKEN"
```

### 6. 聊天功能测试
```bash
# 发送消息
curl -X POST "http://localhost:3000/api/v1/social/chat/2/send" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "你好，很高兴认识你！"}'

# 获取聊天记录
curl -X GET "http://localhost:3000/api/v1/social/chat/2?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"

# 获取聊天会话列表
curl -X GET "http://localhost:3000/api/v1/social/chat/list?page=1&limit=5" \
  -H "Authorization: Bearer $TOKEN"
```

## 测试注意事项

1. **数据依赖**: 确保测试环境中有足够的测试数据（用户、歌曲等）
2. **权限控制**: 注意区分需要认证和可选认证的接口
3. **关联关系**: 测试时注意模型之间的关联关系，如笔记关联歌曲
4. **事务处理**: 点赞、评论等操作涉及统计更新，注意数据一致性
5. **文件上传**: 测试图片上传时注意文件格式和大小限制
6. **分页查询**: 测试大量数据时注意分页参数的使用
7. **错误处理**: 测试各种异常情况，确保错误处理正确

## 性能优化建议

1. **批量操作**: 使用批量检查接口减少网络请求
2. **数据缓存**: 考虑对热门数据进行缓存
3. **分页加载**: 大列表采用分页或无限滚动
4. **图片优化**: 上传的图片进行压缩和格式优化
5. **索引优化**: 确保数据库查询使用了合适的索引
6. **关联查询**: 使用include减少N+1查询问题

---

**更新日期**: 2024-01-15
**版本**: v1.0.0
**维护者**: 开发团队 