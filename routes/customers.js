var express = require('express');
var router = express.Router();
const sqldb = require('mssql/msnodesqlv8');

const authnusers = require('./authn');


// config for your database
const config = {
    user: 'alv***',
    password: '***',
    server: 'STDLHVY5K13\\SQLEXPRESS', 
    database: 'CustomerData',
    driver: 'msnodesqlv8',
    options: {
      trustedConnection : false
    } 
};
    
/* GET customers listing. */
router.get('/all', function(req, res, next) {
  var sql = "SELECT borrower_id, full_name,";
  //var sql = "SELECT borrower_id, full_name,sin_encrypt AS 'Encrypted data',";
  sql += "CONVERT(varchar, DecryptByKey(sin_encrypt)) AS 'SIN#'";
  sql += " FROM CustomerData.dbo.CustomerInfo;" 

  var username = req.header('Username');
  var sqlkey = null;
  if (username === undefined){
    // user is not authenticated
    res.status(500).json({"error":"user not authenticated"});
  }

  var pool = new sqldb.ConnectionPool(config);
  pool.connect().then(() => {
    if (authnusers.users.includes(username)){
      // user is authorized to see SIN#
      var sqlkey = "OPEN SYMMETRIC KEY SymKey_test DECRYPTION BY CERTIFICATE Certificate_test";
      pool.request().query(sqlkey,(err) => {
        if (err){
          res.status(500).json({"error":err});
          sqldb.close()
        }
        else {
          pool.request().query(sql,(err,result) => {
            if (err) 
              res.status(500).json({"error":err});
            else {
              return res.json({
                data : result.recordset
              })
            }
            sqldb.close()
          });
        }
      })
    }
    else {
        // user is not authorized to see SIN#
        pool.request().query(sql,(err,result) => {
          if (err) 
            res.status(500).json({"error":err});
          else {
            return res.json({
              data : result.recordset
            })
          }
          sqldb.close()
        });
    }
    console.log('ending sqldb connection');
  });
});

module.exports = router;
