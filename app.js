var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

var indexRouter = require('./routes/index');
var customersRouter = require('./routes/customers');
const { google } = require('googleapis');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
// app.set('view engine', 'jade');
app.set("view engine", "pug");

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

const oauth2Client = new google.auth.OAuth2(
  '87516391107-nibgp4e2onvh3ba7f06ba7sp8fa606h5.apps.googleusercontent.com',
  'VcZqrykqYys-R6zKH4DTQESP',
  'http://localhost:3000/home'
)

const redirectUrl = oauth2Client.generateAuthUrl({
  access_type : 'offline',
  prompt: 'consent',
  scope: ['https://www.googleapis.com/auth/userinfo.profile','https://www.googleapis.com/auth/userinfo.email']
})

let auth = false;
app.get("/", async (req, res) => {
  let oauth2 = google.oauth2({version: 'v2',auth: oauth2Client});
  if (auth){
    let userInfo = await oauth2.userinfo.v2.me.get();
    res.render("home", {buttonSpan: 'Sign Out',url:'http://localhost:3000/logout',userInfo: userInfo.data, title: "Home" });
  }
  else {
    res.render("index", {buttonSpan: 'Sign In', url: redirectUrl, userInfo : {}, title: "Authentication"})
  }
});

// app.get("/home", async (req, res) => {
//   res.render("home", {title: "Home"})
// });

app.get('/home', async function (req, res) {
  const code = req.query.code;
  if (code) {
      const {tokens} = await oauth2Client.getToken(code);
      oauth2Client.setCredentials(tokens);
      auth = true;
  }
  res.redirect('/');
});

app.get('/logout', (req, res) => {
  oauth2Client.revokeCredentials().then(r => console.log('revoke ', r));
  auth = false;
  res.redirect('/');
});

app.use('/api', indexRouter);
app.use('/api/customers', customersRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});



module.exports = app;
