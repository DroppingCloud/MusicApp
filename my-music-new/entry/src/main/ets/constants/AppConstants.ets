/**
 * 应用常量定义
 */

// API配置接口
interface ApiConfig {
  BASE_URL: string;
  TIMEOUT: number;
  RETRY_TIMES: number;
}

// 存储键名接口
interface StorageKeys {
  USER_TOKEN: string;
  USER_INFO: string;
  REFRESH_TOKEN: string;
  PLAY_MODE: string;
  VOLUME: string;
  PLAY_QUALITY: string;
  AUTO_PLAY: string;
  RECENT_SONGS: string;
  FAVORITES: string;
  PLAYLISTS: string;
  SEARCH_HISTORY: string;
  THEME: string;
  LANGUAGE: string;
  DOWNLOAD_QUALITY: string;
}

// 默认值接口
interface Defaults {
  VOLUME: number;
  PLAY_MODE: string;
  PLAY_QUALITY: string;
  AUTO_PLAY: boolean;
  THEME: string;
  LANGUAGE: string;
  DOWNLOAD_QUALITY: string;
}

// 颜色配置接口
interface Colors {
  PRIMARY: string;
  PRIMARY_LIGHT: string;
  PRIMARY_DARK: string;
  SECONDARY: string;
  SUCCESS: string;
  WARNING: string;
  ERROR: string;
  BACKGROUND: string;
  BACKGROUND_LIGHT: string;
  BACKGROUND_DARK: string;
  TEXT_PRIMARY: string;
  TEXT_SECONDARY: string;
  TEXT_TERTIARY: string;
  TEXT_PLACEHOLDER: string;
  BORDER: string;
  DIVIDER: string;
  PLAYING: string;
  PAUSED: string;
  LIKED: string;
  DISABLED: string;
  SURFACE: string;
}
// 尺寸配置接口
interface Sizes {
  TAB_BAR_HEIGHT: number;
  TOP_BAR_HEIGHT: number;
  MINI_PLAYER_HEIGHT: number;
  FULL_PLAYER_HEIGHT: string;
  COVER_SIZE_SMALL: number;
  COVER_SIZE_MEDIUM: number;
  COVER_SIZE_LARGE: number;
  COVER_SIZE_EXTRA_LARGE: number;
  LIST_ITEM_HEIGHT: number;
  LIST_ITEM_PADDING: number;
  BORDER_RADIUS_SMALL: number;
  BORDER_RADIUS_MEDIUM: number;
  BORDER_RADIUS_LARGE: number;
  BORDER_RADIUS_CIRCLE: number;
}

// 动画配置接口
interface Animation {
  FAST: number;
  NORMAL: number;
  SLOW: number;
  CROSSFADE: number;
}

// 分页配置接口
interface Pagination {
  DEFAULT_PAGE_SIZE: number;
  MAX_PAGE_SIZE: number;
  SEARCH_PAGE_SIZE: number;
}

// 播放质量项接口
interface QualityItem {
  bitrate: number;
  label: string;
}

// 播放质量配置接口
interface PlayQuality {
  LOW: QualityItem;
  MEDIUM: QualityItem;
  HIGH: QualityItem;
}

// 文件限制接口
interface FileLimits {
  AVATAR_MAX_SIZE: number;
  NOTE_IMAGE_MAX_SIZE: number;
  AUDIO_MAX_SIZE: number;
  SUPPORTED_AUDIO_FORMATS: string[];
  SUPPORTED_IMAGE_FORMATS: string[];
}

// 正则表达式接口
interface Regex {
  EMAIL: RegExp;
  USERNAME: RegExp;
  PASSWORD: RegExp;
  PHONE: RegExp;
}

// 错误码接口
interface ErrorCodes {
  NETWORK_ERROR: string;
  AUTH_FAILED: string;
  TOKEN_EXPIRED: string;
  FILE_TOO_LARGE: string;
  UNSUPPORTED_FORMAT: string;
  PLAYER_ERROR: string;
}

// 用户角色接口
interface UserRoles {
  NORMAL: string;
  VIP: string;
  ADMIN: string;
}

export class AppConstants {
  // 应用UI常量
  static readonly APP_NAME: string = 'Harmony Music';
  static readonly VERSION: string = '1.0.0';
  static readonly STATUS_BAR_HEIGHT: number = 44; // 状态栏高度

  // API配置
  static readonly API: ApiConfig = {
    BASE_URL: 'http://10.0.2.2:3000/api/v1',
    TIMEOUT: 10000,
    RETRY_TIMES: 3
  };

  // 存储键名
  static readonly STORAGE_KEYS: StorageKeys = {
    // 用户相关
    USER_TOKEN: 'user_token',
    USER_INFO: 'user_info',
    REFRESH_TOKEN: 'refresh_token',
    
    // 播放设置
    PLAY_MODE: 'play_mode',
    VOLUME: 'volume',
    PLAY_QUALITY: 'play_quality',
    AUTO_PLAY: 'auto_play',
    
    // 用户数据
    RECENT_SONGS: 'recent_songs',
    FAVORITES: 'favorites',
    PLAYLISTS: 'playlists',
    SEARCH_HISTORY: 'search_history',
    
    // 应用设置
    THEME: 'theme',
    LANGUAGE: 'language',
    DOWNLOAD_QUALITY: 'download_quality'
  };

