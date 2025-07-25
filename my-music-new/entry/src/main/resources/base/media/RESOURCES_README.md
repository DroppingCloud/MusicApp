# 自定义资源文件清单

## 说明
此文档列出了项目中需要的所有自定义资源文件，这些文件应放置在 `entry/src/main/resources/base/media` 目录下。

## 已有资源文件
- `house_selected.svg` - 首页选中状态图标
- `house_unselected.svg` - 首页未选中状态图标
- `music_selected.svg` - 音乐选中状态图标
- `music_unselected.svg` - 音乐未选中状态图标（也用作歌曲封面占位图）
- `note_selected.svg` - 笔记选中状态图标
- `note_unselected.svg` - 笔记未选中状态图标
- `user_selected.svg` - 用户选中状态图标
- `user_unselected.svg` - 用户未选中状态图标（也用作用户头像占位图）

## 需要新增的资源文件(已增加)

### 视频资源
- `player.mp4` - 播放器页面动态背景视频（海浪、日落等自然风景）

### 功能图标
1. `ic_search.svg` - 搜索图标（放大镜图标）
2. `ic_play_filled.svg` - 播放按钮图标（填充的三角形）
3. `ic_add.svg` - 添加图标（加号图标）
4. `ic_favorite.svg` - 收藏图标（空心爱心图标）
5. `ic_favorite_filled.svg` - 收藏图标填充版本（实心爱心图标）
6. `ic_comment.svg` - 评论图标（消息气泡图标）
7. `ic_share.svg` - 分享图标（分享箭头图标）
8. `ic_more.svg` - 更多操作图标（三个点图标）
9. `ic_arrow_right.svg` - 右箭头图标（指向右的箭头）

### 菜单和设置图标
10. `ic_settings.svg` - 设置图标（齿轮图标）
11. `ic_clock.svg` - 时钟图标（表示历史记录）
12. `ic_folder.svg` - 文件夹图标（表示歌单或本地扫描）
13. `ic_download.svg` - 下载图标（下载箭头图标）
14. `ic_message.svg` - 消息图标（信封或消息气泡）
15. `ic_palette.svg` - 调色板图标（表示主题设置）
16. `ic_audio.svg` - 音频图标（表示播放设置）
17. `ic_security.svg` - 安全图标（盾牌图标）
18. `ic_help.svg` - 帮助图标（问号图标）
19. `ic_info.svg` - 信息图标（感叹号或i图标）

## 需要新增的资源文件(已增加)

### 播放器控制图标
20. `ic_arrow_down.svg` - 下拉箭头图标（关闭播放器）
21. `ic_pause_filled.svg` - 暂停图标（填充版本）
22. `ic_skip_previous.svg` - 上一首图标（左向双箭头）
23. `ic_skip_next.svg` - 下一首图标（右向双箭头）
24. `ic_repeat.svg` - 循环播放图标（循环箭头）
25. `ic_playlist.svg` - 播放列表图标（列表图标）

## 图标设计建议
- **格式**：建议使用 SVG 格式，便于缩放和着色
- **尺寸**：建议 24x24px 基础尺寸
- **样式**：线性图标风格，笔画粗细一致
- **颜色**：单色图标，支持通过 fillColor 属性动态着色
- **文件命名**：使用小写字母和下划线分隔，如 `ic_play_filled.svg`

## 占位方案
如果暂时没有设计图标，可以：
1. 使用在线图标库（如 Feather Icons、Material Icons）下载SVG格式
2. 使用简单的几何形状作为占位图标
3. 参考现有的系统图标设计类似的自定义图标

## 使用说明
代码中所有系统资源都已替换为自定义资源路径，格式为：
```typescript
Image($r('app.media.ic_图标名称'))
```

每个图标使用位置都已添加注释说明其用途和含义。 