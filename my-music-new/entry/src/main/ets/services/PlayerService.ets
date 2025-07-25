import { media } from '@kit.MediaKit';
import { PlayState, PlayMode, PlayerConfig } from '../models/PlayerState';
import { PlayerState } from '../models/Common';
import { Song } from '../models/Music';
import { MusicService } from './MusicService';
import { UserService } from './UserService';

/**
 * 播放器事件监听器
 */
export interface PlayerEventListener {
  onStateChanged?: (state: PlayerState) => void;                          // 播放状态监听
  onSongChanged?: (song: Song | undefined) => void;                       // 选中音乐监听
  onProgressChanged?: (currentTime: number, duration: number) => void;    // 播放进度监听
  onError?: (error: Error) => void;                                       // 异常监听
}

/**
 * 播放器服务类
 */
export class PlayerService {
  private static instance: PlayerService;
  private avPlayer?: media.AVPlayer;
  private playerState: PlayerState;
  private config: PlayerConfig;
  private listeners: PlayerEventListener[] = [];
  private progressTimer?: number;
  private musicService: MusicService;
  private isInitialized: boolean = false;
  private preparedPromise?: Promise<void>; // 添加prepared状态等待Promise
  private preparedResolve?: () => void;

  private constructor() {
    this.playerState = {
      playState: 'stopped',
      playMode: PlayMode.SEQUENCE,
      currentTime: 0,
      duration: 0,
      volume: 0.8,
      playlist: [],
      currentIndex: -1,
      isLoading: false
    };

    this.config = {
      autoPlay: true,
      volume: 0.8,
      playMode: PlayMode.SEQUENCE,
      crossfadeDuration: 3
    };

    this.musicService = new MusicService();
    this.initializePlayer();
  }

  /**
   * 获取播放器服务实例
   */
  public static getInstance(): PlayerService {
    if (!PlayerService.instance) {
      PlayerService.instance = new PlayerService();
    }
    return PlayerService.instance;
  }

  /**
   * 初始化播放器
   */
  private async initializePlayer(): Promise<void> {
    try {
      this.avPlayer = await media.createAVPlayer();
      this.setupPlayerEvents();
      this.isInitialized = true;
      console.log('Player initialized successfully');
    } catch (error) {
      console.error('Failed to initialize player:', error);
      this.isInitialized = false;
      this.notifyError(error instanceof Error ? error : new Error(String(error)));
    }
  }

  /**
   * 设置播放器事件监听
   */
  private setupPlayerEvents(): void {
    if (!this.avPlayer) return;

    // 播放状态变化
    this.avPlayer.on('stateChange', (state: string) => {
      console.log('Player state changed to:', state);
      this.handleStateChange(state);
    });

    // 播放完成事件 - 使用stateChange监听完成状态
    // HarmonyOS AVPlayer通过stateChange事件监听播放完成

    // 错误处理
    this.avPlayer.on('error', (error: Error) => {
      console.error('Player error:', error);
      this.playerState.isLoading = false;
      this.stopProgressTimer();

      // 清理prepared状态等待
      this.preparedResolve = undefined;
      this.preparedPromise = undefined;

      this.notifyError(error);
    });

    // 时长变化
    this.avPlayer.on('durationUpdate', (duration: number) => {
      console.log('Duration updated:', duration);
      // AVPlayer返回的时长单位是毫秒，需要转换为秒
      this.playerState.duration = Math.floor(duration / 1000);
      this.notifyStateChanged();
    });

    // 播放准备完成 - 使用stateChange事件监听prepared状态
    // HarmonyOS AVPlayer没有单独的prepared事件，而是通过stateChange监听
  }

