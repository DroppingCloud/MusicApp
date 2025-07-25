/**
 * 我的喜欢页面
 */
import router from '@ohos.router';
import { UserService } from '../../services/UserService';
import { MusicService } from '../../services/MusicService';
import { UserFavorite } from '../../models/User';
import { Song } from '../../models/Music';
import { PaginationParams } from '../../models/Common';
import AppConstants from '../../constants/AppConstants';

@Entry
@Component
export struct FavoritesPage {
  @State songs: Song[] = []; // 喜欢的音乐详情
  @State isLoading: boolean = true; // 加载状态
  @State hasMore: boolean = true; // 是否有更多内容
  @State currentPage: number = 1; // 分页页码
  @State totalCount: number = 0; // 总数量
  private userService = new UserService(); // 用户服务
  private musicService = new MusicService(); // 音乐服务

  /**
   * 处理相对URL，拼接完整的图片URL
   */
  private getFullImageUrl(url: string | undefined): string | undefined {
    if (!url) {
      return undefined;
    }

    // 如果已经是完整URL，直接返回
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // 拼接baseURL，去掉"/api/v1"部分
    const baseUrl = AppConstants.API.BASE_URL.replace('/api/v1', '');
    return `${baseUrl}${url}`;
  }

  // 即将进入视图时的生命周期钩子函数
  aboutToAppear(): void {
    console.log('=== FavoritesPage.aboutToAppear 开始 ===');
    this.loadFavoritesData();
    console.log('=== FavoritesPage.aboutToAppear 结束 ===');
  }

  build() {
    Column() {
      // 导航栏
      this.buildNavigationBar()

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color($r('app.color.primary'))

          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.songs.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.ic_favorite'))
            .width(80)
            .height(80)
            .fillColor($r('app.color.surface'))
            .margin({ bottom: 16 })

          Text('暂无收藏歌曲')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })

          Text('快去收藏一些好听的歌曲吧')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 内容区域
        Column() {
          // 喜欢列表信息头部
          this.buildFavoritesHeader()

          // 操作按钮
          this.buildActionButtons()

          // 歌曲列表
          this.buildSongList()
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface'))

  }

  // 导航栏构建
  @Builder
  buildNavigationBar() {
    Row() {
      // 返回按钮
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .onClick(() => {
          router.back();
        })

      Text('我的喜欢')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 更多操作
      Image($r('app.media.ic_more'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.showMoreActions();
        })
    }
    .width('100%')
    .padding(16)
  }

