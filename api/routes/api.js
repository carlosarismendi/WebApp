const router = require('express').Router();
const middleware = require('./middleware');

const apiRegister = require('./controllers/RegisterController');
const apiLogin = require('./controllers/LoginController');
const apiVisibilityType = require('./controllers/VisibilityTypeController');

const apiUser = require('./controllers/UserController')
const apiFollows = require('./controllers/FollowController')
const apiPosts = require('./controllers/PostController')
const apiPrivacy = require('./controllers/PrivacyController')
const apiNotification = require('./controllers/NotificationController')

// Public controllers
router.use('/registers', apiRegister);
router.use('/login', apiLogin);
router.use('/visibility-types', apiVisibilityType);

// Private controllers
router.use('/users', middleware.checkToken, apiUser);
router.use('/follows', middleware.checkToken, apiFollows);
router.use('/posts', middleware.checkToken, apiPosts);
router.use('/privacy', middleware.checkToken, apiPrivacy);
router.use('/notifications', middleware.checkToken, apiNotification);

module.exports = router;
