var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
    var state = "full";
    if(state == "full"){
  		//var user_full = request.object.get("user_full");
  		//var user = request.object.get("user");
  		//var url = request.object.get("image_full")._url;
      var user_full_username = request.params.user_full_username;
      var user = request.params.user;
      var url = request.params.url;
      
      var latlng = request.params.locationFull;
      var city = "";
      var state = "";

      Parse.Cloud.httpRequest({
        url:'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&latlng='+latlng,
        success:function(httpResponse){
          if(httpResponse.data.results[0] && httpResponse.data.results[0].address_components[4]){
            city = httpResponse.data.results[0].address_components[4].long_name; 
          }
          if(httpResponse.data.results[0] && httpResponse.data.results[0].address_components[5]){
            state = httpResponse.data.results[0].address_components[5].long_name;
          }
          
           
        },
        error:function(httpResponse){
          //response.error(httpResponse);
          city = "";
          state = "";
        }
      });  


      console.log(url);
		  
      Parse.Cloud.useMasterKey();

		  var query = new Parse.Query(Parse.User);  		
  		
  		query.get(user.id, {
      
		    success: function(user) {
		    	var email = user.get("email");
		    	var username = user.get("username");
		    	var overexposeEmailAlert = user.get("overexposeEmailAlert");
          var overexposePushAlert = user.get("overexposePushAlert");

          

          var locationInfo = "";

          if(city != "" && state != ""){
            locationInfo = " in " + city + ", " + state;
          }

          var msg = "Hey "+username+", your photo was overexposed by "+ user_full_username + locationInfo;

             
          if(overexposePushAlert == true){
            Notifications.sendPush(user.id,msg);
          }
          
          if(overexposeEmailAlert == true){
            var htmlMsg = msg+ "<br><img src='"+ url + "'></img>";
            var subject = "2by2 - your photo was double exposed by "+ user_full_username;

		    		Notifications.sendMail(msg,htmlMsg,subject, username,email);
          }
          response.success("email sent");
        
        },
	    	error: function(error) {
	      		console.error("Got an error " + error.code + " : " + error.message);
	      		response.error(error);
	    	}
	  	});
	}
}