  // 喜欢列表信息头部构建
  @Builder
  buildFavoritesHeader() {
    Row() {
      // 喜欢列表封面
      Image($r('app.media.ic_favorite_filled'))
        .width(120)
        .height(120)
        .borderRadius(8)
        .backgroundColor('#ccffd1e0')
        .fillColor('#b3ff0044')

      // 喜欢列表信息
      Column() {
        Text('我的喜欢')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text('个人收藏')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })

        Text('这里收藏了你喜欢的音乐')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(`${this.totalCount}首`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(8)
    .margin({ left: 16, right: 16, top: 0 })
  }

  // 操作按钮构建
  @Builder
  buildActionButtons() {
    Row() {
      // 播放全部
      Button('播放全部')
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor('#ffff8ba4')
        .borderRadius(20)
        .layoutWeight(1)
        .enabled(this.songs.length > 0)
        .onClick(() => {
          this.playAllSongs();
        })

      // 清空收藏
      Button('清空收藏')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
        .backgroundColor($r('app.color.surface'))
        .border({ width: 1, color: $r('app.color.divider') })
        .borderRadius(20)
        .width(100)
        .margin({ left: 12 })
        .enabled(this.songs.length > 0)
        .onClick(() => {
          this.clearAllFavorites();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8 })
  }

  // 歌曲列表构建
  @Builder
  buildSongList() {
    Column() {
      // 歌曲列表标题
      Row() {
        Text(`歌曲列表 (${this.songs.length})`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)

        if (this.songs.length > 0) {
          Text('排序')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .onClick(() => {
              // TODO: 显示排序选项
              console.log('显示排序选项');
            })
        }
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 12
      })
      .margin({top:5})

      // 歌曲列表
      Column() {
        ForEach(this.songs, (song: Song, index: number) => {
          Row() {
            // 序号
            Text((index + 1).toString())
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width(32)
              .textAlign(TextAlign.Center)

            // 歌曲封面
            Image(this.getFullImageUrl(song.cover_url) || $r('app.media.music_unselected'))
              .width(44)
              .height(44)
              .borderRadius(4)
              .backgroundColor($r('app.color.divider'))
              .margin({ left: 8 })
              .objectFit(ImageFit.Cover)
              .onError(() => {
                console.warn('歌曲封面加载失败:', song.cover_url);
              })

            // 歌曲信息
            Column() {
              Row() {
                Text(song.title)
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                  .maxLines(1)
                  .layoutWeight(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')

                // // 播放按钮
                // Image($r('app.media.ic_play_filled'))
                //   .width(20)
                //   .height(20)
                //   .margin({ right: 32 })
                //   .onClick(() => {
                //     this.playSong(song, index);
                //   })

                // 取消收藏按钮
                Image($r('app.media.ic_favorite_filled'))
                  .width(20)
                  .height(20)
                  .onClick(() => {
                    this.removeFavorite(song, index);
                  })
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Text(song.artist.name)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(this.formatDuration(song.duration))
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })

          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 12,
            bottom: 12
          })
          .backgroundColor(index % 2 === 0 ? $r('app.color.surface') : $r('app.color.divider'))
          .onClick(() => {
            this.playSong(song, index);
          })
        })

        // 加载更多
        if (this.hasMore) {
          Button('加载更多')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.surface'))
            .border({ width: 1, color: $r('app.color.divider') })
            .borderRadius(20)
            .padding({
              left: 20,
              right: 20,
              top: 8,
              bottom: 8
            })
            .margin({ top: 16 })
            .onClick(() => {
              this.loadMoreSongs();
            })
        }
      }
      .width('100%')
      .backgroundColor($r('app.color.surface'))
      .borderRadius(8)
      .margin({ left: 16, right: 16, top: 0 })
    }
    .width('100%')
  }

  /**
   * 加载喜欢列表数据
   */
  private async loadFavoritesData(): Promise<void> {
    this.isLoading = true;

    try {
      console.log('=== 开始加载喜欢列表数据 ===');

      const params: PaginationParams = {
        page: 1,
        limit: 50
      };

      console.log('正在获取喜欢歌曲列表...');
      const response = await this.userService.getFavoriteSongs(params);

      console.log('喜欢歌曲列表API响应成功');
      console.log('总数:', response.pagination?.total || 0);
      console.log('当前页歌曲数:', response.list?.length || 0);

      // 设置总数
      this.totalCount = response.pagination?.total || 0;

      // 获取歌曲详情
      console.log('正在获取歌曲详情...');
      const songsWithDetails: Song[] = [];

      for (let favorite of response.list) {
        try {
          const songDetail = await this.musicService.getSongDetail(favorite.song_id);
          songsWithDetails.push(songDetail);
          console.log(`歌曲详情获取成功: ${songDetail.title}`);
        } catch (error) {
          console.warn(`歌曲详情获取失败: ${favorite.song_id}`, error);
        }
      }

      // 设置歌曲列表
      this.songs = songsWithDetails;
      this.hasMore = response.pagination.page < response.pagination.totalPages;
      this.currentPage = 1;

      console.log(`喜欢列表处理完成: ${this.songs.length}首歌曲，hasMore: ${this.hasMore}`);
      console.log('=== 喜欢列表数据加载完成 ===');

    } catch (error) {
      console.error('=== 加载喜欢列表数据失败 ===');
      console.error('错误类型:', typeof error);
      console.error('错误信息:', error);
      this.songs = [];
      this.totalCount = 0;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载更多歌曲
   */
  private async loadMoreSongs(): Promise<void> {
    if (!this.hasMore || this.isLoading) {
      return;
    }

    try {
      console.log('加载更多喜欢歌曲...');
      this.currentPage++;

      const params: PaginationParams = {
        page: this.currentPage,
        limit: 50
      };

      const response = await this.userService.getFavoriteSongs(params);

      // 获取新歌曲详情
      const newSongs: Song[] = [];
      for (let favorite of response.list) {
        try {
          const songDetail = await this.musicService.getSongDetail(favorite.song_id);
          newSongs.push(songDetail);
        } catch (error) {
          console.warn(`歌曲详情获取失败: ${favorite.song_id}`, error);
        }
      }

      this.songs = [...this.songs, ...newSongs];
      this.hasMore = response.pagination.page < response.pagination.totalPages;

      console.log(`加载更多喜欢歌曲成功，新增 ${newSongs.length} 首，总计 ${this.songs.length} 首`);

    } catch (error) {
      console.error('加载更多喜欢歌曲失败:', error);
      this.currentPage--; // 回退页码
    }
  }

  /**
   * 播放歌曲
   */
  private async playSong(song: Song, index: number): Promise<void> {
    try {
      console.log('准备播放歌曲:', song.title, 'by', song.artist?.name, 'ID:', song.id);

      // 先获取歌曲详情，确保有完整的播放信息
      console.log('正在获取歌曲详情...');
      const songDetail = await this.musicService.getSongDetail(song.id);
      console.log('歌曲详情获取成功:', songDetail.title, 'audio_url:', songDetail.audio_url);

      // 检查音频链接是否有效
      if (!songDetail.audio_url || songDetail.audio_url.trim() === '') {
        throw new Error(`歌曲《${songDetail.title}》暂无可播放的音频链接`);
      }

      // 导入播放器服务
      const PlayerServiceModule = await import('../../services/PlayerService');
      const playerService = PlayerServiceModule.PlayerService.getInstance();

      // 创建包含详情的播放列表
      const playlistWithDetails = await this.createPlaylistWithDetails(this.songs, index);

      // 将喜欢列表中的歌曲设为播放列表，从指定索引开始播放
      playerService.setPlaylist(playlistWithDetails, index);

      // 开始播放
      await playerService.playBySong(playlistWithDetails[index]);

      // 添加到播放历史
      try {
        await new UserService().addPlayHistory(songDetail.id);
      } catch (e) {
        console.warn('添加播放历史失败', e);
      }

      // 跳转到播放器页面
      router.pushUrl({
        url: 'pages/Player/PlayerPage'
      });

      // 调用播放API记录播放次数
      this.musicService.playSong(songDetail.id).catch((error: Error) => {
        console.warn('记录播放次数失败:', error);
      });

      console.log('歌曲播放启动成功');

    } catch (error) {
      console.error('播放歌曲失败:', error);
      const errorMessage = error instanceof Error ? error.message : '播放失败，请稍后重试';
      console.error('播放错误详情:', errorMessage);
      // TODO: 可以在这里添加Toast提示用户
    }
  }

  /**
   * 创建包含歌曲详情的播放列表
   */
  private async createPlaylistWithDetails(songs: Song[], currentIndex: number): Promise<Song[]> {
    const playlistWithDetails: Song[] = [];

    // 为了性能考虑，只预加载当前歌曲和前后几首的详情
    const preloadRange = 2; // 预加载前后2首
    const startIndex = Math.max(0, currentIndex - preloadRange);
    const endIndex = Math.min(songs.length - 1, currentIndex + preloadRange);

    for (let i = 0; i < songs.length; i++) {
      if (i >= startIndex && i <= endIndex) {
        try {
          // 预加载详情
          const songDetail = await this.musicService.getSongDetail(songs[i].id);
          playlistWithDetails[i] = songDetail;
          console.log(`预加载歌曲详情成功: ${songDetail.title}`);
        } catch (error) {
          console.warn(`预加载歌曲详情失败: ${songs[i].title}`, error);
          // 使用原始数据作为fallback
          playlistWithDetails[i] = songs[i];
        }
      } else {
        // 其他歌曲使用原始数据，播放时再获取详情
        playlistWithDetails[i] = songs[i];
      }
    }

    return playlistWithDetails;
  }

  /**
   * 播放全部歌曲
   */
  private async playAllSongs(): Promise<void> {
    if (this.songs.length > 0) {
      await this.playSong(this.songs[0], 0);
    }
  }

  /**
   * 移除收藏
   */
  private async removeFavorite(song: Song, index: number): Promise<void> {
    try {
      console.log('移除收藏歌曲:', song.title);

      // 调用取消收藏API
      await this.userService.unlikeSong(song.id);

      // 从列表中移除
      this.songs.splice(index, 1);
      this.totalCount = Math.max(0, this.totalCount - 1);
      AppStorage.setOrCreate('favoriteSongsCount', this.totalCount)

      console.log('移除收藏成功');
      // TODO: 可以在这里添加Toast提示用户

    } catch (error) {
      console.error('移除收藏失败:', error);
      const errorMessage = error instanceof Error ? error.message : '操作失败';
      console.error('移除收藏错误详情:', errorMessage);
      // TODO: 可以在这里添加Toast提示用户
    }
  }

  /**
   * 清空所有收藏
   */
  private async clearAllFavorites(): Promise<void> {
    try {
      console.log('清空所有收藏...');

      // 批量移除所有收藏
      for (let song of this.songs) {
        try {
          await this.userService.unlikeSong(song.id);
        } catch (error) {
          console.warn(`移除收藏失败: ${song.title}`, error);
        }
      }

      // 清空列表
      this.songs = [];
      this.totalCount = 0;

      console.log('清空所有收藏成功');
      // TODO: 可以在这里添加Toast提示用户

    } catch (error) {
      console.error('清空所有收藏失败:', error);
      const errorMessage = error instanceof Error ? error.message : '操作失败';
      console.error('清空收藏错误详情:', errorMessage);
      // TODO: 可以在这里添加Toast提示用户
    }
  }

  /**
   * 格式化播放时长
   */
  private formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 显示更多操作菜单
   */
  private showMoreActions(): void {
    // TODO: 实现更多操作菜单
    console.log('显示更多操作菜单');
    // 可以显示：分享收藏列表、导出收藏、设置等选项
  }
} 