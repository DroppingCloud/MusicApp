/**
 * 搜索页面 - 搜索首页展示历史、建议和热门内容
 */
import { SearchService, SearchHistory, SearchSuggestion } from '../../services/SearchService';
import { MusicService } from '../../services/MusicService';
import { UserService } from '../../services/UserService';
import { Song } from '../../models/Music';
import { SongItem } from '../../components/common/SongItem';
import AppConstants from '../../constants/AppConstants';
import router from '@ohos.router';
import { PlayerService } from '../../services/PlayerService';

@Entry
@Component
export struct SearchPage {
  @State searchKeyword: string = '';              // 搜索关键词
  @State searchHistory: SearchHistory[] = [];     // 搜索历史记录
  @State hotKeywords: SearchSuggestion[] = [];    // 热词推荐
  @State recommendSongs: Song[] = [];             // 歌曲推荐
  @State hotSongs: Song[] = [];                   // 热歌推荐
  @State isLoading: boolean = false;

  private searchService: SearchService = SearchService.getInstance();   // 搜索服务
  private musicService = new MusicService();                            // 音乐服务
  private playerService = PlayerService.getInstance();  // 播放器服务

  aboutToAppear() {
    this.loadSearchData();
  }

  build() {
    Column() {
      // 搜索栏
      this.buildSearchBar()

      // 内容区域
      Scroll() {
        Column() {
          // 搜索历史
          if (this.searchHistory.length > 0) {
            this.buildSearchHistory()
          }

          // 猜你喜欢
          this.buildRecommendSection()

          // 热歌榜
          this.buildHotSongs()
        }
        .width('100%')
        .padding({ bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface'))
  }

  @Builder buildSearchBar() {
    Row() {
      // 返回按钮
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .margin({ right: 16 })
        .onClick(() => {
          router.back();
        })

      // 搜索输入框
      Row() {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .margin({ left: 12 })

        TextInput({ placeholder: '搜索歌曲、歌手、专辑', text: this.searchKeyword })
          .layoutWeight(1)
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.performSearch();
          })

        if (this.searchKeyword.length > 0) {
          Image($r('app.media.ic_clear'))
            .width(20)
            .height(20)
            .margin({ right: 12 })
            .onClick(() => {
              this.searchKeyword = '';
            })
        }

        Image($r('app.media.ic_mic'))
          .width(20)
          .height(20)
          .margin({ left: 12, right: 12 })
      }
      .layoutWeight(1)
      .height(40)
      .backgroundColor($r('app.color.surface'))
      .borderRadius(20)
      .border({ width: 1, color: $r('app.color.divider') })

      // 搜索按钮
      Text('搜索')
        .fontSize(16)
        .fontColor($r('app.color.primary'))
        .margin({ left: 16 })
        .onClick(() => {
          this.performSearch();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface'))
  }

  // 搜索历史模块构建
  @Builder buildSearchHistory() {
    Column() {
      // 标题栏
      Row() {
        Text('搜索历史')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)

        Text('清空')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .onClick(() => {
            this.clearSearchHistory();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      // 历史记录列表
      Column() {
        ForEach(this.searchHistory.slice(0, 8), (item: SearchHistory) => {
          Row() {
            Image($r('app.media.ic_search'))
              .width(16)
              .height(16)
              .margin({ right: 12 })

            Text(item.keyword)
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)

            Image($r('app.media.ic_clear'))
              .width(16)
              .height(16)
              .onClick(async() => {
                // 删除单条；历史记录
                // 1. 先调接口删除后端历史
                await this.searchService.deleteSearchHistory(item.id);
                // 2. 本地同步移除，触发响应式更新
                this.searchHistory = this.searchHistory.filter(h => h.id !== item.id);
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .onClick(() => {
            this.searchKeyword = item.keyword;
            this.performSearch();
          })
        })
      }
      .width('100%')
      .backgroundColor($r('app.color.surface'))
      .borderRadius(8)
      .margin({ left: 16, right: 16 })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  // 推荐模块构建
  @Builder buildRecommendSection() {
    Column() {
      Text('猜你喜欢')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })

      // 热门关键词标签
      Column() {
        if (this.hotKeywords.length > 0) {
          Row() {
            Scroll() {
              Row() {
                ForEach(this.hotKeywords, (keyword: SearchSuggestion) => {
                  Text(keyword.keyword)
                    .fontSize(14)
                    .fontColor($r('app.color.primary'))
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    .backgroundColor($r('app.color.surface_light'))
                    .borderRadius(20)
                    .margin({ right: 12 })
                    .onClick(() => {
                      this.searchKeyword = keyword.keyword;
                      this.performSearch();
                    })
                })
              }
              .padding({ left: 16, right: 16 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .layoutWeight(1)
          }
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      // 推荐歌曲列表
      Column() {
        ForEach(this.recommendSongs, (song: Song, index: number) => {
          Row() {
            // 序号
            Text((index + 1).toString())
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width(24)
              .textAlign(TextAlign.Center)

            // 歌曲封面
            Image(song.cover_url || $r('app.media.music_unselected'))
              .width(44)
              .height(44)
              .borderRadius(4)
              .backgroundColor($r('app.color.surface_light'))
              .margin({ left: 12 })
              .objectFit(ImageFit.Cover)

            // 歌曲信息
            Column() {
              Text(song.title)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(`${song.artist.name}${song.album ? ' - ' + song.album.title : ''}`)
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })

            // 时长
            Text(this.formatDuration(song.duration))
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 8 })

            // 更多按钮
            Image($r('app.media.ic_more'))
              .width(20)
              .height(20)
              .margin({ left: 12 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor($r('app.color.surface'))
          .onClick(() => {
            // 播放歌曲
            this.playSong(song);
          })
        })
      }
      .width('100%')
      .backgroundColor($r('app.color.surface'))
      .borderRadius(8)
      .margin({ left: 16, right: 16 })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  // 热词榜模块构建
  @Builder buildHotSongs() {
    Column() {
      Text('热歌榜')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })

      // 热门歌曲列表
      Column() {
        ForEach(this.hotSongs, (song: Song, index: number) => {
          Row() {
            // 排名
            Text((index + 1).toString())
              .fontSize(16)
              .fontColor(index < 3 ? $r('app.color.primary') : $r('app.color.text_secondary'))
              .fontWeight(index < 3 ? FontWeight.Bold : FontWeight.Normal)
              .width(32)
              .textAlign(TextAlign.Center)

            // 歌曲信息
            Column() {
              Text(song.title)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')

              Row() {
                Text(song.artist.name)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .layoutWeight(1)

                Text(this.formatPlayCount(song.stat?.play_count || 0))
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })

            // 播放按钮
            Image($r('app.media.ic_play_filled'))
              .width(20)
              .height(20)
              .margin({ left: 12 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(index % 2 === 0 ? $r('app.color.surface') : $r('app.color.surface_light'))
                    .onClick(() => {
            // 播放歌曲
            this.playSong(song);
          })
        })
      }
      .width('100%')
      .backgroundColor($r('app.color.surface'))
      .borderRadius(8)
      .margin({ left: 16, right: 16 })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  // 加载搜索数据
  private async loadSearchData() {
    this.isLoading = true;
    try {
      await Promise.all([
        this.loadSearchHistory(),
        this.loadHotKeywords(),
        this.loadRecommendSongs(),
        this.loadHotSongs()
      ]);
    } catch (error) {
      console.error('加载搜索数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 加载搜索历史
  private async loadSearchHistory() {
    try {
      const result = await this.searchService.getSearchHistory({ limit: 10 });
      this.searchHistory = result.list;
    } catch (error) {
      console.log('获取搜索历史失败:', error);
      // 使用模拟数据
      const mockHistoryList: SearchHistory[] = [
        { id: 1, keyword: '周杰伦', search_time: '2024-01-15T10:30:00.000Z' },
        { id: 2, keyword: '流行音乐', search_time: '2024-01-15T09:20:00.000Z' },
        { id: 3, keyword: '青花瓷', search_time: '2024-01-14T16:45:00.000Z' },
        { id: 4, keyword: '民谣', search_time: '2024-01-14T14:20:00.000Z' },
        { id: 5, keyword: '经典老歌', search_time: '2024-01-13T18:30:00.000Z' }
      ];
      this.searchHistory = mockHistoryList;
    }
  }

  // 加载热词
  private async loadHotKeywords() {
    try {
      const result = await this.searchService.getHotKeywords({ limit: 10 });
      this.hotKeywords = result;
    } catch (error) {
      console.log('获取热门搜索词失败:', error);
      // 使用模拟数据
      const mockKeywordsList: SearchSuggestion[] = [
        { keyword: '周杰伦', count: 5000 },
        { keyword: '邓紫棋', count: 3500 },
        { keyword: '流行音乐', count: 3000 },
        { keyword: '经典老歌', count: 2800 },
        { keyword: '民谣', count: 2500 }
      ];
      this.hotKeywords = mockKeywordsList;
    }
  }

  // 加载推荐歌曲
  private async loadRecommendSongs() {
    try {
      // 使用推荐歌曲API
      const songs = await this.musicService.getRecommendSongs(5);
      this.recommendSongs = songs;
    } catch (error) {
      console.error('获取推荐歌曲失败:', error);
      this.recommendSongs = [];
    }
  }

  // 加载热门歌曲
  private async loadHotSongs() {
    try {
      // 使用热门歌曲API
      const songs = await this.musicService.getHotSongs(10);
      this.hotSongs = songs;
    } catch (error) {
      console.error('获取热门歌曲失败:', error);
      this.hotSongs = [];
    }
  }

  // 全部清空搜索历史
  private async clearSearchHistory() {
    try {
      await this.searchService.deleteSearchHistory();
      this.searchHistory = [];
    } catch (error) {
      console.error('清空搜索历史失败:', error);
    }
  }

  // 跳转搜索结果页面
  private performSearch() {
    if (this.searchKeyword.trim().length === 0) {
      return;
    }

    router.pushUrl({
      url: 'pages/Search/SearchResultPage',
      params: {
        keyword: this.searchKeyword
      }
    });
  }

  /**
   * 播放歌曲
   */
  private async playSong(song: Song): Promise<void> {
    try {
      console.log('准备播放歌曲:', song.title, 'by', song.artist.name, 'ID:', song.id);
      
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
      await this.playerService.play(songDetail);
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
   * 格式化播放时长
   */
  private formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 格式化播放次数
   */
  private formatPlayCount(count: number): string {
    if (count >= 100000000) {
      return `${(count / 100000000).toFixed(1)}亿`;
    } else if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    } else {
      return count.toString();
    }
  }
} 