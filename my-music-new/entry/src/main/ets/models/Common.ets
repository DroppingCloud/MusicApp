import { PlayMode } from './PlayerState';

/**
 * 基础响应结构
 */
export interface BaseResponse<T> {
  code: number;
  message: string;
  data: T;
  timestamp: string;
}

/**
 * API响应结构（BaseResponse的别名，用于向后兼容）
 */
export interface ApiResponse<T> extends BaseResponse<T> {
  success: boolean;
  pagination?: ApiPaginationInfo;
}

/**
 * 分页信息
 */
export interface PaginationInfo {
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

/**
 * 分页响应
 */
export interface PaginationResponse<T> {
  list: T[];
  pagination: PaginationInfo;
}

// 定义分页信息接口
export interface ApiPaginationInfo {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

/**
 * 分页参数
 */
export interface PaginationParams {
  page?: number;
  limit?: number;
}

/**
 * 歌曲查询参数
 */
export interface SongQueryParams {
  page?: number;
  limit?: number;
  keyword?: string;
  genre?: string;
  artist?: string;
}

/**
 * 歌单查询参数
 */
export interface PlaylistQueryParams {
  page?: number;
  limit?: number;
  keyword?: string;
  userId?: number;
  isPublic?: boolean;
}

/**
 * 歌单歌曲查询参数
 */
export interface PlaylistSongQueryParams {
  page?: number;
  limit?: number;
  playlistId?: number;
}

/**
 * 通用列表查询参数
 */
export interface ListQueryParams {
  page?: number;
  limit?: number;
}

/**
 * 用户统计信息
 */
export interface UserStats {
  favoriteCount: number;
  playlistCount: number;
  historyCount: number;
}

/**
 * 上传文件响应
 */
export interface UploadResponse {
  url: string;
  filename: string;
  size: number;
}

/**
 * 错误信息
 */
export interface ErrorInfo {
  code: number;
  message: string;
  details?: Object;
}

/**
 * 操作结果
 */
export interface OperationResult {
  success: boolean;
  message?: string;
}

/**
 * 排序参数
 */
export interface SortParams {
  field: string;
  order: 'asc' | 'desc';
}

/**
 * 筛选参数
 */
export interface FilterParams {
  keyword?: string;
  category?: string;
  status?: string;
  dateFrom?: string;
  dateTo?: string;
  type?: string;
}

/**
 * 列表请求参数
 */
export interface ListRequest extends PaginationParams {
  sort?: SortParams;
  filter?: FilterParams;
  keyword?: string;
}

/**
 * 统计信息
 */
export interface StatInfo {
  totalCount: number;
  todayCount?: number;
  weekCount?: number;
  monthCount?: number;
}

/**
 * 播放器状态
 */
export interface PlayerState {
  currentSong?: import('./Music').Song;
  playState: 'playing' | 'paused' | 'stopped' | 'loading';
  playMode: PlayMode;
  currentTime: number;
  duration: number;
  volume: number;
  playlist: import('./Music').Song[];
  currentIndex: number;
  isLoading: boolean;
}

/**
 * 播放历史项
 */
export interface PlayHistoryItem {
  song: import('./Music').Song;
  playTime: string;
  duration: number; // 播放时长
}

/**
 * 应用配置
 */
export interface AppConfig {
  theme: 'light' | 'dark' | 'auto';
  language: 'zh-CN' | 'en-US';
  playQuality: 'low' | 'medium' | 'high';
  autoPlay: boolean;
  showLyrics: boolean;
  downloadQuality: 'low' | 'medium' | 'high';
} 