  /**
   * 处理播放状态变化
   */
  private handleStateChange(state: string): void {
    const previousState = this.playerState.playState;

    switch (state) {
      case 'playing':
        this.playerState.playState = 'playing';
        this.startProgressTimer();
        break;
      case 'paused':
        this.playerState.playState = 'paused';
        this.stopProgressTimer();
        break;
      case 'stopped':
        this.playerState.playState = 'stopped';
        this.stopProgressTimer();
        this.resetProgress();
        break;
      case 'completed':
        // 播放完成
        console.log('Playback completed');
        this.stopProgressTimer();
        this.handlePlayComplete();
        break;
      case 'prepared':
        this.playerState.isLoading = false;
        if (this.avPlayer) {
          // AVPlayer返回的时长单位是毫秒，需要转换为秒
          this.playerState.duration = Math.floor(this.avPlayer.duration / 1000);
        }
        console.log('Player is now prepared');
        this.preparedResolve?.(); // 释放等待
        this.preparedResolve = undefined;
        this.preparedPromise = undefined;
        break;
      case 'idle':
        this.playerState.playState = 'stopped';
        this.stopProgressTimer();
        break;
    }

    // 只在状态真正变化时通知
    if (previousState !== this.playerState.playState) {
      console.log(`State changed from ${previousState} to ${this.playerState.playState}`);
      this.notifyStateChanged();
    }
  }

  /**
   * 重置播放进度
   */
  private resetProgress(): void {
    this.playerState.currentTime = 0;
    this.notifyProgressChanged();
  }

  /**
   * 处理播放完成
   */
  private handlePlayComplete(): void {
    console.log('Handling play complete, current mode:', this.playerState.playMode);

    switch (this.playerState.playMode) {
      case PlayMode.SINGLE:
        // 单曲循环
        console.log('Single mode: restarting current song');
        this.seekTo(0);
        this.play();
        break;
      case PlayMode.SEQUENCE:
        // 顺序播放
        console.log('Sequence mode: playing next song');
        this.next();
        break;
      case PlayMode.LOOP:
        // 列表循环
        console.log('Loop mode: checking if last song');
        if (this.playerState.currentIndex >= this.playerState.playlist.length - 1) {
          this.playByIndex(0);
        } else {
          this.next();
        }
        break;
      case PlayMode.SHUFFLE:
        // 随机播放
        console.log('Shuffle mode: playing random song');
        this.playRandom();
        break;
      default:
        console.log('Unknown play mode, stopping');
        this.stop();
    }
  }

  /**
   * 开始进度计时器
   */
  private startProgressTimer(): void {
    this.stopProgressTimer();
    console.log('Starting progress timer');

    this.progressTimer = setInterval(() => {
      if (this.avPlayer && this.playerState.playState === 'playing') {
        // AVPlayer返回的时间单位是毫秒，需要转换为秒
        const currentTimeMs = this.avPlayer.currentTime;
        const currentTime = Math.floor(currentTimeMs / 1000);
        if (currentTime !== this.playerState.currentTime) {
          this.playerState.currentTime = currentTime;
          this.notifyProgressChanged();
        }
      }
    }, 1000); // 改为每秒更新一次
  }

  /**
   * 停止进度计时器
   */
  private stopProgressTimer(): void {
    if (this.progressTimer) {
      console.log('Stopping progress timer');
      clearInterval(this.progressTimer);
      this.progressTimer = undefined;
    }
  }

  // ==================== 公共API ====================

