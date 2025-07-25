/**
 * 漫游页 - 发现新音乐和社交内容
 */
import AppConstants from '../../constants/AppConstants';
import router from '@ohos.router';

@Component
export struct DiscoveryPage {
  @State currentTabIndex: number = 0;
  @State isLoading: boolean = false;

  build() {
    Column() {
      // 顶部导航
      this.buildTopBar()

      // Tab导航
      Tabs({ index: $$this.currentTabIndex }) {
        TabContent() {
          this.buildDiscoveryContent()
        }
        .tabBar('发现音乐')

        TabContent() {
          this.buildSocialContent()
        }
        .tabBar('音乐动态')

        TabContent() {
          this.buildCommunityContent()
        }
        .tabBar('社区')
      }
      .layoutWeight(1)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .padding({ bottom: 80 }) // 为底部导航栏留出空间
  }

  @Builder
  buildTopBar() {
    Row() {
      // 搜索框
      Row() {
        // 搜索图标 - 放大镜图标用于搜索功能
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
        
        Text('搜索歌曲、歌手、专辑')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 8 })
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor($r('app.color.surface'))
      .borderRadius(20)
      .flexGrow(1)
      .height(40)
      .onClick(() => {
        // 跳转到搜索页面
        router.pushUrl({
          url: 'pages/Search/SearchPage'
        }).catch((error: Error) => {
          console.error('跳转到搜索页面失败:', error);
        });
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.surface'))
  }

  @Builder
  buildDiscoveryContent() {
    Scroll() {
      Column() {
        // 音乐分类
        this.buildMusicCategories()

        // 推荐艺术家
        this.buildRecommendedArtists()

        // 新歌首发
        this.buildNewReleases()

        // 音乐榜单
        this.buildMusicCharts()
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
  }

  @Builder
  buildSocialContent() {
    Column() {
      Text('音乐动态功能正在开发中...')
        .fontSize(16)
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildCommunityContent() {
    Column() {
      Text('社区功能正在开发中...')
        .fontSize(16)
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildMusicCategories() {
    Column() {
      Row() {
        Text('音乐分类')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text('全部分类')
          .fontSize(14)
          .fontColor($r('app.color.primary_color'))
      }
      .width('100%')
      .margin({ bottom: 16 })

      Grid() {
        ForEach(['流行', '摇滚', '民谣', '电子', '古典', '爵士'], (category: string) => {
          GridItem() {
            this.buildCategoryCard(category)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .height(160)
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder
  buildCategoryCard(category: string) {
    Column() {
      Image($r('app.media.music_selected'))
        .width(40)
        .height(40)

      Text(category)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // TODO: 进入分类详情
    })
  }

  @Builder
  buildRecommendedArtists() {
    Column() {
      Row() {
        Text('推荐艺术家')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text('查看更多')
          .fontSize(14)
          .fontColor($r('app.color.primary_color'))
      }
      .width('100%')
      .margin({ bottom: 16 })

      Scroll() {
        Row() {
          ForEach([1, 2, 3, 4], (item: number) => {
            this.buildArtistCard(`艺术家 ${item}`)
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder
  buildArtistCard(name: string) {
    Column() {
      Image($r('app.media.user_unselected'))
        .width(80)
        .height(80)
        .borderRadius(40)
        .backgroundColor($r('app.color.surface'))

      Text(name)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8 })

      Button('关注')
        .fontSize(12)
        .backgroundColor($r('app.color.primary_color'))
        .fontColor($r('app.color.surface'))
        .borderRadius(16)
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .margin({ top: 8 })
    }
    .margin({ right: 16 })
    .onClick(() => {
      // TODO: 进入艺术家详情
    })
  }

  @Builder
  buildNewReleases() {
    Column() {
      Row() {
        Text('新歌首发')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text('查看更多')
          .fontSize(14)
          .fontColor($r('app.color.primary_color'))
      }
      .width('100%')
      .margin({ bottom: 16 })

      ForEach([1, 2, 3], (item: number) => {
        this.buildSongCard(`新歌 ${item}`, '新晋艺术家', '刚刚发布')
      })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder
  buildSongCard(title: string, artist: string, time: string) {
    Row() {
      Image($r('app.media.music_unselected'))
        .width(60)
        .height(60)
        .borderRadius(8)
        .backgroundColor($r('app.color.surface'))

      Column() {
        Text(title)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(artist)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })

        Text(time)
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Image($r('app.media.ic_play_filled'))
        .width(24)
        .height(24)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .backgroundColor($r('app.color.surface'))
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => {
      // TODO: 播放歌曲
    })
  }

  @Builder
  buildMusicCharts() {
    Column() {
      Text('音乐榜单')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 16 })

      Grid() {
        ForEach(['热歌榜', '新歌榜', '原创榜'], (chart: string) => {
          GridItem() {
            this.buildChartCard(chart)
          }
        })
      }
      .columnsTemplate('1fr')
      .rowsGap(12)
      .height(180)
    }
    .width('100%')
  }

  @Builder
  buildChartCard(title: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text('最新更新')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(8)
    .onClick(() => {
      // TODO: 进入榜单详情
    })
  }
} 