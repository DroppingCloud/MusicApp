/**
 * 收藏歌单页面
 */
import router from '@ohos.router';
import { UserService } from '../../services/UserService';
import { PaginationParams, PaginationResponse } from '../../models/Common';
import { MusicService } from '../../services/MusicService';
import { AuthManager } from '../../services/AuthManager';
import { Playlist, Song, PlaylistSong, PlaylistSongListResponse, Pagination } from '../../models/Music';
import { User, UserCollect } from '../../models/User';
import AppConstants from '../../constants/AppConstants';

@Entry
@Component
export struct MyPlaylistsPage {
  @State collectedPlaylists: UserCollect[] = [];
  @State isLoading: boolean = true;
  @State hasMore: boolean = true;
  @State currentPage: number = 1;
  @State playlists: Playlist[] = []; // 所有收藏歌单信息
  @State firstSongs: Map<number, Song> = new Map(); // 歌单第一首歌信息
  private musicService = new MusicService(); // 音乐服务
  private userService = new UserService(); // 用户服务

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

  // 使用 async/await 串行，避免 loadPlaylistData 先执行加载到空的 collectedPlaylists
  async aboutToAppear(): Promise<void> {
    await this.loadCollectedPlaylists();
    await this.loadPlaylistData();
  }

  build() {
    Column() {
      // 导航栏
      this.buildNavigationBar()

      if (this.isLoading && this.collectedPlaylists.length === 0) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#701e5f')

          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.collectedPlaylists.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.ic_playlist'))
            .width(80)
            .height(80)
            .fillColor('#CCCCCC')
            .margin({ bottom: 16 })

          Text('暂无收藏的歌单')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          Text('快去收藏一些好听的歌单吧')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 歌单列表
        Column() {
          // 统计信息和操作按钮
          Row() {
            Text(`共${this.playlists.length}个歌单`)
              .fontSize(14)
              .fontColor('#666666')
              .layoutWeight(1)

            Button('清空收藏')
              .fontSize(14)
              .fontColor('#FF6B6B')
              .backgroundColor('transparent')
              .border({ width: 1, color: '#FF6B6B', radius: 20 })
              .height(36)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                this.clearAllPlaylists();
              })
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 16,
            bottom: 16
          })

