/**
 * 播放历史页面
 */
import router from '@ohos.router';
import { Song } from '../../models/Music';
import { UserService } from '../../services/UserService';
import { MusicService } from '../../services/MusicService';
import { PlayerService, PlayerEventListener } from '../../services/PlayerService';
import { SongItem } from '../../components/common/SongItem';
import { PaginationParams, PaginationResponse } from '../../models/Common';
import { UserHistory } from '../../models/User';
import AppConstants from '../../constants/AppConstants';

@Entry
@Component
export struct PlayHistoryPage {
  @State historyList: UserHistory[] = [];
  @State isLoading: boolean = true;
  @State hasMore: boolean = true;
  @State currentPage: number = 1;
  @State playingSongId: number = -1;

  private userService = new UserService();
  private musicService = new MusicService();
  private playerService = PlayerService.getInstance();
  private playerEventListener: PlayerEventListener = {
    onSongChanged: (song: Song | undefined) => {
      this.playingSongId = song?.id || -1;
    }
  };

  aboutToAppear(): void {
    this.loadPlayHistory();

    // 监听播放器状态变化
    this.playerService.addListener(this.playerEventListener);
  }

  build() {
    Column() {
      // 导航栏
      this.buildNavigationBar()

      if (this.isLoading && this.historyList.length === 0) {
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
      } else if (this.historyList.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.ic_clock'))
            .width(80)
            .height(80)
            .fillColor('#CCCCCC')
            .margin({ bottom: 16 })

          Text('暂无播放历史')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          Text('快去听歌吧')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 历史列表
        Scroll() {
          Column() {
            // 统计信息和操作按钮
            Row() {
              Text(`共${this.historyList.length}首歌曲`)
                .fontSize(14)
                .fontColor('#666666')
                .layoutWeight(1)

              Button('清空历史')
                .fontSize(14)
                .fontColor('#FF6B6B')
                .backgroundColor('transparent')
                .border({ width: 1, color: '#FF6B6B', radius: 20 })
                .height(36)
                .padding({ left: 16, right: 16 })
                .onClick(() => {
                  this.clearHistory();
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })

            // 历史记录列表
            ForEach(this.historyList, (history: UserHistory, index: number) => {
              Column() {
                if (history.song) {
                  Row() {
                    SongItem({
                      song: history.song,
                      showIndex: false,
                      isPlaying: this.playingSongId === history.song.id,
                      onPlay: (song: Song) => {
                        this.playSong(song);
                      }
                    })
                      .layoutWeight(1)
                  }

                  // 播放时间
                  //Row() {
                  //  Text(`播放时间: ${this.formatPlayTime(history.playTime)}`)
                  //    .fontSize(12)
                  //    .fontColor('#999999')
                  // }
                  //  .width('100%')
                  // .justifyContent(FlexAlign.End)
                  //.padding({ right: 16, top: 4 })
                }
              }
              .padding({ left: 16, right: 16, top: 8, bottom: 12 })
              .alignItems(HorizontalAlign.Start)
            })

            // 加载更多
            if (this.hasMore) {
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
          .width('100%')
          .padding({ bottom: 100 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
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

      Text('播放历史')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppConstants.COLORS.TEXT_PRIMARY)
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

  // 加载播放历史
  private async loadPlayHistory(): Promise<void> {
    try {
      this.isLoading = true;
      const params: PaginationParams = {
        page: 1,
        limit: 50 // 限制最多加载50条
      };
      const response = await this.userService.getPlayHistory(params);
      console.log('播放历史接口返回：', JSON.stringify(response, null, 2));
      let historyList = response.list.slice(0, 50);

      // 补全song字段
      for (let history of historyList) {
        if (!history.song && history.song_id) {
          try {
            history.song = await this.musicService.getSongDetail(history.song_id);
            console.log('补全歌曲详情成功', history.song_id, history.song);
          } catch (e) {
            console.warn('获取歌曲详情失败', history.song_id, e);
          }
        }
      }
      // 去重：只保留每个 song_id 最新的一条
      const uniqueMap = new Map<number, UserHistory>();
      for (const history of historyList) {
        if (!uniqueMap.has(history.song_id)) {
          uniqueMap.set(history.song_id, history);
        }
      }
      this.historyList = Array.from(uniqueMap.values());
      console.log('补全后的历史列表：', JSON.stringify(this.historyList, null, 2));
      this.hasMore = response.pagination.page < response.pagination.totalPages && this.historyList.length < 50;
      this.currentPage = 1;
    } catch (error) {
      console.error('加载播放历史失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 加载更多
  private async loadMore(): Promise<void> {
    if (!this.hasMore || this.isLoading) return;

    try {
      this.isLoading = true;
      const params: PaginationParams = {
        page: this.currentPage + 1,
        limit: 50
      };
      const response = await this.userService.getPlayHistory(params);
      const combined = this.historyList.concat(response.list);
      this.historyList = combined.slice(0, 50); // 保证总数不超过50
      this.hasMore = response.pagination.page < response.pagination.totalPages && this.historyList.length < 50;
      this.currentPage++;
    } catch (error) {
      console.error('Failed to load more history:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 播放歌曲
  private async playSong(song: Song): Promise<void> {
    try {
      console.log('准备播放历史歌曲:', song.title, 'by', song.artist?.name, 'ID:', song.id);

      // 先获取歌曲详情，确保有完整的播放信息
      console.log('正在获取歌曲详情...');
      const songDetail = await this.musicService.getSongDetail(song.id);
      console.log('歌曲详情获取成功:', songDetail.title, 'audio_url:', songDetail.audio_url);

      // 检查音频链接是否有效
      if (!songDetail.audio_url || songDetail.audio_url.trim() === '') {
        throw new Error(`歌曲《${songDetail.title}》暂无可播放的音频链接`);
      }

      // 导入播放器服务（和喜欢页面保持一致）
      const PlayerServiceModule = await import('../../services/PlayerService');
      const playerService = PlayerServiceModule.PlayerService.getInstance();

      // 设置播放列表（只设置当前歌曲，和喜欢页面保持一致）
      playerService.setPlaylist([songDetail], 0);

      // 开始播放
      await playerService.play(songDetail);

      // 跳转到播放器页面
      router.pushUrl({
        url: 'pages/Player/PlayerPage'
      });

      // 调用播放API记录播放次数
      this.musicService.playSong(songDetail.id).catch((error: Error) => {
        console.warn('记录播放次数失败:', error);
      });

      console.log('历史歌曲播放启动成功');

    } catch (error) {
      console.error('播放历史歌曲失败:', error);
      // 显示错误提示给用户
      const errorMessage = error instanceof Error ? error.message : '播放失败，请稍后重试';
      console.error('播放错误详情:', errorMessage);
      // TODO: 可以在这里添加Toast提示用户
    }
  }

  // 清空历史记录
  private async clearHistory(): Promise<void> {
    try {
      // TODO: 实现清空历史记录的API
      console.log('清空播放历史');
      // 临时清空本地数据
      this.historyList = [];
    } catch (error) {
      console.error('Failed to clear history:', error);
    }
  }

  // 格式化播放时间
  private formatPlayTime(playTime: string): string {
    try {
      const date = new Date(playTime);
      const now = new Date();
      const diffMs = now.getTime() - date.getTime();
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

      if (diffDays === 0) {
        // 今天
        return `今天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
      } else if (diffDays === 1) {
        // 昨天
        return `昨天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
      } else if (diffDays < 7) {
        // 一周内
        return `${diffDays}天前`;
      } else {
        // 超过一周，显示具体日期
        return `${date.getMonth() + 1}-${date.getDate()}`;
      }
    } catch (error) {
      return playTime;
    }
  }
} 