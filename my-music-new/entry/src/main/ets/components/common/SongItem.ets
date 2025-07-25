import { Song } from '../../models/Music';
import { TimeUtils } from '../../utils/TimeUtils';
import AppConstants from '../../constants/AppConstants';

/**
 * 歌曲列表项组件
 */
@Component
export struct SongItem {
  @Prop song: Song;                       // 歌曲对象
  @Prop showIndex?: boolean = false;      // 是否显示序号
  @Prop index?: number = 0;               // 序号
  @Prop isPlaying?: boolean = false;      // 是否播放
  onPlay?: (song: Song) => void;          // 点击播放回调
  onMore?: (song: Song) => void;          // 点击更多回调

  build() {
    Row() {
      // 序号或播放状态图标
      if (this.showIndex) {
        if (this.isPlaying) {
          Image($r('app.media.ic_play_filled'))
            .width(24)
            .height(24)
        } else {
          Text((this.index! + 1).toString())
            .fontSize(14)
            .fontColor('#999999')
            .width(20)
            .textAlign(TextAlign.Center)
        }
      }

      // 歌曲封面图片，如果没有则使用默认音乐占位图
      Image(this.song.cover_url ? this.song.cover_url : $r('app.media.music_unselected'))
        .width(50)
        .height(50)
        .borderRadius(6)
        .backgroundColor(AppConstants.COLORS.SURFACE)
        .margin({ left: this.showIndex ? 12 : 0 })

      // 歌曲信息
      Column() {
        Text(this.song.title)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          if (this.song.artist) {
            Text(this.song.artist.name)
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
          }

          if (this.song.album) {
            Text(' - ')
              .fontSize(14)
              .fontColor(AppConstants.COLORS.TEXT_SECONDARY)

            Text(this.song.album.title)
              .fontSize(14)
              .fontColor(AppConstants.COLORS.TEXT_SECONDARY)
          }
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 右侧操作区域
      Row() {
        // 时长
        if (this.song.duration) {
          Text(TimeUtils.formatTime(this.song.duration))
            .fontSize(12)
            .fontColor('#999999')
        }

        // 更多操作图标 - 三个点图标表示更多操作菜单
        Image($r('app.media.ic_more'))
          .width(20)
          .height(20)
          .margin({ left: 12 })
          .onClick(() => {
            this.onMore?.(this.song);
          })
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8, left: 16, right: 16 })
    .onClick(() => {
      this.onPlay?.(this.song);
    })
  }
} 