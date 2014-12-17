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
    //userQuery.limit(1000);

    userQuery.each(function(u) {

          //make sure current user is not included here
          if(u.id != userID){
            var hasFB = false;

            if(u.get('authData') && u.get('authData').facebook){
              hasFB = true;
            }

            var obj;

            if(hasFB){
              obj = {username:u.get("fullName"),id:u.id,email:u.get("email"),facebookID:u.get('authData').facebook.id};
            }else{
              obj = {username:u.get("fullName"),id:u.id,email:u.get("email"),facebookID:"",twitterProfileImage:u.get("twitterProfileImage")};
              //get("twitterProfileImage")
            }
            
            twoByTwoUsers.push(obj);
          }          

    }).then(function() {
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

              var obj;
              
              if(twoByTwoUsers[i].twitterProfileImage){
                obj ={name:twoByTwoUsers[i].username,parseID:twoByTwoUsers[i].id,facebookID:twoByTwoUsers[i].facebookID,following:following,twitterProfileImage:twoByTwoUsers[i].twitterProfileImage};

              }else{
                obj ={name:twoByTwoUsers[i].username,parseID:twoByTwoUsers[i].id,facebookID:twoByTwoUsers[i].facebookID,following:following};

              }

              //var obj ={name:twoByTwoUsers[i].username,parseID:twoByTwoUsers[i].id,facebookID:twoByTwoUsers[i].facebookID,following:following};
              items.push(obj);
            }
          //};
          
        };

        response.success(items);

    })

    });

  
}