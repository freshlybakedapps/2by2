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
          
          var msg = username+" started to follow you on 2by2. " + phrases[Math.floor(Math.random()*phrases.length)];
          var htmlMsg = "See "+username+"’s profile.";
          htmlMsg += "<br><br>";
          htmlMsg += "Thanks,";
          htmlMsg += "<br>Team 2by2";
          htmlMsg += "<br>PS: To stop receiving this email, turn this notification off in the app settings page.";


          var subject = username+ " started to follow you on 2by2";

          Notifications.sendNotifications(response,"follow",followingUserID,msg,htmlMsg,subject,"0","",userID,username,msg);

          
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