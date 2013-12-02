exports.main = function(request, response){
  var contacts = request.params.contacts;
  var userID = request.params.userID;
  var items = [];
  var followers = [];
  var twoByTwoUsers = [];

  var followQuery = new Parse.Query("Followers");
  followQuery.equalTo("userID", userID);
  followQuery.each(function(f) {
    followers.push(f.get("followingUserID"));
  });

  Parse.Cloud.useMasterKey();

  var userQuery = new Parse.Query(Parse.User);
  userQuery.find({
    success: function(userArr) {

      //console.log(contacts.length);

      for (var i = 0; i < userArr.length; i++) {
        var u = userArr[i];
        var obj = {username:u.get("fullName"),id:u.id,email:u.get("email"),facebookID:u.get('authData').facebook.id};
        twoByTwoUsers.push(obj);
      }

      var followersStr = followers.join();

      for (var i = contacts.length - 1; i >= 0; i--) {
        for (var j = twoByTwoUsers.length - 1; j >= 0; j--) {
          if(contacts[i].email == twoByTwoUsers[j].email){
            var following = false;
            if(followersStr.indexOf(twoByTwoUsers[j].id) != -1){
              following = true;
            }
            
            var obj ={name:twoByTwoUsers[j].username,parseID:twoByTwoUsers[j].id,facebookID:twoByTwoUsers[j].facebookID,following:following};
            items.push(obj);
          }
        };
        
      };

      response.success(items);



    },
    error: function(error) {
      status.error(error.description);
    }
  });
}