  /**
   * 播放歌曲
   */
  async play(song?: Song): Promise<void> {
    try {
      console.log(`=== play() called ===`);
      console.log(`传入歌曲: ${song ? `${song.title} (ID:${song.id})` : '无'}`);
      console.log(`当前歌曲: ${this.playerState.currentSong ? `${this.playerState.currentSong.title} (ID:${this.playerState.currentSong.id})` : '无'}`);
      console.log(`AVPlayer状态: ${this.avPlayer?.state || '未初始化'}`);
      console.log(`播放器初始化状态: ${this.isInitialized}`);

      if (!this.isInitialized || !this.avPlayer) {
        console.error('Player not initialized');
        throw new Error('播放器未初始化');
      }

      // 确定要播放的歌曲
      const targetSong = song || this.playerState.currentSong;
      if (!targetSong) {
        throw new Error('没有可播放的歌曲');
      }

      // 新增：添加到播放历史
      try {
        await new UserService().addPlayHistory(targetSong.id);
      } catch (e) {
        console.warn('添加播放历史失败', e);
      }

      // 检查是否需要加载歌曲（新歌曲或AVPlayer状态不正确）
      const needsLoading = !this.playerState.currentSong ||
        this.playerState.currentSong.id !== targetSong.id ||
        !this.avPlayer ||
        (this.avPlayer.state !== 'prepared' && this.avPlayer.state !== 'paused' && this.avPlayer.state !== 'completed');

      if (needsLoading) {
        console.log(`Loading song needed: currentSong=${this.playerState.currentSong?.title}, targetSong=${targetSong.title}, avPlayerState=${this.avPlayer?.state}`);

        // 只在需要时停止播放器
        const currentState = this.avPlayer.state;
        if (currentState === 'prepared' || currentState === 'playing' || currentState === 'paused' || currentState === 'completed') {
          console.log('Stopping playback from state:', currentState);
          try {
            await this.avPlayer.stop();
          } catch (stopError) {
            console.warn('Failed to stop player:', stopError);
            // 如果停止失败，尝试重置
            await this.avPlayer.reset();
          }
        } else if (currentState === 'idle') {
          console.log('Player is already in idle state, no need to stop');
        } else {
          console.log('Player in state:', currentState, 'will reset directly');
        }

        this.resetProgress();
        await this.loadSong(targetSong);

        // 等待prepared状态，添加超时机制
        if (this.preparedPromise) {
          console.log('Waiting for player to be prepared...');
          const timeoutPromise = new Promise<void>((_, reject) => {
            setTimeout(() => reject(new Error('播放器准备超时')), 10000); // 10秒超时
          });

          try {
            await Promise.race([this.preparedPromise, timeoutPromise]);
            console.log('Player is ready, proceeding with playback');
          } catch (error) {
            console.error('Prepared timeout or error:', error);
            this.preparedResolve = undefined;
            this.preparedPromise = undefined;
            throw error instanceof Error ? error : new Error(String(error));
          }
        }
      } else {
        console.log(`Song already loaded and ready: ${targetSong.title}, avPlayerState=${this.avPlayer?.state}`);
      }

      // 记录播放次数（仅对新传入的歌曲）
      if (song) {
        try {
          await this.musicService.playSong(song.id);
        } catch (playError) {
          console.warn('Failed to record play count:', playError);
          // 不影响播放，继续执行
        }
      }

      if (this.avPlayer && this.playerState.currentSong) {
        // 检查当前状态是否允许播放
        const currentState = this.avPlayer.state;
        console.log('Current AVPlayer state:', currentState);

        if (currentState === 'prepared' || currentState === 'paused' || currentState === 'completed') {
          console.log('Starting playback...');
          this.playerState.isLoading = true;
          this.notifyStateChanged();
          await this.avPlayer.play();
        } else {
          throw new Error(`播放器状态不正确，当前状态: ${currentState}，需要prepared/paused/completed状态`);
        }
      } else {
        throw new Error('没有可播放的歌曲或播放器未初始化');
      }
    } catch (error) {
      console.error('Failed to play:', error);
      this.playerState.isLoading = false;
      this.notifyStateChanged();
      this.notifyError(error instanceof Error ? error : new Error(String(error)));
    }
  }

  /**
   * 暂停播放
   */
  async pause(): Promise<void> {
    try {
      if (this.avPlayer && this.playerState.playState === 'playing') {
        console.log('Pausing playback');
        await this.avPlayer.pause();
      }
    } catch (error) {
      console.error('Failed to pause:', error);
      this.notifyError(error instanceof Error ? error : new Error(String(error)));
    }
  }

  /**
   * 停止播放
   */
  async stop(): Promise<void> {
    try {
      if (this.avPlayer) {
        const currentState = this.avPlayer.state;
        console.log('Stopping playback, current state:', currentState);
        this.stopProgressTimer();

        // 清理prepared状态等待
        this.preparedResolve = undefined;
        this.preparedPromise = undefined;

        // 只在允许的状态下调用stop
        if (currentState === 'prepared' || currentState === 'playing' || currentState === 'paused' || currentState === 'completed') {
          await this.avPlayer.stop();
        } else {
          console.log('Player state does not require stop operation:', currentState);
        }

        this.resetProgress();
        this.notifyStateChanged();
      }
    } catch (error) {
      console.error('Failed to stop:', error);
      this.notifyError(error instanceof Error ? error : new Error(String(error)));
    }
  }

