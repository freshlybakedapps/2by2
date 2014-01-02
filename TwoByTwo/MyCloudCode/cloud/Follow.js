var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
  var userID = request.params.userID;
  var username = request.params.username;
  var followingUserID = request.params.followingUserID;  
  
  var followQuery = new Parse.Query("Followers");
  followQuery.equalTo("userID", userID);
  followQuery.equalTo("followingUserID", followingUserID);

  var phrases = ["You must be good looking!", "No pressure!", "We did not see that one coming ;)", "Kids these days!", "YAY, mashed potatoes, no gravy!", "I bet is that new haircut.", "It's going to be an awesome day.", "BTW, that color looks great on you."];

  followQuery.find({
  success: function(arr) {
    console.log(arr.length);
    if(arr.length < 1){
      var Followers = Parse.Object.extend("Followers");
      var followers = new Followers();
      followers.set("userID", userID);
      followers.set("followingUserID", followingUserID);

      followers.save(null, {
        success: function(follower) {
          
          Parse.Cloud.useMasterKey();
          
          var query = new Parse.Query(Parse.User);      
          query.get(followingUserID, {
            success: function(user) {
              var email = user.get("email");
              
              var followsEmailAlert = user.get("followsEmailAlert");
              var followsPushAlert = user.get("followsPushAlert");
              var msg = "Hi "+user.get("username")+", "+username+" started to follow you on 2by2. " + phrases[Math.floor(Math.random()*phrases.length)];
              var subject = "2by2 - new follower";

              Notifications.sendNotifications(response,"follow",user.id,msg,msg,subject,"0","",userID,username,msg);

              /*
              if(followsPushAlert == true){
                Notifications.sendPush(user.id,msg);
              }

              if(followsEmailAlert == true){
                Notifications.sendMail(msg,msg,subject, username,email);
              }
              */
              //response.success(true);
            },
            error: function(error) {
              console.error("Got an error " + error.code + " : " + error.message);
              //response.error(error);
            }
          });

          
        },
        error: function(follower, error) {      
          response.error('Failed to create new object, with error code: ' + error.description);
        }
      });
    }else{
      //unfollow
      arr[0].destroy({
          success:function() {
               response.success(false);
          },
          error:function(error) {
               response.error('Could not delete object.');
          }
     });
      
    }
  },

  error: function(error) {
    response.error(error.description);
  }
});
}