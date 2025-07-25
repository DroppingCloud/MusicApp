const { sequelize } = require('../config/sequelize')
const User = require('./User')
const UserFavorite = require('./UserFavorite')
const UserCollect = require('./UserCollect')
const UserHistory = require('./UserHistory')
const Follow = require('./Follow')
const Like = require('./Like')

// 音乐相关模型
const Song = require('./Song')
const Album = require('./Album')
const Artist = require('./Artist')
const Playlist = require('./Playlist')
const PlaylistSong = require('./PlaylistSong')
const SongStat = require('./SongStat')
const Tag = require('./Tag')
const SongTag = require('./SongTag')

// 搜索相关模型
const SearchHistory = require('./SearchHistory')
const SearchTrend = require('./SearchTrend')

// 社交相关模型
const Comment = require('./Comment')
const Note = require('./Note')
const NoteImage = require('./NoteImage')
const Chat = require('./Chat')
const Message = require('./Message')

// 导出所有模型
const models = {
  User,
  UserFavorite,
  UserCollect,
  UserHistory,
  Follow,
  Like,
  Song,
  Album,
  Artist,
  Playlist,
  PlaylistSong,
  SongStat,
  Tag,
  SongTag,
  SearchHistory,
  SearchTrend,
  Comment,
  Note,
  NoteImage,
  Chat,
  Message
}

