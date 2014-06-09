var _ = require('underscore.js');

var counter = 0;


exports.main = function(request, status) {
    Parse.Cloud.useMasterKey();
    var query = new Parse.Query(Parse.User);    

    query.count({
        success: function(count) {          
          main(request, status,count,0);
              
        },
        error: function(error) {
            console.log("Uh oh, something went wrong.");
        }
    });

    
}

function main(request, status,count,skip) {
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  //query.exists("email");
  //query.equalTo("digestEmailAlert", true);  
  query.limit(1000);
  query.skip(skip);
  
  //http://stackoverflow.com/questions/22275508/parse-com-cloud-job-promise-with-nested-query
  
  query.find().then(function(users) {
      if(users.length == 0){
        status.success('FixUserName success- '+ counter+" / "+count);
      }

      var promises = [];
      _.each(users, function(user) {
        var username = user.get("username");

        username = username.replace(".","");
        username = username.replace(" ","");


        user.set("username", username);
        user.save(null, {
            success: function (n) {
                //console.log("Save ok");
                counter++;
            },
            error: function (item,error) {
                console.log("FixUserNames Save error: " + error.message);
            }
        });          
      });
      return Parse.Promise.when(promises);
  })
  .then(function() {
      //status.success('WeeklyDigest successfully sent. - '+ counter);
      main(request, status,count,skip+1000)
  });
  

  
}