  /**
   * 下一首
   */
  async next(): Promise<void> {
    const nextIndex = this.playerState.currentIndex + 1;
    if (nextIndex < this.playerState.playlist.length) {
      console.log(`Playing next song at index ${nextIndex}`);
      await this.playByIndex(nextIndex);
    } else if (this.playerState.playMode === PlayMode.LOOP) {
      console.log('Loop mode: playing first song');
      await this.playByIndex(0);
    } else {
      console.log('Reached end of playlist');
      await this.stop();
    }
  }

  /**
   * 上一首
   */
  async previous(): Promise<void> {
    const prevIndex = this.playerState.currentIndex - 1;
    if (prevIndex >= 0) {
      console.log(`Playing previous song at index ${prevIndex}`);
      await this.playByIndex(prevIndex);
    } else if (this.playerState.playMode === PlayMode.LOOP) {
      console.log('Loop mode: playing last song');
      await this.playByIndex(this.playerState.playlist.length - 1);
    } else {
      console.log('Already at first song');
    }
  }


  // // 切换上一首
  // async previousSong(songsList: Song[]): Promise<void>{
  //   console.log('上一首')
  //   const currentIndex = songsList.findIndex(song => song.id === this.playerState?.currentSong?.id)
  //
  //   if (currentIndex < 0) {
  //     console.warn('当前歌曲不在列表中');
  //     return;
  //   }
  //
  //   let preIndex = (currentIndex - 1) % songsList.length;
  //   if(preIndex < 0){
  //     preIndex = songsList.length - 1;
  //   }
  //
  //   if (preIndex < songsList.length) {
  //     const preSong = songsList[preIndex];
  //     this.playByIndex(preSong.id)
  //   }
  // }
  //
  // // 下一首
  // async nextSong(songsList: Song[]): Promise<void>{
  //   console.log('下一首')
  //   const currentIndex = songsList.findIndex(song => song.id === this.playerState?.currentSong?.id)
  //
  //   if (currentIndex < 0) {
  //     console.warn('当前歌曲不在列表中');
  //     return;
  //   }
  //
  //   let preIndex = (currentIndex + 1) % songsList.length;
  //
  //   if (preIndex < songsList.length) {
  //     const preSong = songsList[preIndex];
  //     this.playByIndex(preSong.id)
  //   }
  // }

  /**
   * 跳转到指定时间
   */
  async seekTo(time: number): Promise<void> {
    try {
      if (this.avPlayer && this.playerState.duration > 0) {
        const clampedTime = Math.max(0, Math.min(time, this.playerState.duration));
        console.log(`Seeking to time: ${clampedTime} seconds`);
        // AVPlayer的seek方法期望毫秒单位，需要将秒转换为毫秒
        await this.avPlayer.seek(clampedTime * 1000);
        this.playerState.currentTime = clampedTime;
        this.notifyProgressChanged();
      }
    } catch (error) {
      console.error('Failed to seek:', error);
      this.notifyError(error instanceof Error ? error : new Error(String(error)));
    }
  }

  /**
   * 设置音量
   */
  async setVolume(volume: number): Promise<void> {
    try {
      const clampedVolume = Math.max(0, Math.min(1, volume));
      this.playerState.volume = clampedVolume;
      this.config.volume = clampedVolume;

      if (this.avPlayer) {
        // 注意：实际的音量设置可能需要根据HarmonyOS API文档调整
        // this.avPlayer.volume = clampedVolume;
      }

      this.notifyStateChanged();
    } catch (error) {
      console.error('Failed to set volume:', error);
      this.notifyError(error instanceof Error ? error : new Error(String(error)));
    }
  }

  /**
   * 设置播放模式
   */
  setPlayMode(mode: PlayMode): void {
    this.playerState.playMode = mode;
    this.config.playMode = mode;
    this.notifyStateChanged();
  }

