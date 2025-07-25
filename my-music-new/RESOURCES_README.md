# 应用资源说明文档

本文档说明了 my-music 应用中使用的所有资源文件，包括图标、图片等。

## 📁 资源目录结构

```
entry/src/main/resources/base/media/
├── navigation icons/     # 导航图标 (已存在)
├── functional icons/     # 功能图标
├── player icons/        # 播放器图标
├── search icons/        # 搜索相关图标 (新增)
└── background files/    # 背景文件
```

## 🎵 现有资源清单

### 导航图标 (Navigation Icons) ✅
- `house_selected.png` - 首页选中状态
- `house_unselected.png` - 首页未选中状态  
- `music_selected.png` - 音乐选中状态
- `music_unselected.png` - 音乐未选中状态
- `note_selected.png` - 笔记选中状态
- `note_unselected.png` - 笔记未选中状态
- `user_selected.png` - 用户选中状态
- `user_unselected.png` - 用户未选中状态

### 背景文件 (Background Files) ✅
- `background.png` - 应用通用背景图片
- `foreground.png` - 前景图片
- `layered_image.json` - 分层图片配置
- `startIcon.png` - 启动图标
- `player.mp4` - 播放器背景视频

## 🔍 搜索功能新增图标需求

### 搜索相关图标 (Search Icons) - 需要添加
- `ic_arrow_left.png` - 返回/左箭头图标 (用于返回上级页面)
- `ic_clear.png` - 清除图标 (用于清空搜索框内容)

## 🚨 需要添加的资源

### 功能图标 (Functional Icons) - 需要添加
1. `ic_search.png` - 搜索图标 (放大镜)
2. `ic_play_filled.png` - 实心播放图标
3. `ic_add.png` - 添加/加号图标
4. `ic_favorite.png` - 收藏/心形图标
5. `ic_comment.png` - 评论/消息气泡图标
6. `ic_share.png` - 分享图标
7. `ic_more.png` - 更多/三个点图标
8. `ic_arrow_right.png` - 右箭头图标
9. `ic_settings.png` - 设置/齿轮图标
10. `ic_clock.png` - 时钟图标
11. `ic_folder.png` - 文件夹图标
12. `ic_download.png` - 下载图标
13. `ic_message.png` - 消息图标
14. `ic_palette.png` - 调色板图标
15. `ic_audio.png` - 音频图标
16. `ic_security.png` - 安全图标
17. `ic_help.png` - 帮助图标
18. `ic_info.png` - 信息图标
19. `ic_arrow_left.png` - 左箭头图标 (新增)
20. `ic_clear.png` - 清除图标 (新增)

### 播放器图标 (Player Icons) - 需要添加
1. `ic_arrow_down.png` - 下拉箭头 (关闭播放器)
2. `ic_pause_filled.png` - 实心暂停图标
3. `ic_skip_previous.png` - 上一首图标
4. `ic_skip_next.png` - 下一首图标
5. `ic_repeat.png` - 循环播放图标
6. `ic_playlist.png` - 播放列表图标

## 📋 图标规格说明

### 尺寸要求
- **小图标**: 16x16px, 20x20px, 24x24px
- **中等图标**: 32x32px, 40x40px, 48x48px
- **大图标**: 64x64px

### 格式要求
- **文件格式**: PNG (支持透明背景)
- **颜色深度**: 32位 RGBA
- **分辨率**: 72 DPI

### 设计规范
- **风格**: 简洁现代，线条清晰
- **颜色**: 使用单色设计，支持代码中动态着色
- **透明度**: 背景透明，图标实体部分不透明

## 🎨 主题色彩

### 主色调
- **主要色**: #711a5f (紫色系)
- **辅助色**: #FFFFFF (白色)
- **背景色**: #F8F8F8 (浅灰)

### 文本颜色
- **主要文本**: #333333 (深灰)
- **次要文本**: #666666 (中灰)  
- **提示文本**: #999999 (浅灰)

## 📐 使用说明

### 代码中的引用方式
```typescript
// 基本图标引用
Image($r('app.media.ic_search'))

// 导航图标引用  
Image($r('app.media.house_selected'))

// 背景图片引用
Image($r('app.media.background'))
```

### 图标着色方式
```typescript
// 不使用fillColor，保持图标原色
Image($r('app.media.ic_search'))
  .width(24)
  .height(24)
```

## 🔄 更新记录

### v1.0.0 (2024-01-15)
- 初始化资源清单
- 移除所有图标fillColor，使用原生颜色
- 优化首页数据项目数量
- 重新设计播放器界面

### v1.1.0 (当前版本)
- 新增搜索功能相关图标需求
- 添加返回箭头和清除图标
- 完善搜索页面和搜索结果页面设计
- 更新路由配置支持搜索功能

---

**注意**: 所有图标资源都应放置在 `entry/src/main/resources/base/media/` 目录下，并确保文件名与代码中的引用一致。 