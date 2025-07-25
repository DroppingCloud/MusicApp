/**
 * 个人页 - 个人中心和设置
 */
import AppConstants from '../../constants/AppConstants';
import { AuthManager } from '../../services/AuthManager';
import { User, UpdateUserRequest, ChangePasswordRequest } from '../../models/User';
import { UserService } from '../../services/UserService';
import { UserStats, PaginationParams } from '../../models/Common';
import router from '@ohos.router';
import { ColorMetrics } from '@kit.ArkUI';
import { UserCollect } from '../../models/User';
import { Playlist, Song } from '../../models/Music';
import common from '@ohos.app.ability.common';

@Entry
@Component
export struct ProfilePage {
  @State currentUser: User | null = null;
  @State isLoading: boolean = false;
  @State userStats: UserStats = {
    favoriteCount: 0,
    playlistCount: 0,
    historyCount: 0
  };

  // 用户信息编辑控制
  @State showEditDialog: boolean = false;
  @State editUsername: string = '';
  @State editEmail: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State passwordError: string = '';

  // Tab页面切换
  @State currentTabIndex: number = 0;
  
  // 歌单相关状态
  @State collectedPlaylists: UserCollect[] = [];
  @State playlists: Playlist[] = [];
  @State firstSongs: Map<number, Song> = new Map();
  @State isMusicLoading: boolean = false;
  // @State favoriteSongsCount: number = 0;
  @StorageLink('favoriteSongsCount') favoriteSongsCount: number = 0

  @State showRightDrawer: boolean = false;
  @State rightDrawerOffset: number = 280; // 初始偏移为弹窗宽度

  private authManager = AuthManager.getInstance();
  private userService = new UserService();

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

  aboutToAppear(): void {
    this.loadUserInfo();
    this.loadMusicTabData();
    
    // 监听认证状态变化
    this.authManager.addAuthStateListener((isLoggedIn: boolean, user: User | null) => {
      if (isLoggedIn && user) {
        this.currentUser = user;
        this.loadUserStats();
      } else {
        this.currentUser = null;
      }
    });
  }

  aboutToDisappear(): void {
    // 移除监听器
    this.authManager.removeAuthStateListener(this.handleAuthStateChange);
  }

  // 认证状态变化处理
  private handleAuthStateChange = (isLoggedIn: boolean, user: User | null): void => {
    if (isLoggedIn && user) {
      this.currentUser = user;
      this.loadUserStats();
    } else {
      this.currentUser = null;
    }
  }

  // 加载用户信息
  private async loadUserInfo(): Promise<void> {
    try {
      this.isLoading = true;
      console.log('开始加载用户信息...');
      
      // 使用UserService的getCurrentUser方法获取最新用户信息
      const user = await this.userService.getCurrentUser();
      console.log('获取用户信息成功:', user);
      
      this.currentUser = user;
      
      // 更新AuthManager中的用户信息
      this.authManager.updateUserInfo(user);
      
      // 加载用户统计信息
      await this.loadUserStats();
      
    } catch (error) {
      console.error('加载用户信息失败:', error);
      // 如果API调用失败，尝试从AuthManager获取缓存的用户信息
      this.currentUser = this.authManager.getCurrentUser();
      
      // 仍然尝试加载统计信息
      await this.loadUserStats();
    } finally {
      this.isLoading = false;
    }
  }

