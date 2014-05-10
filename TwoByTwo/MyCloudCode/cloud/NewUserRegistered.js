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

              //console.log("access_token: "+user.get('authData').facebook.access_token);
              

              (function(index, indexOfLastPush, _user) {
                //don't run this for the user that just registered
                //if(_user.id != userID){
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
                            
                            var msg = "Sneak attack!, your friend "+newRegisteredUser_username+" just joined 2by2.";
                            var subject = msg;
                            var htmlMsg = "Your friend " + newRegisteredUser_username + ", just joined the party.";  
                            
                            htmlMsg += "<br><a href='http://www.2by2app.com/pdp?profile="+_user.id+"'>Check out their profile</a>";

                            htmlMsg += "<br><br>";
                            htmlMsg += "Thanks,";
                            htmlMsg += "<br>Team 2by2";
                            htmlMsg += "<br>PS: To stop receiving this email, turn this notification off in the app settings page.";


                            console.log(msg);

                            Notifications.sendNotifications(null,"newUser",_user.id,msg,htmlMsg,subject,"0","",userID,newRegisteredUser_username,msg);

                            //Notifications.addNotification(_user.id,"0","newUser",userID,newRegisteredUser_username,"",msg);



                            //Notifications.sendPush(_user.id,msg,"0");//userID,msg,photoID
                            break;                            
                          }                         
                        };

                        if(index == indexOfLastPush){
                          //console.log("counter: "+counter+" / "+index+ " / " + indexOfLastPush);
                          //response.success("Total users: "+indexOfLastPush);
                        }                             
                      },
                      error:function(httpResponse){
                        console.log(_user.get("fullName")+" error: "+httpResponse);
                      }
                    });

                                   
                //}
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