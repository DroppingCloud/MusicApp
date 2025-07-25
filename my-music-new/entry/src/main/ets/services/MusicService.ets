import { HttpClient } from './HttpClient';
import {
  ApiResponse,
  SongQueryParams,
  PlaylistQueryParams,
  PlaylistSongQueryParams,
  ListQueryParams
} from '../models/Common';
import {
  Song,
  Playlist,
  PlaylistSong,
  SongListResponse,
  PlaylistListResponse,
  PlaylistSongListResponse,
  CreatePlaylistRequest,
  CreateSongRequest
} from '../models/Music';

/**
 * 音乐服务类
 */
export class MusicService {
  private httpClient: HttpClient;

  constructor() {
    this.httpClient = HttpClient.getInstance();
  }

  // 参数转换工具方法
  private convertSongParams(params?: SongQueryParams): Record<string, string | number> | undefined {
    if (!params) return undefined;
    const result: Record<string, string | number> = {};
    if (params.page !== undefined) result['page'] = params.page;
    if (params.limit !== undefined) result['limit'] = params.limit;
    if (params.keyword !== undefined) result['keyword'] = params.keyword;
    if (params.genre !== undefined) result['genre'] = params.genre;
    if (params.artist !== undefined) result['artist'] = params.artist;
    return result;
  }

  private convertPlaylistParams(params?: PlaylistQueryParams): Record<string, string | number> | undefined {
    if (!params) return undefined;
    const result: Record<string, string | number> = {};
    if (params.page !== undefined) result['page'] = params.page;
    if (params.limit !== undefined) result['limit'] = params.limit;
    if (params.keyword !== undefined) result['keyword'] = params.keyword;
    if (params.userId !== undefined) result['userId'] = params.userId;
    if (params.isPublic !== undefined) result['isPublic'] = params.isPublic ? 1 : 0;
    return result;
  }

  private convertPlaylistSongParams(params?: PlaylistSongQueryParams): Record<string, string | number> | undefined {
    if (!params) return undefined;
    const result: Record<string, string | number> = {};
    if (params.page !== undefined) result['page'] = params.page;
    if (params.limit !== undefined) result['limit'] = params.limit;
    if (params.playlistId !== undefined) result['playlistId'] = params.playlistId;
    return result;
  }

  private convertListParams(params?: ListQueryParams): Record<string, string | number> | undefined {
    if (!params) return undefined;
    const result: Record<string, string | number> = {};
    if (params.page !== undefined) result['page'] = params.page;
    if (params.limit !== undefined) result['limit'] = params.limit;
    return result;
  }

