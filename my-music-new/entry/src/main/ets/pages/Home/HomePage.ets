/**
 * 首页 - 音乐推荐和热门内容
 */
import router from '@ohos.router';
import { MusicService } from '../../services/MusicService';
import { Song, Playlist } from '../../models/Music';
import { AuthManager } from '../../services/AuthManager';
import { User } from '../../models/User';
import AppConstants from '../../constants/AppConstants';
import { UserService } from '../../services/UserService';
import { PlayerService } from '../../services/PlayerService';

@Component
export struct HomePage {
  @State isLoading: boolean = false;
  @State refreshing: boolean = false;
  @State currentBannerIndex: number = 0;
  @State currentUser: User | null = null;
  //@StorageLink('theme') theme: string = 'light';
  
  // 音乐数据状态
  @State bannerSongs: Song[] = [];
  @State recommendPlaylists: Playlist[] = [];
  @State hotSongs: Song[] = [];
  @State latestSongs: Song[] = [];
  
  private musicService = new MusicService();            // 音乐服务
  private authManager = AuthManager.getInstance();      // 认证服务
  private playerService = PlayerService.getInstance();  // 播放器服务

  async aboutToAppear(): Promise<void> {
    // 获取当前用户信息
    this.currentUser = this.authManager.getCurrentUser();
    
    // 监听认证状态变化
    this.authManager.addAuthStateListener((isLoggedIn: boolean, user: User | null) => {
      this.currentUser = user;
    });
    
    await this.loadHomeData();
  }