// 设置模型关联关系
const setupAssociations = () => {
  // 用户相关关系
  User.hasMany(UserFavorite, { foreignKey: 'user_id', as: 'favorites' })
  UserFavorite.belongsTo(User, { foreignKey: 'user_id', as: 'user' })
  
  // 用户收藏歌单关系
  User.hasMany(UserCollect, { foreignKey: 'user_id', as: 'collections' })
  UserCollect.belongsTo(User, { foreignKey: 'user_id', as: 'user' })
  
  // 用户播放历史关系
  User.hasMany(UserHistory, { foreignKey: 'user_id', as: 'playHistory' })
  UserHistory.belongsTo(User, { foreignKey: 'user_id', as: 'user' })
  
  // 用户关注关系
  User.hasMany(Follow, { foreignKey: 'follower_id', as: 'following' })
  User.hasMany(Follow, { foreignKey: 'followed_id', as: 'followers' })
  Follow.belongsTo(User, { foreignKey: 'follower_id', as: 'follower' })
  Follow.belongsTo(User, { foreignKey: 'followed_id', as: 'followed' })
  
  // 用户点赞关系
  User.hasMany(Like, { foreignKey: 'user_id', as: 'likes' })
  Like.belongsTo(User, { foreignKey: 'user_id', as: 'user' })
  
  // 音乐相关关系
  // 艺术家 - 歌曲关系
  Artist.hasMany(Song, { foreignKey: 'artist_id', as: 'songs' })
  Song.belongsTo(Artist, { foreignKey: 'artist_id', as: 'artist' })
  
  // 艺术家 - 专辑关系
  Artist.hasMany(Album, { foreignKey: 'artist_id', as: 'albums' })
  Album.belongsTo(Artist, { foreignKey: 'artist_id', as: 'artist' })
  
  // 专辑 - 歌曲关系
  Album.hasMany(Song, { foreignKey: 'album_id', as: 'songs' })
  Song.belongsTo(Album, { foreignKey: 'album_id', as: 'album' })
  
  // 用户 - 歌单关系
  User.hasMany(Playlist, { foreignKey: 'user_id', as: 'playlists' })
  Playlist.belongsTo(User, { foreignKey: 'user_id', as: 'creator' })
  
  // 歌单 - 歌曲关系（多对多）
  Playlist.belongsToMany(Song, { 
    through: PlaylistSong, 
    foreignKey: 'playlist_id',
    otherKey: 'song_id',
    as: 'songs'
  })
  Song.belongsToMany(Playlist, { 
    through: PlaylistSong, 
    foreignKey: 'song_id',
    otherKey: 'playlist_id',
    as: 'playlists'
  })
  
  // 歌单歌曲关联表的关系
  Playlist.hasMany(PlaylistSong, { foreignKey: 'playlist_id', as: 'playlistSongs' })
  PlaylistSong.belongsTo(Playlist, { foreignKey: 'playlist_id', as: 'playlist' })
  
  Song.hasMany(PlaylistSong, { foreignKey: 'song_id', as: 'playlistSongs' })
  PlaylistSong.belongsTo(Song, { foreignKey: 'song_id', as: 'song' })
  
  // 歌曲 - 统计关系
  Song.hasOne(SongStat, { foreignKey: 'song_id', as: 'stat' })
  SongStat.belongsTo(Song, { foreignKey: 'song_id', as: 'song' })
  
  // 歌曲 - 标签关系（多对多）
  Song.belongsToMany(Tag, { 
    through: SongTag, 
    foreignKey: 'song_id',
    otherKey: 'tag_id',
    as: 'tags'
  })
  Tag.belongsToMany(Song, { 
    through: SongTag, 
    foreignKey: 'tag_id',
    otherKey: 'song_id',
    as: 'songs'
  })
  
  // 用户行为关系
  User.hasMany(UserFavorite, { foreignKey: 'user_id', as: 'favoriteSongs' })
  Song.hasMany(UserFavorite, { foreignKey: 'song_id', as: 'favorites' })
  UserFavorite.belongsTo(Song, { foreignKey: 'song_id', as: 'song' })
  
  User.hasMany(UserCollect, { foreignKey: 'user_id', as: 'collectedPlaylists' })
  Playlist.hasMany(UserCollect, { foreignKey: 'playlist_id', as: 'collections' })
  UserCollect.belongsTo(Playlist, { foreignKey: 'playlist_id', as: 'playlist' })
  
  User.hasMany(UserHistory, { foreignKey: 'user_id', as: 'playedSongs' })
  Song.hasMany(UserHistory, { foreignKey: 'song_id', as: 'playHistory' })
  UserHistory.belongsTo(Song, { foreignKey: 'song_id', as: 'song' })
  
  // 搜索相关关系
  User.hasMany(SearchHistory, { foreignKey: 'user_id', as: 'searchHistory' })
  SearchHistory.belongsTo(User, { foreignKey: 'user_id', as: 'user' })
  
  // 社交相关关系
  // 用户 - 评论关系
  User.hasMany(Comment, { foreignKey: 'user_id', as: 'comments' })
  Comment.belongsTo(User, { foreignKey: 'user_id', as: 'user' })
  
  // 评论 - 回复关系（自关联）
  Comment.hasMany(Comment, { foreignKey: 'parent_id', as: 'replies' })
  Comment.belongsTo(Comment, { foreignKey: 'parent_id', as: 'parent' })
  
  // 用户 - 笔记关系
  User.hasMany(Note, { foreignKey: 'user_id', as: 'notes' })
  Note.belongsTo(User, { foreignKey: 'user_id', as: 'user' })
  
  // 歌曲 - 笔记关系
  Song.hasMany(Note, { foreignKey: 'song_id', as: 'notes' })
  Note.belongsTo(Song, { foreignKey: 'song_id', as: 'song' })
  
  // 笔记 - 图片关系
  Note.hasMany(NoteImage, { foreignKey: 'note_id', as: 'images' })
  NoteImage.belongsTo(Note, { foreignKey: 'note_id', as: 'note' })
  
  // 聊天相关关系
  User.hasMany(Chat, { foreignKey: 'user1_id', as: 'initiatedChats' })
  User.hasMany(Chat, { foreignKey: 'user2_id', as: 'receivedChats' })
  Chat.belongsTo(User, { foreignKey: 'user1_id', as: 'user1' })
  Chat.belongsTo(User, { foreignKey: 'user2_id', as: 'user2' })
  
  // 聊天 - 消息关系
  Chat.hasMany(Message, { foreignKey: 'chat_id', as: 'messages' })
  Message.belongsTo(Chat, { foreignKey: 'chat_id', as: 'chat' })
  
  // 用户 - 消息关系
  User.hasMany(Message, { foreignKey: 'sender_id', as: 'sentMessages' })
  Message.belongsTo(User, { foreignKey: 'sender_id', as: 'sender' })
}

// 初始化数据库
const initDatabase = async () => {
  try {
    // 建立模型关联关系
    setupAssociations()
    
    // 同步数据库
    await sequelize.sync({ alter: false })
    console.log('数据库同步完成')
    
    return true
  } catch (error) {
    console.error('数据库初始化失败:', error)
    return false
  }
}

module.exports = {
  sequelize,
  models,
  initDatabase,
  // 导出各个模型
  User,
  UserFavorite,
  UserCollect,
  UserHistory,
  Follow,
  Like,
  Song,
  Album,
  Artist,
  Playlist,
  PlaylistSong,
  SongStat,
  Tag,
  SongTag,
  SearchHistory,
  SearchTrend,
  Comment,
  Note,
  NoteImage,
  Chat,
  Message
} 