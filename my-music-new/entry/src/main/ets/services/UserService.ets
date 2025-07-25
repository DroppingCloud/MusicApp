import { HttpClient } from './HttpClient';
import { ApiResponse, ApiPaginationInfo, PaginationParams, PaginationResponse, PaginationInfo } from '../models/Common';
import { 
  User, 
  UpdateUserRequest,
  UploadAvatarRequest,
  UserStats, 
  UserCollect,
  LoginRequest,
  RegisterRequest,
  LoginResponse,
  UserPublicInfo,
  UserHistory,
  UserFavorite,
  ChangePasswordRequest
} from '../models/User';

// 定义调试日志接口
interface CollectedDebugInfo {
  原始数据长度: number;
  适配后列表长度: number;
  分页信息: PaginationInfo;
}

// 定义请求接口
interface RefreshTokenRequest {
  refreshToken: string;
}

interface SongIdRequest {
  songId: number;
}

interface PlaylistIdRequest {
  playlistId: number;
}

interface UserIdRequest {
  userId: number;
}

interface UsernameRequest extends Record<string, string | number> {
  username: string;
}

interface EmailRequest extends Record<string, string | number> {
  email: string;
}

// 定义响应接口
interface OperationResult {
  success: boolean;
  message: string;
}

// 头像上传响应接口
interface AvatarUploadResponse {
  user: User;
  avatar: string;
}

interface AvailabilityResponse {
  available: boolean;
}

// 用户基本信息接口
interface UserBasicInfo {
  id: number;
  username: string;
  avatar?: string;
}

// 关注关系接口定义
interface FollowRelation {
  id: number;
  follower_id: number;
  followed_id: number;
  created_at: string;
  followed?: UserBasicInfo;
  follower?: UserBasicInfo;
}

// 列表请求接口
interface ListRequest {
  page?: number;
  limit?: number;
  keyword?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

interface Pagination {
  page: number;
  totalPages: number;
  total: number;
  limit: number;
}

export interface PlayHistoryResponse {
  list: UserHistory[];
  pagination: Pagination;
}

interface GeneratedTypeLiteralInterface_2 {
  list: UserHistory[];
  pagination?: Pagination;
}

interface GeneratedTypeLiteralInterface_1 {
  data: UserHistory[];
  pagination?: Pagination;
}

type PlayHistoryApiResponse =
  | GeneratedTypeLiteralInterface_1
  | GeneratedTypeLiteralInterface_2
  | UserHistory[];

/**
 * 用户服务类
 */
interface GeneratedTypeLiteralInterface_5 {
  pagination?: Pagination;
}

interface GeneratedTypeLiteralInterface_4 {
  list: UserHistory[];
}

interface GeneratedTypeLiteralInterface_3 {
  data: UserHistory[];
}


interface GeneratedTypeLiteralInterface_6 {
  list?: UserHistory[];
  data?: UserHistory[];
  pagination?: Pagination;
}

export class UserService {
  private static instance: UserService;
  private httpClient: HttpClient;

  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  constructor() {
    this.httpClient = HttpClient.getInstance();
  }

  /**
   * 用户注册
   */
  async register(data: RegisterRequest): Promise<LoginResponse> {
    const response = await this.httpClient.post<LoginResponse>('/auth/register', data);
    if (response.success && response.data.token) {
      this.httpClient.setToken(response.data.token);
    }
    return response.data;
  }

  /**
   * 用户登录
   */
  async login(data: LoginRequest): Promise<LoginResponse> {
    const response = await this.httpClient.post<LoginResponse>('/auth/login', data);
    if (response.success && response.data.token) {
      this.httpClient.setToken(response.data.token);
    }
    return response.data;
  }

  /**
   * 刷新令牌
   */
  async refreshToken(refreshToken: string): Promise<LoginResponse> {
    const requestData: RefreshTokenRequest = { refreshToken };
    const response = await this.httpClient.post<LoginResponse>('/auth/refresh', requestData);
    if (response.success && response.data.token) {
      this.httpClient.setToken(response.data.token);
    }
    return response.data;
  }

  /**
   * 退出登录
   */
  async logout(): Promise<OperationResult> {
    const response = await this.httpClient.post<OperationResult>('/auth/logout');
    if (response.success) {
      this.httpClient.setToken('');
    }
    return response.data;
  }

  /**
   * 获取当前用户信息
   */
  async getCurrentUser(): Promise<User> {
    const response = await this.httpClient.get<User>('/auth/me');
    return response.data;
  }
  /**
   * 更新用户信息
   */
  async updateUserInfo(data: UpdateUserRequest): Promise<User> {
    const response = await this.httpClient.post<User>('/user/update', data);
    return response.data;
  }

