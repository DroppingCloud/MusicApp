/**
 * 笔记页 - 音乐笔记和收藏
 */
import AppConstants from '../../constants/AppConstants';
import { WaterFlowDataSource, WaterFlowNote } from '../../models/WaterFLowDataSource';
//import $r from '@ohos.resources';

/*import { TextOverflow, HorizontalAlign } from '@ohos.arkui';*/

enum FooterState {
  Loading = 0,
  End = 1
}

@Component
export struct NotePage {
  @State currentTabIndex: number = 0;
  private waterFlowDataSource: WaterFlowDataSource = new WaterFlowDataSource();
  dataSource: WaterFlowDataSource = new WaterFlowDataSource(); // dataSource是一个示例类，包含可调用的方法
  @State notes: WaterFlowNote[] = [] //notes是数组
  @State total: number = this.waterFlowDataSource.totalCount();
  @State footerState: FooterState = FooterState.Loading;
  @StorageLink('theme') theme: string = 'auto'; // 主题

  build() {
    Column() {
      // 顶部导航
      this.buildTopBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .padding({ bottom: 80 }) // 为底部导航栏留出空间
  }

  // 构建数据流
  @Builder
  buildWaterFLow() {
    // 获取数据

    WaterFlow({ footer: this.itemFoot() }) {
      LazyForEach(this.dataSource, (item: number, index: number) => {
        FlowItem() {
          this.buildWaterFlowNoteCard(this.dataSource.getData(index))
        }
        .width('100%')
      }, (item: number, index: number) => item.toString())
    }
    .columnsTemplate("1fr 1fr")
    .columnsGap(8)
    .rowsGap(8)
    .backgroundColor($r('app.color.surface'))
    .width('100%')
    .height('100%')
    .onReachEnd(() => {
      console.info("onReachEnd")
      /*if (this.dataSource.totalCount() > 200) {
        this.footerState = FooterState.End;
        return;
      }
      setTimeout(() => {
        for (let i = 0; i < 100; i++) {
          this.dataSource.addLastItem();
        }
      }, 1000)*/
    })
    .onReachStart(() => {
      console.info('waterFlow reach start');
    })
    .onScrollStart(() => {
      console.info('waterFlow scroll start');
    })
    .onScrollStop(() => {
      console.info('waterFlow scroll stop');
    })
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      console.info('waterFlow scrollFrameBegin offset: ' + offset + ' state: ' + state.toString());
      return { offsetRemain: offset };
    })
  }

  @Builder
  buildWaterFlowNoteCard(note: WaterFlowNote) {
    Column() {
      // 图片
      Image($r('app.media.notepic' + (note.id % 10)))
        .width('100%')
        .objectFit(ImageFit.Cover)
        .backgroundColor($r('app.color.surface_light'))

      Column(){
        // 标题
        Text(note.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 8 })

        // 内容
        Text(note.content)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 6 })

        // 底部信息
        Row() {
          // 点赞
          Row() {
            Image($r('app.media.ic_favorite'))
              .width(16)
              .height(16)
            Text((note.likeCount ?? 0).toString())
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
              .margin({ right: 8, left: 2 })
          }

          Row() {
            // 评论
            Image($r('app.media.ic_comment'))
              .width(16)
              .height(16)
            Text((note.commentCount ?? 0).toString())
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
              .margin({ left: 2 })
          }

          Blank()
          // 时间
          Text(note.createdAt.substring(0, 10))
            .margin({ left: 8 })
            .fontSize(11)
            .fontColor(AppConstants.COLORS.TEXT_PLACEHOLDER)
        }
        .margin({ top: 10, bottom: 10})
      }
      .height(85)
      .width('100%')
      .padding(10)
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor($r('app.color.surface_content'))
    .backdropBlur(10) // 添加毛玻璃效果
    .borderRadius(8)
    .clip( true)
    .shadow({
      radius: 10,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 4
    })
    .width('100%')
  }

  @Builder
  itemFoot() {
    // 不要直接用IfElse节点作为footer的根节点。
    Column() {
      if (this.footerState == FooterState.Loading) {
        Text(`加载中...`)
          .fontSize(10)
          .backgroundColor(Color.Red)
          .width(50)
          .height(50)
          .align(Alignment.Center)
          .margin({ top: 2 })
      } else if (this.footerState == FooterState.End) {
        Text(`到底啦...`)
          .fontSize(10)
          .backgroundColor(Color.Red)
          .width(50)
          .height(50)
          .align(Alignment.Center)
          .margin({ top: 2 })
      } else {
        Text(`Footer`)
          .fontSize(10)
          .backgroundColor(Color.Red)
          .width(50)
          .height(50)
          .align(Alignment.Center)
          .margin({ top: 2 })
      }
    }
  }

  @Builder
  buildTopBar() {
    Stack({ alignContent: Alignment.TopEnd }) {
      // Tab导航
      Tabs({ index: $$this.currentTabIndex }) {
        TabContent() {
          this.buildWaterFLow()
        }
        .tabBar('推荐')

        TabContent() {
          this.buildCollectionsContent()
        }
        .tabBar('我的')
      }
      .barWidth(120)
      .layoutWeight(1)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })

      // 添加图标 - 加号图标用于创建新笔记
      Image($r('app.media.ic_add'))
        .width(24)
        .height(24)
        .margin({ right: 16, top: 16 })
    }

  }

  @Builder
  buildCollectionsContent() {
    Scroll() {
      Column() {
        ForEach([1, 2, 3], (item: number) => {
          this.buildCollectionCard(`收藏歌单 ${item}`, '100首歌曲')
        })
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
  }

  @Builder
  buildNoteCard(title: string, content: string, time: string) {
    Column() {
      Row() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text(time)
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(content)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 12 })

      Row() {
        // 收藏图标 - 心形图标用于收藏笔记
        Image($r('app.media.ic_favorite'))
          .width(20)
          .height(20)

        Text('喜欢')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 4 })
      }
      .margin({ right: 16 })

      Row() {
        // 评论图标 - 消息气泡图标用于查看评论
        Image($r('app.media.ic_comment'))
          .width(20)
          .height(20)

        Text('评论')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 4 })
      }
      .margin({ right: 16 })

      Row() {
        // 分享图标 - 分享按钮用于分享笔记
        Image($r('app.media.ic_share'))
          .width(20)
          .height(20)

        Text('分享')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 4 })
      }
      .width('100%')
    }
    .padding(16)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(8)
    .margin({ bottom: 12 })
    .onClick(() => {
      // TODO: 查看笔记详情
    })
  }

  @Builder
  buildCollectionCard(title: string, subtitle: string) {
    Row() {
      // 歌曲封面图片 - 音乐专辑封面占位图
      Image($r('app.media.music_unselected'))
        .width(40)
        .height(40)
        .borderRadius(4)
        .backgroundColor($r('app.color.surface'))

      Column() {
        Text(title)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(subtitle)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 右箭头图标 - 表示进入详情页面
      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(8)
    .margin({ bottom: 12 })
    .onClick(() => {
      // TODO: 查看收藏详情
    })
  }
}