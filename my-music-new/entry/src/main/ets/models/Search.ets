/**
 * 搜索历史模型
 */
export interface SearchHistory {
  id: number;
  userId: number;
  keyword: string;
  searchTime: string;
}

/**
 * 搜索热词模型
 */
export interface SearchTrend {
  id: number;
  keyword: string;
  count: number;
  updatedAt: string;
}

/**
 * 综合搜索结果
 */
export interface SearchResult {
  songs: import('./Music').Song[];
  artists: import('./Music').Artist[];
  albums: import('./Music').Album[];
  playlists: import('./Music').Playlist[];
  users: import('./User').UserPublicInfo[];
  notes: import('./Social').Note[];
  // ArkTS 接口规范问题（可忽略）
  total: {
    songs: number;
    artists: number;
    albums: number;
    playlists: number;
    users: number;
    notes: number;
  };
}

/**
 * 搜索请求参数
 */
export interface SearchRequest {
  keyword: string;
  type?: 'all' | 'song' | 'artist' | 'album' | 'playlist' | 'user' | 'note';
  page?: number;
  pageSize?: number;
}

/**
 * 搜索建议
 */
export interface SearchSuggestion {
  keyword: string;
  type: 'song' | 'artist' | 'album' | 'playlist' | 'user';
  id?: number;
  extra?: string; // 额外信息，如艺术家名字等
}

/**
 * 艺术家搜索结果
 */
export interface ArtistSearchResult {
  artists: import('./Music').Artist[];
  total: number;
  page: number;
  pageSize: number;
}

/**
 * 专辑搜索结果
 */
export interface AlbumSearchResult {
  albums: import('./Music').Album[];
  total: number;
  page: number;
  pageSize: number;
}

/**
 * 用户搜索结果
 */
export interface UserSearchResult {
  users: import('./User').UserPublicInfo[];
  total: number;
  page: number;
  pageSize: number;
} 