  /**
   * 上传用户头像
   */
  async uploadAvatar(fileUri: string): Promise<User> {
    try {
      console.log('UserService: 开始上传头像，文件路径:', fileUri);

      // 使用HttpClient的uploadFile方法上传头像
      // 根据API文档，头像上传接口是 POST /user/avatar，字段名为 avatar
      const response = await this.httpClient.uploadFile<AvatarUploadResponse>('/user/avatar', fileUri, 'avatar');
      
      console.log('UserService: 头像上传成功，服务器响应:', response);
      
      if (response.success && response.data) {
        // API返回的data包含user和avatar字段，我们需要提取user对象
        const updatedUser = response.data.user;
        console.log('UserService: 头像上传完成，更新后的用户信息:', updatedUser);
        return updatedUser;
      } else {
        throw new Error(response.message || '头像上传失败');
      }

    } catch (error) {
      console.error('UserService: 头像上传失败:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('头像上传失败');
      }
    }
  }

  /**
   * 修改用户密码
   */
  async changePassword(request: ChangePasswordRequest): Promise<OperationResult> {
    const response = await this.httpClient.post<OperationResult>('/user/change-password', request);
    return response.data;
  }
  /**
   * 获取用户公开信息
   */
  async getUserPublicInfo(userId: number): Promise<UserPublicInfo> {
    const response = await this.httpClient.get<UserPublicInfo>(`/user/profile/${userId}`);
    return response.data;
  }

  /**
   * 获取用户统计信息
   */
  async getUserStats(): Promise<UserStats> {
    const response = await this.httpClient.get<UserStats>('/user/stats');
    return response.data;
  }

  /**
   * 获取用户列表
   */
  async getUserList(params: ListRequest): Promise<PaginationResponse<UserPublicInfo>> {
    const queryParams = this.buildListRequestParams(params);
    const response = await this.httpClient.get<PaginationResponse<UserPublicInfo>>('/user/list', queryParams);
    return response.data;
  }

  /**
   * 获取播放历史
   */
  async getPlayHistory(params: PaginationParams): Promise<PlayHistoryResponse> {
    const queryParams = this.buildPaginationParams(params);
    const response = await this.httpClient.get<GeneratedTypeLiteralInterface_6>('/user/history', queryParams);

    let dataArray: UserHistory[] = [];
    let paginationInfo: Pagination = {
      page: 1,
      totalPages: 1,
      total: 0,
      limit: 50
    };

    if (Array.isArray(response.data)) {
      dataArray = response.data;
      paginationInfo.total = dataArray.length;
      paginationInfo.limit = dataArray.length;
    } else if (Array.isArray(response)) {
      dataArray = response;
      paginationInfo.total = dataArray.length;
      paginationInfo.limit = dataArray.length;
    } else if (response.data && typeof response.data === 'object') {
      // 处理嵌套结构
      if (Array.isArray(response.data.list)) {
        dataArray = response.data.list;
        paginationInfo = response.data.pagination || paginationInfo;
      } else if (Array.isArray(response.data.data)) {
        // 双重嵌套的情况
        dataArray = response.data.data;
        paginationInfo = response.data.pagination || paginationInfo;
      }
    }

    return {
      list: dataArray,
      pagination: paginationInfo
    };
  }

  /**
   * 添加播放历史
   */
  async addPlayHistory(songId: number): Promise<OperationResult> {
    const requestData: SongIdRequest = { songId };
    const response = await this.httpClient.post<OperationResult>('/user/history', requestData);
    return response.data;
  }

  /**
   * 获取喜欢的歌曲
   */
  async getFavoriteSongs(params: PaginationParams): Promise<PaginationResponse<UserFavorite>> {
    const queryParams = this.buildPaginationParams(params);

    const response = await this.httpClient.get<UserFavorite[]>('/user/favorites', queryParams);

    // 适配API响应格式：将data数组转换为list格式
    const paginationInfo: PaginationInfo = {
      page: response.pagination?.page || 1,
      pageSize: response.pagination?.limit || 50,
      total: response.pagination?.total || 0,
      totalPages: response.pagination?.totalPages || 0
    };

    const adaptedResponse: PaginationResponse<UserFavorite> = {
      list: response.data || [],
      pagination: paginationInfo
    };

    return adaptedResponse;
  }

  /**
   * 喜欢歌曲
   */
  async likeSong(songId: number): Promise<OperationResult> {
    const requestData: SongIdRequest = { songId };
    const response = await this.httpClient.post<OperationResult>('/user/like-song', requestData);
    return response.data;
  }

  /**
   * 取消喜欢歌曲
   */
  async unlikeSong(songId: number): Promise<OperationResult> {
    const requestData: SongIdRequest = { songId };
    const response = await this.httpClient.post<OperationResult>('/user/unlike-song', requestData);
    return response.data;
  }

