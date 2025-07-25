/**
 * 播放器页面 - 全屏音乐播放界面
 */
import router from '@ohos.router';
import AppConstants from '../../constants/AppConstants';
import { PlayerService, PlayerEventListener } from '../../services/PlayerService';
import { PlayerState, PaginationResponse} from '../../models/Common';
import { UserService } from '../../services/UserService';
import { PlayMode } from '../../models/PlayerState';
import { User, UserFavorite } from '../../models/User';
import { AuthManager } from '../../services/AuthManager';
import { MusicService } from '../../services/MusicService';
import { Song } from '../../models/Music'

@Entry
@Component
export struct PlayerPage {
  @State playerState: PlayerState | null = null;                // 播放器状态
  @State videoError: boolean = false;                           // 视频异常
  @State videoOpacity: number = 0;                              // 视频显示控制
  @State isUserSeeking: boolean = false;                        // 用户拖拽状态
  @State tempSeekTime: number = 0;                              // 临时拖拽时间
  @State currentUser: User | null = null;                       // 当前登录用户
  @State isLiked: boolean = false;                              // 当前用户是否已喜欢该歌曲
  @State isCheckingLikeStatus: boolean = true;                  // 正在检测喜欢状态
  @State songsList: Song[] = [];                                // 候选播放列表
  @State showSongsList: boolean = false                         // 播放列表显示控制

  @State likeAnimScale: number = 1;                             // 喜欢动画效果控制

  private playerService: PlayerService = PlayerService.getInstance();   // 播放器服务
  private userService = new UserService();                              // 用户服务
  private authManager = AuthManager.getInstance();                      // 认证服务
  private musicService = new MusicService();                            // 音乐服务

  private playerListener: PlayerEventListener = {
    onStateChanged: (state: PlayerState) => {
      this.playerState = state;
    },
    onProgressChanged: (currentTime: number, duration: number) => {
      // 只在用户没有拖拽时更新进度
      if (!this.isUserSeeking && this.playerState) {
        // 不使用展开运算符，直接更新属性
        this.playerState.currentTime = currentTime;
        this.playerState.duration = duration;
      }
    },
    onError: (error: Error) => {
      console.error('Player error:', error);
    }
  };                                                                   // 播放器事件监视

  // 页面渲染生命周期钩子
  async aboutToAppear() {
    this.playerService.addListener(this.playerListener);               // 启动监听
    this.playerState = this.playerService.getPlayerState();            // 加载播放器状态
    this.startVideoFadeIn();                                           // 启用动态背景

    // 获取当前用户信息
    this.currentUser = this.authManager.getCurrentUser();
    console.log('当前用户信息:', this.currentUser ? this.currentUser.username : '未登录');

    // 检查喜欢状态
    if (this.currentUser) {
      console.log('开始检查喜欢状态...');
      await this.checkLikeStatus();
    } else {
      this.isCheckingLikeStatus = false;
      console.log('跳过喜欢状态检查（未登录）');
    }

    // 加载播放列表
    this.loadSongsList()
  }

  // 页面销毁生命周期钩子
  aboutToDisappear() {
    this.playerService.removeListener(this.playerListener);
  }

