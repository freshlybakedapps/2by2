exports.main = function(request, response){
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  var twitterFriends = request.params.twitterFriends;
 
  var twoByTwoUsers = [];

  var userQuery = new Parse.Query(Parse.User);  
  userQuery.exists("twitterId");

  userQuery.find({
      success: function(userArr) {
        var twitterFriendsStr = twitterFriends.join();
        
        for (var i = 0; i < userArr.length; i++) {
        	var twitterId = userArr[i].get("twitterId");

        	if(twitterFriendsStr.indexOf(twitterId) != -1){             
		  		var obj = {twitterProfileImage:userArr[i].get("TwitterProfileImage"),twitterId:twitterId,name:userArr[i].get("fullName"),id:userArr[i].id};
		    	twoByTwoUsers.push(obj);
			}		  	   
        }

        response.success(twoByTwoUsers);
      },
      error: function(error) {
        response.error(error.description);
      }
    });
}