  build() {
    Refresh({ refreshing: $$this.refreshing }) {
      Column() {
        // 顶部导航栏
        this.buildTopBar()

        // 内容区域
        Scroll() {
          Column() {
            // 轮播图区域
            this.buildBannerSection()

            // 推荐歌单
            this.buildRecommendedPlaylists()

            // 热门歌曲
            this.buildHotSongs()

            // 最新发布
            this.buildLatestReleases()
          }
          .padding({ top: 16, bottom: 80 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .onRefreshing(() => {
      this.handleRefresh();
    })
  }

  // 顶部导航栏构建
  @Builder
  buildTopBar() {
    Row() {
      // 搜索框
      Row() {
        // 搜索图标 - 放大镜图标用于搜索功能
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .margin({ right: 8 })

        Text('搜索音乐、歌单、用户')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .opacity(0.8)
          .layoutWeight(1)
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('rgba(255,255,255,0.2)')
      .borderRadius(20)
      .layoutWeight(1)
      .onClick(() => {
        // 跳转到搜索页面
        router.pushUrl({
          url: 'pages/Search/SearchPage'
        });
      })

      // 个人头像
      if (this.currentUser && this.currentUser.avatar && this.getFullImageUrl(this.currentUser.avatar)) {
        Image(this.getFullImageUrl(this.currentUser.avatar)!)
          .width(32)
          .height(32)
          .borderRadius(16)
          .margin({ left: 12 })
          .objectFit(ImageFit.Cover)
          .onError(() => {
            console.error('用户头像加载失败:', this.currentUser?.avatar);
          })
          .onClick(() => {
            // 跳转到个人页面
            AppStorage.setOrCreate('currentTabIndex',3)
          })
      } else {
        Image($r('app.media.user_unselected'))
          .width(32)
          .height(32)
          .borderRadius(16)
          .margin({ left: 12 })
          .onClick(() => {
            // 跳转到个人页面
            AppStorage.setOrCreate('currentTabIndex',3)
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#ffff8ba4')
  }

  // 轮播图模块构建
  @Builder
  buildBannerSection() {
    Column() {
      if (this.isLoading) {
        // 加载状态
        Row() {
          LoadingProgress()
            .width(32)
            .height(32)
            .color($r('app.color.primary'))
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 12 })
        }
        .width('100%')
        .height(160)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.surface'))
        .borderRadius(12)
      } else if (this.bannerSongs.length === 0) {
        // 空数据状态
        Column() {
          Text('暂无轮播内容')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(160)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.surface'))
        .borderRadius(12)
      } else {
        // 轮播图
        Swiper() {
          ForEach(this.bannerSongs, (song: Song, index: number) => {
          // 轮播图项 - 使用真实歌曲数据
          Stack() {
            Image(song.cover_url || $r('app.media.background'))
              .width('100%')
              .height(160)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
              .backgroundColor($r('app.color.divider'))

            // 轮播图遮罩和文字
            Column() {
              Text(song.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .margin({ bottom: 8 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(song.artist.name)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .opacity(0.9)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.End)
            .width('100%')
            .height('100%')
            .padding(16)
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['rgba(0,0,0,0)', 0.0], ['rgba(0,0,0,0.6)', 1.0]]
            })
          }
          .width('100%')
          .height(160)
          .onClick(() => {
            // 播放歌曲
            this.playSong(song);
          })
        })
      }
      .width('100%')
      .height(160)
      .borderRadius(12)
      .autoPlay(true)
      .interval(3000)
      .indicator(
        new DotIndicator()
          .itemWidth(8)
          .itemHeight(8)
          .selectedItemWidth(16)
          .selectedItemHeight(8)
          .color($r('app.color.text_primary'))
          .selectedColor($r('app.color.primary'))
      )
      .onChange((index: number) => {
        this.currentBannerIndex = index;
      })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 20 })
  }

  // 推荐歌单模块构建
  @Builder
  buildRecommendedPlaylists() {
    Column() {
      // 标题
      Row() {
        Text('推荐歌单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      // 歌单列表 - 左右滑动
      if (this.recommendPlaylists.length === 0) {
        Column() {
          Text('暂无推荐歌单')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(140)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 16, right: 16 })
      } else {
        Scroll() {
          Row() {
            ForEach(this.recommendPlaylists, (playlist: Playlist, index: number) => {
            Column() {
              // 歌单封面图片
              Image(playlist.cover_url || $r('app.media.music_selected'))
                .width(120)
                .height(120)
                .borderRadius(8)
                .backgroundColor($r('app.color.divider'))
                .objectFit(ImageFit.Cover)

              Text(playlist.title)
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 8 })
            }
            .width(120)
            .margin({ right: index === this.recommendPlaylists.length - 1 ? 0 : 12 })
            .onClick(() => {
              // 跳转到歌单详情
              this.goToPlaylistDetail(playlist.id);
            })
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  // 热歌模块构建
  @Builder
  buildHotSongs() {
    Column() {
      // 标题
      Row() {
        Text('热门歌曲')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      // 歌曲列表处理
      if (this.hotSongs.length === 0) {
        Column() {
          Text('暂无热门歌曲')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(180)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 16, right: 16 })
      } else {
        // 左右滑动的网格布局
        Scroll() {
          Row() {
            // 将歌曲按每列3个分组
            ForEach(this.getColumnGroups(), (columnSongs: Song[], columnIndex: number) => {
              Column() {
                ForEach(columnSongs, (song: Song, rowIndex: number) => {
                  Row() {
                    // 排名
                    Text((columnIndex * 3 + rowIndex + 1).toString())
                      .fontSize(14)
                      .fontColor(columnIndex * 3 + rowIndex < 3 ? $r('app.color.primary')  : $r('app.color.text_secondary'))
                      .fontWeight(columnIndex * 3 + rowIndex < 3 ? FontWeight.Bold : FontWeight.Normal)
                      .width(20)
                      .textAlign(TextAlign.Center)

                    // 歌曲封面
                    Image(song.cover_url || $r('app.media.music_unselected'))
                      .width(40)
                      .height(40)
                      .borderRadius(4)
                      .margin({ left: 8, right: 12 })
                      .backgroundColor($r('app.color.divider'))
                      .objectFit(ImageFit.Cover)

                    // 歌曲信息
                    Column() {
                      Text(song.title)
                        .fontSize(14)
                        .fontColor($r('app.color.text_primary'))
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      Text(song.artist?.name || '未知艺术家')
                        .fontSize(12)
                        .fontColor($r('app.color.text_secondary'))
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .margin({ top: 2 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    // 播放按钮
                    Image($r('app.media.ic_play'))
                      .width(20)
                      .height(20)
                  }
                  .width('100%')
                  .height(52)
                  .backgroundColor($r('app.color.surface'))
                  .borderRadius(8)
                  .padding({ left: 12, right: 12 })
                  .margin({ bottom: rowIndex < columnSongs.length - 1 ? 8 : 0 })
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => {
                    this.playSong(song);
                  })
                })
              }
              .width(280) // 固定列宽
              .margin({ right: columnIndex < this.getColumnGroups().length - 1 ? 16 : 0 })
              .alignItems(HorizontalAlign.Start)
            })
          }
          .alignItems(VerticalAlign.Top)
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  // 获取按列分组的歌曲数据
  private getColumnGroups(): Song[][] {
    const groups: Song[][] = [];
    const songsPerColumn = 3;
    
    for (let i = 0; i < this.hotSongs.length; i += songsPerColumn) {
      const group = this.hotSongs.slice(i, i + songsPerColumn);
      if (group.length > 0) {
        groups.push(group);
      }
    }
    
    return groups;
  }

  // 最新发布模块构建
  @Builder
  buildLatestReleases() {
    Column() {
      // 标题
      Row() {
        Text('最新发布')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      // 最新发布列表 - 左右滑动
      if (this.latestSongs.length === 0) {
        Column() {
          Text('暂无最新发布')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(140)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 16, right: 16 })
      } else {
        Scroll() {
          Row() {
            ForEach(this.latestSongs, (song: Song, index: number) => {
            Column() {
              // 专辑封面图片
              Image(song.cover_url || $r('app.media.music_unselected'))
                .width(100)
                .height(100)
                .borderRadius(8)
                .backgroundColor($r('app.color.divider'))
                .objectFit(ImageFit.Cover)

              Text(song.title)
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 8 })

              Text(song.artist?.name || '未知艺术家')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(100)
            .margin({ right: index === this.latestSongs.length - 1 ? 0 : 12 })
            .onClick(() => {
              // 播放歌曲
              this.playSong(song);
            })
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  private async handleRefresh(): Promise<void> {
    await this.loadHomeData();
    this.refreshing = false;
  }

  /**
   * 加载首页数据
   */
  private async loadHomeData(): Promise<void> {
    this.isLoading = true;
    console.log('HomePage: 开始加载首页数据...');
    
    try {
      // 分别加载各个模块的数据，避免一个失败影响全部
      console.log('HomePage: 开始并行加载数据...');
      
      const bannerSongsPromise = this.musicService.getBannerSongs(5).catch((error: Error): Song[] => {
        console.error('HomePage: 加载轮播图失败:', error);
        return [] as Song[];
      });
      
      const recommendPlaylistsPromise = this.musicService.getRecommendPlaylists(6).catch((error: Error): Playlist[] => {
        console.error('HomePage: 加载推荐歌单失败:', error);
        return [] as Playlist[];
      });
      
      const hotSongsPromise = this.musicService.getTopHotSongs(9).catch((error: Error): Song[] => {
        console.error('HomePage: 加载热门歌曲失败:', error);
        return [] as Song[];
      });
      
      const latestSongsPromise = this.musicService.getLatestAlbums(6).catch((error: Error): Song[] => {
        console.error('HomePage: 加载最新发布失败:', error);
        return [] as Song[];
      });
      
      const results = await Promise.allSettled([
        bannerSongsPromise,
        recommendPlaylistsPromise,
        hotSongsPromise,
        latestSongsPromise
      ]);
      
      // 处理结果
      const bannerSongs: Song[] = results[0].status === 'fulfilled' ? results[0].value as Song[] : [];
      const recommendPlaylists: Playlist[] = results[1].status === 'fulfilled' ? results[1].value as Playlist[] : [];
      const hotSongs: Song[] = results[2].status === 'fulfilled' ? results[2].value as Song[] : [];
      const latestSongs: Song[] = results[3].status === 'fulfilled' ? results[3].value as Song[] : [];
      
      console.log('HomePage: 数据加载完成:');
      console.log('- 轮播图歌曲数量:', bannerSongs?.length || 0);
      console.log('- 推荐歌单数量:', recommendPlaylists?.length || 0);
      console.log('- 热门歌曲数量:', hotSongs?.length || 0);
      console.log('- 最新发布数量:', latestSongs?.length || 0);
      
      // 验证数据有效性
      this.bannerSongs = Array.isArray(bannerSongs) ? bannerSongs : [];
      this.recommendPlaylists = Array.isArray(recommendPlaylists) ? recommendPlaylists : [];
      this.hotSongs = Array.isArray(hotSongs) ? hotSongs : [];
      this.latestSongs = Array.isArray(latestSongs) ? latestSongs : [];
      
      // 如果所有数据都为空，可能是网络问题
      const totalItems = this.bannerSongs.length + this.recommendPlaylists.length + 
                        this.hotSongs.length + this.latestSongs.length;
      
      if (totalItems === 0) {
        console.warn('HomePage: 所有数据都为空，可能存在网络问题');
      }
      
    } catch (error) {
      console.error('HomePage: 加载首页数据出现未捕获错误:', error);
      console.error('HomePage: 错误详情:', JSON.stringify(error));
      
      // 设置为空数组，显示空状态
      this.bannerSongs = [];
      this.recommendPlaylists = [];
      this.hotSongs = [];
      this.latestSongs = [];
    } finally {
      this.isLoading = false;
      console.log('HomePage: 数据加载流程结束');
    }
  }

  /**
   * 播放歌曲
   */
  private async playSong(song: Song): Promise<void> {
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
      
      // 设置播放列表（使用详情数据）
      this.playerService.setPlaylist([songDetail], 0);
      
      // 开始播放
      await this.playerService.playBySong(songDetail);
      // 新增：添加到播放历史
      try {
        await new UserService().addPlayHistory(songDetail.id);
      } catch (e) {
        console.warn('添加播放历史失败', e);
      }
      
      // 跳转到播放器页面（即为首页）
      router.pushUrl({
        url: 'pages/Index'
      });
      AppStorage.setOrCreate("showPlayer",true)
      
      // 调用播放API记录播放次数（不影响播放体验）
      this.musicService.playSong(songDetail.id).catch((error: Error) => {
        console.warn('记录播放次数失败:', error);
      });
      
      console.log('歌曲播放启动成功');
      
    } catch (error) {
      console.error('播放歌曲失败:', error);
      // 显示错误提示给用户
      const errorMessage = error instanceof Error ? error.message : '播放失败，请稍后重试';
      console.error('播放错误详情:', errorMessage);
      // TODO: 可以在这里添加Toast提示用户
    }
  }

  /**
   * 跳转到歌单详情页面
   */
  private goToPlaylistDetail(playlistId: number): void {
    router.pushUrl({
      url: 'pages/Playlist/PlaylistDetailPage',
      params: { playlistId }
    });
  }

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
} 