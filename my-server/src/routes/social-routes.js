const Router = require('koa-router')
const SocialController = require('../controllers/social-controller')
const { auth, optionalAuth } = require('../middleware/auth')

const router = new Router()

/**
 * 社交相关路由
 */

// 关注功能
router.post('/follow/:userId', auth, SocialController.followUser)
router.post('/unfollow/:userId', auth, SocialController.unfollowUser)
router.get('/following/:userId', optionalAuth, SocialController.getFollowingList)
router.get('/followers/:userId', optionalAuth, SocialController.getFollowersList)
router.get('/follow-stats/:userId', optionalAuth, SocialController.getUserFollowStats)
router.get('/check-following/:userId', auth, SocialController.checkFollowing)
router.get('/mutual-friends', auth, SocialController.getMutualFriends)

// 点赞功能
router.post('/like', auth, SocialController.addLike)
router.post('/unlike', auth, SocialController.removeLike)
router.get('/likes', auth, SocialController.getUserLikes)
router.post('/batch-check-liked', auth, SocialController.batchCheckLiked)
router.post('/like-stats', optionalAuth, SocialController.getLikeStats)

// 评论功能
router.get('/comments', optionalAuth, SocialController.getCommentList)
router.post('/comment', auth, SocialController.addComment)
router.post('/comment/delete/:id', auth, SocialController.deleteComment)

// 聊天功能
router.get('/chat/list', auth, SocialController.getChatList)
router.get('/chat/:userId', auth, SocialController.getChatMessages)
router.post('/chat/:userId/send', auth, SocialController.sendMessage)

module.exports = router 