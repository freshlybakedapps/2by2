var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
  var comment = request.object;
  var objid = comment.id;
  var commentID = comment.get("commentID");
  var userID = comment.get("userID");

  console.log("objid: "+objid);

  var query = new Parse.Query("Comment");
  query.equalTo("commentID", commentID);
  /*
  comment[@"text"] = t;
  comment[@"username"] = u;
  comment[@"commentID"] = c;
  comment[@"facebookId"] = fb;
  comment[@"userID"] = userID;
  */
  query.find({
    success: function(commentArray) {
      var uniqueUsers = [];
      for (var i = commentArray.length - 1; i >= 0; i--) {
        var c = commentArray[i];
        var username = c.get("username");
        if(c.get("userID") != userID){
          var obj = {};
          obj.id = c.get("userID");
          obj.username = username;
          uniqueUsers.pushUnique(obj);
        }
        
      };

      for (var i = uniqueUsers.length - 1; i >= 0; i--) {        
        Notifications.sendPush(uniqueUsers[i].id,uniqueUsers[i].username+" - You have a new comment",commentID);
      };
    
          
    },
    error: function(error) {      
        response.error('error: ' + error);
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