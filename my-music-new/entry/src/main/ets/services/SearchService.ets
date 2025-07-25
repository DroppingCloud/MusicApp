/**
 * 搜索服务 - 处理所有搜索相关的API请求
 */
import { HttpClient } from './HttpClient';

// 搜索结果接口定义
export interface SearchResult {
  songs?: SongSearchResult;
  artists?: ArtistSearchResult;
  albums?: AlbumSearchResult;
  playlists?: PlaylistSearchResult;
  users?: UserSearchResult;
}

export interface SongSearchResult {
  list: Song[];
  total: number;
  pagination: Pagination;
}

export interface ArtistSearchResult {
  list: Artist[];
  total: number;
  pagination: Pagination;
}

export interface AlbumSearchResult {
  list: Album[];
  total: number;
  pagination: Pagination;
}

export interface PlaylistSearchResult {
  list: Playlist[];
  total: number;
  pagination: Pagination;
}

export interface UserSearchResult {
  list: User[];
  total: number;
  pagination: Pagination;
}

export interface Song {
  id: number;
  title: string;
  audio_url: string;
  cover_url: string;
  duration: number;
  release_date: string;
  artist: SongArtist;
  album: SongAlbum;
  stat: SongStat;
  tags: SongTag[];
}

export interface SongArtist {
  id: number;
  name: string;
  avatar: string;
}

export interface SongAlbum {
  id: number;
  title: string;
  cover_url: string;
}

export interface SongStat {
  play_count: number;
  like_count: number;
  comment_count: number;
}

export interface SongTag {
  id: number;
  name: string;
  type: string;
}

export interface Artist {
  id: number;
  name: string;
  avatar: string;
  bio: string;
  song_count: number;
  album_count: number;
}

export interface Album {
  id: number;
  title: string;
  cover_url: string;
  publish_time: string;
  artist: AlbumArtist;
  song_count: number;
}

export interface AlbumArtist {
  id: number;
  name: string;
  avatar: string;
}

export interface Playlist {
  id: number;
  title: string;
  cover_url: string;
  description: string;
  create_time: string;
  song_count: number;
  collect_count: number;
  creator: PlaylistCreator;
}

export interface PlaylistCreator {
  id: number;
  username: string;
  avatar: string;
}

export interface User {
  id: number;
  username: string;
  avatar: string;
  created_at: string;
}

export interface Pagination {
  limit: number;
  offset: number;
  totalPages: number;
}

export interface SearchSuggestion {
  keyword: string;
  count: number;
}

export interface SearchHistory {
  id: number;
  keyword: string;
  search_time: string;
}

export interface SearchParams {
  keyword: string;
  page?: number;
  limit?: number;
  type?: 'all' | 'song' | 'artist' | 'album' | 'playlist' | 'user';
}

export interface SearchResponse {
  keyword: string;
  results: SearchResult;
  pagination: SearchPagination;
}

export interface SearchPagination {
  page: number;
  limit: number;
}

export interface SuggestionsParams {
  keyword: string;
  limit?: number;
}

export interface SearchTypeParams {
  keyword: string;
  page?: number;
  limit?: number;
}

export interface HotKeywordsParams {
  limit?: number;
}

export interface HistoryParams {
  page?: number;
  limit?: number;
}

export interface HistoryResponse {
  list: SearchHistory[];
  pagination: HistoryPagination;
}

export interface HistoryPagination {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface DeleteHistoryResponse {
  deletedCount: number;
}

export interface DeleteHistoryRequest {
  historyId?: number;
}

export interface SearchQueryParams {
  keyword: string;
  page: number;
  limit: number;
  type?: string;
}

export interface SuggestionQueryParams {
  keyword: string;
  page: number;
  limit: number;
}

export interface HotKeywordsQueryParams {
  limit?: number;
}

export interface HistoryQueryParams {
  page: number;
  limit: number;
}

export class SearchService {
  private static instance: SearchService;
  private httpClient: HttpClient;

  private constructor() {
    this.httpClient = HttpClient.getInstance();
  }

  public static getInstance(): SearchService {
    if (!SearchService.instance) {
      SearchService.instance = new SearchService();
    }
    return SearchService.instance;
  }

  /**
   * 构建查询字符串 - 搜索参数
   */
  private buildSearchQueryString(params: SearchQueryParams): string {
    const queryParts: string[] = [];
    
    if (params.keyword !== undefined && params.keyword !== null) {
      queryParts.push(`keyword=${encodeURIComponent(params.keyword)}`);
    }
    if (params.page !== undefined && params.page !== null) {
      queryParts.push(`page=${encodeURIComponent(String(params.page))}`);
    }
    if (params.limit !== undefined && params.limit !== null) {
      queryParts.push(`limit=${encodeURIComponent(String(params.limit))}`);
    }
    if (params.type !== undefined && params.type !== null) {
      queryParts.push(`type=${encodeURIComponent(params.type)}`);
    }
    
    return queryParts.join('&');
  }

  /**
   * 构建查询字符串 - 建议参数
   */
  private buildSuggestionQueryString(params: SuggestionQueryParams): string {
    const queryParts: string[] = [];
    
    if (params.keyword !== undefined && params.keyword !== null) {
      queryParts.push(`keyword=${encodeURIComponent(params.keyword)}`);
    }
    if (params.page !== undefined && params.page !== null) {
      queryParts.push(`page=${encodeURIComponent(String(params.page))}`);
    }
    if (params.limit !== undefined && params.limit !== null) {
      queryParts.push(`limit=${encodeURIComponent(String(params.limit))}`);
    }
    
    return queryParts.join('&');
  }

