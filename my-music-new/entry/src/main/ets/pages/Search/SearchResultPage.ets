/**
 * 搜索结果页面 - 分类展示搜索结果
 */
import { SearchService, SearchResult, Song, Artist, Album, Playlist, User, SearchTypeParams } from '../../services/SearchService';
import { SongItem } from '../../components/common/SongItem';
import AppConstants from '../../constants/AppConstants';
import { MusicService } from '../../services/MusicService';
import router from '@ohos.router';
import { UserService } from '../../services/UserService';

type SearchType = 'all' | 'song' | 'artist' | 'album' | 'playlist' | 'user';

interface SearchTypeItem {
  key: SearchType;
  label: string;
}

interface RouteParams {
  keyword: string;
}

// 路由参数接口
interface ArtistRouteParams {
  artistId: number;
  artistName: string;
}

interface PlaylistRouteParams {
  playlistId: number;
}

interface AlbumRouteParams {
  albumId: number;
  albumTitle: string;
}

@Entry
@Component
export struct SearchResultPage {
  @State keyword: string = '';                  // 搜索关键词
  @State currentType: SearchType = 'all';       // 搜索类型
  @State searchResult: SearchResult = {};       // 搜索结果
  @State songs: Song[] = [];                    // 歌曲结果
  @State artists: Artist[] = [];                // 歌手结果
  @State albums: Album[] = [];                  // 专辑结果
  @State playlists: Playlist[] = [];            // 歌单结果
  @State users: User[] = [];                    // 用户结果
  @State isLoading: boolean = false;            // 加载状态
  @State page: number = 1;                      // 分页参数
  @State hasMore: boolean = true;               // "加载更多"