  /**
   * 设置播放列表
   */
  setPlaylist(playlist: Song[], index: number = 0): void {
    this.playerState.playlist = playlist;
    this.playerState.currentIndex = index;
    this.playerState.currentSong = playlist[index];
    this.notifyStateChanged();
    this.notifySongChanged();
  }

  /**
   * 按索引播放（歌单模式）
   */
  async playByIndex(index: number): Promise<void> {
    if (index >= 0 && index < this.playerState.playlist.length) {
      console.log(`Playing song at index ${index}`);

      // 停止当前播放并重置状态
      await this.stop();

      // 更新索引和当前歌曲
      this.playerState.currentIndex = index;
      let songToPlay: Song = this.playerState.playlist[index];

      // 如果歌曲没有完整的音频链接，尝试获取详情
      if (!songToPlay.audio_url || songToPlay.audio_url.trim() === '') {
        try {
          console.log(`Song ${songToPlay.title} missing audio_url, fetching details...`);
          const songDetail = await this.musicService.getSongDetail(songToPlay.id);
          songToPlay = songDetail;

          // 更新播放列表中的歌曲详情
          this.playerState.playlist[index] = songDetail;
        } catch (error) {
          console.warn(`Failed to fetch song details for ${songToPlay.title}:`, error);
          // 继续使用原始数据，让loadSong处理错误
        }
      }

      this.playerState.currentSong = songToPlay;
      this.notifyStateChanged();
      this.notifySongChanged();

      // 播放新歌曲
      await this.play(songToPlay);
    } else {
      console.error(`Invalid index: ${index}, playlist length: ${this.playerState.playlist.length}`);
    }
  }

  /**
   * 按索引播放（列表模式）
   */
  async playBySong(song: Song): Promise<void> {
    console.log(`Playing song at index ${song.id}`);

    // 停止当前播放并重置状态
    await this.stop();

    // 更新索引和当前歌曲
    this.playerState.currentIndex = song.id;

    // 如果歌曲没有完整的音频链接，尝试获取详情
    if (!song.audio_url || song.audio_url.trim() === '') {
      try {
        console.log(`Song ${song.title} missing audio_url, fetching details...`);
        const songDetail = await this.musicService.getSongDetail(song.id);
        song = songDetail;

      } catch (error) {
        console.warn(`Failed to fetch song details for ${song.title}:`, error);
        // 继续使用原始数据，让loadSong处理错误
      }
    }

    this.playerState.currentSong = song;
    this.notifyStateChanged();
    this.notifySongChanged();

    // 播放新歌曲
    await this.play(song);
  }

  /**
   * 随机播放
   */
  async playRandom(): Promise<void> {
    if (this.playerState.playlist.length > 0) {
      let randomIndex: number;
      do {
        randomIndex = Math.floor(Math.random() * this.playerState.playlist.length);
      } while (randomIndex === this.playerState.currentIndex && this.playerState.playlist.length > 1);

      console.log(`Playing random song at index ${randomIndex}`);
      await this.playByIndex(randomIndex);
    }
  }

  /**
   * 加载歌曲
   */
  private async loadSong(song: Song): Promise<void> {
    try {
      if (!song) {
        throw new Error('歌曲信息为空');
      }

      if (!song.audio_url || song.audio_url.trim() === '') {
        throw new Error(`歌曲《${song.title}》没有有效的音频链接`);
      }

      if (!this.avPlayer) {
        throw new Error('播放器未初始化');
      }

      console.log(`Loading song: ${song.title}, URL: ${song.audio_url}`);

      // 重置之前的准备Promise
      this.preparedResolve = undefined;
      this.preparedPromise = undefined;

      this.playerState.isLoading = true;
      this.playerState.currentSong = song;
      this.resetProgress(); // 重置进度
      this.notifyStateChanged();
      this.notifySongChanged();

      // 创建新的prepared等待Promise
      this.preparedPromise = new Promise<void>((resolve) => {
        this.preparedResolve = resolve;
      });

      // 检查当前状态，决定如何处理
      const currentState = this.avPlayer.state;
      console.log('Current state before loading:', currentState);

      // 重置AVPlayer到idle状态
      if (currentState !== 'idle') {
        console.log('Resetting AVPlayer to idle state');
        await this.avPlayer.reset();
        // 等待一下确保reset完成
        await new Promise<void>(resolve => setTimeout(resolve, 100));
      }

      // 设置URL (idle -> initialized)
      this.avPlayer.url = song.audio_url;
      console.log(`Set URL: ${song.audio_url}, waiting for initialized state...`);

      // 等待状态变为initialized
      await this.waitForState('initialized', 5000);
      console.log('Player is now in initialized state, calling prepare...');

      // 准备播放 (initialized -> prepared)
      await this.avPlayer.prepare();
      console.log(`Prepare called for: ${song.title}`);

    } catch (error) {
      console.error('Failed to load song:', error);
      this.playerState.isLoading = false;
      this.preparedResolve = undefined;
      this.preparedPromise = undefined;
      this.notifyStateChanged();
      this.notifyError(error instanceof Error ? error : new Error(String(error)));
    }
  }

