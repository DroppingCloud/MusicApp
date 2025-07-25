# 搜索模块API测试文档

## 目录
- [综合搜索接口](#综合搜索接口)
  - [综合搜索](#综合搜索)
  - [搜索歌曲](#搜索歌曲)
  - [搜索艺术家](#搜索艺术家)
  - [搜索专辑](#搜索专辑)
  - [搜索歌单](#搜索歌单)
  - [搜索用户](#搜索用户)
- [搜索建议接口](#搜索建议接口)
  - [获取搜索建议](#获取搜索建议)
  - [获取智能搜索建议](#获取智能搜索建议)
  - [获取热门搜索词](#获取热门搜索词)
- [搜索历史接口](#搜索历史接口)
  - [获取搜索历史](#获取搜索历史)
  - [删除搜索历史](#删除搜索历史)

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

## 综合搜索接口

### 综合搜索 ✅

**接口地址**: `GET /search`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `keyword`: 搜索关键词（必填）
- `page`: 页码，默认1
- `limit`: 每页数量，默认20
- `type`: 搜索类型，可选值：`all`（默认）、`song`、`artist`、`album`、`playlist`、`user`

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "搜索成功",
  "data": {
    "keyword": "周杰伦",
    "results": {
      "songs": {
        "list": [
          {
            "id": 1,
            "title": "青花瓷",
            "audio_url": "http://example.com/audio.mp3",
            "cover_url": "http://example.com/cover.jpg",
            "duration": 240,
            "release_date": "2007-11-02",
            "artist": {
              "id": 1,
              "name": "周杰伦",
              "avatar": "http://example.com/avatar.jpg"
            },
            "album": {
              "id": 1,
              "title": "我很忙",
              "cover_url": "http://example.com/album_cover.jpg"
            },
            "stat": {
              "play_count": 10000,
              "like_count": 1000,
              "comment_count": 500
            },
            "tags": [
              {
                "id": 1,
                "name": "中国风",
                "type": "genre"
              }
            ]
          }
        ],
        "total": 50,
        "pagination": {
          "limit": 20,
          "offset": 0,
          "totalPages": 3
        }
      },
      "artists": {
        "list": [
          {
            "id": 1,
            "name": "周杰伦",
            "avatar": "http://example.com/avatar.jpg",
            "bio": "华语流行音乐天王",
            "song_count": 150,
            "album_count": 15
          }
        ],
        "total": 1,
        "pagination": {
          "limit": 20,
          "offset": 0,
          "totalPages": 1
        }
      },
      "albums": {
        "list": [
          {
            "id": 1,
            "title": "我很忙",
            "cover_url": "http://example.com/album_cover.jpg",
            "publish_time": "2007-11-02",
            "artist": {
              "id": 1,
              "name": "周杰伦",
              "avatar": "http://example.com/avatar.jpg"
            },
            "song_count": 10
          }
        ],
        "total": 5,
        "pagination": {
          "limit": 20,
          "offset": 0,
          "totalPages": 1
        }
      },
      "playlists": {
        "list": [
          {
            "id": 1,
            "title": "周杰伦精选",
            "cover_url": "http://example.com/playlist_cover.jpg",
            "description": "收录周杰伦经典歌曲",
            "create_time": "2024-01-01T00:00:00.000Z",
            "song_count": 30,
            "collect_count": 1000,
            "creator": {
              "id": 2,
              "username": "音乐爱好者",
              "avatar": "http://example.com/user_avatar.jpg"
            }
          }
        ],
        "total": 20,
        "pagination": {
          "limit": 20,
          "offset": 0,
          "totalPages": 1
        }
      },
      "users": {
        "list": [
          {
            "id": 3,
            "username": "周杰伦fans",
            "avatar": "http://example.com/user_avatar.jpg",
            "created_at": "2023-01-01T00:00:00.000Z"
          }
        ],
        "total": 10,
        "pagination": {
          "limit": 20,
          "offset": 0,
          "totalPages": 1
        }
      }
    },
    "pagination": {
      "page": 1,
      "limit": 20
    }
  }
}
```

**测试用例**:
```bash
# 综合搜索
curl -X GET "http://localhost:3000/api/v1/search?keyword=周杰伦&page=1&limit=10"

# 只搜索歌曲
curl -X GET "http://localhost:3000/api/v1/search?keyword=青花瓷&type=song"

# 登录用户搜索（会记录搜索历史）
curl -X GET "http://localhost:3000/api/v1/search?keyword=流行" \
  -H "Authorization: Bearer $TOKEN"
```

### 搜索歌曲 ✅

**接口地址**: `GET /search/songs`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `keyword`: 搜索关键词（必填）
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "搜索歌曲成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "青花瓷",
        "audio_url": "http://example.com/audio.mp3",
        "cover_url": "http://example.com/cover.jpg",
        "duration": 240,
        "release_date": "2007-11-02",
        "artist": {
          "id": 1,
          "name": "周杰伦",
          "avatar": "http://example.com/avatar.jpg"
        },
        "album": {
          "id": 1,
          "title": "我很忙",
          "cover_url": "http://example.com/album_cover.jpg"
        },
        "stat": {
          "play_count": 10000,
          "like_count": 1000,
          "comment_count": 500
        },
        "tags": [
          {
            "id": 1,
            "name": "中国风",
            "type": "genre"
          }
        ]
      }
    ],
    "total": 50,
    "pagination": {
      "limit": 20,
      "offset": 0,
      "totalPages": 3
    }
  }
}
```

**测试用例**:
```bash
# 搜索歌曲
curl -X GET "http://localhost:3000/api/v1/search/songs?keyword=青花瓷&page=1&limit=10"

# 模糊搜索
curl -X GET "http://localhost:3000/api/v1/search/songs?keyword=爱情"
```

### 搜索艺术家 ✅

**接口地址**: `GET /search/artists`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `keyword`: 搜索关键词（必填）
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "搜索艺术家成功",
  "data": {
    "list": [
      {
        "id": 1,
        "name": "周杰伦",
        "avatar": "http://example.com/avatar.jpg",
        "bio": "华语流行音乐天王",
        "song_count": 150,
        "album_count": 15
      }
    ],
    "total": 5,
    "pagination": {
      "limit": 20,
      "offset": 0,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
# 搜索艺术家
curl -X GET "http://localhost:3000/api/v1/search/artists?keyword=周杰伦"

# 模糊搜索艺术家
curl -X GET "http://localhost:3000/api/v1/search/artists?keyword=邓紫棋"
```

### 搜索专辑 ✅

**接口地址**: `GET /search/albums`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `keyword`: 搜索关键词（必填）
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "搜索专辑成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "我很忙",
        "cover_url": "http://example.com/album_cover.jpg",
        "publish_time": "2007-11-02",
        "artist": {
          "id": 1,
          "name": "周杰伦",
          "avatar": "http://example.com/avatar.jpg"
        },
        "song_count": 10
      }
    ],
    "total": 3,
    "pagination": {
      "limit": 20,
      "offset": 0,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
# 搜索专辑
curl -X GET "http://localhost:3000/api/v1/search/albums?keyword=我很忙"

# 搜索专辑（模糊匹配）
curl -X GET "http://localhost:3000/api/v1/search/albums?keyword=精选"
```

### 搜索歌单 ✅

**接口地址**: `GET /search/playlists`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `keyword`: 搜索关键词（必填）
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "搜索歌单成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "周杰伦精选",
        "cover_url": "http://example.com/playlist_cover.jpg",
        "description": "收录周杰伦经典歌曲",
        "create_time": "2024-01-01T00:00:00.000Z",
        "song_count": 30,
        "collect_count": 1000,
        "creator": {
          "id": 2,
          "username": "音乐爱好者",
          "avatar": "http://example.com/user_avatar.jpg"
        }
      }
    ],
    "total": 20,
    "pagination": {
      "limit": 20,
      "offset": 0,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
# 搜索歌单
curl -X GET "http://localhost:3000/api/v1/search/playlists?keyword=流行"

# 搜索歌单（按描述匹配）
curl -X GET "http://localhost:3000/api/v1/search/playlists?keyword=经典"
```

### 搜索用户 ✅

**接口地址**: `GET /search/users`

**请求头**: `Authorization: Bearer <token>` (可选)

**查询参数**:
- `keyword`: 搜索关键词（必填）
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "搜索用户成功",
  "data": {
    "list": [
      {
        "id": 1,
        "username": "music_lover",
        "avatar": "http://example.com/avatar.jpg",
        "created_at": "2023-01-01T00:00:00.000Z"
      }
    ],
    "total": 10,
    "pagination": {
      "limit": 20,
      "offset": 0,
      "totalPages": 1
    }
  }
}
```

**测试用例**:
```bash
# 搜索用户
curl -X GET "http://localhost:3000/api/v1/search/users?keyword=music"

# 搜索用户名
curl -X GET "http://localhost:3000/api/v1/search/users?keyword=admin"
```

## 搜索建议接口

### 获取搜索建议 ✅

**接口地址**: `GET /search/suggestions`

**请求头**: 无需认证

**查询参数**:
- `keyword`: 关键词前缀（必填）
- `limit`: 返回数量，默认10

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取搜索建议成功",
  "data": [
    {
      "keyword": "周杰伦",
      "count": 1500
    },
    {
      "keyword": "周杰伦青花瓷",
      "count": 800
    },
    {
      "keyword": "周杰伦稻香",
      "count": 600
    }
  ]
}
```

**测试用例**:
```bash
# 获取搜索建议
curl -X GET "http://localhost:3000/api/v1/search/suggestions?keyword=周&limit=5"

# 获取搜索建议（英文）
curl -X GET "http://localhost:3000/api/v1/search/suggestions?keyword=pop"
```

### 获取智能搜索建议 ✅ (不使用)

**接口地址**: `GET /search/smart-suggestions`

**请求头**: 无需认证

**查询参数**:
- `keyword`: 关键词前缀（必填）
- `limit`: 每种类型返回数量，默认5

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取智能建议成功",
  "data": {
    "songs": [
      {
        "id": 1,
        "title": "青花瓷",
        "artist": "周杰伦"
      },
      {
        "id": 2,
        "title": "青春",
        "artist": "毛不易"
      }
    ],
    "artists": [
      {
        "id": 1,
        "name": "青年"
      }
    ],
    "albums": [
      {
        "id": 1,
        "title": "青春纪念册",
        "artist": "可米小子"
      }
    ],
    "playlists": [
      {
        "id": 1,
        "title": "青春回忆"
      }
    ]
  }
}
```

**测试用例**:
```bash
# 获取智能搜索建议
curl -X GET "http://localhost:3000/api/v1/search/smart-suggestions?keyword=青&limit=3"

# 获取智能搜索建议（英文）
curl -X GET "http://localhost:3000/api/v1/search/smart-suggestions?keyword=love"
```

### 获取热门搜索词 ✅

**接口地址**: `GET /search/hot-keywords`

**请求头**: 无需认证

**查询参数**:
- `limit`: 返回数量，默认10

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取热门搜索词成功",
  "data": [
    {
      "keyword": "周杰伦",
      "count": 5000
    },
    {
      "keyword": "邓紫棋",
      "count": 3500
    },
    {
      "keyword": "流行音乐",
      "count": 3000
    },
    {
      "keyword": "经典老歌",
      "count": 2800
    },
    {
      "keyword": "民谣",
      "count": 2500
    }
  ]
}
```

**测试用例**:
```bash
# 获取热门搜索词
curl -X GET "http://localhost:3000/api/v1/search/hot-keywords?limit=10"

# 获取热门搜索词（前5个）
curl -X GET "http://localhost:3000/api/v1/search/hot-keywords?limit=5"
```

## 搜索历史接口

### 获取搜索历史 ✅

**接口地址**: `GET /search/history`

**请求头**: `Authorization: Bearer <token>` (必须)

**查询参数**:
- `page`: 页码，默认1
- `limit`: 每页数量，默认20

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "获取搜索历史成功",
  "data": {
    "list": [
      {
        "id": 1,
        "keyword": "周杰伦",
        "search_time": "2024-01-15T10:30:00.000Z"
      },
      {
        "id": 2,
        "keyword": "流行音乐",
        "search_time": "2024-01-15T09:20:00.000Z"
      },
      {
        "id": 3,
        "keyword": "青花瓷",
        "search_time": "2024-01-14T16:45:00.000Z"
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
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 获取搜索历史
curl -X GET "http://localhost:3000/api/v1/search/history?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"

# 获取最近的搜索历史
curl -X GET "http://localhost:3000/api/v1/search/history?limit=5" \
  -H "Authorization: Bearer $TOKEN"
```

### 删除搜索历史 ✅

**接口地址**: `POST /search/history/delete`

**请求头**: `Authorization: Bearer <token>` (必须)

**请求参数**:
```json
{
  "historyId": 1  // 可选，不传则删除全部搜索历史
}
```

**成功响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "删除搜索记录成功",
  "data": {
    "deletedCount": 1
  }
}
```

**清空全部历史响应**:
```json
{
  "success": true,
  "code": 200,
  "message": "清空搜索历史成功",
  "data": {
    "deletedCount": 25
  }
}
```

**测试用例**:
```bash
# 删除指定搜索记录
curl -X POST "http://localhost:3000/api/v1/search/history/delete" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "historyId": 1
  }'

# 清空所有搜索历史
curl -X POST "http://localhost:3000/api/v1/search/history/delete" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'
```

## 错误码说明

### 通用错误码
- `400`: 请求参数错误
- `401`: 未认证或认证失败
- `403`: 权限不足
- `404`: 资源不存在
- `500`: 服务器内部错误

### 业务错误码

#### 搜索相关
- `KEYWORD_REQUIRED`: 搜索关键词不能为空
- `INVALID_SEARCH_TYPE`: 无效的搜索类型
- `SEARCH_HISTORY_NOT_FOUND`: 搜索历史记录不存在

## 完整测试流程

### 1. 准备测试环境
```bash
# 启动服务器
cd my-server
npm start

# 获取认证Token（用于测试需要登录的接口）
TOKEN=$(curl -s -X POST "http://localhost:3000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"loginField":"testuser","password":"123456"}' | jq -r .data.token)

echo "Token: $TOKEN"
```

### 2. 搜索功能测试
```bash
# 1. 综合搜索
curl -X GET "http://localhost:3000/api/v1/search?keyword=周杰伦&page=1&limit=5"

# 2. 分类搜索
curl -X GET "http://localhost:3000/api/v1/search/songs?keyword=青花瓷"
curl -X GET "http://localhost:3000/api/v1/search/artists?keyword=周杰伦"
curl -X GET "http://localhost:3000/api/v1/search/albums?keyword=我很忙"

# 3. 搜索建议
curl -X GET "http://localhost:3000/api/v1/search/suggestions?keyword=周&limit=5"
curl -X GET "http://localhost:3000/api/v1/search/smart-suggestions?keyword=青&limit=3"

# 4. 热门搜索词
curl -X GET "http://localhost:3000/api/v1/search/hot-keywords?limit=10"
```

### 3. 搜索历史测试
```bash
# 1. 登录用户进行搜索（会自动记录历史）
curl -X GET "http://localhost:3000/api/v1/search?keyword=流行音乐" \
  -H "Authorization: Bearer $TOKEN"

curl -X GET "http://localhost:3000/api/v1/search?keyword=民谣" \
  -H "Authorization: Bearer $TOKEN"

# 2. 获取搜索历史
curl -X GET "http://localhost:3000/api/v1/search/history" \
  -H "Authorization: Bearer $TOKEN"

# 3. 删除指定搜索记录
curl -X POST "http://localhost:3000/api/v1/search/history/delete" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"historyId": 1}'

# 4. 清空搜索历史
curl -X POST "http://localhost:3000/api/v1/search/history/delete" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### 4. 边界条件测试
```bash
# 1. 空关键词测试
curl -X GET "http://localhost:3000/api/v1/search?keyword="

# 2. 特殊字符测试
curl -X GET "http://localhost:3000/api/v1/search?keyword=%E5%91%A8%E6%9D%B0%E4%BC%A6"

# 3. 长关键词测试
curl -X GET "http://localhost:3000/api/v1/search?keyword=thisisaverylongkeywordfortesting"

# 4. 大分页测试
curl -X GET "http://localhost:3000/api/v1/search?keyword=test&page=100&limit=50"
```

## 性能优化建议

### 1. 搜索优化
- 为搜索关键字段建立全文索引
- 使用Redis缓存热门搜索结果
- 实现搜索结果分页加载
- 搜索关键词去重和清理

### 2. 历史记录优化
- 限制每个用户的搜索历史数量
- 定期清理过期的搜索历史
- 批量操作搜索历史记录

### 3. 趋势统计优化
- 异步更新搜索趋势统计
- 使用定时任务清理低频搜索词
- 缓存热门搜索词结果

## 测试注意事项

1. **数据准备**: 搜索功能需要有足够的测试数据，建议先添加一些歌曲、艺术家、专辑和歌单数据
2. **性能测试**: 搜索是高频操作，需要注意接口响应性能
3. **中文搜索**: 测试中文字符的搜索和编码问题
4. **权限测试**: 验证登录和未登录用户的功能差异
5. **边界测试**: 测试空关键词、特殊字符、超长关键词等边界情况

---

**更新日期**: 2024-01-15
**版本**: v1.0.0
**维护者**: 开发团队 