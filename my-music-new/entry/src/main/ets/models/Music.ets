/**
 * 艺术家信息
 */
export interface Artist {
  id: number;
  name: string;
  avatar: string;
  bio?: string;
}

/**
 * 专辑信息
 */
export interface Album {
  id: number;
  title: string;
  cover_url: string;
  publish_time?: string;
}

/**
 * 歌曲统计信息
 */
export interface SongStat {
  play_count: number;
  like_count: number;
  comment_count: number;
}

/**
 * 标签信息
 */
export interface Tag {
  id: number;
  name: string;
  type: string;
}

/**
 * 歌曲信息
 */
export interface Song {
  id: number;
  title: string;
  audio_url: string;
  cover_url: string;
  duration: number;
  release_date?: string;
  artist: Artist;
  album?: Album;
  stat: SongStat;
  tags?: Tag[];
}

/**
 * 歌单创建者信息
 */
export interface PlaylistCreator {
  id: number;
  username: string;
  avatar: string;
}

/**
 * 歌单信息
 */
export interface Playlist {
  id: number;
  title: string;
  cover_url: string;
  description?: string;
  create_time: string;
  song_count: number;
  collect_count?: number;
  creator: PlaylistCreator;
}

/**
 * 歌单中的歌曲
 */
export interface PlaylistSong {
  id: number;
  playlist_id: number;
  song_id: number;
  order_index: number;
  song: Song;
}

/**
 * 分页信息
 */
export interface Pagination {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

/**
 * 歌曲列表响应
 */
export interface SongListResponse {
  list: Song[];
  pagination: Pagination;
}

/**
 * 歌单列表响应
 */
export interface PlaylistListResponse {
  list: Playlist[];
  pagination: Pagination;
}

/**
 * 歌单歌曲列表响应
 */
export interface PlaylistSongListResponse {
  list: PlaylistSong[];
  pagination: Pagination;
}

/**
 * 创建歌单请求
 */
export interface CreatePlaylistRequest {
  title: string;
  cover_url?: string;
  description?: string;
}

/**
 * 创建歌曲请求
 */
export interface CreateSongRequest {
  title: string;
  artist_id: number;
  album_id?: number;
  audio_url: string;
  cover_url?: string;
  duration: number;
  release_date?: string;
  tags?: string[];
} 