  /**
   * 等待播放器到达指定状态
   */
  private async waitForState(targetState: string, timeoutMs: number = 5000): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      // 如果已经是目标状态，直接返回
      if (this.avPlayer?.state === targetState) {
        resolve();
        return;
      }

      // 设置超时
      const timeout = setTimeout(() => {
        reject(new Error(`等待状态 ${targetState} 超时，当前状态: ${this.avPlayer?.state}`));
      }, timeoutMs);

      // 轮询检查状态
      const checkState = () => {
        if (this.avPlayer?.state === targetState) {
          clearTimeout(timeout);
          resolve();
        } else {
          setTimeout(checkState, 50); // 每50ms检查一次
        }
      };

      checkState();
    });
  }

  /**
   * 获取播放器状态
   */
  getPlayerState(): PlayerState {
    return {
      currentSong: this.playerState.currentSong,
      playState: this.playerState.playState,
      playMode: this.playerState.playMode,
      currentTime: this.playerState.currentTime,
      duration: this.playerState.duration,
      volume: this.playerState.volume,
      playlist: this.playerState.playlist,
      currentIndex: this.playerState.currentIndex,
      isLoading: this.playerState.isLoading
    };
  }

  /**
   * 获取播放器配置
   */
  getConfig(): PlayerConfig {
    return {
      autoPlay: this.config.autoPlay,
      volume: this.config.volume,
      playMode: this.config.playMode,
      crossfadeDuration: this.config.crossfadeDuration
    };
  }

  // ==================== 事件监听器管理 ====================

  /**
   * 添加事件监听器
   */
  addEventListener(listener: PlayerEventListener): void {
    this.listeners.push(listener);
  }

  /**
   * 移除事件监听器
   */
  removeEventListener(listener: PlayerEventListener): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  /**
   * 添加事件监听器 (别名)
   */
  addListener(listener: PlayerEventListener): void {
    this.addEventListener(listener);
  }

  /**
   * 移除事件监听器 (别名)
   */
  removeListener(listener: PlayerEventListener): void {
    this.removeEventListener(listener);
  }

  /**
   * 通知状态变化
   */
  private notifyStateChanged(): void {
    this.listeners.forEach(listener => {
      listener.onStateChanged?.(this.getPlayerState());
    });
  }

  /**
   * 通知歌曲变化
   */
  private notifySongChanged(): void {
    this.listeners.forEach(listener => {
      listener.onSongChanged?.(this.playerState.currentSong);
    });
  }

  /**
   * 通知进度变化
   */
  private notifyProgressChanged(): void {
    this.listeners.forEach(listener => {
      listener.onProgressChanged?.(this.playerState.currentTime, this.playerState.duration);
    });
  }

  /**
   * 通知错误
   */
  private notifyError(error: Error): void {
    this.listeners.forEach(listener => {
      listener.onError?.(error);
    });
  }

  /**
   * 销毁播放器
   */
  async destroy(): Promise<void> {
    try {
      this.stopProgressTimer();
      if (this.avPlayer) {
        await this.avPlayer.release();
        this.avPlayer = undefined;
      }
      this.listeners = [];
    } catch (error) {
      console.error('Failed to destroy player:', error);
    }
  }
} 