exports.index = function(req, resp){
	var User = Parse.Object.extend("User");
    var query = new Parse.Query(User);

    var usernames = [];

    query.each(
        function(result){
            var obj = {};
            
            if(result.get("TwitterProfileImage") && result.get("TwitterProfileImage") != ""){
            	obj.name = result.get("username");
            	obj.avatar = result.get("TwitterProfileImage");
				obj.type = "Twitter";
				usernames.push(obj);
            }else{
            	if(result.get("facebookId")){
            		obj.name = result.get("username");
            		obj.avatar = "https://graph.facebook.com/"+result.get("facebookId")+"/picture?type=square&width=60&height=60";
					obj.type = "Facebook";
					usernames.push(obj);
				}
			}
			
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



 
