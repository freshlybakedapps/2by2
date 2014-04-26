var Notifications = require('cloud/Notifications.js');
var CopyManager = require('cloud/CopyManager.js');

function notifyUser(response,photo,user_id,photoUsername,comment,isYourPhoto){
  var commentID = comment.get("commentID");
  var userID = comment.get("userID");
  var username = comment.get("username");
  var commentText = comment.get("text");
  
  var msg;
  var htmlMsg;
  
  if(isYourPhoto == true){
    msg = CopyManager.getCopy(CopyManager.friend_left_comment_your_photo, {"username":username});
    htmlMsg = "<b>"+username +"</b> said: '"+ commentText + "'";
  }else{
    msg = CopyManager.getCopy(CopyManager.friend_left_comment, {"username":username});
    htmlMsg = "Your friend " + username + ", just joined the conversation, he said:'"+ commentText + "'";
  }
  
  htmlMsg += "<br><a href='http://www.2by2app.com/pdp/"+commentID+"'>See photo.</a>";
  htmlMsg += "<br><br>";
  htmlMsg += "Thanks,";
  htmlMsg += "<br>Team 2by2";
  htmlMsg += "<br>PS: To stop receiving this email, turn this notification off in the app settings page.";

  var subject = msg;

  Notifications.sendNotifications(response,"comment",user_id,msg,htmlMsg,subject,commentID,"",userID,username,msg);
}

exports.main = function(request, response){
  var comment = request.object;
  var objid = comment.id;
  
  //commentID and photoID are the same
  //so I can use this ID to get info about the photo or comment associated with that photo
  var commentID = comment.get("commentID");
  var userID = comment.get("userID");
  var username = comment.get("username");
  var commentText = comment.get("text");

  console.log("objid: "+objid);




  
  /*
  comment[@"text"] = t;
  comment[@"username"] = u;
  comment[@"commentID"] = c;
  comment[@"facebookId"] = fb;
  comment[@"userID"] = userID;
  */

  var query = new Parse.Query("Photo");
  query.include("user");
  query.include("user_full");  

  query.get(commentID, {
    success: function(photo) {    
      var user = photo.get("user");
      
      var photoUserID = user.id;

      var mentionArray = commentText.match(/(:\/\/|>)?(@([_a-z0-9\-]+))/gi);

      if(mentionArray.length > 0){
        for (var i = mentionArray.length - 1; i >= 0; i--) {
          var mention = mentionArray[i].replace("#","");
          
          var msg = username + " just mentioned you on a photo.";
          
          Notifications.sendNotifications(null,"comment",photoUserID,msg,msg,msg,commentID,"",userID,username,msg);
        };
      }


      //if we need to know if commenter is a facebook friend

      /*
      Parse.Cloud.run('getFacebookFriends', { user: photoUserID }, {
        success: function(arr) {
          var isFBfriend = false;
          for (var i = arr.length - 1; i >= 0; i--) {
            if(arr[i].parseID == userID){
              isFBfriend = true;
            }
          };

          if(isFBfriend){
            //notifyUser(response,photo,photoUserID,photo.get("username"),comment,true);
          }else{
            //notifyUser(response,photo,photoUserID,photo.get("username"),comment,true);
          }

        },
        error: function(error) {
          console.log(error);
        }
      });
      */

      //if we need to know if commenter is someone you follow

      /*
      var followQuery = new Parse.Query("Followers");
      followQuery.equalTo("userID", userID);
      followQuery.equalTo("followingUserID", photoUserID);      
      
      followQuery.find({
        success: function(arr) {
          if(arr.length > 0){
            //notifyUser(response,photo,photoUserID,photo.get("username"),comment,true);
          }else{
            //notifyUser(response,photo,photoUserID,photo.get("username"),comment,true);
          }

          
        },
        error: function(error) {      
            console.log('error: ' + error);
        }
      });
      */ 

      
      //inform the 1st photographer (if he is not the one commenting)
      if(userID != photoUserID){
        notifyUser(null,photo,photoUserID,user.get("username"),comment,true);
      }

      

      var photoUserID_full;

      if(photo.get("state") == "full"){
        var user_full = photo.get("user_full");
        photoUserID_full = user_full.id;

        //inform the 2nd photographer (if he is not the one commenting)
        if(userID != photoUserID_full){
          notifyUser(null,photo,user_full.id,user.get("username"),comment,true);
        }

        
      }else{
        photoUserID_full = photoUserID;
      }

      var commentQuery = new Parse.Query("Comment");
      commentQuery.equalTo("commentID", commentID);
      //send a notification to every person that has also commented on this thread
      commentQuery.find({
        success: function(commentArray) {
          var uniqueUsers = [];
          for (var i = commentArray.length - 1; i >= 0; i--) {
            var c = commentArray[i];
           
            
            //don't send it to person commenting on the photo or person who took the photo (since he/she is already getting a notification)
            if(c.get("userID") != userID && c.get("userID") != photoUserID &&  c.get("userID") != photoUserID_full){
              var obj = {};
              obj.id = c.get("userID");
              obj.username = c.get("username");
              uniqueUsers.pushUnique(obj);
            }
            
          };

          for (var i = uniqueUsers.length - 1; i >= 0; i--) {        
            notifyUser(null,photo,uniqueUsers[i].id,username,comment,false);
            //Notifications.sendPush(uniqueUsers[i].id,uniqueUsers[i].username+" - You have a new comment - "+commentText,commentID);
          };
        
              
        },
        error: function(error) {      
            response.error('error: ' + error);
        }
      }); 
      
    },
    error: function(error) {
        console.log("Got an error " + error);
        //response.error(error);
    }
  });


  
}


Array.prototype.pushUnique = function (item){
    if(this.indexOf(item) == -1) {    
        this.push(item);
        return true;
    }
    return false;
}