var express = require('express');
var router = express.Router();
const sqldb = require('mssql/msnodesqlv8');

const activedirectory = require('./authn');


// config for your database
const config = {
    user: '',
    password: '',
    server: 'STDLHVY5K13\\SQLEXPRESS', 
    database: 'StudentLoans',
    driver: 'msnodesqlv8',
    options: {
      trustedConnection : false
    } 
};
    
/* GET customers listing. */
router.get('/all/:email', function(req, res, next) {

  var sql = "SELECT borrower_id, full_name,";
  //var sql = "SELECT borrower_id, full_name,sin_encrypt AS 'Encrypted data',";
  sql += "CONVERT(varchar, DecryptByKey(sin_encrypt)) AS 'sin'";
  sql += " FROM StudentLoans.dbo.CustomerInfo;" 

  var userEmail = req.params.email;
  if (userEmail === undefined){
    // user is not authenticated
    res.status(500).json({response : {error:"user not authenticated"}});
  }

  // get User and its Permission from directory
  var selectedEntry = activedirectory.profiles.find(x => x.email === userEmail);
  if (selectedEntry === undefined){
    // res.status(500).json({response : {error:"user not accepted"}});
    res.status(500).json(
      {
        response : {
          error:"user not accepted",
          user: {
            email: '',
            group: '',
            role : '',
            org : '',
            tenant: '',
            permission : ''
          }
        }
      });
  };
  
  var userGroup = activedirectory.users.find(x => x.user === selectedEntry.user).group;
  var userRole = activedirectory.users.find(x => x.user === selectedEntry.user).role;
  var userOrg = activedirectory.users.find(x => x.user === selectedEntry.user).org;
  var userTenant = activedirectory.users.find(x => x.user === selectedEntry.user).tenant;
  var permission = activedirectory.users.find(x => x.user === selectedEntry.user).permission;

  //var permission = req.header('Permission');
  if (permission === undefined)
  {
    // user is not authenticated
    res.status(500).json(
    {
      response : {
        error:"permission not provided",
        user: {
          email: userEmail,
          group: userGroup,
          role : userRole,
          org : userOrg,
          tenant: userTenant,
          permission : ''
        }
      }
    });
  }

  if (!(activedirectory.permissions.find(x => x.permission === permission) === undefined)){
    // user in group is authorized to have access to data, but will see SIN# based on its permission
    // get user role and password and update Config settings
    config.user = activedirectory.permissions.find(x => x.permission === permission).permission;
    config.password = activedirectory.permissions.find(x => x.permission === permission).password;
    var pool = new sqldb.ConnectionPool(config);
    pool.connect().then(() => {
      var sqlkey = "OPEN SYMMETRIC KEY SymKey_test DECRYPTION BY CERTIFICATE Certificate_test";
      pool.request().query(sqlkey,(err) => {
        if (err){
          //res.status(500).json({response: {error:err.message}});
          res.status(500).json(
            {
              response : {
                error:`Error: ${err.message} * Running Query: ${sql}`,
                user: {
                  email: userEmail,
                  group: userGroup,
                  role : userRole,
                  org : userOrg,
                  tenant: userTenant,
                  permission : permission
                }
              }
            });
          sqldb.close()
        }
        else {
          pool.request().query(sql,(err,result) => {
            if (err) 
              //res.status(500).json({response: {error:err}});
              res.status(500).json(
                {
                  response : {
                    error:err,
                    user: {
                      email: userEmail,
                      group: userGroup,
                      role : userRole,
                      org : userOrg,
                      tenant: userTenant,
                      permission : permission
                    }
                  }
                });
            else {
              // return res.json({
              //   response : {data : result.recordset}
              // })
              res.status(200).json(
                {
                  response : {
                    data: result.recordset,
                    user: {
                      email: userEmail,
                      group: userGroup,
                      role : userRole,
                      org : userOrg,
                      tenant: userTenant,
                      permission : permission
                    }
                  }
                });
            }
            sqldb.close()
          });
        }
      })
    })
  }
  else {
      // user's provided role is not authorized to access data
      //res.status(500).json({response: {error:"permission not authorized to query data"}});
      res.status(500).json(
        {
          response : {
            error: "permission not authorized to query data",
            user: {
              email: userEmail,
              group: userGroup,
              role : userRole,
              org : userOrg,
              tenant: userTenant,
              permission : permission
            }
          }
        });
  }
  console.log('ending sqldb connection');
});

module.exports = router;