  /**
   * 获取歌曲列表
   */
  async getSongList(params?: SongQueryParams): Promise<SongListResponse> {
    try {
      console.log('getSongList: 开始请求, params:', JSON.stringify(params));
      const queryParams = this.convertSongParams(params);
      console.log('getSongList: 转换后的查询参数:', JSON.stringify(queryParams));

      const response = await this.httpClient.get<Song[]>('/song/list', queryParams);
      console.log('getSongList: HTTP原始响应:', JSON.stringify(response));
      console.log('getSongList: 响应数据类型:', typeof response.data);
      console.log('getSongList: 响应数据:', JSON.stringify(response.data));

      const songsArray = response.data;

      // 构造符合接口期望的响应格式
      const SongsListResponse: SongListResponse = {
        list: songsArray || [],
        pagination: {
          page: params?.page || 1,
          limit: params?.limit || 50,
          total: songsArray?.length || 0,
          totalPages: 1 // 当前API返回所有数据，所以总是1页
        }
      };

      return SongsListResponse;
    } catch (error) {
      console.error('getSongList: 请求失败:', error);
      console.error('getSongList: 错误详情:', JSON.stringify(error));
      throw new Error(`获取歌曲列表失败: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 获取歌曲详情
   */
  async getSongDetail(id: number): Promise<Song> {
    const response = await this.httpClient.get<Song>(`/song/detail/${id}`);
    return response.data;
  }

  /**
   * 创建歌曲
   */
  async createSong(data: CreateSongRequest): Promise<Song> {
    const response = await this.httpClient.post<Song>('/song/create', data);
    return response.data;
  }

  /**
   * 更新歌曲信息
   */
  async updateSong(id: number, data: Partial<CreateSongRequest>): Promise<Song> {
    const response = await this.httpClient.post<Song>(`/song/update/${id}`, data);
    return response.data;
  }

  /**
   * 删除歌曲
   */
  async removeSong(id: number): Promise<void> {
    await this.httpClient.post(`/song/remove/${id}`);
  }

  /**
   * 播放歌曲
   */
  async playSong(id: number): Promise<void> {
    await this.httpClient.post(`/song/play/${id}`);
  }

  /**
   * 获取热门歌曲
   */
  async getHotSongs(limit: number = 50): Promise<Song[]> {
    const params: ListQueryParams = { limit };
    const queryParams = this.convertListParams(params);
    const response = await this.httpClient.get<Song[]>('/song/hot', queryParams);
    return response.data;
  }

  /**
   * 获取推荐歌曲
   */
  async getRecommendSongs(limit: number = 20): Promise<Song[]> {
    const params: ListQueryParams = { limit };
    const queryParams = this.convertListParams(params);
    const response = await this.httpClient.get<Song[]>('/song/recommend', queryParams);
    return response.data;
  }

  /**
   * 喜欢歌曲
   */
  async likeSong(id: number): Promise<void> {
    await this.httpClient.post(`/song/like/${id}`);
  }

  /**
   * 取消喜欢歌曲
   */
  async unlikeSong(id: number): Promise<void> {
    await this.httpClient.post(`/song/unlike/${id}`);
  }

  // ==================== 歌单相关接口 ====================

  /**
   * 获取歌单列表
   */
  async getPlaylistList(params?: PlaylistQueryParams): Promise<PlaylistListResponse> {
    try {
      console.log('getPlaylistList: 开始请求, params:', JSON.stringify(params));
      const queryParams = this.convertPlaylistParams(params);
      console.log('getPlaylistList: 转换后的查询参数:', JSON.stringify(queryParams));

      const response = await this.httpClient.get<PlaylistListResponse>('/playlist/list', queryParams);
      console.log('getPlaylistList: HTTP原始响应:', JSON.stringify(response));
      console.log('getPlaylistList: 响应数据类型:', typeof response.data);
      console.log('getPlaylistList: 响应数据:', JSON.stringify(response.data));

      return response.data;
    } catch (error) {
      console.error('getPlaylistList: 请求失败:', error);
      console.error('getPlaylistList: 错误详情:', JSON.stringify(error));
      throw new Error(`获取歌单列表失败: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 获取歌单详情
   */
  async getPlaylistDetail(id: number): Promise<Playlist> {
    try {
      console.log('MusicService.getPlaylistDetail: 开始请求, id:', id);
      const response = await this.httpClient.get<Playlist>(`/playlist/detail/${id}`);
      console.log('MusicService.getPlaylistDetail: HTTP响应成功');
      console.log('MusicService.getPlaylistDetail: 响应数据:', JSON.stringify(response.data));
      return response.data;
    } catch (error) {
      console.error('MusicService.getPlaylistDetail: 请求失败, id:', id);
      console.error('MusicService.getPlaylistDetail: 错误详情:', JSON.stringify(error));
      throw new Error(`获取歌单详情失败: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 创建歌单
   */
  async createPlaylist(data: CreatePlaylistRequest): Promise<Playlist> {
    const response = await this.httpClient.post<Playlist>('/playlist/create', data);
    return response.data;
  }

  /**
   * 更新歌单信息
   */
  async updatePlaylist(id: number, data: Partial<CreatePlaylistRequest>): Promise<Playlist> {
    const response = await this.httpClient.post<Playlist>(`/playlist/update/${id}`, data);
    return response.data;
  }

  /**
   * 删除歌单
   */
  async removePlaylist(id: number): Promise<void> {
    await this.httpClient.post(`/playlist/remove/${id}`);
  }

  /**
   * 获取歌单中的歌曲
   */
  async getPlaylistSongs(id: number, params?: PlaylistSongQueryParams): Promise<PlaylistSongListResponse> {
    try {
      console.log('MusicService.getPlaylistSongs: 开始请求, id:', id, 'params:', JSON.stringify(params));
      const queryParams = this.convertPlaylistSongParams(params);
      console.log('MusicService.getPlaylistSongs: 转换后的查询参数:', JSON.stringify(queryParams));

      // 适配实际API响应格式：data字段直接是歌曲数组
      const response = await this.httpClient.get<PlaylistSong[]>(`/playlist/songs/${id}`, queryParams);
      console.log('MusicService.getPlaylistSongs: HTTP响应成功');

      const songsArray = response.data;
      console.log('MusicService.getPlaylistSongs: 歌曲数组长度:', songsArray?.length || 0);

      // 构造符合接口期望的响应格式
      const playlistSongResponse: PlaylistSongListResponse = {
        list: songsArray || [],
        pagination: {
          page: params?.page || 1,
          limit: params?.limit || 50,
          total: songsArray?.length || 0,
          totalPages: 1 // 当前API返回所有数据，所以总是1页
        }
      };

      console.log('MusicService.getPlaylistSongs: 转换后的响应格式:', {
        列表长度: playlistSongResponse.list?.length || 0,
        分页信息: playlistSongResponse.pagination
      });

      return playlistSongResponse;
    } catch (error) {
      console.error('MusicService.getPlaylistSongs: 请求失败, id:', id);
      console.error('MusicService.getPlaylistSongs: 错误详情:', JSON.stringify(error));
      throw new Error(`获取歌单歌曲失败: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 添加歌曲到歌单
   */
  async addSongToPlaylist(playlistId: number, songId: number): Promise<void> {
    await this.httpClient.post(`/playlist/add-song/${playlistId}/${songId}`);
  }

  /**
   * 从歌单移除歌曲
   */
  async removeSongFromPlaylist(playlistId: number, songId: number): Promise<void> {
    await this.httpClient.post(`/playlist/remove-song/${playlistId}/${songId}`);
  }

  /**
   * 收藏歌单
   */
  async collectPlaylist(id: number): Promise<void> {
    await this.httpClient.post(`/playlist/collect/${id}`);
  }

  /**
   * 取消收藏歌单
   */
  async uncollectPlaylist(id: number): Promise<void> {
    await this.httpClient.post(`/playlist/uncollect/${id}`);
  }

  /**
   * 获取收藏的歌单
   */
  async getCollectedPlaylists(params?: ListQueryParams): Promise<PlaylistListResponse> {
    const queryParams = this.convertListParams(params);
    const response = await this.httpClient.get<PlaylistListResponse>('/playlist/collected', queryParams);
    return response.data;
  }

  /**
   * 获取用户创建的歌单
   */
  async getUserPlaylists(userId: number, params?: ListQueryParams): Promise<PlaylistListResponse> {
    const queryParams = this.convertListParams(params);
    const response = await this.httpClient.get<PlaylistListResponse>(`/playlist/user/${userId}`, queryParams);
    return response.data;
  }

  // ==================== 首页数据获取方法 ====================

  /**
   * 获取首页轮播图数据（随机歌曲）
   */
  async getBannerSongs(limit: number = 5): Promise<Song[]> {
    try {
      // 随机获取歌曲作为轮播图
      const response = await this.getSongList({ page: 1, limit: limit * 2 });
      const songs = Array.isArray(response) ? response : (response?.list || []);

      // 随机选择指定数量的歌曲
      const shuffled = songs.sort(() => 0.5 - Math.random());
      return shuffled.slice(0, limit);
    } catch (error) {
      console.error('getBannerSongs: 获取轮播图数据失败:', error);
      return [];
    }
  }

  /**
   * 获取首页推荐歌单（随机歌单）
   */
  async getRecommendPlaylists(limit: number = 6): Promise<Playlist[]> {
    try {
      const response = await this.getPlaylistList({ page: 1, limit: limit * 2 });
      const playlists = Array.isArray(response) ? response : (response?.list || []);

      // 随机选择指定数量的歌单
      const shuffled = playlists.sort(() => 0.5 - Math.random());
      return shuffled.slice(0, limit);
    } catch (error) {
      console.error('getRecommendPlaylists: 获取推荐歌单失败:', error);
      return [];
    }
  }

  /**
   * 获取首页热门歌曲（按播放次数排序）
   */
  async getTopHotSongs(limit: number = 10): Promise<Song[]> {
    try {
      return await this.getHotSongs(limit);
    } catch (error) {
      console.error('获取热门歌曲失败:', error);
      return [];
    }
  }

  /**
   * 获取首页最新发布专辑（模拟数据，API文档中暂无专辑接口）
   */
  async getLatestAlbums(limit: number = 4): Promise<Song[]> {
    try {
      // 由于API文档中没有专辑接口，这里用最新歌曲代替
      const response = await this.getSongList({ page: 1, limit });
      return Array.isArray(response) ? response : (response?.list || []);
    } catch (error) {
      console.error('getLatestAlbums: 获取最新发布失败:', error);
      return [];
    }
  }
}