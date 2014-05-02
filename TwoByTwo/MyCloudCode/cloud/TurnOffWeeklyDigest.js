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
        status.success('TurnOffWeeklyDigest success- '+ counter+" / "+count);
      }

      var promises = [];
      _.each(users, function(user) {
        user.set("digestEmailAlert", false);
        user.save(null, {
            success: function (n) {
                //console.log("Save ok");
                counter++;
            },
            error: function (item,error) {
                console.log("Save error: " + error.message);
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