  // 默认值
  static readonly DEFAULTS: Defaults = {
    VOLUME: 0.8,
    PLAY_MODE: 'sequence',
    PLAY_QUALITY: 'medium',
    AUTO_PLAY: true,
    THEME: 'auto',
    LANGUAGE: 'zh-CN',
    DOWNLOAD_QUALITY: 'medium'
  };

  // 主题颜色
  static readonly COLORS: Colors = {
    PRIMARY: '#007DFF',
    PRIMARY_LIGHT: '#4A90E2',
    PRIMARY_DARK: '#0056CC',
    SECONDARY: '#36D',
    SUCCESS: '#52C41A',
    WARNING: '#FAAD14',
    ERROR: '#F5222D',

    // 背景色
    BACKGROUND: '#F5F5F5',
    BACKGROUND_LIGHT: '#FFFFFF',
    BACKGROUND_DARK: '#1C1C1E',
    SURFACE: '#FFFFFF',

    // 文字颜色
    TEXT_PRIMARY: '#333333',
    TEXT_SECONDARY: '#666666',
    TEXT_TERTIARY: '#999999',
    TEXT_PLACEHOLDER: '#CCCCCC',

    // 边框和分割线
    BORDER: '#E5E5E5',
    DIVIDER: '#F0F0F0',

    // 状态颜色
    PLAYING: '#007DFF',
    PAUSED: '#999999',
    LIKED: '#FF6B6B',
    DISABLED: '#D9D9D9'
  };



  // 尺寸
  static readonly SIZES: Sizes = {
    // 导航栏
    TAB_BAR_HEIGHT: 60,
    TOP_BAR_HEIGHT: 56,
    
    // 播放器
    MINI_PLAYER_HEIGHT: 60,
    FULL_PLAYER_HEIGHT: '100%',
    
    // 封面图片
    COVER_SIZE_SMALL: 40,
    COVER_SIZE_MEDIUM: 60,
    COVER_SIZE_LARGE: 120,
    COVER_SIZE_EXTRA_LARGE: 200,
    
    // 列表项
    LIST_ITEM_HEIGHT: 60,
    LIST_ITEM_PADDING: 16,
    
    // 圆角
    BORDER_RADIUS_SMALL: 4,
    BORDER_RADIUS_MEDIUM: 8,
    BORDER_RADIUS_LARGE: 12,
    BORDER_RADIUS_CIRCLE: 50
  };

  // 动画时长
  static readonly ANIMATION: Animation = {
    FAST: 200,
    NORMAL: 300,
    SLOW: 500,
    CROSSFADE: 3000
  };

  // 分页配置
  static readonly PAGINATION: Pagination = {
    DEFAULT_PAGE_SIZE: 20,
    MAX_PAGE_SIZE: 100,
    SEARCH_PAGE_SIZE: 15
  };

  // 播放质量
  static readonly PLAY_QUALITY: PlayQuality = {
    LOW: { bitrate: 128, label: '流畅' },
    MEDIUM: { bitrate: 320, label: '标准' },
    HIGH: { bitrate: 1411, label: '高品质' }
  };

  // 文件限制
  static readonly FILE_LIMITS: FileLimits = {
    AVATAR_MAX_SIZE: 2 * 1024 * 1024, // 2MB
    NOTE_IMAGE_MAX_SIZE: 5 * 1024 * 1024, // 5MB
    AUDIO_MAX_SIZE: 50 * 1024 * 1024, // 50MB
    SUPPORTED_AUDIO_FORMATS: ['mp3', 'flac', 'aac', 'm4a', 'wav'],
    SUPPORTED_IMAGE_FORMATS: ['jpg', 'jpeg', 'png', 'webp']
  };

  // 正则表达式
  static readonly REGEX: Regex = {
    EMAIL: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
    USERNAME: /^[a-zA-Z0-9_\u4e00-\u9fa5]{2,20}$/,
    PASSWORD: /^.{6,20}$/,
    PHONE: /^1[3-9]\d{9}$/
  };

  // 错误码
  static readonly ERROR_CODES: ErrorCodes = {
    NETWORK_ERROR: 'NETWORK_ERROR',
    AUTH_FAILED: 'AUTH_FAILED',
    TOKEN_EXPIRED: 'TOKEN_EXPIRED',
    FILE_TOO_LARGE: 'FILE_TOO_LARGE',
    UNSUPPORTED_FORMAT: 'UNSUPPORTED_FORMAT',
    PLAYER_ERROR: 'PLAYER_ERROR'
  };

  // 用户角色
  static readonly USER_ROLES: UserRoles = {
    NORMAL: 'normal',
    VIP: 'vip',
    ADMIN: 'admin'
  };
}

// 默认导出
export default AppConstants;