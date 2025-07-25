# 我的音乐 - HarmonyOS音乐社交应用

一个基于HarmonyOS ArkTS和ArkUI开发的全功能音乐社交应用，提供音乐播放、社交互动、内容发现等丰富功能。

## 📱 功能特性

### 🎵 音乐功能
- 在线音乐播放和本地音乐管理
- 多种播放模式（顺序、循环、随机、单曲循环）
- 歌单创建和管理
- 音乐收藏和播放历史
- 高品质音频支持（无损/高清/标准）
- 个性化音乐推荐

### 🌐 社交功能
- 用户关注和粉丝系统
- 音乐笔记分享和评论
- 点赞和互动
- 私信聊天
- 音乐动态分享

### 🔍 发现功能
- 综合搜索（歌曲、艺术家、专辑、用户、笔记）
- 音乐分类和榜单
- 热门搜索和搜索历史
- 智能推荐算法

### 👤 用户系统
- 完整的用户注册登录体系
- 个人资料和偏好设置
- 多主题支持
- 数据同步和备份

## 🏗️ 项目架构

```
my-music/
├── AppScope/                    # 应用级配置
│   ├── app.json5               # 应用配置文件
│   └── resources/              # 应用级资源
├── entry/                      # 主模块
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/   # 应用入口
│   │   │   ├── pages/          # 页面组件
│   │   │   │   ├── Index.ets   # 主页面（Tab导航）
│   │   │   │   ├── Home/       # 首页
│   │   │   │   │   └── HomePage.ets
│   │   │   │   ├── Discovery/  # 漫游页面
│   │   │   │   │   └── DiscoveryPage.ets
│   │   │   │   ├── Note/       # 笔记页面
│   │   │   │   │   └── NotePage.ets
│   │   │   │   ├── Profile/    # 个人页面
│   │   │   │   │   └── ProfilePage.ets
│   │   │   │   ├── Player/     # 播放器页面
│   │   │   │   ├── Auth/       # 认证页面
│   │   │   │   └── Detail/     # 详情页面
│   │   │   ├── components/     # 组件库
│   │   │   │   ├── player/     # 播放器组件
│   │   │   │   └── common/     # 通用组件
│   │   │   │       └── SongItem.ets
│   │   │   ├── models/         # 数据模型
│   │   │   │   ├── User.ets    # 用户相关模型
│   │   │   │   ├── Music.ets   # 音乐相关模型
│   │   │   │   ├── Social.ets  # 社交相关模型
│   │   │   │   ├── Search.ets  # 搜索相关模型
│   │   │   │   ├── Common.ets  # 通用模型
│   │   │   │   ├── PlayerState.ets # 播放器状态
│   │   │   │   └── Song.ets    # 兼容性导出
│   │   │   ├── services/       # 服务层
│   │   │   │   ├── HttpClient.ets    # HTTP客户端
│   │   │   │   ├── UserService.ets   # 用户服务
│   │   │   │   ├── MusicService.ets  # 音乐服务
│   │   │   │   ├── SocialService.ets # 社交服务
│   │   │   │   ├── SearchService.ets # 搜索服务
│   │   │   │   └── PlayerService.ets # 播放器服务
│   │   │   ├── utils/          # 工具类
│   │   │   │   └── TimeUtils.ets # 时间工具
│   │   │   └── constants/      # 常量定义
│   │   │       └── AppConstants.ets # 应用常量
│   │   ├── module.json5        # 模块配置
│   │   └── resources/          # 资源文件
│   │       ├── base/           # 基础资源
│   │       │   └── media/      # 自定义图标资源
│   │       ├── dark/           # 深色主题资源
│   │       └── rawfile/        # 原始文件
│   └── oh-package.json5        # 模块依赖配置
├── database/                   # 数据库文档
│   └── my-app.sql             # 数据库表结构
├── docs/                      # API文档
│   ├── 用户模块API测试文档.md
│   ├── 音乐模块API测试文档.md
│   ├── 社交模块API测试文档.md
│   └── 搜索模块API测试文档.md
├── build-profile.json5        # 构建配置
├── hvigorfile.ts             # 构建脚本
└── oh-package.json5          # 项目依赖配置
```

## 🛠️ 技术栈

- **开发语言**: ArkTS (TypeScript扩展)
- **UI框架**: ArkUI
- **平台**: HarmonyOS
- **构建工具**: Hvigor
- **包管理**: ohpm
- **网络请求**: @kit.NetworkKit
- **媒体播放**: @kit.MediaKit

## 📋 核心模块说明

### 数据模型层 (Models)
- **User.ets**: 用户信息、登录注册、个人资料等模型
- **Music.ets**: 歌曲、艺术家、专辑、歌单等音乐相关模型
- **Social.ets**: 关注、点赞、评论、笔记、聊天等社交模型
- **Search.ets**: 搜索请求、结果、历史、热词等搜索模型
- **Common.ets**: API响应、分页、配置等通用模型
- **PlayerState.ets**: 播放器状态和配置模型

