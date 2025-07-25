# 音乐模块API测试文档

## 目录
- [歌曲相关接口](#歌曲相关接口)
  - [获取歌曲列表](#获取歌曲列表)
  - [获取歌曲详情](#获取歌曲详情)
  - [创建歌曲](#创建歌曲)
  - [更新歌曲信息](#更新歌曲信息)
  - [删除歌曲](#删除歌曲)
  - [播放歌曲](#播放歌曲)
  - [获取热门歌曲](#获取热门歌曲)
  - [获取推荐歌曲](#获取推荐歌曲)
  - [喜欢歌曲](#喜欢歌曲)
  - [取消喜欢歌曲](#取消喜欢歌曲)
- [歌单相关接口](#歌单相关接口)
  - [获取歌单列表](#获取歌单列表)
  - [获取歌单详情](#获取歌单详情)
  - [创建歌单](#创建歌单)
  - [更新歌单信息](#更新歌单信息)
  - [删除歌单](#删除歌单)
  - [获取歌单中的歌曲](#获取歌单中的歌曲)
  - [添加歌曲到歌单](#添加歌曲到歌单)
  - [从歌单移除歌曲](#从歌单移除歌曲)
  - [收藏歌单](#收藏歌单)
  - [取消收藏歌单](#取消收藏歌单)
  - [获取收藏的歌单](#获取收藏的歌单)
  - [获取用户创建的歌单](#获取用户创建的歌单)

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

## 歌曲相关接口

### 获取歌曲列表 ✅

**接口地址**: `GET /song/list`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20
- `keyword`: 搜索关键词
- `genre`: 音乐风格/标签
- `artist`: 艺术家名称

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取歌曲列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "歌曲名称",
        "audio_url": "http://example.com/audio.mp3",
        "cover_url": "http://example.com/cover.jpg",
        "duration": 240,
        "release_date": "2024-01-01",
        "artist": {
          "id": 1,
          "name": "歌手名",
          "avatar": "http://example.com/avatar.jpg"
        },
        "album": {
          "id": 1,
          "title": "专辑名",
          "cover_url": "http://example.com/album_cover.jpg"
        },
        "stat": {
          "play_count": 1000,
          "like_count": 100,
          "comment_count": 50
        },
        "tags": [
          {
            "id": 1,
            "name": "流行",
            "type": "genre"
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
# 获取歌曲列表
curl -X GET "http://localhost:3000/api/v1/song/list?page=1&limit=10"

# 搜索歌曲
curl -X GET "http://localhost:3000/api/v1/song/list?keyword=love"

# 按风格筛选
curl -X GET "http://localhost:3000/api/v1/song/list?genre=流行"

# 按艺术家筛选
curl -X GET "http://localhost:3000/api/v1/song/list?artist=周杰伦"
```

### 获取歌曲详情 ✅ 

**接口地址**: `GET /song/detail/:id`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `id`: 歌曲ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取歌曲详情成功",
  "data": {
    "id": 1,
    "title": "歌曲名称",
    "audio_url": "http://example.com/audio.mp3",
    "cover_url": "http://example.com/cover.jpg",
    "duration": 240,
    "release_date": "2024-01-01",
    "artist": {
      "id": 1,
      "name": "歌手名",
      "avatar": "http://example.com/avatar.jpg",
      "bio": "歌手简介"
    },
    "album": {
      "id": 1,
      "title": "专辑名",
      "cover_url": "http://example.com/album_cover.jpg",
      "publish_time": "2024-01-01"
    },
    "stat": {
      "play_count": 1000,
      "like_count": 100,
      "comment_count": 50
    },
    "tags": [
      {
        "id": 1,
        "name": "流行",
        "type": "genre"
      }
    ]
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/song/detail/1"
```

### 创建歌曲 ✅ (要求"专辑"与"歌手"存在)

**接口地址**: `POST /song/create`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求参数**:
```json
{
  "title": "歌曲名称",
  "artist_id": 1,
  "album_id": 1,
  "audio_url": "http://example.com/audio.mp3",
  "cover_url": "http://example.com/cover.jpg",
  "duration": 240,
  "release_date": "2024-01-01",
  "tags": ["流行", "摇滚"]
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 201,
  "message": "创建歌曲成功",
  "data": {
    "id": 1,
    "title": "歌曲名称",
    "audio_url": "http://example.com/audio.mp3",
    "cover_url": "http://example.com/cover.jpg",
    "duration": 240,
    "release_date": "2024-01-01",
    "artist": {
      "id": 1,
      "name": "歌手名",
      "avatar": "http://example.com/avatar.jpg"
    },
    "album": {
      "id": 1,
      "title": "专辑名",
      "cover_url": "http://example.com/album_cover.jpg"
    },
    "tags": [
      {
        "id": 1,
        "name": "流行",
        "type": "genre"
      }
    ]
  }
}
```

**测试用例**:
```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X POST "http://localhost:3000/api/v1/song/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "测试歌曲",
    "artist_id": 1,
    "audio_url": "http://example.com/test.mp3",
    "duration": 180,
    "tags": ["流行"]
  }'
```

### 更新歌曲信息 ✅

**接口地址**: `POST /song/update/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌曲ID

**请求参数**:
```json
{
  "title": "新歌曲名称",
  "cover_url": "http://example.com/new_cover.jpg",
  "tags": ["摇滚", "民谣"]
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "更新歌曲成功",
  "data": {
    "id": 1,
    "title": "新歌曲名称",
    "audio_url": "http://example.com/audio.mp3",
    "cover_url": "http://example.com/new_cover.jpg",
    "duration": 240,
    "release_date": "2024-01-01",
    "artist": {
      "id": 1,
      "name": "歌手名",
      "avatar": "http://example.com/avatar.jpg"
    },
    "tags": [
      {
        "id": 2,
        "name": "摇滚",
        "type": "genre"
      }
    ]
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/song/update/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "更新后的歌曲名",
    "tags": ["摇滚"]
  }'
```

### 删除歌曲 ✅

**接口地址**: `POST /song/remove/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌曲ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "删除歌曲成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/song/remove/1" \
  -H "Authorization: Bearer $TOKEN"
```

### 播放歌曲 ✅

**接口地址**: `POST /song/play/:id`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `id`: 歌曲ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "播放歌曲成功",
  "data": null
}
```

**测试用例**:
```bash
# 登录用户播放（会记录播放历史）
curl -X POST "http://localhost:3000/api/v1/song/play/1" \
  -H "Authorization: Bearer $TOKEN"

# 未登录用户播放（仅统计播放次数）
curl -X POST "http://localhost:3000/api/v1/song/play/1"
```

### 获取热门歌曲 ✅

**接口地址**: `GET /song/hot`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `limit`: 返回数量，默认50

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取热门歌曲成功",
  "data": [
    {
      "id": 1,
      "title": "热门歌曲1",
      "audio_url": "http://example.com/audio1.mp3",
      "cover_url": "http://example.com/cover1.jpg",
      "duration": 240,
      "artist": {
        "id": 1,
        "name": "歌手名",
        "avatar": "http://example.com/avatar.jpg"
      },
      "stat": {
        "play_count": 10000,
        "like_count": 1000,
        "comment_count": 500
      }
    }
  ]
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/song/hot?limit=20"
```

### 获取推荐歌曲 ✅ (智能推荐算法待实现)

**接口地址**: `GET /song/recommend`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `limit`: 返回数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取推荐歌曲成功",
  "data": [
    {
      "id": 1,
      "title": "推荐歌曲1",
      "audio_url": "http://example.com/audio1.mp3",
      "cover_url": "http://example.com/cover1.jpg",
      "duration": 240,
      "artist": {
        "id": 1,
        "name": "歌手名",
        "avatar": "http://example.com/avatar.jpg"
      },
      "stat": {
        "play_count": 5000,
        "like_count": 500,
        "comment_count": 200
      }
    }
  ]
}
```

**测试用例**:
```bash
# 登录用户获取个性化推荐
curl -X GET "http://localhost:3000/api/v1/song/recommend?limit=10" \
  -H "Authorization: Bearer $TOKEN"

# 未登录用户获取热门推荐
curl -X GET "http://localhost:3000/api/v1/song/recommend?limit=10"
```

### 喜欢歌曲 ✅

**接口地址**: `POST /song/like/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌曲ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "喜欢歌曲成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/song/like/1" \
  -H "Authorization: Bearer $TOKEN"
```

### 取消喜欢歌曲 ✅

**接口地址**: `POST /song/unlike/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌曲ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "取消喜欢歌曲成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/song/unlike/1" \
  -H "Authorization: Bearer $TOKEN"
```

## 歌单相关接口

### 获取歌单列表 ✅

**接口地址**: `GET /playlist/list`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20
- `keyword`: 搜索关键词

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取歌单列表成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "我的歌单",
        "cover_url": "http://example.com/playlist_cover.jpg",
        "description": "歌单描述",
        "create_time": "2024-01-01T00:00:00.000Z",
        "song_count": 50,
        "creator": {
          "id": 1,
          "username": "用户名",
          "avatar": "http://example.com/avatar.jpg"
        }
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
# 获取歌单列表
curl -X GET "http://localhost:3000/api/v1/playlist/list?page=1&limit=10"

# 搜索歌单
curl -X GET "http://localhost:3000/api/v1/playlist/list?keyword=摇滚"
```

### 获取歌单详情 ✅

**接口地址**: `GET /playlist/detail/:id`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `id`: 歌单ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取歌单详情成功",
  "data": {
    "id": 1,
    "title": "我的歌单",
    "cover_url": "http://example.com/playlist_cover.jpg",
    "description": "歌单描述",
    "create_time": "2024-01-01T00:00:00.000Z",
    "song_count": 50,
    "collect_count": 100,
    "creator": {
      "id": 1,
      "username": "用户名",
      "avatar": "http://example.com/avatar.jpg"
    }
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/playlist/detail/1"
```

### 创建歌单 ✅

**接口地址**: `POST /playlist/create`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求参数**:
```json
{
  "title": "新歌单",
  "cover_url": "http://example.com/cover.jpg",
  "description": "歌单描述"
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 201,
  "message": "创建歌单成功",
  "data": {
    "id": 1,
    "title": "新歌单",
    "cover_url": "http://example.com/cover.jpg",
    "description": "歌单描述",
    "create_time": "2024-01-01T00:00:00.000Z",
    "song_count": 0,
    "collect_count": 0,
    "creator": {
      "id": 1,
      "username": "用户名",
      "avatar": "http://example.com/avatar.jpg"
    }
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/playlist/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "我的新歌单",
    "description": "收藏的好歌"
  }'
```

### 更新歌单信息 ✅

**接口地址**: `POST /playlist/update/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌单ID

**请求参数**:
```json
{
  "title": "更新后的歌单名",
  "description": "新的描述"
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "更新歌单成功",
  "data": {
    "id": 1,
    "title": "更新后的歌单名",
    "cover_url": "http://example.com/cover.jpg",
    "description": "新的描述",
    "create_time": "2024-01-01T00:00:00.000Z",
    "song_count": 10,
    "collect_count": 5,
    "creator": {
      "id": 1,
      "username": "用户名",
      "avatar": "http://example.com/avatar.jpg"
    }
  }
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/playlist/update/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "更新的歌单名",
    "description": "更新的描述"
  }'
```

### 删除歌单 ✅

**接口地址**: `POST /playlist/remove/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌单ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "删除歌单成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/playlist/remove/1" \
  -H "Authorization: Bearer $TOKEN"
```

### 获取歌单中的歌曲 ✅

**接口地址**: `GET /playlist/songs/:id`

**请求头**: `Authorization: Bearer <token>` (可选)

**路径参数**:
- `id`: 歌单ID

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认50

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取歌单歌曲成功",
  "data": {
    "list": [
      {
        "id": 1,
        "playlist_id": 1,
        "song_id": 1,
        "order_index": 1,
        "song": {
          "id": 1,
          "title": "歌曲名称",
          "audio_url": "http://example.com/audio.mp3",
          "cover_url": "http://example.com/cover.jpg",
          "duration": 240,
          "artist": {
            "id": 1,
            "name": "歌手名",
            "avatar": "http://example.com/avatar.jpg"
          },
          "album": {
            "id": 1,
            "title": "专辑名",
            "cover_url": "http://example.com/album_cover.jpg"
          }
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 50,
      "total": 20,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
curl -X GET "http://localhost:3000/api/v1/playlist/songs/1?page=1&limit=20"
```

### 添加歌曲到歌单 ✅

**接口地址**: `POST /playlist/add-song/:id/:songId`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌单ID
- `songId`: 歌曲ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "添加歌曲到歌单成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/playlist/add-song/1/10" \
  -H "Authorization: Bearer $TOKEN"
```

### 从歌单移除歌曲 ✅

**接口地址**: `POST /playlist/remove-song/:id/:songId`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌单ID
- `songId`: 歌曲ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "从歌单移除歌曲成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/playlist/remove-song/1/10" \
  -H "Authorization: Bearer $TOKEN"
```

### 收藏歌单 ✅

**接口地址**: `POST /playlist/collect/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌单ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "收藏歌单成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/playlist/collect/1" \
  -H "Authorization: Bearer $TOKEN"
```

### 取消收藏歌单 ✅

**接口地址**: `POST /playlist/uncollect/:id`

**请求头**: `Authorization: Bearer <token>` (必须)

**路径参数**:
- `id`: 歌单ID

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "取消收藏歌单成功",
  "data": null
}
```

**测试用例**:
```bash
curl -X POST "http://localhost:3000/api/v1/playlist/uncollect/1" \
  -H "Authorization: Bearer $TOKEN"
```

### 获取收藏的歌单 ✅

**接口地址**: `GET /playlist/collected`

**请求头**: `Authorization: Bearer <token>` (必须)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取收藏歌单成功",
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "playlist_id": 1,
        "created_at": "2024-01-01T00:00:00.000Z",
        "playlist": {
          "id": 1,
          "title": "收藏的歌单",
          "cover_url": "http://example.com/cover.jpg",
          "description": "歌单描述",
          "create_time": "2024-01-01T00:00:00.000Z",
          "song_count": 30,
          "creator": {
            "id": 2,
            "username": "创建者",
            "avatar": "http://example.com/creator_avatar.jpg"
          }
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
curl -X GET "http://localhost:3000/api/v1/playlist/collected?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### 获取用户创建的歌单 ✅

**接口地址**: `GET /playlist/user/:userId`

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
  "message": "获取用户歌单成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "用户的歌单",
        "cover_url": "http://example.com/cover.jpg",
        "description": "歌单描述",
        "create_time": "2024-01-01T00:00:00.000Z",
        "song_count": 25,
        "creator": {
          "id": 1,
          "username": "用户名",
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
# 获取指定用户的歌单
curl -X GET "http://localhost:3000/api/v1/playlist/user/1?page=1&limit=10"

# 获取自己的歌单
curl -X GET "http://localhost:3000/api/v1/playlist/user/1?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

## 错误码说明

### 通用错误码
- `400`: 请求参数错误
- `401`: 未认证或认证失败
- `403`: 权限不足
- `404`: 资源不存在
- `500`: 服务器内部错误

### 业务错误码

#### 歌曲相关
- `SONG_NOT_FOUND`: 歌曲不存在
- `ARTIST_NOT_FOUND`: 艺术家不存在
- `ALBUM_NOT_FOUND`: 专辑不存在
- `SONG_ALREADY_LIKED`: 歌曲已在喜欢列表中
- `SONG_NOT_LIKED`: 歌曲不在喜欢列表中

#### 歌单相关
- `PLAYLIST_NOT_FOUND`: 歌单不存在
- `PERMISSION_DENIED`: 没有权限操作
- `SONG_ALREADY_IN_PLAYLIST`: 歌曲已在歌单中
- `SONG_NOT_IN_PLAYLIST`: 歌曲不在歌单中
- `PLAYLIST_ALREADY_COLLECTED`: 已收藏该歌单
- `PLAYLIST_NOT_COLLECTED`: 未收藏该歌单
- `CANNOT_COLLECT_OWN_PLAYLIST`: 不能收藏自己的歌单

## 完整测试流程

### 1. 准备测试环境
```bash
# 启动服务器
cd my-server
npm start

# 获取认证Token
TOKEN=$(curl -s -X POST "http://localhost:3000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"loginField":"testuser","password":"123456"}' | jq -r .data.token)

echo "Token: $TOKEN"
```

### 2. 歌曲功能测试
```bash
# 获取歌曲列表
curl -X GET "http://localhost:3000/api/v1/song/list?page=1&limit=5"

# 创建歌曲（需要先有艺术家数据）
curl -X POST "http://localhost:3000/api/v1/song/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "测试歌曲",
    "artist_id": 1,
    "audio_url": "http://example.com/test.mp3",
    "duration": 180,
    "tags": ["流行", "测试"]
  }'

# 播放歌曲
curl -X POST "http://localhost:3000/api/v1/song/play/1" \
  -H "Authorization: Bearer $TOKEN"

# 喜欢歌曲
curl -X POST "http://localhost:3000/api/v1/song/like/1" \
  -H "Authorization: Bearer $TOKEN"

# 获取推荐歌曲
curl -X GET "http://localhost:3000/api/v1/song/recommend?limit=5" \
  -H "Authorization: Bearer $TOKEN"
```

### 3. 歌单功能测试
```bash
# 创建歌单
curl -X POST "http://localhost:3000/api/v1/playlist/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "我的测试歌单",
    "description": "用于测试的歌单"
  }'

# 添加歌曲到歌单
curl -X POST "http://localhost:3000/api/v1/playlist/add-song/1/1" \
  -H "Authorization: Bearer $TOKEN"

# 获取歌单歌曲
curl -X GET "http://localhost:3000/api/v1/playlist/songs/1"

# 收藏歌单（需要另一个用户的歌单）
curl -X POST "http://localhost:3000/api/v1/playlist/collect/2" \
  -H "Authorization: Bearer $TOKEN"

# 获取收藏的歌单
curl -X GET "http://localhost:3000/api/v1/playlist/collected" \
  -H "Authorization: Bearer $TOKEN"
```

## 测试注意事项

1. **数据依赖**: 歌曲创建需要先有艺术家数据，建议先手动插入一些测试数据
2. **权限控制**: 某些操作需要特定权限，确保使用正确的用户Token
3. **数据完整性**: 删除操作会级联删除相关数据，测试时注意数据备份
4. **性能考虑**: 大量数据查询时注意分页参数，避免一次性加载过多数据

---

**更新日期**: 2024-01-15
**版本**: v1.0.0
**维护者**: 开发团队 