  /**
   * 构建查询字符串 - 热门关键词参数
   */
  private buildHotKeywordsQueryString(params: HotKeywordsQueryParams): string {
    const queryParts: string[] = [];
    
    if (params.limit !== undefined && params.limit !== null) {
      queryParts.push(`limit=${encodeURIComponent(String(params.limit))}`);
    }
    
    return queryParts.join('&');
  }

  /**
   * 构建查询字符串 - 历史参数
   */
  private buildHistoryQueryString(params: HistoryQueryParams): string {
    const queryParts: string[] = [];
    
    if (params.page !== undefined && params.page !== null) {
      queryParts.push(`page=${encodeURIComponent(String(params.page))}`);
    }
    if (params.limit !== undefined && params.limit !== null) {
      queryParts.push(`limit=${encodeURIComponent(String(params.limit))}`);
    }
    
    return queryParts.join('&');
  }

  /**
   * 综合搜索
   */
  async search(params: SearchParams): Promise<SearchResponse> {
    const queryParams: SearchQueryParams = {
      keyword: params.keyword,
      page: params.page || 1,
      limit: params.limit || 20,
    };
    
    if (params.type) {
      queryParams.type = params.type;
    }

    const queryString = this.buildSearchQueryString(queryParams);
    const response = await this.httpClient.get(`/search?${queryString}`);
    return response.data as SearchResponse;
  }

  /**
   * 搜索歌曲
   */
  async searchSongs(params: SearchTypeParams): Promise<SongSearchResult> {
    const queryParams: SuggestionQueryParams = {
      keyword: params.keyword,
      page: params.page || 1,
      limit: params.limit || 20,
    };

    const queryString = this.buildSuggestionQueryString(queryParams);
    const response = await this.httpClient.get(`/search/songs?${queryString}`);
    return response.data as SongSearchResult;
  }

  /**
   * 搜索艺术家
   */
  async searchArtists(params: SearchTypeParams): Promise<ArtistSearchResult> {
    const queryParams: SuggestionQueryParams = {
      keyword: params.keyword,
      page: params.page || 1,
      limit: params.limit || 20,
    };

    const queryString = this.buildSuggestionQueryString(queryParams);
    const response = await this.httpClient.get(`/search/artists?${queryString}`);
    return response.data as ArtistSearchResult;
  }

  /**
   * 搜索专辑
   */
  async searchAlbums(params: SearchTypeParams): Promise<AlbumSearchResult> {
    const queryParams: SuggestionQueryParams = {
      keyword: params.keyword,
      page: params.page || 1,
      limit: params.limit || 20,
    };

    const queryString = this.buildSuggestionQueryString(queryParams);
    const response = await this.httpClient.get(`/search/albums?${queryString}`);
    return response.data as AlbumSearchResult;
  }

  /**
   * 搜索歌单
   */
  async searchPlaylists(params: SearchTypeParams): Promise<PlaylistSearchResult> {
    const queryParams: SuggestionQueryParams = {
      keyword: params.keyword,
      page: params.page || 1,
      limit: params.limit || 20,
    };

    const queryString = this.buildSuggestionQueryString(queryParams);
    const response = await this.httpClient.get(`/search/playlists?${queryString}`);
    return response.data as PlaylistSearchResult;
  }

  /**
   * 搜索用户
   */
  async searchUsers(params: SearchTypeParams): Promise<UserSearchResult> {
    const queryParams: SuggestionQueryParams = {
      keyword: params.keyword,
      page: params.page || 1,
      limit: params.limit || 20,
    };

    const queryString = this.buildSuggestionQueryString(queryParams);
    const response = await this.httpClient.get(`/search/users?${queryString}`);
    return response.data as UserSearchResult;
  }

  /**
   * 获取搜索建议
   */
  async getSearchSuggestions(params: SuggestionsParams): Promise<SearchSuggestion[]> {
    const queryParams: SuggestionQueryParams = {
      keyword: params.keyword,
      page: 1,
      limit: params.limit || 10,
    };

    const queryString = this.buildSuggestionQueryString(queryParams);
    const response = await this.httpClient.get(`/search/suggestions?${queryString}`);
    return response.data as SearchSuggestion[];
  }

  /**
   * 获取热门搜索词
   */
  async getHotKeywords(params?: HotKeywordsParams): Promise<SearchSuggestion[]> {
    const queryParams: HotKeywordsQueryParams = {};
    if (params?.limit) {
      queryParams.limit = params.limit;
    }

    const queryString = this.buildHotKeywordsQueryString(queryParams);
    const response = await this.httpClient.get(`/search/hot-keywords?${queryString}`);
    return response.data as SearchSuggestion[];
  }

  /**
   * 获取搜索历史
   */
  async getSearchHistory(params?: HistoryParams): Promise<HistoryResponse> {
    const queryParams: HistoryQueryParams = {
      page: params?.page || 1,
      limit: params?.limit || 20,
    };

    const queryString = this.buildHistoryQueryString(queryParams);
    const response = await this.httpClient.get(`/search/history?${queryString}`);
    return response.data as HistoryResponse;
  }

  /**
   * 删除搜索历史
   */
  async deleteSearchHistory(historyId?: number): Promise<DeleteHistoryResponse> {
    const requestData: DeleteHistoryRequest = {
      historyId
    };
    const response = await this.httpClient.post('/search/history/delete', requestData);
    return response.data as DeleteHistoryResponse;
  }
} 