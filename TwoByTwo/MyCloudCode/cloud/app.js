var express = require('express');
var parseExpressCookieSession = require('parse-express-cookie-session');

var app = express();
var querystring = require('querystring');
var _ = require('underscore');
var Buffer = require('buffer').Buffer;
app.set('views', 'cloud/views');
//https://github.com/visionmedia/ejs
app.set('view engine', 'ejs');    
app.use(express.bodyParser());
//app.use(express.cookieParser('qlOiXmQEpBNU2i9Ictj0zfKtHlgTzCDm2c0uImMu'));
//app.use(parseExpressCookieSession({ cookie: { maxAge: 3600000 } }));

var indexController = require('cloud/routes/index.js');
var profileController2 = require('cloud/routes/profile2.js');
var pdpController2 = require('cloud/routes/pdp2.js');
var aboutController = require('cloud/routes/about.js');
var contactController = require('cloud/routes/contact.js');
var termsController = require('cloud/routes/terms.js');
var locationsController = require('cloud/routes/locations.js');
var locationsController2 = require('cloud/routes/locations2.js');
var featuredController = require('cloud/routes/featured.js');
var imageController = require('cloud/routes/img.js');
var hashtagController = require('cloud/routes/hashtag.js');
var feedController = require('cloud/routes/feed.js');
var topUsersController = require('cloud/routes/topUsers.js');
var topLikesController = require('cloud/routes/topLikes.js');
var usernamesController = require('cloud/routes/usernames.js');


var auth = express.basicAuth('admin', 'Nelson12345');
//app.get('/locations',auth,locationsController2.index);

app.get('/', indexController.index);
app.get('/index', indexController.index);
app.get('/profile', profileController2.index);
app.get('/profile/:u', profileController2.withUserID);
app.get('/pdp', pdpController2.index);
app.get('/pdp/:id', pdpController2.index);
app.get('/about', aboutController.index);
app.get('/contact', contactController.index);
app.get('/terms', termsController.index);
app.get('/locations2',locationsController.index);
app.get('/locations',locationsController2.index);
app.get('/featured',featuredController.index);
app.get('/img',imageController.index);
app.get('/hashtag/:hash',hashtagController.index);
app.get('/feed/:type',feedController.index);
app.get('/feed/:type/:extra',feedController.index);

app.get('/topUsers',auth,topUsersController.index);
app.get('/topLikes',auth,topLikesController.index);

app.get('/usernames',usernamesController.index);


//Logon github test
//var Github = require('cloud/Github.js');
//Github.init(app); 

//Logon linkedIn test
//var LinkedIn = require('cloud/LinkedIn.js');
//LinkedIn.init(app);

//Logon twitter
var Twitter = require('cloud/Twitter.js');
Twitter.init(app);  

app.listen();