### 服务层 (Services)
- **HttpClient.ets**: 统一的HTTP请求客户端，支持认证和错误处理
- **UserService.ets**: 用户认证、资料管理、行为记录等服务
- **MusicService.ets**: 音乐资源管理、歌单操作等服务
- **SocialService.ets**: 社交功能、笔记管理、聊天等服务
- **SearchService.ets**: 搜索功能、建议、历史管理等服务
- **PlayerService.ets**: 音频播放控制和状态管理服务

### 页面架构 (Pages)
- **Index.ets**: 主页面，底部Tab导航容器
- **HomePage.ets**: 首页，音乐推荐和快速访问
- **DiscoveryPage.ets**: 漫游页，音乐发现和社交内容
- **NotePage.ets**: 笔记页，音乐笔记和收藏管理
- **ProfilePage.ets**: 个人页，用户中心和应用设置

### 组件库 (Components)
- **SongItem.ets**: 歌曲列表项通用组件
- 更多组件开发中...

## 🎨 设计系统

### 颜色规范
- **主色调**: #007DFF (HarmonyOS蓝)
- **成功色**: #52C41A
- **警告色**: #FAAD14
- **错误色**: #F5222D
- **文字色**: #333333 / #666666 / #999999

### 尺寸规范
- **导航栏**: 60px
- **列表项**: 60px
- **封面图**: 40px / 60px / 120px / 200px
- **圆角**: 4px / 8px / 12px

## 🌐 后端接口

项目包含完整的后端API文档，支持以下模块：

### 用户模块
- 用户注册、登录、资料管理
- 播放历史、收藏、关注等行为数据
- 头像上传、设置管理

### 音乐模块
- 歌曲、专辑、艺术家信息管理
- 歌单创建、编辑、分享
- 播放统计、推荐算法

### 社交模块
- 用户关注关系管理
- 音乐笔记发布、评论、点赞
- 私信聊天功能

### 搜索模块
- 综合搜索、分类搜索
- 搜索建议、热词统计
- 搜索历史管理

## 🚀 开发环境搭建

1. **环境要求**
   - DevEco Studio 4.0+
   - HarmonyOS SDK API 9+
   - Node.js 16+ (后端开发)

2. **项目配置**
   ```bash
   # 克隆项目
   git clone <repository-url>
   cd my-music
   
   # 使用DevEco Studio打开项目
   # 配置签名和设备
   # 点击运行调试
   ```

3. **后端服务**
   - 参考API文档配置后端服务
   - 修改 `AppConstants.ets` 中的API_BASE_URL
   - 确保网络权限配置正确

## 📝 开发规范

### 代码规范
- 遵循ArkTS官方代码规范
- 使用TypeScript严格模式
- 组件命名使用PascalCase
- 服务和工具类使用camelCase
- 常量使用UPPER_SNAKE_CASE

### 文件组织
- 按功能模块组织代码结构
- 单一职责原则，每个文件功能明确
- 统一的导入导出规范
- 完善的类型定义

### Git提交规范
- feat: 新功能
- fix: 修复问题
- docs: 文档更新
- style: 代码格式调整
- refactor: 重构代码
- test: 测试相关

## 🔄 开发路线图

### Phase 1: 基础功能 (已完成)
- ✅ 项目架构搭建
- ✅ 数据模型设计
- ✅ 服务层封装
- ✅ 页面框架开发
- ✅ 导航系统实现

### Phase 2: 核心功能 (开发中)
- 🔄 用户认证系统
- 🔄 音乐播放功能
- 🔄 数据加载和状态管理
- 🔄 基础UI组件库

### Phase 3: 高级功能 (计划中)
- 📋 社交功能实现
- 📋 搜索和推荐
- 📋 离线下载
- 📋 主题系统

### Phase 4: 优化完善 (计划中)
- 📋 性能优化
- 📋 动画效果
- 📋 国际化支持
- 📋 无障碍功能

## 🤝 贡献指南

1. Fork 项目到个人仓库
2. 创建功能分支 `git checkout -b feature/AmazingFeature`
3. 提交更改 `git commit -m 'Add some AmazingFeature'`
4. 推送到分支 `git push origin feature/AmazingFeature`
5. 创建 Pull Request

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 👥 开发团队

- **项目架构**: Harmony Music Team
- **UI设计**: 遵循HarmonyOS设计语言
- **后端开发**: Node.js + Express + MySQL

---

**注意**: 这是一个功能完整的音乐社交应用项目，当前版本提供了完整的架构设计和核心框架。具体的业务功能正在逐步实现中。