  build() {
    Stack() {
      // 动态视频背景
      Stack() {
        // 静态图片背景
        Image($r('app.media.background'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .opacity(this.videoError ? 1.0 : 0.3)

        // 动态视频背景
        if (!this.videoError) {
          Video({
            src: $r('app.media.player')
          })
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .autoPlay(true)
            .loop(true)
            .muted(true)
            .controls(false)
            .opacity(this.videoOpacity)
            .onError(() => {
              console.log('Video failed to load, falling back to image');
              this.videoError = true;
            })
        }

        // 渐变遮罩
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 180,
            colors: [
              ['rgba(0,0,0,0.4)', 0],
              ['rgba(0,0,0,0.8)', 1]
            ]
          })
      }
      .width('100%')
      .height('100%')

      // 前景内容
      Column() {
        this.buildTopBar()

        Blank()

        this.buildPlayerControls()
      }
      .width('100%')
      .height('100%')
      .padding({ top: AppConstants.STATUS_BAR_HEIGHT, bottom: 40 })

      if(this.showSongsList)
        this.buildSongslist()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  // 顶部导航栏构建
  @Builder
  buildTopBar() {
    Row() {
      // 下拉图标
      Image($r('app.media.ic_arrow_down'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.closePlayer();
        })

      Column() {
        Text('私人漫游')
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Medium)

        Text('默认模式')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 2 })
      }

      // 更多操作图标
      Image($r('app.media.ic_share'))
        .width(24)
        .height(24)
        .onClick(() => {
          // TODO: 显示更多选项
        })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 20, right: 20 })
  }

  // 播放器控制组件构建
  @Builder
  buildPlayerControls() {
    Column() {
      if (!this.playerState || !this.playerState.currentSong) {
        // 没有歌曲时的占位显示
        Column() {
          Text('暂无播放歌曲')
            .fontSize(24)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 32 })
      } else {
        // 歌曲信息区域
        Column() {
          // 歌曲标题
          Row() {
            Marquee({
              start: true,
              step: 3,
              loop: -1,
              fromStart: true,
              src: this.playerState.currentSong.title
            })
              .fontSize(24)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .allowScale(false)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 8 })

          // 歌手名与功能按钮行
          Row() {
            // 左侧：歌手名
            Text(this.playerState.currentSong.artist?.name || '未知艺术家')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .layoutWeight(1)

            // 右侧：功能按钮
            Row() {
              Row() {
                if (!this.isLiked) {
                  Image($r('app.media.ic_favorite'))
                    .width(20)
                    .height(20)
                  // .scale({ x: this.likeAnimScale, y: this.likeAnimScale })   // 添加缩放动画
                } else {
                  Image($r('app.media.ic_favorite_filled'))
                    .width(20)
                    .height(20)
                    .scale({ x: this.likeAnimScale, y: this.likeAnimScale })   // 添加缩放动画
                }

                Text('150w+')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ left: 4 })
              }
              .margin({ right: 16 })
              .onClick(() => {
                this.toggleLikeSong();
              })

              // 评论按钮
              Row() {
                Image($r('app.media.ic_comment'))
                  .width(20)
                  .height(20)

                Text('1w+')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ left: 4 })
              }
              .onClick(() => {
                // TODO: 查看评论
              })
            }
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .margin({ bottom: 24 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 进度条
        Column() {
          Slider({
            value: this.isUserSeeking ? this.tempSeekTime : (this.playerState?.currentTime || 0),
            min: 0,
            max: Math.max(this.playerState?.duration || 1, 1),
            step: 1,
            style: SliderStyle.OutSet
          })
            .width('100%')
            .trackColor($r('app.color.slider_track'))
            .selectedColor($r('app.color.slider_selected'))
            .blockColor($r('app.color.slider_block'))
            .onChange((value: number, mode: number) => {
              if (mode === 0) { // Begin
                // 开始拖拽
                this.isUserSeeking = true;
                this.tempSeekTime = value;
              } else if (mode === 1) { // Moving
                // 拖拽中
                this.tempSeekTime = value;
              } else if (mode === 2) { // End
                // 拖拽结束，执行跳转
                this.isUserSeeking = false;
                this.playerService.seekTo(value);
              }
            })

          Row() {
            Text(this.formatTime(this.isUserSeeking ? this.tempSeekTime : (this.playerState?.currentTime || 0)))
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))

            Blank()

            Text(this.formatTime(this.playerState?.duration || 0))
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .margin({ top: 8 })
        }
        .width('100%')
        .margin({ bottom: 24 })

        // 播放控制按钮组
        Row() {
          // 循环模式
          Image(this.getPlayModeIcon())
            .width(24)
            .height(24)
            .onClick(() => {
              this.togglePlayMode();
            })

          // 上一首
          Image($r('app.media.ic_skip_previous'))
            .width(32)
            .height(32)
            .onClick(() => {
              this.previousSong();
            })

          // 播放/暂停
          Image(this.playerState?.playState === 'playing' ? $r('app.media.ic_continue') : $r('app.media.ic_play_filled'))
            .width(64)
            .height(64)
            .onClick(() => {
              this.togglePlayPause();
            })

          // 下一首
          Image($r('app.media.ic_skip_next'))
            .width(32)
            .height(32)
            .onClick(() => {
              this.nextSong();
            })

          // 播放列表
          Image($r('app.media.ic_playlist'))
            .width(24)
            .height(24)
            .onClick(() => {
              // TODO: 显示播放列表
              this.showSongsList = true
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
  }

  // 播放列表构建
  @Builder
  buildSongslist() {
    // 弹窗遮罩
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0,0,0,0.5)')
      .onClick(() => {
        this.showSongsList = false; // 点击遮罩关闭弹窗
      })

    // 底部弹窗内容
    Column() {
      // 顶部下拉小横条
      Row() {
        Blank().width(40).height(4)
          .borderRadius(2)
          .backgroundColor($r('app.color.divider'))
          .margin({ top: 10, bottom: 10 })
      }
      .width('100%').justifyContent(FlexAlign.Center)

      // 顶部栏
      Row() {
        Image($r('app.media.ic_arrow_down'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.showSongsList = false;
          })

        Text('当前播放')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .textAlign(TextAlign.Center)
          .layoutWeight(1)

        // 占位，保持居中
        Row().width(24).height(24)
        // 可以扩展历史播放Tab切换等
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      // 播放列表内容
      Scroll() {
        Column() {
          ForEach(this.songsList, (song: Song, index: number) => {
            Row() {
              // 歌曲序号
              Text(`${index + 1}.`)
                .fontSize(16)
                .fontColor($r('app.color.text_secondary'))
                .margin({ right: 12 })

              // 歌曲名与艺术家
              Column() {
                Row(){
                  Text(song.title)
                    .fontSize(16)
                    .fontColor($r('app.color.text_primary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                }
                .margin({top:4})

                Row(){
                  Text(song.artist.name)
                    .fontSize(12)
                    .fontColor($r('app.color.text_tertiary'))
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .margin({top:4})
              }
              .margin({ right: 12 })
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              // 切换播放
              this.showSongsList = false
              this.playerService.playBySong(song)
            })

            if (index < this.songsList.length - 1) {
              Divider()
                .color('#CCCCCC')
                .opacity(0.6)
                .margin({ left: 16, right: 16 })
            }

          })
        }
        .padding({ bottom: 24, top: 8 })
      }
      .width('100%')
      .height(340) // 控制半屏弹窗高度
    }
    .width('100%')
    .backgroundColor($r('app.color.surface'))
    .borderRadius({ topLeft: 24, topRight: 24 })
    .position({ x: 0, y: '42%' })
    .animation({ duration: 200 })
  }

  // 页面转场动画
  pageTransition() {
    PageTransitionEnter({ duration: 300 })
      .slide(SlideEffect.Bottom)
    PageTransitionExit({ duration: 300 })
      .slide(SlideEffect.Bottom)
  }

  // 格式化时间显示
  private formatTime(seconds: number): string {
    if (!seconds || isNaN(seconds) || seconds < 0) {
      return '00:00';
    }

    const totalSeconds = Math.floor(seconds);
    const mins = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 开始视频淡入效果
  private startVideoFadeIn() {
    // 淡入动画
    animateTo({
      duration: 1000,
      curve: Curve.EaseInOut
    }, () => {
      this.videoOpacity = 1.0;
    });
  }

  // 关闭播放器
  private closePlayer(): void {
    AppStorage.setOrCreate("showPlayer",false)
    router.back();
  }

  // 切换播放/暂停
  private togglePlayPause(): void {
    if (!this.playerState) return;

    if (this.playerState.playState === 'playing') {
      this.playerService.pause();
    } else {
      // 确保有当前歌曲才能播放
      if (this.playerState.currentSong) {
        this.playerService.play(this.playerState.currentSong);
      } else {
        console.warn('当前没有音乐可播放');
      }
    }
  }

  // 切换播放模式
  private togglePlayMode(): void {
    if (!this.playerState) return;

    const modes: PlayMode[] = [PlayMode.SEQUENCE, PlayMode.LOOP, PlayMode.SHUFFLE, PlayMode.SINGLE];
    const currentIndex = modes.indexOf(this.playerState.playMode);
    const nextIndex = (currentIndex + 1) % modes.length;

    this.playerService.setPlayMode(modes[nextIndex]);
  }

  // 获取播放模式图标
  private getPlayModeIcon(): Resource {
    if (!this.playerState) return $r('app.media.ic_repeat');

    switch (this.playerState.playMode) {
      case PlayMode.SHUFFLE:
        return $r('app.media.ic_shuffle');
      case PlayMode.SINGLE:
        return $r('app.media.ic_repeat_one');
      case PlayMode.SEQUENCE:
        return $r('app.media.ic_sequence')
      default:
        return $r('app.media.ic_repeat');
    }
  }

  // 获取当前播放音乐在播放列表中的位置索引
  private getCurrentIndex(): number {
    return this.songsList.findIndex(song => {
      console.log('【song.id】',song.id)
      console.log('【this.playerState?.currentSong?.id】',this.playerState?.currentSong?.id)
      return song.id === this.playerState?.currentSong?.id
    });
  }

  // 切换上一首
  private async previousSong(): Promise<void>{
    console.log('上一首')
    const currentIndex = this.getCurrentIndex();
    if (currentIndex < 0) {
      console.warn('当前歌曲不在列表中');
      return;
    }

    const preIndex = (currentIndex - 1 + this.songsList.length) % this.songsList.length;
    const songToPlay = this.songsList[preIndex]

    this.checkLikeStatus()

    await this.playerService.playBySong(songToPlay);
  }

  // 切换下一首
  private async nextSong(): Promise<void>{
    console.log('下一首')
    const currentIndex = this.getCurrentIndex();
    if (currentIndex < 0) {
      console.warn('当前歌曲不在列表中');
      return;
    }

    const nextIndex = (currentIndex + 1) % this.songsList.length;
    const songToPlay = this.songsList[nextIndex]

    this.checkLikeStatus()

    await this.playerService.playBySong(songToPlay);
  }

  /**
   * 检查喜欢状态
   */
  private async checkLikeStatus(): Promise<void> {
    try {
      this.isCheckingLikeStatus = true;
      console.log('检查歌曲喜欢状态...');

      // 获取用户收藏的歌单列表
      const LikeResponse = await this.userService.getFavoriteSongs({ page: 1, limit: 100 });
      const LikeSongs = LikeResponse.list;

      // ======== 调试输出 START ========
      console.log("LikeResponse: ", JSON.stringify(LikeResponse, null, 2))
      console.log("LikeSongs: ", JSON.stringify(LikeSongs, null, 2))
      // ======== 调试输出 END ========

      // 检查当前歌曲是否已在喜欢列表
      if (LikeResponse && Array.isArray(LikeSongs)) {
        this.isLiked = LikeSongs.some((item: UserFavorite) => {
          console.log("item.song_id: ", item.song_id);
          console.log("this.playlistId: ", this.playerState?.currentSong?.id);
          return item.song_id === this.playerState?.currentSong?.id
        }
        );
      } else {
        console.warn('喜欢列表数据格式不正确，默认设为未喜欢');
        this.isLiked = false;
      }

      console.log('喜欢状态检查完成:', this.isLiked ? '已喜欢' : '未喜欢');

    } catch (error) {
      console.warn('检查喜欢状态失败:', error);
      this.isLiked = false;
    } finally {
      this.isCheckingLikeStatus = false;
    }
  }

  /**
   * 切换喜欢状态
   */
  private async toggleLikeSong(): Promise<void>{
    if (!this.currentUser) {
      console.log('无法操作：用户未登录');
      return;
    }

    if (this.isCheckingLikeStatus) {
      console.log('正在检查喜欢状态，请稍后');
      return;
    }

    // 触发动画：先缩小再回弹
    animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
      this.likeAnimScale = 0.7;
      setTimeout(() => {
        animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
          this.likeAnimScale = 2.0;
          setTimeout(() => {
            animateTo({ duration: 80, curve: Curve.EaseIn }, () => {
              this.likeAnimScale = 1;
            });
          }, 150);
        });
      }, 120);
    });

    try {
      this.isCheckingLikeStatus = true;

      if (this.isLiked) {
        console.log('取消喜欢歌曲...');
        if(this.playerState?.currentSong?.id)
          await this.musicService.unlikeSong(this.playerState?.currentSong?.id);
        this.isLiked = false;
        console.log('取消喜欢成功');

        // 更新喜欢数(-1)
        if (this.playerState?.currentSong && this.playerState?.currentSong.stat.like_count) {
          this.playerState.currentSong.stat.like_count = Math.max(0, this.playerState.currentSong.stat.like_count - 1);
        }
      } else {
        console.log('喜欢歌曲...');
        if(this.playerState?.currentSong?.id)
          await this.musicService.likeSong(this.playerState?.currentSong?.id);
        this.isLiked = true;
        console.log('喜欢成功');

        // 更新喜欢数(+1)
        if (this.playerState?.currentSong) {
          this.playerState.currentSong.stat.like_count = (this.playerState.currentSong.stat.like_count || 0) + 1;
        }
      }
    } catch (error) {
      console.error('喜欢操作失败:', error);
      const errorMessage = error instanceof Error ? error.message : '操作失败';

      // 根据错误类型提供不同的提示
      if (errorMessage.includes('PLAYLIST_ALREADY_COLLECTED')) {
        console.log('歌曲已喜欢');
        this.isLiked = true;
      } else if (errorMessage.includes('PLAYLIST_NOT_COLLECTED')) {
        console.log('歌单已收藏');
        this.isLiked = false;
      } else {
        // TODO: 显示错误提示给用户
        console.error('收藏操作失败:', errorMessage);
      }
    } finally {
      this.isCheckingLikeStatus = false;
    }
  }

  /**
   * 加载播放列表
   */
  private async loadSongsList(){
    // 获取歌曲列表
    const songsResponse = await this.musicService.getSongList({ page: 1, limit: 100 })
    console.log('【songsResponse】：',JSON.stringify(songsResponse, null, 2))

    const songsList = songsResponse.list
    console.log('【songsList】：',JSON.stringify(songsList, null, 2))

    // 构造候选列表
    this.songsList = this.getRandomSongs(songsList);
    console.log('【this.songsList】：',JSON.stringify(this.songsList, null, 2))

    // 设置当前歌曲为列表首位
    if(this.playerState?.currentSong)
      this.songsList = [this.playerState?.currentSong, ...this.songsList];
  }

  /**
   * 从歌曲列表中随机取 10 首
   */
  private getRandomSongs(songs: Song[], count: number = 9): Song[] {
    const shuffled = [...songs];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled.slice(0, count);
  }

} 