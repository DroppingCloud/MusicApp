/**
 * 关注关系模型
 */
export interface Follow {
  id: number;
  followerId: number;
  followedId: number;
  createdAt: string;
  follower?: import('./User').UserPublicInfo;
  followed?: import('./User').UserPublicInfo;
}

/**
 * 关注统计信息
 */
export interface FollowStat {
  followersCount: number;
  followingCount: number;
  mutualCount: number;
}

/**
 * 点赞模型
 */
export interface Like {
  id: number;
  userId: number;
  type: 'song' | 'note' | 'comment';
  targetId: number;
  createdAt: string;
  user?: import('./User').UserPublicInfo;
}

/**
 * 评论模型
 */
export interface Comment {
  id: number;
  userId: number;
  type: 'song' | 'note' | 'playlist';
  targetId: number;
  content: string;
  parentId?: number;
  createdAt: string;
  user?: import('./User').UserPublicInfo;
  replies?: Comment[];
  likeCount?: number;
  isLiked?: boolean;
}

/**
 * 创建评论请求
 */
export interface CreateCommentRequest {
  type: 'song' | 'note' | 'playlist';
  targetId: number;
  content: string;
  parentId?: number;
}

/**
 * 笔记图片模型
 */
export interface NoteImage {
  id: number;
  noteId: number;
  imageUrl: string;
  orderIndex: number;
}

/**
 * 笔记模型
 */
export interface Note {
  id: number;
  userId: number;
  title?: string;
  content?: string;
  songId?: number;
  createdAt: string;
  user?: import('./User').UserPublicInfo;
  song?: import('./Music').Song;
  images?: NoteImage[];
  likeCount?: number;
  commentCount?: number;
  isLiked?: boolean;
}

/**
 * 创建笔记请求
 */
export interface CreateNoteRequest {
  title?: string;
  content?: string;
  songId?: number;
  images?: string[];
}

/**
 * 更新笔记请求
 */
export interface UpdateNoteRequest {
  title?: string;
  content?: string;
  images?: string[];
}

/**
 * 聊天会话模型
 */
export interface Chat {
  id: number;
  user1Id: number;
  user2Id: number;
  lastMsg?: string;
  lastTime?: string;
  user1?: import('./User').UserPublicInfo;
  user2?: import('./User').UserPublicInfo;
  unreadCount?: number;
}

/**
 * 消息模型
 */
export interface Message {
  id: number;
  chatId: number;
  senderId: number;
  content: string;
  sendTime: string;
  sender?: import('./User').UserPublicInfo;
}

/**
 * 发送消息请求
 */
export interface SendMessageRequest {
  receiverId: number;
  content: string;
}

/**
 * 笔记搜索结果
 */
export interface NoteSearchResult {
  notes: Note[];
  total: number;
  page: number;
  pageSize: number;
} 