  // 加载用户状态
  private async loadUserStats(): Promise<void> {
    try {
      console.log('开始加载用户统计信息...');
      
      // 并发加载统计数据
      const favoritesParams: PaginationParams = { page: 1, limit: 1 };
      const historyParams: PaginationParams = { page: 1, limit: 1 };
      const collectedParams: PaginationParams = { page: 1, limit: 1 };
      
      const results = await Promise.allSettled([
        this.userService.getFavoriteSongs(favoritesParams),
        this.userService.getPlayHistory(historyParams),
        this.userService.getCollectedPlaylists(collectedParams)
      ]);

      // 更新收藏歌曲数
      const favoritesResult = results[0];
      if (favoritesResult.status === 'fulfilled') {
        this.userStats.favoriteCount = favoritesResult.value.pagination.total;
        console.log('收藏歌曲数:', this.userStats.favoriteCount);
      } else {
        console.error('获取收藏歌曲统计失败:', favoritesResult.reason);
      }

      // 更新播放历史数
      const historyResult = results[1];
      if (historyResult.status === 'fulfilled') {
        this.userStats.historyCount = historyResult.value.pagination.total;
        console.log('播放历史数:', this.userStats.historyCount);
      } else {
        console.error('获取播放历史统计失败:', historyResult.reason);
      }

      // 更新收藏歌单数（替代创建的歌单）
      const collectedResult = results[2];
      if (collectedResult.status === 'fulfilled') {
        this.userStats.playlistCount = collectedResult.value.pagination.total;
        console.log('收藏歌单数:', this.userStats.playlistCount);
      } else {
        console.error('获取收藏歌单统计失败:', collectedResult.reason);
      }

    } catch (error) {
      console.error('加载用户统计信息失败:', error);
    }
  }

  // 加载音乐Tab数据（收藏歌单及其详情）
  private async loadMusicTabData(): Promise<void> {
    this.isMusicLoading = true;
    try {
      const params: PaginationParams = { page: 1, limit: 10 };
      // 获取喜欢的歌曲数量
      const favoriteRes = await this.userService.getFavoriteSongs({ page: 1, limit: 1 });
      this.favoriteSongsCount = favoriteRes.pagination.total;
      // 获取收藏的歌单
      const collectedResponse = await this.userService.getCollectedPlaylists(params);
      this.collectedPlaylists = collectedResponse.list;
      // 歌单详情和第一首歌
      const playlistsWithDetails: Playlist[] = [];
      const firstSongsMap: Map<number, Song> = new Map();
      const musicService = new (await import('../../services/MusicService')).MusicService();
      for (const item of this.collectedPlaylists) {
        try {
          const playlistDetail = await musicService.getPlaylistDetail(item.playlist_id);
          playlistsWithDetails.push(playlistDetail);
          if (playlistDetail.song_count > 0) {
            try {
              const songsResponse = await musicService.getPlaylistSongs(playlistDetail.id, { page: 1, limit: 1 });
              if (songsResponse.list && songsResponse.list.length > 0) {
                const firstSong = songsResponse.list[0].song;
                firstSongsMap.set(playlistDetail.id, firstSong);
              }
            } catch {}
          }
        } catch {}
      }
      this.playlists = playlistsWithDetails;
      this.firstSongs = firstSongsMap;
    } catch (error) {
      this.collectedPlaylists = [];
      this.playlists = [];
      this.firstSongs = new Map();
      this.favoriteSongsCount = 0;
    } finally {
      this.isMusicLoading = false;
    }
  }

