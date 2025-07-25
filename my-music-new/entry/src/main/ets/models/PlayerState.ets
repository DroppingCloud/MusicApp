 /**
 * 播放状态枚举
 */
export enum PlayState {
  PLAYING = 'playing',
  PAUSED = 'paused',
  STOPPED = 'stopped',
  LOADING = 'loading'
}

/**
 * 播放模式枚举
 */
export enum PlayMode {
  SEQUENCE = 'sequence',    // 顺序播放
  LOOP = 'loop',           // 循环播放
  SHUFFLE = 'shuffle',     // 随机播放
  SINGLE = 'single'        // 单曲循环
}

/**
 * 播放器控制事件数据
 */
export type PlayerControlEventData = number | string | boolean | Record<string, Object>;

/**
 * 播放器控制事件
 */
export interface PlayerControlEvent {
  type: 'play' | 'pause' | 'stop' | 'next' | 'previous' | 'seek' | 'volume';
  data?: PlayerControlEventData;
}

/**
 * 播放器配置
 */
export interface PlayerConfig {
  autoPlay: boolean;
  volume: number;
  playMode: PlayMode;
  crossfadeDuration: number; // 淡入淡出时长
}