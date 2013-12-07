var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  var userID = request.params.userID;
  var newRegisteredUser_username = request.params.username;
  
  var counter = 0;
  

  var userQuery = new Parse.Query(Parse.User);
  
  userQuery.find({
          success: function(arr) {
            
            for (var i = 0; i < arr.length; i++) {
              var user = arr[i];
              var currentUser_fullName = user.get("fullName");
              

              (function(index, indexOfLastPush, _user) {
                //don't run this for the user that just registered
                if(_user.id != userID){
                    var url = 'https://graph.facebook.com/'+user.get('authData').facebook.id+'/friends?access_token='+user.get('authData').facebook.access_token;
                    //var url =  "https://graph.facebook.com/"+user.get('authData').facebook.id+"?fields=friends.fields(name)&access_token="+user.get('authData').facebook.access_token;

                    




                    Parse.Cloud.httpRequest({
                      url:url,
                      success:function(httpResponse){
                        
                        counter++;

                        console.log(_user.get("fullName")+" / "+counter + " / " + indexOfLastPush);

                        var facebookFriends = httpResponse.data.data;

                        for (var i = facebookFriends.length - 1; i >= 0; i--) {
                          var n1 = facebookFriends[i].name;

                          if(newRegisteredUser_username == n1){
                            //send email/notification to current user letting them know their friend just joined 2by2
                            var msg = _user.get("fullName") + ", "+ newRegisteredUser_username + " just joined 2by2!!";
                            console.log(msg);
                            Notifications.sendPush(_user.id,msg);//
                            break;                            
                          }                         
                        };

                        if(index == indexOfLastPush){
                          //console.log("counter: "+counter+" / "+index+ " / " + indexOfLastPush);
                          response.success("Total users: "+indexOfLastPush);
                        }                             
                      },
                      error:function(httpResponse){
                        console.log(httpResponse);
                      }
                    });

                                   
                }
              })(i,arr.length-2,arr[i]);
            };
          },
          error: function(error) {
            console.log(error);
          }
  }).then(function() {
    //response.success("counter: "+counter);
  });  
}