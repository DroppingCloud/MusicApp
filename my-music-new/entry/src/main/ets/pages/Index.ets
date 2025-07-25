import { HomePage } from './Home/HomePage';
import { DiscoveryPage } from './Discovery/DiscoveryPage';
import { NotePage } from './Note/NotePage';
import { ProfilePage } from './Profile/ProfilePage';
import { PlayerPage } from './Player/PlayerPage';
import { AuthManager } from '../services/AuthManager';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import AppConstants from '../constants/AppConstants';
//import StorageLink from '@ohos.data.preferences';

@Entry
@Component
struct Index {
  // @State currentTabIndex: number = 0;                        // 当前导航项
  @StorageLink('showPlayer') showPlayer: boolean = false;
  @State playerPageRef: PlayerPage | null = null;
  @State isAuthChecked: boolean = false;
  @StorageLink('theme') theme: string = 'light';
  
  private authManager = AuthManager.getInstance();

  @StorageLink('currentTabIndex') currentTabIndex: number = 0;  // 当前导航项

  async aboutToAppear(): Promise<void> {
    try {
      // 初始化全局状态
      AppStorage.setOrCreate('showPlayer', false);
      
      // 初始化认证管理器
      const context = getContext(this) as common.UIAbilityContext;
      await this.authManager.init(context);
      
      // 检查登录状态
      if (!this.authManager.getIsLoggedIn()) {
        // 未登录，跳转到认证页面
        router.replaceUrl({
          url: 'pages/Auth/AuthPage'
        });
        return;
      }
      
      this.isAuthChecked = true;
    } catch (error) {
      console.error('Auth check failed:', error);
      // 认证检查失败，跳转到认证页面
      router.replaceUrl({
        url: 'pages/Auth/AuthPage'
      });
    }
  }

   build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 认证检查中的加载状态
      if (!this.isAuthChecked) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#701e5e')
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('app.color.surface'))
      } else {
        // 页面内容区域
        Column() {
        if (this.currentTabIndex === 0) {
          HomePage()
        } else if (this.currentTabIndex === 1) {
          // "漫游"不显示独立页面，直接弹出播放器
          Column() {
            Text('点击底部"漫游"按钮开始音乐之旅')
              .fontSize(18)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.surface'))
        } else if (this.currentTabIndex === 2) {
          NotePage()
        } else if (this.currentTabIndex === 3) {
          ProfilePage()
        }
        }
        .width('100%')
        .height('100%')

        // 底部导航栏 - 叠加在页面上
        this.buildBottomTabBar()

        // 播放器页面 - 从底部弹出
        if (this.showPlayer) {
          PlayerPage()
            .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({
              duration: 500,
              curve: Curve.EaseInOut
            }))
        }
      }

    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildBottomTabBar() {
    Row() {
      this.TabBarBuilder('首页', 0, 'house')
      this.TabBarBuilder('漫游', 1, 'music')
      this.TabBarBuilder('笔记', 2, 'note')
      this.TabBarBuilder('我的', 3, 'user')
    }
      .width('100%')
    .height(60)
    .backgroundColor($r('app.color.surface'))
    .border({
      width: { top: 0.5 },
      color: 'rgba(0, 0, 0, 0.1)'
    })
    .backdropBlur(10) // 添加毛玻璃效果
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  TabBarBuilder(title: string, index: number, iconName: string) {
    Column() {
      Image(this.getTabIcon(iconName, this.currentTabIndex === index))
        .width(24)
        .height(24)
        .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
      
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? $r('app.color.primary') : $r('app.color.text_secondary')) // 使用主题色
        .margin({ top: 4 })
        .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
    }
    .layoutWeight(1) // 使用layoutWeight替代width: '100%'
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.handleTabClick(index);
    })
  }

  // 处理标签点击
  private handleTabClick(index: number) {
    if (index === 1) {
      // 点击"漫游"时弹出播放器
      this.showPlayerPage();
    } else {
      // 其他标签正常切换
      animateTo({
        duration: 200,
        curve: Curve.EaseInOut
      }, () => {
        this.currentTabIndex = index;
      });
    }
  }

  // 显示播放器页面
  private showPlayerPage() {
    // 确保返回首页
    this.currentTabIndex = 0;

    router.pushUrl({
      url: 'pages/Index'
    });
    
    animateTo({
      duration: 500,
      curve: Curve.EaseInOut
    }, () => {
      this.showPlayer = true;
    });
  }

  // 随机播放歌曲（预留逻辑）
  private playRandomSong() {
    console.log('Starting random song playback...');
    // TODO: 这里将来会调用音频服务播放随机歌曲
    // 目前只是日志输出，实际播放逻辑待后续实现
  }

  private getTabIcon(iconName: string, isSelected: boolean): Resource {
    const suffix = isSelected ? '_selected' : '_unselected';
    return $r(`app.media.${iconName}${suffix}`);
  }
}

