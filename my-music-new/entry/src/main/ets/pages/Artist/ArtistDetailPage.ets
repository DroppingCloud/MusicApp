/**
 * 歌手详情页面 - 展示歌手信息和歌曲列表
 */
import router from '@ohos.router';
import { MusicService } from '../../services/MusicService';
import { Song } from '../../models/Music';
import AppConstants from '../../constants/AppConstants';

// 歌手信息接口
interface Artist {
  id: number;
  name: string;
  avatar: string;
  bio: string;
  song_count: number;
  album_count: number;
}

interface RouteParams {
  artistId: number;
  artistName?: string;
}

@Entry
@Component
export struct ArtistDetailPage {
  @State artist: Artist | null = null;
  @State songs: Song[] = [];
  @State isLoading: boolean = false;
  @State isLoadingSongs: boolean = false;
  @State page: number = 1;
  @State hasMore: boolean = true;
  
  private musicService = new MusicService();

  aboutToAppear(): void {
    const params = router.getParams() as Object;
    const routeParams = params as RouteParams;
    if (routeParams?.artistId) {
      this.loadArtistInfo(routeParams.artistId);
      this.loadArtistSongs(routeParams.artistId);
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
            // 歌手信息区域
            this.buildArtistInfo()

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

      Text(this.artist?.name || '歌手详情')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

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
  buildArtistInfo() {
    Column() {
      // 歌手头像
      Image(this.getFullImageUrl(this.artist?.avatar) || $r('app.media.user_unselected'))
        .width(120)
        .height(120)
        .borderRadius(60)
        .backgroundColor('#E0E0E0')
        .objectFit(ImageFit.Cover)
        .margin({ bottom: 16 })

      // 歌手名称
      Text(this.artist?.name || '')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      // 统计信息
      Row() {
        Column() {
          Text(this.artist?.song_count?.toString() || '0')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text('歌曲')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.artist?.album_count?.toString() || '0')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text('专辑')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 40 })
      }
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 16 })

      // 歌手简介
      if (this.artist?.bio) {
        Text(this.artist.bio)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 20, bottom: 20 })
    .backgroundColor('#FAFAFA')
  }

  @Builder
  buildSongsList() {
    Column() {
      // 标题栏
      Row() {
        Text('热门歌曲')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)

        if (this.songs.length > 0) {
          Text(`共${this.songs.length}首`)
            .fontSize(12)
            .fontColor('#666666')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

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
        .fontColor(index < 3 ? '#FF6B6B' : '#666666')
        .fontWeight(index < 3 ? FontWeight.Bold : FontWeight.Normal)
        .width(30)
        .textAlign(TextAlign.Center)

      // 歌曲封面
      Image(this.getFullImageUrl(song.cover_url) || $r('app.media.music_unselected'))
        .width(50)
        .height(50)
        .borderRadius(4)
        .backgroundColor('#E0E0E0')
        .objectFit(ImageFit.Cover)
        .margin({ left: 8, right: 12 })

      // 歌曲信息
      Column() {
        Text(song.title)
          .fontSize(16)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (song.album?.title) {
          Text(song.album.title)
            .fontSize(12)
            .fontColor('#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

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
   * 加载歌手信息
   */
  private async loadArtistInfo(artistId: number): Promise<void> {
    try {
      this.isLoading = true;
      console.log('开始加载歌手信息:', artistId);
      
      // 模拟歌手信息（实际应该调用API）
      await new Promise<void>(resolve => setTimeout(resolve, 500));
      
      this.artist = {
        id: artistId,
        name: '周杰伦',
        avatar: '/uploads/artists/jay.jpg',
        bio: '华语流行音乐天王，创作型歌手、演员、导演、制作人。以其独特的音乐风格和创作才华闻名于世。',
        song_count: 150,
        album_count: 15
      };
      
      console.log('歌手信息加载完成:', this.artist);
    } catch (error) {
      console.error('加载歌手信息失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载歌手歌曲
   */
  private async loadArtistSongs(artistId: number): Promise<void> {
    try {
      this.isLoadingSongs = true;
      console.log('开始加载歌手歌曲:', artistId);
      
      // 使用现有的MusicService获取热门歌曲（模拟歌手歌曲）
      const hotSongs = await this.musicService.getTopHotSongs(20);
      this.songs = hotSongs || [];
      
      console.log('歌手歌曲加载完成:', this.songs.length);
    } catch (error) {
      console.error('加载歌手歌曲失败:', error);
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