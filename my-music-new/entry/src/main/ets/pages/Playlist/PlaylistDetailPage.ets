/**
 * 歌单详情页面
 */
import router from '@ohos.router';
import { MusicService } from '../../services/MusicService';
import { UserService } from '../../services/UserService';
import { AuthManager } from '../../services/AuthManager';
import { Playlist, Song, PlaylistSong, PlaylistSongListResponse, Pagination } from '../../models/Music';
import { User, UserCollect } from '../../models/User';
import { PaginationParams } from '../../models/Common';
import AppConstants from '../../constants/AppConstants';

@Entry
@Component
export struct PlaylistDetailPage {
  @State playlist: Playlist | null = null;           // 当前歌单信息
  @State songs: Song[] = [];                         // 歌单包含的歌曲列表
  @State isLoading: boolean = true;                  // 加载状态
  @State isCollected: boolean = false;               // 当前用户是否已收藏该歌单
  @State isCheckingCollectStatus: boolean = true;    // 正在检测收藏状态
  @State currentPage: number = 1;                    // 分页页码
  @State hasMore: boolean = true;                    // 是否有更多内容
  @State currentUser: User | null = null;            // 当前登录用户
  @State isOwner: boolean = false;                   // 当前用户是否为歌单创建者

  private musicService = new MusicService();         // 音乐服务
  private userService = new UserService();           // 用户服务
  private authManager = AuthManager.getInstance();   // 认证服务
  private playlistId: number = 0;                    // 歌单ID