          // 歌单列表
          List() {
            ForEach(this.playlists, (playlist: Playlist, index: number) => {
              ListItem() {
                this.buildPlaylistItem(playlist, index)
              }
              .padding({
                left: 16,
                right: 16,
                top: 8,
                bottom: 12
              })
            })

            // 加载更多
            if (this.hasMore) {
              ListItem() {
                Row() {
                  if (this.isLoading) {
                    LoadingProgress()
                      .width(24)
                      .height(24)
                      .color('#701e5f')

                    Text('加载中...')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 8 })
                  } else {
                    Button('加载更多')
                      .fontSize(14)
                      .fontColor('#701e5f')
                      .backgroundColor('transparent')
                      .border({ width: 1, color: '#701e5f', radius: 20 })
                      .height(36)
                      .onClick(() => {
                        this.loadMore();
                      })
                  }
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding(16)
              }
            }
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
        .padding({ bottom: 100 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface'))
  }

  @Builder
  buildNavigationBar() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .onClick(() => {
          router.back();
        })

      Text('我的收藏')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 占位，保持居中
      Row().width(24).height(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.surface'))
  }

  // 歌单项构建
  @Builder
  buildPlaylistItem(playlist: Playlist, index: number) {
    Row() {
      // 歌单封面
      Image(this.getFullImageUrl(playlist.cover_url) || $r('app.media.ic_playlist'))
        .width(50)
        .height(50)
        .borderRadius(6)
        .backgroundColor(AppConstants.COLORS.SURFACE)
        .objectFit(ImageFit.Cover)

      // 歌单信息
      Column() {
        Text(playlist.title)
          .fontSize(16)
          .fontColor(AppConstants.COLORS.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(`${playlist.song_count || 0}首`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ right: 5 })

          Text(this.getFirstSongTitle(playlist.id) || '暂无歌曲')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 右侧操作区域
      Row() {
        // 更多操作图标
        Image($r('app.media.ic_more'))
          .width(20)
          .height(20)
          .onClick(() => {
            this.showPlaylistActions(playlist);
          })
      }
    }
    .width('100%')
    .padding({
      top: 8,
      bottom: 8,
      left: 16,
      right: 16
    })
    .onClick(() => {
      this.goToPlaylistDetail(playlist.id);
    })
  }


  // 加载收藏的歌单
  private async loadCollectedPlaylists(): Promise<void> {
    try {
      this.isLoading = true;
      const params: PaginationParams = {
        page: 1,
        limit: 20
      };
      // 获取收藏的歌单
      const collectedResponse = await this.userService.getCollectedPlaylists(params);
      this.collectedPlaylists = collectedResponse.list;

      console.log('【调试】完整 collectedResponse:', JSON.stringify(collectedResponse, null, 2));
      console.log('【调试】完整 collectedPlaylists:', JSON.stringify(this.collectedPlaylists, null, 2));

      this.hasMore = collectedResponse.pagination.page < collectedResponse.pagination.totalPages;
      this.currentPage = 1;

    } catch (error) {
      console.error('加载收藏歌单失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载歌单数据
   */
  private async loadPlaylistData(): Promise<void> {
    this.isLoading = true;

    try {
      console.log('正在获取歌单详情...');
      const playlistsWithDetails: Playlist[] = [];
      const firstSongsMap: Map<number, Song> = new Map();

      console.log('【调试】collectedPlaylists:', JSON.stringify(this.collectedPlaylists, null, 2));

      for (const item of this.collectedPlaylists) {
        try {
          const playlistDetail = await this.musicService.getPlaylistDetail(item.playlist_id);
          console.log('歌单详情API响应成功:', playlistDetail.title);
          console.log('创建者:', playlistDetail.creator.username);
          console.log('歌曲数量:', playlistDetail.song_count);

          // 追加歌单详情
          playlistsWithDetails.push(playlistDetail);

          // 获取歌单的第一首歌
          if (playlistDetail.song_count > 0) {
            try {
              const songsResponse = await this.musicService.getPlaylistSongs(playlistDetail.id, { page: 1, limit: 1 });
              if (songsResponse.list && songsResponse.list.length > 0) {
                const firstSong = songsResponse.list[0].song;
                firstSongsMap.set(playlistDetail.id, firstSong);
                console.log(`获取歌单第一首歌成功: ${firstSong.title}`);
              }
            } catch (songError) {
              console.warn(`获取歌单第一首歌失败: ${playlistDetail.title}`, songError);
            }
          }
        } catch (error) {
          console.error('歌单详情API调用失败:', error);
          console.error('错误详情:', JSON.stringify(error));
          continue;
        }
      }

      // 设置歌单列表和第一首歌信息
      this.playlists = playlistsWithDetails;
      this.firstSongs = firstSongsMap;

    } catch (error) {
      console.error('=== 加载歌单数据失败 ===');
      console.error('错误类型:', typeof error);
      console.error('错误信息:', error);
      console.error('错误堆栈:', error instanceof Error ? error.stack : 'No stack');
      this.playlists = [];
      this.firstSongs = new Map();
    } finally {
      this.isLoading = false;
    }
  }

  // 加载更多
  private async loadMore(): Promise<void> {
    if (this.isLoading || !this.hasMore) {
      return;
    }

    try {
      this.isLoading = true;
      const params: PaginationParams = {
        page: this.currentPage + 1,
        limit: 20
      };
      const response = await this.userService.getCollectedPlaylists(params);

      // 追加到现有列表
      this.collectedPlaylists = [...this.collectedPlaylists, ...response.list];
      this.hasMore = response.pagination.page < response.pagination.totalPages;
      this.currentPage = response.pagination.page;

    } catch (error) {
      console.error('加载更多失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 跳转到歌单详情
  private goToPlaylistDetail(playlistId: number): void {
    router.pushUrl({
      url: 'pages/Playlist/PlaylistDetailPage',
      params: {
        playlistId: playlistId
      }
    });
  }

  /**
   * 获取歌单第一首歌的标题和作者
   */
  private getFirstSongTitle(playlistId: number | undefined): string | undefined {
    if (!playlistId) {
      return undefined;
    }
    const firstSong = this.firstSongs.get(playlistId);
    if (!firstSong) {
      return undefined;
    }
    return `${firstSong.title} - ${firstSong.artist.name}`;
  }

  /**
   * 清空所有收藏
   */
  private async clearAllPlaylists(): Promise<void> {
    try {
      console.log('清空所有收藏...');

      // 批量移除所有收藏
      for (let playlist of this.playlists) {
        try {
          await this.userService.uncollectPlaylist(playlist.id);
        } catch (error) {
          console.warn(`移除收藏失败: ${playlist.title}`, error);
        }
      }

      // 清空列表
      this.playlists = [];
      this.firstSongs = new Map();

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
   * 显示歌单操作菜单
   */
  private showPlaylistActions(playlist: Playlist): void {
    // TODO: 实现歌单操作菜单
    console.log('显示歌单操作菜单:', playlist.title);
    // 可以显示：播放歌单、取消收藏、分享等选项
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
   * 格式化日期
   */
  private formatDate(timestamp: string): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
} 