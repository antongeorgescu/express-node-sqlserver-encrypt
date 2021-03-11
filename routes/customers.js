var express = require('express');
var router = express.Router();
const sqldb = require('mssql/msnodesqlv8');

const authnpermissions = require('./authn');


// config for your database
const config = {
    user: 'csr',
    password: 'reporter@1',
    server: 'STDLHVY5K13\\SQLEXPRESS', 
    database: 'StudentLoans',
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
  sql += " FROM StudentLoans.dbo.CustomerInfo;" 

  var permission = req.header('Permission');
  if (permission === undefined){
    // user is not authenticated
    res.status(500).json({"error":"permission not provided"});
  }

  if (!(authnpermissions.permissions.find(x => x.permission === permission) === undefined)){
    // user in group is authorized to have access to data, but will see SIN# based on its permission
    // get user role and password and update Config settings
    config.user = authnpermissions.permissions.find(x => x.permission === permission).permission;
    config.password = authnpermissions.permissions.find(x => x.permission === permission).password;
    var pool = new sqldb.ConnectionPool(config);
    pool.connect().then(() => {
      var sqlkey = "OPEN SYMMETRIC KEY SymKey_test DECRYPTION BY CERTIFICATE Certificate_test";
      pool.request().query(sqlkey,(err) => {
        if (err){
          res.status(500).json({"error":err.message});
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
    })
  }
  else {
      // user's provided role is not authorized to access data
      res.status(500).json({"error":"permission not authorized to query data"});
  }
  console.log('ending sqldb connection');
});

module.exports = router;