  /**
   * 获取收藏的歌单
   */
  async getCollectedPlaylists(params: PaginationParams): Promise<PaginationResponse<UserCollect>> {
    const queryParams = this.buildPaginationParams(params);

    const response = await this.httpClient.get<UserCollect[]>('/user/collected', queryParams);


    // ======== 调试输出 START ========
    try {
      console.log('【调试】完整 response:', JSON.stringify(response, null, 2));
      console.log('response.data：', JSON.stringify(response.data, null, 2))
    } catch (err) {
      console.log('【调试】response 无法字符串化:', err);
    }
    // ======== 调试输出 END ========


    // 适配API响应格式：将data数组转换为list格式
    const paginationInfo: PaginationInfo = {
      page: response.pagination?.page || 1,
      pageSize: response.pagination?.limit || 50,
      total: response.pagination?.total || 0,
      totalPages: response.pagination?.totalPages || 0
    };

    const adaptedResponse: PaginationResponse<UserCollect> = {
      list: response.data || [],
      pagination: paginationInfo
    };

    // ======== 调试输出 START ========
    console.log("adadptedResponse: ", JSON.stringify(adaptedResponse, null, 2))
    // ======== 调试输出 END ========

    const debugInfo: CollectedDebugInfo = {
      原始数据长度: response.data?.length || 0,
      适配后列表长度: adaptedResponse.list?.length || 0,
      分页信息: paginationInfo
    };

    console.log('收藏歌单API响应适配完成:', debugInfo);

    return adaptedResponse;
  }

  /**
   * 收藏歌单
   */
  async collectPlaylist(playlistId: number): Promise<OperationResult> {
    const requestData: PlaylistIdRequest = { playlistId };
    const response = await this.httpClient.post<OperationResult>('/user/collect-playlist', requestData);
    return response.data;
  }

  /**
   * 取消收藏歌单
   */
  async uncollectPlaylist(playlistId: number): Promise<OperationResult> {
    const requestData: PlaylistIdRequest = { playlistId };
    const response = await this.httpClient.post<OperationResult>('/user/uncollect-playlist', requestData);
    return response.data;
  }

  /**
   * 关注用户
   */
  async followUser(userId: number): Promise<OperationResult> {
    const requestData: UserIdRequest = { userId };
    const response = await this.httpClient.post<OperationResult>('/user/follow', requestData);
    return response.data;
  }

  /**
   * 取消关注用户
   */
  async unfollowUser(userId: number): Promise<OperationResult> {
    const requestData: UserIdRequest = { userId };
    const response = await this.httpClient.post<OperationResult>('/user/unfollow', requestData);
    return response.data;
  }

  /**
   * 获取关注列表
   */
  async getFollowing(params: PaginationParams): Promise<PaginationResponse<FollowRelation>> {
    const queryParams = this.buildPaginationParams(params);
    const response = await this.httpClient.get<PaginationResponse<FollowRelation>>('/user/following', queryParams);
    return response.data;
  }

  /**
   * 获取粉丝列表
   */
  async getFollowers(params: PaginationParams): Promise<PaginationResponse<FollowRelation>> {
    const queryParams = this.buildPaginationParams(params);
    const response = await this.httpClient.get<PaginationResponse<FollowRelation>>('/user/followers', queryParams);
    return response.data;
  }

  /**
   * 检查用户名是否可用
   */
  async checkUsernameAvailable(username: string): Promise<AvailabilityResponse> {
    const requestData: UsernameRequest = { username };
    const response = await this.httpClient.post<AvailabilityResponse>('/user/check-username', requestData);
    return response.data;
  }
  /**
   * 检查邮箱是否可用
   */
  async checkEmailAvailable(email: string): Promise<AvailabilityResponse> {
    const requestData: EmailRequest = { email };
    const response = await this.httpClient.get<AvailabilityResponse>('/auth/check-email', requestData);
    return response.data;
  }

  /**
   * 构建分页查询参数
   */
  private buildPaginationParams(params: PaginationParams): Record<string, string | number> {
    const result: Record<string, string | number> = {};
    if (params.page !== undefined) result.page = params.page;
    if (params.limit !== undefined) result.limit = params.limit;
    return result;
  }

  /**
   * 构建ListRequest查询参数
   */
  private buildListRequestParams(params: ListRequest): Record<string, string | number> {
    const result: Record<string, string | number> = {};

    if (params.page !== undefined) result.page = params.page;
    if (params.limit !== undefined) result.limit = params.limit;
    if (params.keyword !== undefined && params.keyword !== '') result.keyword = params.keyword;
    if (params.sortBy !== undefined && params.sortBy !== '') result.sortBy = params.sortBy;
    if (params.sortOrder !== undefined) result.sortOrder = params.sortOrder;

    return result;
  }
} 