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
  }).then(function() {
    Parse.Cloud.useMasterKey();

    var userQuery = new Parse.Query(Parse.User);
    userQuery.find({
      success: function(userArr) {

        //console.log(contacts.length);

        for (var i = 0; i < userArr.length; i++) {          
          var u = userArr[i];
          //make sure current user is not included here
          if(u.id != userID){            
            var obj = {};
            obj.username = u.get("fullName") || "";
            obj.id = u.id;

            obj.email = u.get("email") || "";
            if(u.get('authData') && u.get('authData').facebook){
              obj.facebookID = u.get('authData').facebook.id;
            }else{
              obj.facebookID = "0";
            }
            
            twoByTwoUsers.push(obj);
          }          
        }

        var followersStr = followers.join();
        var contactsStr = contacts.join();

        for (var i = twoByTwoUsers.length - 1; i >= 0; i--) {
          //for (var j = contacts.length - 1; j >= 0; j--) {
            //if(contacts[j].email == twoByTwoUsers[i].email){
            if(contactsStr.indexOf(twoByTwoUsers[i].email) != -1){
              var following = false;
              if(followersStr.indexOf(twoByTwoUsers[i].id) != -1){
                following = true;
              }
              
              var obj ={name:twoByTwoUsers[i].username,parseID:twoByTwoUsers[i].id,facebookID:twoByTwoUsers[i].facebookID,following:following};
              items.push(obj);
            }
          //};
          
        };

        response.success(items);



      },
      error: function(error) {
        status.error(error.description);
      }
    });
  });

  
}