  build() {
    Scroll() {
      Stack({alignContent: Alignment.TopEnd}){
        // ====== 底部背景层 ======
        // // 背景图片
        // Image($r('app.media.profile_bg'))
        //   .width('100%')
        //   .height('100%')
        //   .objectFit(ImageFit.Cover)
        //   .position({ x: 0, y: 0 })
        //
        // // 半透明灰色遮罩
        // Column() { }
        // .width('100%')
        // .height('100%')
        // .backgroundColor('rgba(70,70,70,0.62)')
        // .position({ x: 0, y: 0 })

        Column() {
          // 用户信息区域
          this.buildUserProfile()
          // 横排灰色按钮区
          this.buildGreyButton()
          // Tab区域
          this.buildTab()
/*          // 功能菜单
          this.buildMenuSection()
          // 设置选项
          this.buildSettingsSection()
          // 退出登录区域
          this.buildLogoutSection()*/
          if(this.showEditDialog)
            this.buildEditUserDialog()
        }
        .padding({ bottom: 80 }) // 为底部导航栏留出空间

        Image($r('app.media.ic_more'))
          .width(24)
          .height(24)
          .margin({ right: 16, top: 16 })
          .onClick(() => {
            this.rightDrawerOffset = 280;
            this.showRightDrawer = true;
            setTimeout(() => { this.rightDrawerOffset = 0 }, 10); // 触发动画
          })

        if (this.showRightDrawer) {
          this.showSetWindow()
        }
      }
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface'))
  }

  // 横排灰色按钮
  @Builder
  buildGreyButton(){
    Row() {
      // 最近
      Row(){
        Image($r('app.media.ic_clock'))
          .width(24)
          .margin({ left: 5, right: 5, top: 5, bottom: 5 })
        Text('最近')
          .margin({right: 5, top: 5, bottom: 5 })
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('20%')
      .margin({ right: 16 })
      .backgroundColor('#97f8f8f8')
      .borderRadius(4)
      .onClick(() => {
        this.goToPlayHistory();
      })
      //.margin({ right: 20 })

      // 本地
      Row(){
        Image($r('app.media.ic_download'))
          .width(24)
          .margin({ left: 5, right: 5, top: 5, bottom: 5 })
        Text('本地')
          .margin({right: 5, top: 5, bottom: 5 })
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('20%')
      .margin({ right: 16 })
      .backgroundColor('#97f8f8f8')
      .borderRadius(4)

      // 主题
      Row(){
        Image($r('app.media.ic_theme'))
          .width(24)
          .margin({ left: 5, right: 5, top: 5, bottom: 5 })
        Text('主题')
          .margin({right: 5, top: 5, bottom: 5 })
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('20%')
      .margin({ right: 16 })
      .backgroundColor('#97f8f8f8')
      .borderRadius(4)
      .onClick(() => {
        router.pushUrl({ url: 'pages/Profile/ChangeThemeColor' });
      })

    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')


  }

  // Tab区域构建
  @Builder
  buildTab(){
    Tabs({ index: $$this.currentTabIndex }) {
      TabContent() {
        this.buildMusicContent()
      }
      .tabBar('我的歌单')

      TabContent() {
        this.buildNotesContent()
      }
      .tabBar('笔记')
    }
    .onChange((index: number) => {
      this.currentTabIndex = index;
    })
  }

  // 音乐内容构建
  @Builder
  buildMusicContent() {
    Column() {
      // 我的喜欢歌单卡片
      Row() {
        Image($r('app.media.ic_favorite_filled'))
          .width(50)
          .height(50)
          .borderRadius(8)
          .backgroundColor('#ccffd1e0')
          .fillColor('#b3ff0044')
        Column() {
          Text('我的喜欢')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${this.favoriteSongsCount} 首歌曲`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 8, bottom: 8, left: 16, right: 16 })
      .onClick(() => this.goToFavorites())

      // 收藏歌单列表
      if (this.isMusicLoading) {
        Row() {
          LoadingProgress()
            .width(32)
            .height(32)
            .color($r('app.color.primary'))
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 24 })
      } else if (this.playlists.length === 0) {
        // Row() {
        //   Image($r('app.media.ic_playlist'))
        //     .width(20)
        //     .height(20)
        //     .borderRadius(8)
        //     .backgroundColor($r('app.color.divider'))
        //     .fillColor($r('app.color.text_secondary'))
        //   Text('暂无收藏歌单')
        //     .fontSize(12)
        //     .fontColor($r('app.color.text_secondary'))
        //     .margin({ left: 10 })
        // }
        // .width('100%')
        // .justifyContent(FlexAlign.Center)
        // .margin({ top: 24 })
      } else {
        Column() {
          ForEach(this.playlists, (playlist: Playlist, index: number) => {
            Row() {
              // 歌单封面
              Image(this.getFullImageUrl(playlist.cover_url) || $r('app.media.ic_playlist'))
                .width(50)
                .height(50)
                .borderRadius(6)
                .backgroundColor($r('app.color.surface'))
                .objectFit(ImageFit.Cover)
              // 歌单信息
              Column() {
                Text(playlist.title)
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
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
                Image($r('app.media.ic_more'))
                  .width(20)
                  .height(20)
                  .onClick(() => this.showPlaylistActions(playlist))
              }
            }
            .width('100%')
            .padding({ top: 8, bottom: 8, left: 16, right: 16 })
            .onClick(() => this.goToPlaylistDetail(playlist.id))
          }, (playlist: Playlist) => `${playlist.id}`)
        }
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }

  // 设置右弹窗
  @Builder
  showSetWindow() {
    Stack({ alignContent: Alignment.End}) {
      // 遮罩层，点击关闭弹窗
      Column() {}
        .width('100%').height('100%')
        .backgroundColor('rgba(0,0,0,0.3)')
        .onClick(() => {
          this.rightDrawerOffset = 280;
          setTimeout(() => { this.showRightDrawer = false }, 200); // 动画结束后关闭
        })
      // 右侧弹层内容
      Column() {
        this.buildSettingsSection()
        this.buildLogoutSection()
      }
      .width(280)
      .height('100%')
      .backgroundColor($r('app.color.surface'))
      .justifyContent(FlexAlign.Start)
      .translate({ x: this.rightDrawerOffset, y: 0 })
      .animation({ duration: 200, curve: Curve.EaseInOut })
    }
    //.width('100%').height('100%')
    //.position({ x: 0, y: 0 })
    //.zIndex(1000)
  }

  // 获取歌单第一首歌名
  private getFirstSongTitle(playlistId: number | undefined): string | undefined {
    if (!playlistId) return undefined;
    const firstSong = this.firstSongs.get(playlistId);
    if (!firstSong) return undefined;
    return `${firstSong.title} - ${firstSong.artist.name}`;
  }

  // 歌单操作菜单（可选实现）
  private showPlaylistActions(playlist: Playlist): void {
    // TODO: 实现歌单操作菜单
  }

  // 跳转到歌单详情
  private goToPlaylistDetail(playlistId: number): void {
    router.pushUrl({
      url: 'pages/Playlist/PlaylistDetailPage',
      params: { playlistId }
    });
  }

  // 笔记内容构建
  @Builder
  buildNotesContent() {
    Text('笔记')
  }

  // 用户信息项构建
  @Builder
  buildUserProfile() {
    Column() {
      if (this.currentUser) {
        // 已登录状态 - 显示真实用户信息
        Column() {
          // 用户头像
          Stack() {
            if (this.currentUser.avatar && this.getFullImageUrl(this.currentUser.avatar)) {
              Image(this.getFullImageUrl(this.currentUser.avatar)!)
                .width(80)
                .height(80)
                .borderRadius(40)
                .backgroundColor($r('app.color.surface'))
                .objectFit(ImageFit.Cover)
                .onError(() => {
                  console.error('头像加载失败:', this.currentUser?.avatar);
                })
            } else {
              Image($r('app.media.user_unselected'))
                .width(80)
                .height(80)
                .borderRadius(40)
                .backgroundColor($r('app.color.surface'))
            }

            // // 上传提示图标
            // if (!this.isLoading) {
            //   Image($r('app.media.ic_edit'))
            //     .width(24)
            //     .height(24)
            //     .borderRadius(12)
            //     .backgroundColor('rgba(0, 0, 0, 0.6)')
            //     .padding(4)
            //     .fillColor('#FFFFFF')
            // } else {
            //   LoadingProgress()
            //     .width(24)
            //     .height(24)
            //     .color('#FFFFFF')
            // }
          }
          .width(80)
          .height(80)
          .margin({ bottom: 16 })
          .onClick(() => {
            if (!this.isLoading) {
              this.uploadAvatar();
            }
          })

          Row(){
            // 用户昵称
            Text(this.currentUser.username)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })

            // 编辑项
            Image($r('app.media.ic_edit'))
              .width(16)
              .height(16)
              .borderRadius(16)
              .margin({ left: 12, bottom: 5 })
              .onClick(() => {
                // 初始化编辑表单数据
                this.editUsername = this.currentUser?.username ?? '';
                this.editEmail = this.currentUser?.email ?? '';
                this.showEditDialog = true;
                console.log("弹窗状态改变")
              })
          }

          // // 用户邮箱
          // if (this.currentUser.email) {
          //   Text(this.currentUser.email)
          //     .fontSize(14)
          //     .fontColor('#666666')
          //     .margin({ bottom: 16 })
          // }

          if (this.isLoading) {
            LoadingProgress()
              .width(24)
              .height(24)
              .color($r('app.color.text_secondary'))
              .margin({ top: 8 })
          }
        }
        .width('100%')
        .padding(24)
        .backgroundColor($r('app.color.surface'))
        .borderRadius(16)
        .margin({ left: 16, right: 16, top: 16 })
        .alignItems(HorizontalAlign.Center)

      } else {
        // 未登录状态（理论上不会出现，因为有路由守卫）
        Column() {
          Image($r('app.media.user_unselected'))
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor($r('app.color.surface'))
            .margin({ bottom: 16 })

          Text('用户信息加载中...')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            
          if (this.isLoading) {
            LoadingProgress()
              .width(24)
              .height(24)
              .color($r('app.color.text_secondary'))
              .margin({ top: 8 })
          }
        }
        .width('100%')
        .padding(24)
        .backgroundColor($r('app.color.surface'))
        .borderRadius(16)
        .margin({ left: 16, right: 16, top: 16 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')

  }

  // 功能项构建
  @Builder
  buildStatItem(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildMenuSection() {
    Column() {
      Text('我的音乐')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      this.buildMenuItem('我的喜欢', $r('app.media.ic_favorite'), () => {
        this.goToFavorites();
      })

      this.buildMenuItem('播放历史', $r('app.media.ic_clock'), () => {
        this.goToPlayHistory();
      })

      this.buildMenuItem('收藏歌单', $r('app.media.ic_playlist'), () => {
        this.goToMyPlaylists();
      })

      this.buildMenuItem('本地下载', $r('app.media.ic_download'), () => {
        this.goToDownloads();
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(16)
    .margin({ left: 16, right: 16, top: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSettingsSection() {
    Column() {
      Text('设置')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      // this.buildMenuItem('主题设置', $r('app.media.ic_palette'), () => {
      //   router.pushUrl({ url: 'pages/Profile/ChangeThemeColor' });
      // })

      this.buildMenuItem('消息通知', $r('app.media.ic_message'), () => {
        // TODO: 跳转到消息设置页面
      })

      this.buildMenuItem('音频设置', $r('app.media.ic_audio'), () => {
        // TODO: 跳转到音频设置页面
      })

      this.buildMenuItem('关于应用', $r('app.media.ic_info'), () => {
        // TODO: 跳转到关于页面
      })

      this.buildMenuItem('帮助反馈', $r('app.media.ic_help'), () => {
        // TODO: 跳转到帮助页面
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(16)
    .margin({ left: 16, right: 16, top: 16, bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildLogoutSection() {
    Column() {
      Text('账号管理')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      this.buildMenuItem('退出登录', $r('app.media.ic_logout'), () => {
        this.handleLogout();
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(16)
    .margin({ left: 16, right: 16, top: 16, bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildMenuItem(title: string, icon: Resource, onClick: () => void) {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .margin({ right: 12 })

      Text(title)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
    }
    .width('100%')
    .height(44)
    .padding({ left: 0, right: 0 })
    .alignItems(VerticalAlign.Center)
    .onClick(onClick)
  }

  // 信息编辑弹窗
  @Builder
  buildEditUserDialog() {
    Stack() {
      // 遮罩
      Column() {}
      .width('100%').height('100%')
      .backgroundColor('rgba(0,0,0,0.5)') // 半透明黑色
      .onClick(() => this.showEditDialog = false)

      // 弹窗主体
      Column() {
        Text('编辑个人信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        // 用户名
        TextInput({ placeholder: '用户名', text: this.editUsername })
          .onChange((val: string) => this.editUsername = val)
          .width(240)
          .margin({ bottom: 12 })

        // 邮箱（置灰，禁用）
        TextInput({ placeholder: '邮箱', text: this.editEmail })
          .enabled(false)
          .width(240)
          .margin({ bottom: 12 })
          .fontColor($r('app.color.text_secondary'))

        // 新密码
        TextInput({ placeholder: '新密码', text: this.newPassword})
          .onChange((val: string) => this.newPassword = val)
          .width(240)
          .margin({ bottom: 12 })
          .type(InputType.Password)

        // 再次输入密码
        TextInput({ placeholder: '再次输入新密码', text: this.confirmPassword})
          .onChange((val: string) => this.confirmPassword = val)
          .width(240)
          .margin({ bottom: 12 })
          .type(InputType.Password)

        // 错误提示
        if (this.passwordError) {
          Text(this.passwordError)
            .fontSize(12)
            .fontColor(AppConstants.COLORS.ERROR)
            .margin({ bottom: 8 })
        }

        Row() {
          Button('取消')
            .backgroundColor(AppConstants.COLORS.DIVIDER)
            .fontColor($r('app.color.text_secondary'))
            .margin({ right: 16 })
            .onClick(() => this.showEditDialog = false)
          Button('保存')
            .onClick(() => this.handleEditUserInfo())
        }
        .justifyContent(FlexAlign.End)
      }
      .padding(24)
      .backgroundColor($r('app.color.surface'))
      .borderRadius(16)
      .alignItems(HorizontalAlign.Center)
      .width(280)
    }
    .width('100%').height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  private async handleEditUserInfo(): Promise<void> {
    // 清空错误提示
    this.passwordError = '';

    // 表单基础校验
    if (!this.editUsername.trim()) {
      this.passwordError = '用户名不能为空';
      return;
    }
    // 校验密码一致性与长度
    if (this.newPassword || this.confirmPassword) {
      if (this.newPassword !== this.confirmPassword) {
        this.passwordError = '两次输入的密码不一致';
        return;
      }
      if (this.newPassword.length < 6) {
        this.passwordError = '密码长度至少为6位';
        return;
      }
    }

    // 组装要提交的对象
    const updateData: UpdateUserRequest = {
      username: this.editUsername.trim()
    };
    const updatePwd: ChangePasswordRequest = {
      newPassword: this.confirmPassword.trim()
    }

    console.log("newPwd: ",this.confirmPassword)

    // 调用API进行更新
    try {
      this.isLoading = true;
      // 更新用户信息
      const updatedUser = await this.userService.updateUserInfo(updateData);
      await this.userService.changePassword(updatePwd);

      // 更新本地显示
      this.currentUser = updatedUser;
      // 关闭弹窗
      this.showEditDialog = false;

      // 清空密码相关字段
      this.newPassword = '';
      this.confirmPassword = '';
      this.passwordError = '';

      console.log('用户信息更新成功:', updatedUser);
    } catch (error) {
      // 处理后端返回的错误
      this.passwordError = error instanceof Error ? error.message : '用户信息修改失败，请重试';
      console.error('用户信息更新失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 上传用户头像
  private async uploadAvatar(): Promise<void> {
    // try {
    //   console.log('ProfilePage: 开始选择头像图片...');
    //
    //   // 使用HarmonyOS文件选择器API
    //   // 注意：不同版本的HarmonyOS可能有不同的文件选择器API
    //   // 这里提供了一个兼容性方案
    //   try {
    //     const picker = await import('@ohos.file.picker');
    //
    //     // 尝试使用DocumentViewPicker选择图片文件
    //     const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    //
    //     // 初始化选择结果
    //     let selectResult: string[] = [];
    //
    //     // 检查DocumentViewPicker是否可用
    //     if (picker.DocumentViewPicker) {
    //       const documentPicker = new picker.DocumentViewPicker(context);
    //       const selectOptions = new picker.DocumentSelectOptions();
    //       selectOptions.maxSelectNumber = 1;
    //       selectOptions.fileSuffixFilters = ['图片文件|.jpg,.jpeg,.png,.gif,.bmp'];
    //
    //       selectResult = await documentPicker.select(selectOptions);
    //     } else {
    //       // 如果DocumentViewPicker不可用，提供提示
    //       console.warn('ProfilePage: DocumentViewPicker不可用，请使用其他方式选择图片');
    //       selectResult = [];
    //     }
    //
    //     if (selectResult && selectResult.length > 0) {
    //       const selectedImageUri: string = selectResult[0];
    //       console.log('ProfilePage: 选择的图片URI:', selectedImageUri);
    //
    //       // 显示加载状态
    //       this.isLoading = true;
    //
    //       try {
    //         // 上传头像
    //         const updatedUser = await this.userService.uploadAvatar(selectedImageUri);
    //
    //         // 更新本地用户信息
    //         this.currentUser = updatedUser;
    //
    //         // 更新AuthManager中的用户信息
    //         this.authManager.updateUserInfo(updatedUser);
    //
    //         console.log('ProfilePage: 头像上传成功，更新用户信息:', updatedUser);
    //
    //         // 可以显示成功提示
    //         // 这里可以添加Toast提示用户上传成功
    //
    //       } catch (uploadError) {
    //         console.error('ProfilePage: 头像上传失败:', uploadError);
    //
    //         // 显示错误提示
    //         const errorMessage: string = uploadError instanceof Error ? uploadError.message : '头像上传失败';
    //         console.error('ProfilePage: 头像上传错误:', errorMessage);
    //
    //         // 这里可以添加Toast或弹窗提示用户上传失败
    //         // 暂时使用console.error输出错误信息
    //       } finally {
    //         this.isLoading = false;
    //       }
    //
    //     } else {
    //       console.log('ProfilePage: 用户取消了图片选择');
    //     }
    //
    //   } catch (pickerError) {
    //     console.error('ProfilePage: 文件选择器失败:', pickerError);
    //     const errorMessage: string = pickerError instanceof Error ? pickerError.message : '文件选择失败';
    //     console.error('ProfilePage: 文件选择器错误:', errorMessage);
    //     this.isLoading = false;
    //   }
    // } catch (error) {
    //   console.error('ProfilePage: 整体选择流程失败:', error);
    //   this.isLoading = false;
    //
    //   // 显示错误提示
    //   const errorMessage: string = error instanceof Error ? error.message : '选择图片失败';
    //   console.error('ProfilePage: 选择图片错误:', errorMessage);
    // }
  }

  // 处理退出登录
  private async handleLogout(): Promise<void> {
    if (this.isLoading) return;
    
    this.isLoading = true;
    
    try {
      await this.authManager.logout();
      
      // 退出成功，跳转到认证页面
      router.replaceUrl({
        url: 'pages/Auth/AuthPage'
      });
      
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 跳转到我的喜欢
  private goToFavorites(): void {
    router.pushUrl({
      url: 'pages/Profile/FavoritesPage'
    });
  }

  // 跳转到播放历史
  private goToPlayHistory(): void {
    router.pushUrl({
      url: 'pages/Profile/PlayHistoryPage'
    });
  }

  // 跳转到本地下载
  private goToDownloads(): void {
    // TODO: 实现本地下载页面
    console.log('跳转到本地下载页面');
  }

  // 跳转到收藏的歌单
  private goToMyPlaylists(): void {
    router.pushUrl({
      url: 'pages/Profile/MyPlaylistsPage'
    });
  }
} 