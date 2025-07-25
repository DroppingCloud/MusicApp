import { HttpClient } from './HttpClient';
import {
  Follow,
  FollowStat,
  Like,
  Comment,
  CreateCommentRequest,
  Note,
  CreateNoteRequest,
  UpdateNoteRequest,
  Chat,
  Message,
  SendMessageRequest,
  NoteSearchResult
} from '../models/Social';
import { UserPublicInfo } from '../models/User';
import { PaginationResponse, ListRequest, OperationResult } from '../models/Common';

/**
 * 社交服务类
 */
export class SocialService {
  private httpClient: HttpClient;

  constructor() {
    this.httpClient = HttpClient.getInstance();
  }

  // ==================== 关注相关接口 ====================

  /**
   * 关注用户
   */
  async followUser(userId: number): Promise<OperationResult> {
    const response = await this.httpClient.post<OperationResult>('/social/follow', { userId });
    return response.data;
  }

  /**
   * 取消关注用户
   */
  async unfollowUser(userId: number): Promise<OperationResult> {
    const response = await this.httpClient.delete<OperationResult>(`/social/follow/${userId}`);
    return response.data;
  }

  /**
   * 获取关注列表
   */
  async getFollowingList(userId?: number, params?: { page?: number; pageSize?: number }): Promise<PaginationResponse<Follow>> {
    const url = userId ? `/social/users/${userId}/following` : '/social/following';
    const response = await this.httpClient.get<PaginationResponse<Follow>>(url, params);
    return response.data;
  }

  /**
   * 获取粉丝列表
   */
  async getFollowersList(userId?: number, params?: { page?: number; pageSize?: number }): Promise<PaginationResponse<Follow>> {
    const url = userId ? `/social/users/${userId}/followers` : '/social/followers';
    const response = await this.httpClient.get<PaginationResponse<Follow>>(url, params);
    return response.data;
  }

  /**
   * 获取关注统计
   */
  async getFollowStats(userId?: number): Promise<FollowStat> {
    const url = userId ? `/social/users/${userId}/follow-stats` : '/social/follow-stats';
    const response = await this.httpClient.get<FollowStat>(url);
    return response.data;
  }

  /**
   * 检查关注状态
   */
  async checkFollowStatus(userId: number): Promise<{ isFollowing: boolean }> {
    const response = await this.httpClient.get<{ isFollowing: boolean }>(`/social/follow-status/${userId}`);
    return response.data;
  }

  /**
   * 获取互相关注好友
   */
  async getMutualFollows(params: { page?: number; pageSize?: number }): Promise<PaginationResponse<UserPublicInfo>> {
    const response = await this.httpClient.get<PaginationResponse<UserPublicInfo>>('/social/mutual-follows', params);
    return response.data;
  }

  // ==================== 点赞相关接口 ====================

  /**
   * 点赞
   */
  async like(type: 'song' | 'note' | 'comment', targetId: number): Promise<OperationResult> {
    const response = await this.httpClient.post<OperationResult>('/social/like', { type, targetId });
    return response.data;
  }

  /**
   * 取消点赞
   */
  async unlike(type: 'song' | 'note' | 'comment', targetId: number): Promise<OperationResult> {
    const response = await this.httpClient.delete<OperationResult>(`/social/like/${type}/${targetId}`);
    return response.data;
  }

  /**
   * 获取用户点赞列表
   */
  async getUserLikes(type?: 'song' | 'note' | 'comment', params?: { page?: number; pageSize?: number }): Promise<PaginationResponse<Like>> {
    const queryParams = { ...params, type };
    const response = await this.httpClient.get<PaginationResponse<Like>>('/social/likes', queryParams);
    return response.data;
  }

  /**
   * 批量检查点赞状态
   */
  async checkLikeStatus(items: { type: string; targetId: number }[]): Promise<Record<string, boolean>> {
    const response = await this.httpClient.post<Record<string, boolean>>('/social/like-status', { items });
    return response.data;
  }

  /**
   * 获取点赞统计
   */
  async getLikeStats(type: 'song' | 'note' | 'comment', targetId: number): Promise<{ count: number; isLiked: boolean }> {
    const response = await this.httpClient.get<{ count: number; isLiked: boolean }>(`/social/like-stats/${type}/${targetId}`);
    return response.data;
  }

  // ==================== 评论相关接口 ====================

  /**
   * 获取评论列表
   */
  async getComments(type: 'song' | 'note' | 'playlist', targetId: number, params: { page?: number; pageSize?: number }): Promise<PaginationResponse<Comment>> {
    const response = await this.httpClient.get<PaginationResponse<Comment>>(`/social/comments/${type}/${targetId}`, params);
    return response.data;
  }