  private searchService: SearchService = SearchService.getInstance();     // 搜索服务
  private musicService = new MusicService();                              // 音乐服务（包含播放）
  private readonly searchTypes: SearchTypeItem[] = [                      
    { key: 'all', label: '综合' },
    { key: 'song', label: '歌曲' },
    { key: 'playlist', label: '歌单' },
    { key: 'album', label: '专辑' },
    { key: 'artist', label: '歌手' },
    { key: 'user', label: '用户' }
  ];                                                                      // 搜索类型

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

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Object;
    const routeParams = params as RouteParams;
    if (routeParams?.keyword) {
      this.keyword = routeParams.keyword;
      this.performSearch();
    }
  }

  build() {
    Column() {
      // 搜索栏
      this.buildSearchBar()

      // 分类标签栏
      this.buildTypeFilter()

      Row(){
        // 搜索结果内容
        if (this.isLoading && this.page === 1) {
          this.buildLoadingView()
        } else {
          this.buildSearchResults()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface'))
    .justifyContent(FlexAlign.Start)
  }

  // 搜索栏构建
  @Builder
  buildSearchBar() {
    Row() {
      // 返回按钮
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .margin({ right: 12 })
        .onClick(() => {
          router.back();
        })

      // 搜索输入框
      Row() {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .margin({ right: 8 })

        TextInput({ placeholder: '搜索音乐、歌单、用户', text: this.keyword })
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.keyword = value;
          })
          .onSubmit(() => {
            this.resetAndSearch();
          })

        if (this.keyword.length > 0) {
          Image($r('app.media.ic_clear'))
            .width(16)
            .height(16)
            .margin({ left: 8 })
            .onClick(() => {
              this.keyword = '';
            })
        }
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor($r('app.color.surface'))
      .borderRadius(20)
      .layoutWeight(1)

      // 搜索按钮
      Text('搜索')
        .fontSize(14)
        .fontColor($r('app.color.primary'))
        .margin({ left: 12 })
        .onClick(() => {
          this.resetAndSearch();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('rgba(113, 26, 95, 0.05)')
  }

  // 分类标签栏构建
  @Builder
  buildTypeFilter() {
    Scroll() {
      Row() {
        ForEach(this.searchTypes, (type: SearchTypeItem) => {
          Text(type.label)
            .fontSize(14)
            .fontColor(this.currentType === type.key ? '#FFFFFF' : '#666666')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.currentType === type.key ? '#711a5f' : '#F8F8F8')
            .borderRadius(16)
            .margin({ right: 8 })
            .onClick(() => {
              if (this.currentType !== type.key) {
                this.currentType = type.key;
                this.resetAndSearch();
              }
            })
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .margin({bottom: 8})
  }

  // "加载中"占位视图
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#711a5f')

      Text('搜索中...')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 12 })
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  // 搜索结果内容构建
  @Builder
  buildSearchResults() {
    if (this.currentType === 'all') {
      this.buildComprehensiveResults()
    } else {
      this.buildCategoryResults()
    }
  }

  // 综合搜索结果构建
  @Builder
  buildComprehensiveResults() {
    Scroll() {
      Column() {
        // 歌曲结果
        if (this.searchResult.songs && this.searchResult.songs.list.length > 0) {
          this.buildSongSection(this.searchResult.songs.list.slice(0, 3), true)
        }

        // 歌手结果
        if (this.searchResult.artists && this.searchResult.artists.list.length > 0) {
          this.buildArtistSection(this.searchResult.artists.list.slice(0, 3), true)
        }

        // 专辑结果
        if (this.searchResult.albums && this.searchResult.albums.list.length > 0) {
          this.buildAlbumSection(this.searchResult.albums.list.slice(0, 3), true)
        }

        // 歌单结果
        if (this.searchResult.playlists && this.searchResult.playlists.list.length > 0) {
          this.buildPlaylistSection(this.searchResult.playlists.list.slice(0, 3), true)
        }

        // 用户结果
        if (this.searchResult.users && this.searchResult.users.list.length > 0) {
          this.buildUserSection(this.searchResult.users.list.slice(0, 3), true)
        }
      }
      .padding({ bottom: 20 })
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }

  // 分类结果构建
  @Builder
  buildCategoryResults() {
    Scroll() {
      Column() {
        if (this.currentType === 'song') {
          this.buildSongSection(this.songs, false)
        } else if (this.currentType === 'artist') {
          this.buildArtistSection(this.artists, false)
        } else if (this.currentType === 'album') {
          this.buildAlbumSection(this.albums, false)
        } else if (this.currentType === 'playlist') {
          this.buildPlaylistSection(this.playlists, false)
        } else if (this.currentType === 'user') {
          this.buildUserSection(this.users, false)
        }
      }
      .padding({ bottom: 20 })
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }

  // 歌曲结果
  @Builder
  buildSongSection(songs: Song[], showTitle: boolean) {
    Column() {
      if (showTitle) {
        Row() {
          Text('歌曲')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          Text('查看更多')
            .fontSize(14)
            .fontColor($r('app.color.primary'))
            .onClick(() => {
              this.currentType = 'song';
              this.resetAndSearch();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
      }

      ForEach(songs, (song: Song, index: number) => {
        Row() {
          // 歌曲封面
          if (song?.cover_url) {
            Image(this.getFullImageUrl(song?.cover_url))
              .width(60)
              .height(60)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          } else {
            Image($r('app.media.music_unselected'))
              .width(48)
              .height(48)
              .borderRadius(4)
              .backgroundColor('#E0E0E0')
          }

          // 歌曲信息
          Column() {
            Text(song.title)
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Text(`${song.artist.name} - ${song.album.title}`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })

          // 播放按钮
          Image($r('app.media.ic_play_filled'))
            .width(24)
            .height(24)
            .margin({ left: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          this.playSong(song);
        })
      })
    }
    .width('100%')
    .margin({ bottom: showTitle ? 24 : 0 })
  }

  // 歌手结果
  @Builder
  buildArtistSection(artists: Artist[], showTitle: boolean) {
    Column() {
      if (showTitle) {
        Row() {
          Text('歌手')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          Text('查看更多')
            .fontSize(14)
            .fontColor($r('app.color.primary'))
            .onClick(() => {
              this.currentType = 'artist';
              this.resetAndSearch();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
      }

      ForEach(artists, (artist: Artist) => {
        Row() {
          // 歌手头像
          if (artist?.avatar) {
            Image(this.getFullImageUrl(artist?.avatar))
              .width(60)
              .height(60)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          } else {
            Image($r('app.media.user_unselected'))
              .width(48)
              .height(48)
              .borderRadius(24)
              .backgroundColor('#E0E0E0')
          }

          // 歌手信息
          Column() {
            Text(artist.name)
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Text(`${artist.song_count}首歌曲 · ${artist.album_count}张专辑`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })

          // 关注按钮
          Text('关注')
            .fontSize(12)
            .fontColor($r('app.color.primary'))
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .border({ width: 1, color: '#711a5f' })
            .borderRadius(12)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          this.goToArtistDetail(artist.id, artist.name);
        })
      })
    }
    .width('100%')
    .margin({ bottom: showTitle ? 24 : 0 })
  }

  // 专辑结果
  @Builder
  buildAlbumSection(albums: Album[], showTitle: boolean) {
    Column() {
      if (showTitle) {
        Row() {
          Text('专辑')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          Text('查看更多')
            .fontSize(14)
            .fontColor($r('app.color.primary'))
            .onClick(() => {
              this.currentType = 'album';
              this.resetAndSearch();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
      }

      ForEach(albums, (album: Album) => {
        Row() {
          // 专辑封面
          if (album?.cover_url) {
            Image(this.getFullImageUrl(album?.cover_url))
              .width(60)
              .height(60)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          } else {
            Image($r('app.media.ic_album'))
              .width(48)
              .height(48)
              .borderRadius(4)
          }

          // 专辑信息
          Column() {
            Text(album.title)
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Text(`${album.artist.name} · ${album.song_count}首歌曲`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })

          // 播放按钮
          Image($r('app.media.ic_play_filled'))
            .width(24)
            .height(24)
            .margin({ left: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          this.goToAlbumDetail(album.id, album.title);
        })
      })
    }
    .width('100%')
    .margin({ bottom: showTitle ? 24 : 0 })
  }

  // 歌单结果
  @Builder
  buildPlaylistSection(playlists: Playlist[], showTitle: boolean) {
    Column() {
      if (showTitle) {
        Row() {
          Text('歌单')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          Text('查看更多')
            .fontSize(14)
            .fontColor($r('app.color.primary'))
            .onClick(() => {
              this.currentType = 'playlist';
              this.resetAndSearch();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
      }

      ForEach(playlists, (playlist: Playlist) => {
        Row() {
          // 歌单封面
          if (playlist?.cover_url) {
            Image(this.getFullImageUrl(playlist?.cover_url))
              .width(60)
              .height(60)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          } else {
            Image($r('app.media.user_unselected'))
              .width(48)
              .height(48)
              .borderRadius(4)
              .backgroundColor('#E0E0E0')
          }

          // 歌单信息
          Column() {
            Text(playlist.title)
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Text(`${playlist.creator.username} · ${playlist.song_count}首歌曲`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })

          // 播放按钮
          Image($r('app.media.ic_play_filled'))
            .width(24)
            .height(24)
            .margin({ left: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          this.goToPlaylistDetail(playlist.id);
        })
      })
    }
    .width('100%')
    .margin({ bottom: showTitle ? 24 : 0 })
  }

  // 用户结果
  @Builder
  buildUserSection(users: User[], showTitle: boolean) {
    Column() {
      if (showTitle) {
        Row() {
          Text('用户')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)

          Text('查看更多')
            .fontSize(14)
            .fontColor($r('app.color.primary'))
            .onClick(() => {
              this.currentType = 'user';
              this.resetAndSearch();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
      }

      ForEach(users, (user: User) => {
        Row() {
          // 用户头像
          if (user?.avatar) {
            Image(this.getFullImageUrl(user?.avatar))
              .width(60)
              .height(60)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          } else {
            Image($r('app.media.user_unselected'))
              .width(48)
              .height(48)
              .borderRadius(4)
              .backgroundColor('#E0E0E0')
          }

          // 用户信息
          Column() {
            Text(user.username)
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')

            Text(`加入时间：${this.formatDate(user.created_at)}`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })

          // 关注按钮
          Text('关注')
            .fontSize(12)
            .fontColor($r('app.color.primary'))
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .border({ width: 1, color: '#711a5f' })
            .borderRadius(12)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          // TODO: 跳转到用户详情
        })
      })
    }
    .width('100%')
    .margin({ bottom: showTitle ? 24 : 0 })
  }

  // 搜索功能
  private async performSearch() {
    if (this.keyword.trim().length === 0) {
      return;
    }

    try {
      this.isLoading = true;

      if (this.currentType === 'all') {
        // 综合搜索
        const result = await this.searchService.search({
          keyword: this.keyword,
          page: this.page,
          limit: 20
        });
        this.searchResult = result.results;
      } else {
        // 分类搜索
        await this.searchByType();
      }
    } catch (error) {
      console.error('搜索失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 分类搜索
  private async searchByType() {
    try {
      const params: SearchTypeParams = { keyword: this.keyword, page: this.page, limit: 20 };

      switch (this.currentType) {
        case 'song':
          const songResult = await this.searchService.searchSongs(params);
          if (this.page === 1) {
            this.songs = songResult.list;
          } else {
            this.songs = this.songs.concat(songResult.list);
          }
          this.hasMore = songResult.list.length === 20;
          break;

        case 'artist':
          const artistResult = await this.searchService.searchArtists(params);
          if (this.page === 1) {
            this.artists = artistResult.list;
          } else {
            this.artists = this.artists.concat(artistResult.list);
          }
          this.hasMore = artistResult.list.length === 20;
          break;

        case 'album':
          const albumResult = await this.searchService.searchAlbums(params);
          if (this.page === 1) {
            this.albums = albumResult.list;
          } else {
            this.albums = this.albums.concat(albumResult.list);
          }
          this.hasMore = albumResult.list.length === 20;
          break;

        case 'playlist':
          const playlistResult = await this.searchService.searchPlaylists(params);
          if (this.page === 1) {
            this.playlists = playlistResult.list;
          } else {
            this.playlists = this.playlists.concat(playlistResult.list);
          }
          this.hasMore = playlistResult.list.length === 20;
          break;

        case 'user':
          const userResult = await this.searchService.searchUsers(params);
          if (this.page === 1) {
            this.users = userResult.list;
          } else {
            this.users = this.users.concat(userResult.list);
          }
          this.hasMore = userResult.list.length === 20;
          break;
      }
    } catch (error) {
      console.error('分类搜索失败:', error);
    }
  }

  // 重置搜索状态
  private resetAndSearch() {
    this.page = 1;
    this.hasMore = true;
    this.clearResults();
    this.performSearch();
  }

  // 清空搜索结果
  private clearResults() {
    this.searchResult = {};
    this.songs = [];
    this.artists = [];
    this.albums = [];
    this.playlists = [];
    this.users = [];
  }

  private formatDate(dateString: string): string {
    const date = new Date(dateString);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  }

  /**
   * 跳转到歌手详情页面
   */
  private goToArtistDetail(artistId: number, artistName: string): void {
    const params: ArtistRouteParams = { artistId, artistName };
    router.pushUrl({
      url: 'pages/Artist/ArtistDetailPage',
      params: params
    });
  }

  /**
   * 跳转到歌单详情页面
   */
  private goToPlaylistDetail(playlistId: number): void {
    const params: PlaylistRouteParams = { playlistId };
    router.pushUrl({
      url: 'pages/Playlist/PlaylistDetailPage',
      params: params
    });
  }

  /**
   * 跳转到专辑详情页面
   */
  private goToAlbumDetail(albumId: number, albumTitle: string): void {
    const params: AlbumRouteParams = { albumId, albumTitle };
    router.pushUrl({
      url: 'pages/Album/AlbumDetailPage',
      params: params
    });
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

      // 导入播放器服务
      const PlayerServiceModule = await import('../../services/PlayerService');
      const playerService = PlayerServiceModule.PlayerService.getInstance();

      // 设置播放列表（使用详情数据）
      playerService.setPlaylist([songDetail], 0);

      // 开始播放
      await playerService.playBySong(songDetail);
      // 新增：添加到播放历史
      try {
        await new UserService().addPlayHistory(songDetail.id);
      } catch (e) {
        console.warn('添加播放历史失败', e);
      }

      // 跳转到播放器页面
      router.pushUrl({
        url: 'pages/Player/PlayerPage'
      });

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
} 