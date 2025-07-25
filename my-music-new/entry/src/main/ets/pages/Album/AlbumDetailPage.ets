/**
 * 专辑详情页面 - 展示专辑信息和歌曲列表
 */
import router from '@ohos.router';
import { MusicService } from '../../services/MusicService';
import { Song } from '../../models/Music';
import AppConstants from '../../constants/AppConstants';

// 专辑艺术家接口
interface AlbumArtist {
  id: number;
  name: string;
  avatar: string;
}

// 专辑信息接口
interface Album {
  id: number;
  title: string;
  cover_url: string;
  publish_time: string;
  artist: AlbumArtist;
  song_count: number;
}

interface RouteParams {
  albumId: number;
  albumTitle?: string;
}

@Entry
@Component
export struct AlbumDetailPage {
  @State album: Album | null = null;
  @State songs: Song[] = [];
  @State isLoading: boolean = false;
  @State isLoadingSongs: boolean = false;
  @State page: number = 1;
  @State hasMore: boolean = true;
  
  private musicService = new MusicService();

  aboutToAppear(): void {
    const params = router.getParams() as Object;
    const routeParams = params as RouteParams;
    if (routeParams?.albumId) {
      this.loadAlbumInfo(routeParams.albumId);
      this.loadAlbumSongs(routeParams.albumId);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildTopBar()

      if (this.isLoading) {
        this.buildLoadingView()
      } else {
        Scroll() {
          Column() {
            // 专辑信息区域
            this.buildAlbumInfo()

            // 歌曲列表区域
            this.buildSongsList()
          }
          .padding({ bottom: 80 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildTopBar() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .onClick(() => {
          router.back();
        })

      Text(this.album?.title || '专辑详情')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 占位空间，保持标题居中
      Row()
        .width(24)
        .height(24)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#711a5f')

      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildAlbumInfo() {
    Row() {
      // 专辑封面
      Image(this.getFullImageUrl(this.album?.cover_url) || $r('app.media.music_selected'))
        .width(120)
        .height(120)
        .borderRadius(8)
        .backgroundColor('#E0E0E0')
        .objectFit(ImageFit.Cover)

      // 专辑信息
      Column() {
        // 专辑名称
        Text(this.album?.title || '')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

        // 歌手名称
        if (this.album?.artist) {
          Text(this.album.artist.name)
            .fontSize(16)
            .fontColor('#666666')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ bottom: 8 })
        }

        // 发布时间
        if (this.album?.publish_time) {
          Text(this.formatDate(this.album.publish_time))
            .fontSize(14)
            .fontColor('#999999')
            .margin({ bottom: 8 })
        }

        // 歌曲数量
        Text(`共${this.album?.song_count || 0}首歌曲`)
          .fontSize(12)
          .fontColor('#666666')

        // 播放全部按钮
        Button('播放全部')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#711a5f')
          .borderRadius(20)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .margin({ top: 12 })
          .onClick(() => {
            this.playAllSongs();
          })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 20, bottom: 20 })
    .backgroundColor('#FAFAFA')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  buildSongsList() {
    Column() {
      // 歌曲列表
      if (this.isLoadingSongs && this.songs.length === 0) {
        this.buildSongsLoadingView()
      } else if (this.songs.length === 0) {
        this.buildEmptySongsView()
      } else {
        ForEach(this.songs, (song: Song, index: number) => {
          this.buildSongItem(song, index)
        })

        // 加载更多
        if (this.hasMore && this.songs.length > 0) {
          Button('加载更多')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#E0E0E0' })
            .borderRadius(20)
            .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            .margin({ top: 16, bottom: 16 })
            .onClick(() => {
              this.loadMoreSongs();
            })
        }
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildSongItem(song: Song, index: number) {
    Row() {
      // 排名
      Text((index + 1).toString())
        .fontSize(14)
        .fontColor('#666666')
        .width(30)
        .textAlign(TextAlign.Center)

      // 歌曲信息
      Column() {
        Text(song.title)
          .fontSize(16)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          if (song.artist?.name) {
            Text(song.artist.name)
              .fontSize(12)
              .fontColor('#999999')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          if (song.duration) {
            Text(this.formatDuration(song.duration))
              .fontSize(12)
              .fontColor('#999999')
              .margin({ left: 8 })
          }
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 播放按钮
      Image($r('app.media.ic_play'))
        .width(24)
        .height(24)
        .margin({ left: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(index % 2 === 0 ? '#FFFFFF' : '#FAFAFA')
    .onClick(() => {
      this.playSong(song, index);
    })
  }

  @Builder
  buildSongsLoadingView() {
    Column() {
      LoadingProgress()
        .width(32)
        .height(32)
        .color('#711a5f')

      Text('加载歌曲中...')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(120)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptySongsView() {
    Column() {
      Text('暂无歌曲')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height(120)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 加载专辑信息
   */
  private async loadAlbumInfo(albumId: number): Promise<void> {
    try {
      this.isLoading = true;
      console.log('开始加载专辑信息:', albumId);
      
      // 模拟专辑信息（实际应该调用API）
      await new Promise<void>(resolve => setTimeout(resolve, 500));
      
      const artistInfo: AlbumArtist = {
        id: 1,
        name: '周杰伦',
        avatar: '/uploads/artists/jay.jpg'
      };
      
      this.album = {
        id: albumId,
        title: '我很忙',
        cover_url: '/uploads/albums/album1.jpg',
        publish_time: '2007-11-02',
        artist: artistInfo,
        song_count: 10
      };
      
      console.log('专辑信息加载完成:', this.album);
    } catch (error) {
      console.error('加载专辑信息失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载专辑歌曲
   */
  private async loadAlbumSongs(albumId: number): Promise<void> {
    try {
      this.isLoadingSongs = true;
      console.log('开始加载专辑歌曲:', albumId);
      
      // 使用现有的MusicService获取热门歌曲（模拟专辑歌曲）
      const hotSongs = await this.musicService.getTopHotSongs(10);
      this.songs = hotSongs || [];
      
      console.log('专辑歌曲加载完成:', this.songs.length);
    } catch (error) {
      console.error('加载专辑歌曲失败:', error);
      this.songs = [];
    } finally {
      this.isLoadingSongs = false;
    }
  }

  /**
   * 加载更多歌曲
   */
  private async loadMoreSongs(): Promise<void> {
    if (!this.hasMore || this.isLoadingSongs) return;
    
    try {
      this.isLoadingSongs = true;
      this.page++;
      
      // 模拟加载更多
      await new Promise<void>(resolve => setTimeout(resolve, 500));
      
      // 模拟没有更多数据
      this.hasMore = false;
      
    } catch (error) {
      console.error('加载更多歌曲失败:', error);
    } finally {
      this.isLoadingSongs = false;
    }
  }

  /**
   * 播放歌曲
   */
  private async playSong(song: Song, index: number): Promise<void> {
    try {
      console.log('准备播放歌曲:', song.title);
      
      // 导入播放器服务
      const PlayerServiceModule = await import('../../services/PlayerService');
      const playerService = PlayerServiceModule.PlayerService.getInstance();
      
      // 设置播放列表
      playerService.setPlaylist(this.songs, index);
      
      // 开始播放
      await playerService.play(song);
      
      // 跳转到播放器页面
      router.pushUrl({
        url: 'pages/Player/PlayerPage'
      });
      
    } catch (error) {
      console.error('播放歌曲失败:', error);
    }
  }

  /**
   * 播放全部歌曲
   */
  private async playAllSongs(): Promise<void> {
    if (this.songs.length === 0) return;
    
    await this.playSong(this.songs[0], 0);
  }

  /**
   * 格式化时长
   */
  private formatDuration(seconds: number): string {
    if (!seconds || isNaN(seconds) || seconds < 0) {
      return '00:00';
    }
    
    const totalSeconds = Math.floor(seconds);
    const mins = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 格式化日期
   */
  private formatDate(dateString: string): string {
    const date = new Date(dateString);
    return `${date.getFullYear()}年${date.getMonth() + 1}月`;
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