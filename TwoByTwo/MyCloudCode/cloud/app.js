var express = require('express');
var parseExpressCookieSession = require('parse-express-cookie-session');

var app = express();
app.set('views', 'cloud/views');
//https://github.com/visionmedia/ejs
app.set('view engine', 'ejs');    
app.use(express.bodyParser());
app.use(express.cookieParser('qlOiXmQEpBNU2i9Ictj0zfKtHlgTzCDm2c0uImMu'));
app.use(parseExpressCookieSession({ cookie: { maxAge: 3600000 } }));

var indexController = require('cloud/routes/index.js');
var profileController = require('cloud/routes/profile.js');
var profileController2 = require('cloud/routes/profile2.js');
var pdpController = require('cloud/routes/pdp.js');
var pdpController2 = require('cloud/routes/pdp2.js');

app.get('/', indexController.index);
app.get('/profile', profileController.index);
app.get('/profile2', profileController2.index);
app.get('/pdp', pdpController.index);
app.get('/pdp2', pdpController2.index);



 


 
// Making a "login" endpoint is SOOOOOOOO easy.
app.post("/login", function(req, res) {
  Parse.User.logIn(req.body.username, req.body.password).then(function() {
    // Login succeeded, redirect to homepage.
    // parseExpressCookieSession will automatically set cookie.
    res.redirect('/');
  },
  function(error) {
    // Login failed, redirect back to login form.
    res.redirect("/login");
  });
});


app.listen();


