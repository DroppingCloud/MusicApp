/**
 * 用户信息模型
 */
export interface User {
  id: number;
  username: string;
  email?: string;
  avatar?: string;
  background?: string;
  created_at: string;
}

/**
 * 用户公开信息（给其他用户看的）
 */
export interface UserPublicInfo {
  id: number;
  username: string;
  avatar?: string;
  background?: string;
  followersCount: number;
  followingCount: number;
  notesCount: number;
  isFollowing?: boolean;
  created_at: string;
}

/**
 * 用户登录请求
 */
export interface LoginRequest {
  loginField: string; // 用户名或邮箱
  password: string;
}

/**
 * 用户注册请求
 */
export interface RegisterRequest {
  username: string;
  password: string;
  email?: string;
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
 * 用户登录响应
 */
export interface LoginResponse {
  user: User;
  token: string;
  refreshToken: string;
}

/**
 * 用户更新信息请求
 */
export interface UpdateUserRequest {
  username?: string;
  email?: string;
  avatar?: string;
  background?: string;
}

/**
 * 用户更新密码请求
 */
export interface ChangePasswordRequest {
  oldPassword?: string;
  newPassword: string;
}

/**
 * 用户上传头像请求
 */
export interface UploadAvatarRequest {
  avatarUrl: string
}

/**
 * 用户偏好标签
 */
export interface UserProfileTag {
  user_id: number;
  tag: string;
  weight: number;
  lastUpdate?: string;
}

/**
 * 用户播放历史
 */
export interface UserHistory {
  id: number;
  user_id: number;
  song_id: number;
  playTime: string;
  song?: import('./Music').Song;
}

/**
 * 用户收藏歌曲
 */
export interface UserFavorite {
  id: number;
  user_id: number;
  song_id: number;
  createdAt: string;
  song?: import('./Music').Song;
}

/**
 * 用户收藏歌单
 */
export interface UserCollect {
  id: number;
  user_id: number;
  playlist_id: number;
  createdAt: string;
  playlist?: import('./Music').Playlist;
} 