  /**
   * 添加评论
   */
  async addComment(data: CreateCommentRequest): Promise<Comment> {
    const response = await this.httpClient.post<Comment>('/social/comments', data);
    return response.data;
  }

  /**
   * 删除评论
   */
  async deleteComment(commentId: number): Promise<OperationResult> {
    const response = await this.httpClient.delete<OperationResult>(`/social/comments/${commentId}`);
    return response.data;
  }

  // ==================== 笔记相关接口 ====================

  /**
   * 获取笔记列表
   */
  async getNoteList(params: ListRequest): Promise<PaginationResponse<Note>> {
    const response = await this.httpClient.get<PaginationResponse<Note>>('/social/notes', params);
    return response.data;
  }

  /**
   * 获取笔记详情
   */
  async getNoteDetail(noteId: number): Promise<Note> {
    const response = await this.httpClient.get<Note>(`/social/notes/${noteId}`);
    return response.data;
  }

  /**
   * 创建笔记
   */
  async createNote(data: CreateNoteRequest): Promise<Note> {
    const response = await this.httpClient.post<Note>('/social/notes', data);
    return response.data;
  }

  /**
   * 更新笔记
   */
  async updateNote(noteId: number, data: UpdateNoteRequest): Promise<Note> {
    const response = await this.httpClient.put<Note>(`/social/notes/${noteId}`, data);
    return response.data;
  }

  /**
   * 删除笔记
   */
  async deleteNote(noteId: number): Promise<OperationResult> {
    const response = await this.httpClient.delete<OperationResult>(`/social/notes/${noteId}`);
    return response.data;
  }

  /**
   * 点赞笔记
   */
  async likeNote(noteId: number): Promise<OperationResult> {
    const response = await this.httpClient.post<OperationResult>(`/social/notes/${noteId}/like`);
    return response.data;
  }

  /**
   * 取消点赞笔记
   */
  async unlikeNote(noteId: number): Promise<OperationResult> {
    const response = await this.httpClient.delete<OperationResult>(`/social/notes/${noteId}/like`);
    return response.data;
  }

  /**
   * 获取笔记评论
   */
  async getNoteComments(noteId: number, params: { page?: number; pageSize?: number }): Promise<PaginationResponse<Comment>> {
    const response = await this.httpClient.get<PaginationResponse<Comment>>(`/social/notes/${noteId}/comments`, params);
    return response.data;
  }

  /**
   * 添加笔记评论
   */
  async addNoteComment(noteId: number, content: string, parentId?: number): Promise<Comment> {
    const response = await this.httpClient.post<Comment>(`/social/notes/${noteId}/comments`, { content, parentId });
    return response.data;
  }

  /**
   * 获取我的笔记
   */
  async getMyNotes(params: { page?: number; pageSize?: number }): Promise<PaginationResponse<Note>> {
    const response = await this.httpClient.get<PaginationResponse<Note>>('/social/notes/mine', params);
    return response.data;
  }

  /**
   * 根据歌曲获取笔记
   */
  async getNotesBySong(songId: number, params: { page?: number; pageSize?: number }): Promise<PaginationResponse<Note>> {
    const response = await this.httpClient.get<PaginationResponse<Note>>(`/social/notes/song/${songId}`, params);
    return response.data;
  }

  /**
   * 上传笔记图片
   */
  async uploadNoteImage(file: File): Promise<{ url: string }> {
    // TODO: 实现文件上传逻辑
    const response = await this.httpClient.post<{ url: string }>('/upload/note-image', file);
    return response.data;
  }

  // ==================== 聊天相关接口 ====================

  /**
   * 获取聊天会话列表
   */
  async getChatList(params: { page?: number; pageSize?: number }): Promise<PaginationResponse<Chat>> {
    const response = await this.httpClient.get<PaginationResponse<Chat>>('/social/chats', params);
    return response.data;
  }

  /**
   * 获取聊天消息
   */
  async getChatMessages(chatId: number, params: { page?: number; pageSize?: number }): Promise<PaginationResponse<Message>> {
    const response = await this.httpClient.get<PaginationResponse<Message>>(`/social/chats/${chatId}/messages`, params);
    return response.data;
  }

  /**
   * 发送消息
   */
  async sendMessage(data: SendMessageRequest): Promise<Message> {
    const response = await this.httpClient.post<Message>('/social/messages', data);
    return response.data;
  }

  /**
   * 获取或创建与指定用户的聊天会话
   */
  async getOrCreateChat(userId: number): Promise<Chat> {
    const response = await this.httpClient.post<Chat>('/social/chats', { userId });
    return response.data;
  }

  /**
   * 标记消息为已读
   */
  async markMessagesAsRead(chatId: number): Promise<OperationResult> {
    const response = await this.httpClient.put<OperationResult>(`/social/chats/${chatId}/read`);
    return response.data;
  }
} 