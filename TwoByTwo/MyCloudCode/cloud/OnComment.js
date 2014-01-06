var Notifications = require('cloud/Notifications.js');

function notifyUser(response,photo,user_id,photoUsername,comment,isYourPhoto){
  var commentID = comment.get("commentID");
  var userID = comment.get("userID");
  var username = comment.get("username");
  
  
  var url;

  if(photo.get("state") == "full"){
    url = photo.get("image_full")._url;
  }else{
    url = photo.get("image_half")._url;
  }
  

  
  //TODO: add location and distance
  var msg = username+", just left a comment on your photo.";

  if(!isYourPhoto){
    msg = username+", just left a comment.";
  }

  //if I comment on my own photo it should not send me a notification
  if(photoUsername != username){
      
      //Notifications.sendPush(user.id,msg,commentID);
      var htmlMsg = msg+ "<br><img src='"+ url + "'></img>";
      var subject = "2by2 - your photo was just commented by "+ username;

      //Notifications.sendMail(msg,htmlMsg,subject, photoUsername,email);

      Notifications.sendNotifications(response,"comment",user_id,msg,htmlMsg,subject,commentID,"",userID,username,msg);
          
  }
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
      notifyUser(response,photo,user.id,photo.get("username"),comment,true);

      var photoUserID_full;

      if(photo.get("state") == "full"){
        var user_full = photo.get("user_full");
        photoUserID_full = user_full.id;
        notifyUser(response,photo,user_full.id,photo.get("username"),comment,true);
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
            var username = c.get("username");
            
            //don't send it to person liking the photo or person who took the photo (since he/she is already getting a notification)
            if(c.get("userID") != userID && c.get("userID") != photoUserID &&  c.get("userID") != photoUserID_full){
              var obj = {};
              obj.id = c.get("userID");
              obj.username = username;
              uniqueUsers.pushUnique(obj);
            }
            
          };

          for (var i = uniqueUsers.length - 1; i >= 0; i--) {        
            notifyUser(response,photo,uniqueUsers[i].id,photo.get("username"),c,false);
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