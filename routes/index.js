var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Oh, Express-ioh is running...' });
});

router.get('/hello', function(req, res, next) {
  res.render('index', { title: 'This is a sample application that shows a way to encrypt/decrypt Sql Server data at column level.' });
});

module.exports = router;
