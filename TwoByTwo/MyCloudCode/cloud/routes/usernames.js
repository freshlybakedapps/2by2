exports.index = function(req, resp){
	var User = Parse.Object.extend("User");
    var query = new Parse.Query(User);

    var usernames = [];

    query.each(
        function(result){
            var obj = {};
            obj.name = result.get("username");
            if(result.get("facebookId") && result.get("facebookId") != ""){
            	obj.avatar = "https://graph.facebook.com/"+result.get("facebookId")+"/picture?type=square&width=60&height=60";
				obj.type = "Facebook";
			}else{
				obj.avatar = result.get("TwitterProfileImage");
				obj.type = "Twitter";
            }
			usernames.push(obj);
        }, 
        {
        success: function() {
            resp.set('Content-Type', 'application/json');
			var jsonAsString = JSON.stringify(usernames);
  			resp.send(jsonAsString); 
        },
        error: function(error) {
            console.log('@error');
            response.error("Failed to save vote. Error=" + error.message);
        }
    });

};



 