  /**
   * 处理相对URL，拼接完整的图片URL
   */
  private getFullImageUrl(url: string | undefined): string | undefined {
    if (!url) return undefined;

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
    console.log('=== PlaylistDetailPage.aboutToAppear 开始 ===');

    // 统一处理路由参数：支持 playlistId 和 id 两种参数名
    const params = router.getParams() as Record<string, Object>;
    console.log('路由参数原始数据:', JSON.stringify(params));
    console.log('路由参数类型信息:', typeof params);
    if (params) {
      console.log('参数键名:', Object.keys(params));
    }

    // 尝试获取歌单ID
    const playlistIdFromPlaylistId = params?.playlistId as number;
    const playlistIdFromId = params?.id as number;

    console.log('playlistId 参数:', playlistIdFromPlaylistId, typeof playlistIdFromPlaylistId);
    console.log('id 参数:', playlistIdFromId, typeof playlistIdFromId);

    // 统一歌单ID参数为 playlistId
    this.playlistId = playlistIdFromPlaylistId || playlistIdFromId;

    console.log('最终使用的歌单ID:', this.playlistId, typeof this.playlistId);

    if (!this.playlistId || this.playlistId <= 0) {
      console.error('PlaylistDetailPage: 缺少有效的歌单ID参数');
      if (params) {
        console.error('可用参数:', Object.keys(params));
        console.error('参数值:', JSON.stringify(params));
      }
      return;
    }

    console.log('PlaylistDetailPage: 准备加载歌单ID =', this.playlistId);

    // 获取当前用户信息
    this.currentUser = this.authManager.getCurrentUser();
    console.log('当前用户信息:', this.currentUser ? this.currentUser.username : '未登录');

    this.loadPlaylistData();

    console.log('=== PlaylistDetailPage.aboutToAppear 结束 ===');
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
      } else if (this.playlist) {
        // 内容区域
        Scroll() {
          Column() {
            // 歌单信息头部
            this.buildPlaylistHeader()

            // 操作按钮
            this.buildActionButtons()

            // 歌曲列表
            this.buildSongList()
          }
          .width('100%')
          .padding({ bottom: 100 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      } else {
        // 错误状态
        Column() {
          Text('歌单不存在或已被删除')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
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

      Text('歌单')
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
    .backgroundColor('#FFFFFF')
  }

  // 歌单信息头部构建
  @Builder
  buildPlaylistHeader() {
    Row() {
      // 歌单封面
      Image(this.getFullImageUrl(this.playlist?.cover_url) || $r('app.media.music_selected'))
        .width(120)
        .height(120)
        .borderRadius(8)
        .backgroundColor($r('app.color.surface'))
        .objectFit(ImageFit.Cover)
        .onError(() => {
          console.error('歌单封面加载失败:', this.playlist?.cover_url);
        })

      // 歌单信息
      Column() {
        Text(this.playlist?.title || '')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(`@${this.playlist?.creator.username || ''}`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })

        if (this.playlist?.description) {
          Text(this.playlist.description)
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .margin({ top: 8 })
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        Row() {
          Text(`${this.playlist?.song_count || 0}首`)
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))

          Text(`${this.playlist?.collect_count || 0}收藏`)
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .margin({ left: 16 })
        }
        .margin({ top: 8 })

        // 创建时间
        if (this.playlist?.create_time) {
          Text(`创建于 ${this.formatDate(this.playlist.create_time)}`)
            .fontSize(11)
            .fontColor($r('app.color.text_tertiary'))
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(8)
    .margin({ left: 16, right: 16, top: 16 })
  }

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

      // 收藏按钮（非歌单创建者显示）
      if (!this.isOwner && this.currentUser) {
        if (this.isCheckingCollectStatus) {
          // 检查收藏状态中
          LoadingProgress()
            .width(20)
            .height(20)
            .color($r('app.color.text_secondary'))
            .margin({ left: 12 })
        } else {
          Button(this.isCollected ? '已收藏' : '收藏')
            .fontSize(16)
            .fontColor(this.isCollected ? $r('app.color.primary') :  $r('app.color.text_secondary'))
            .backgroundColor(this.isCollected ? $r('app.color.surface_light') :$r('app.color.surface'))
            .border({ width: 1, color: this.isCollected ? $r('app.color.primary') :$r('app.color.border_light') })
            .borderRadius(20)
            .width(100)
            .margin({ left: 12 })
            .onClick(() => {
              this.toggleCollectPlaylist();
            })
        }
      }

      // 编辑按钮（歌单创建者显示）
      if (this.isOwner) {
        Button('编辑')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor($r('app.color.surface'))
          .border({ width: 1, color: $r('app.color.border_light')  })
          .borderRadius(20)
          .width(80)
          .margin({ left: 12 })
          .onClick(() => {
            this.editPlaylist();
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

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
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      if (this.songs.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.ic_music_note'))
            .width(64)
            .height(64)
            .fillColor($r('app.color.text_tertiary'))
            .margin({ bottom: 16 })

          Text('歌单暂无歌曲')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })

          if (this.isOwner) {
            Text('快去添加一些好听的歌曲吧')
              .fontSize(14)
              .fontColor($r('app.color.text_tertiary'))
          }
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('app.color.surface'))
        .borderRadius(8)
        .margin({ left: 16, right: 16 })
      } else {
        // 歌曲列表
        Column() {
          ForEach(this.songs, (song: Song, index: number) => {
            Row() {
              // 序号
              Text((index + 1).toString())
                .fontSize(14)
                .fontColor($r('app.color.text_tertiary'))
                .width(32)
                .textAlign(TextAlign.Center)

              // 歌曲封面
              Image(this.getFullImageUrl(song.cover_url) || $r('app.media.music_unselected'))
                .width(44)
                .height(44)
                .borderRadius(4)
                .backgroundColor($r('app.color.surface'))
                .margin({ left: 8 })
                .objectFit(ImageFit.Cover)
                .onError(() => {
                  console.warn('歌曲封面加载失败:', song.cover_url);
                })

              // 歌曲信息
              Column() {
                Row(){
                  Text(song.title)
                    .fontSize(16)
                    .fontColor($r('app.color.text_primary'))
                    .maxLines(1)
                    .layoutWeight(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  // 播放按钮
                  Image($r('app.media.ic_play_filled'))
                    .width(20)
                    .height(20)
                    .margin({ right:0 })
                    .onClick(() => {
                      this.playSong(song, index);
                    })
                }
                .width('100%')
                .margin({ top: 4})

                Row() {
                  Text(song.artist.name)
                    .fontSize(12)
                    .fontColor($r('app.color.text_tertiary'))
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(this.formatDuration(song.duration))
                    .fontSize(12)
                    .fontColor($r('app.color.text_tertiary'))
                }
                .width('100%')
                .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor($r('app.color.surface'))
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
              .border({ width: 1, color: $r('app.color.border_light') })
              .borderRadius(20)
              .padding({ left: 20, right: 20, top: 8, bottom: 8 })
              .margin({ top: 16 })
              .onClick(() => {
                this.loadMoreSongs();
              })
          }
        }
        .width('100%')
        .backgroundColor($r('app.color.surface'))
        .borderRadius(8)
        .margin({ left: 16, right: 16 })
      }
    }
    .width('100%')
  }

  /**
   * 加载歌单数据
   */
  private async loadPlaylistData(): Promise<void> {
    this.isLoading = true;

    try {
      console.log('=== 开始加载歌单数据 ===');
      console.log('歌单ID:', this.playlistId);
      console.log('当前用户:', this.currentUser?.username || '未登录');

      // 先单独测试歌单详情API
      console.log('正在获取歌单详情...');
      let playlistDetail: Playlist | null = null;

      try {
        playlistDetail = await this.musicService.getPlaylistDetail(this.playlistId);
        console.log('歌单详情API响应成功:', playlistDetail.title);
        console.log('创建者:', playlistDetail.creator.username);
        console.log('歌曲数量:', playlistDetail.song_count);
      } catch (error) {
        console.error('歌单详情API调用失败:', error);
        console.error('错误详情:', JSON.stringify(error));
        this.playlist = null;
        return;
      }

      // 再测试歌曲列表API
      console.log('正在获取歌曲列表...');
      let songsResponse: PlaylistSongListResponse | null = null;

      try {
        songsResponse = await this.musicService.getPlaylistSongs(this.playlistId, { page: 1, limit: 50 });
        console.log('歌曲列表API响应成功');
        console.log('总数:', songsResponse.pagination?.total || 0);
        console.log('当前页歌曲数:', songsResponse.list?.length || 0);
        console.log('分页信息:', songsResponse.pagination?.page, '/', songsResponse.pagination?.totalPages);
      } catch (error) {
        console.warn('歌曲列表API调用失败:', error);
        console.warn('错误详情:', JSON.stringify(error));
        // 歌曲列表失败不应该阻止歌单详情显示
        // 创建空的分页对象
        const emptyPagination: Pagination = {
          page: 1,
          limit: 50,
          total: 0,
          totalPages: 0
        } as Pagination;

        // 创建空的歌曲响应对象
        songsResponse = {
          list: [],
          pagination: emptyPagination
        } as PlaylistSongListResponse;
      }

      // 设置歌单信息
      this.playlist = playlistDetail;

      // 检查是否为歌单创建者
      if (this.currentUser && this.playlist.creator.id === this.currentUser.id) {
        this.isOwner = true;
        console.log('当前用户是歌单创建者');
      }

      // 设置歌曲列表
      if (songsResponse && songsResponse.list) {
        this.songs = songsResponse.list.map((item: PlaylistSong): Song => item.song).filter((song: Song): boolean => song !== null && song !== undefined);
        this.hasMore = songsResponse.pagination.page < songsResponse.pagination.totalPages;
        console.log(`歌曲列表处理完成: ${this.songs.length}首歌曲，hasMore: ${this.hasMore}`);
      } else {
        this.songs = [];
        this.hasMore = false;
        console.log('歌曲列表为空');
      }

      // 检查收藏状态（仅非创建者需要检查）
      if (!this.isOwner && this.currentUser) {
        console.log('开始检查收藏状态...');
        await this.checkCollectStatus();
      } else {
        this.isCheckingCollectStatus = false;
        console.log('跳过收藏状态检查（创建者或未登录）');
      }

      console.log('=== 歌单数据加载完成 ===');

    } catch (error) {
      console.error('=== 加载歌单数据失败 ===');
      console.error('错误类型:', typeof error);
      console.error('错误信息:', error);
      console.error('错误堆栈:', error instanceof Error ? error.stack : 'No stack');
      this.playlist = null;
      this.songs = [];
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 检查收藏状态
   */
  private async checkCollectStatus(): Promise<void> {
    try {
      this.isCheckingCollectStatus = true;
      console.log('检查歌单收藏状态...');

      // 获取用户收藏的歌单列表
      const collectedResponse = await this.userService.getCollectedPlaylists({ page: 1, limit: 100 });
      const collectedPlaylists = collectedResponse.list;

      // ======== 调试输出 START ========
      console.log("collectedResponse: ", JSON.stringify(collectedResponse, null, 2))
      console.log("collectedPlaylists: ", JSON.stringify(collectedPlaylists, null, 2))
      // ======== 调试输出 END ========

      console.log('收藏列表获取成功:', {
        列表长度: collectedPlaylists?.length || 0,
        列表类型: typeof collectedPlaylists,
        是否为数组: Array.isArray(collectedPlaylists)
      });

      // 检查当前歌单是否已在收藏列表
      if (collectedPlaylists && Array.isArray(collectedPlaylists)) {
        this.isCollected = collectedPlaylists.some((item: UserCollect) => {
          console.log("item.playlistId: ", item.playlist_id);
          console.log("this.playlistId: ", this.playlistId);
          return item.playlist_id === this.playlistId
        }
        );
      } else {
        console.warn('收藏列表数据格式不正确，默认设为未收藏');
        this.isCollected = false;
      }

      console.log('收藏状态检查完成:', this.isCollected ? '已收藏' : '未收藏');

    } catch (error) {
      console.warn('检查收藏状态失败:', error);
      this.isCollected = false;
    } finally {
      this.isCheckingCollectStatus = false;
    }
  }

  /**
   * 加载更多歌曲
   */
  private async loadMoreSongs(): Promise<void> {
    if (!this.hasMore || this.isLoading) return;

    try {
      console.log('加载更多歌曲...');
      this.currentPage++;
      const response = await this.musicService.getPlaylistSongs(this.playlistId, {
        page: this.currentPage,
        limit: 50
      });

      const newSongs = response.list.map(item => item.song);
      this.songs = [...this.songs, ...newSongs];
      this.hasMore = response.pagination.page < response.pagination.totalPages;

      console.log(`加载更多歌曲成功，新增 ${newSongs.length} 首，总计 ${this.songs.length} 首`);

    } catch (error) {
      console.error('加载更多歌曲失败:', error);
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

      // 将歌单中的歌曲设为播放列表，从指定索引开始播放
      playerService.setPlaylist(playlistWithDetails, index);

      // 开始播放
      await playerService.playBySong(playlistWithDetails[index]);
      // 新增：添加到播放历史
      try {
        await new UserService().addPlayHistory(songDetail.id);
      } catch (e) {
        console.warn('添加播放历史失败', e);
      }

      // 跳转到播放器页面
      router.pushUrl({
        url: 'pages/Index'
      });
      AppStorage.setOrCreate("showPlayer",true)

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
   * 切换收藏状态
   */
  private async toggleCollectPlaylist(): Promise<void> {
    if (!this.currentUser || this.isOwner) {
      console.log('无法操作：用户未登录或为歌单创建者');
      return;
    }

    if (this.isCheckingCollectStatus) {
      console.log('正在检查收藏状态，请稍后');
      return;
    }

    try {
      this.isCheckingCollectStatus = true;

      if (this.isCollected) {
        console.log('取消收藏歌单...');
        await this.musicService.uncollectPlaylist(this.playlistId);
        this.isCollected = false;
        console.log('取消收藏成功');

        // 更新收藏数
        if (this.playlist && this.playlist.collect_count) {
          this.playlist.collect_count = Math.max(0, this.playlist.collect_count - 1);
        }
      } else {
        console.log('收藏歌单...');
        await this.musicService.collectPlaylist(this.playlistId);
        this.isCollected = true;
        console.log('收藏成功');

        // 更新收藏数
        if (this.playlist) {
          this.playlist.collect_count = (this.playlist.collect_count || 0) + 1;
        }
      }
    } catch (error) {
      console.error('收藏操作失败:', error);
      const errorMessage = error instanceof Error ? error.message : '操作失败';

      // 根据错误类型提供不同的提示
      if (errorMessage.includes('PLAYLIST_ALREADY_COLLECTED')) {
        console.log('歌单已收藏');
        this.isCollected = true;
      } else if (errorMessage.includes('PLAYLIST_NOT_COLLECTED')) {
        console.log('歌单未收藏');
        this.isCollected = false;
      } else if (errorMessage.includes('CANNOT_COLLECT_OWN_PLAYLIST')) {
        console.log('不能收藏自己的歌单');
      } else {
        // TODO: 显示错误提示给用户
        console.error('收藏操作失败:', errorMessage);
      }
    } finally {
      this.isCheckingCollectStatus = false;
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
   * 格式化日期
   */
  private formatDate(timestamp: string): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 显示更多操作菜单
   */
  private showMoreActions(): void {
    // TODO: 实现更多操作菜单
    console.log('显示更多操作菜单');
    // 可以显示：分享歌单、举报、复制链接等选项
  }

  /**
   * 显示歌曲操作菜单
   */
  private showSongActions(song: Song, index: number): void {
    // TODO: 实现歌曲操作菜单
    console.log('显示歌曲操作菜单:', song.title, '索引:', index);
    // 歌单创建者可以：从歌单中移除、调整顺序等
    // 其他用户可以：添加到我的歌单、分享等
  }

  /**
   * 编辑歌单
   */
  private editPlaylist(): void {
    if (!this.isOwner) {
      console.log('只有歌单创建者可以编辑');
      return;
    }

    // TODO: 实现编辑歌单功能
    console.log('编辑歌单:', this.playlist?.title);
    // 可以跳转到编辑页面或显示编辑对话框
    router.pushUrl({
      url: 'pages/Playlist/EditPlaylistPage',
      params: {
        playlistId: this.playlistId
      }
    }).catch((error: Error) => {
      console.warn('跳转编辑页面失败:', error);
      // 如果编辑页面不存在，可以显示简单的编辑对话框
    });
  }
} 