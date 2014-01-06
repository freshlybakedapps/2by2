var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
    var state = "full";
    if(state == "full"){
  		//var user_full = request.object.get("user_full");
  		//var user = request.object.get("user");
  		//var url = request.object.get("image_full")._url;
      var user_full_username = request.params.user_full_username;
      var user_full_id = request.params.user_full_id;
      var userID = request.params.userID;
      var url = request.params.url;
      var photoID = request.params.photoID;
      
      var latlng_full = request.params.locationFull;

      var latlng = request.params.location;

      var distance = " - Distance between two photographers: " + getDistance(latlng,latlng_full)  + " miles";

      if(!distance || distance == 0 || distance < 1){
        distance = "";
      }

      var city = "";
      var state = "";

      Parse.Cloud.httpRequest({
        url:'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&latlng='+latlng_full
      }).then(function(httpResponse){
        if(httpResponse && httpResponse.data.results[0] && httpResponse.data.results[0].address_components[4]){
            city = httpResponse.data.results[0].address_components[4].long_name; 
          }
        if(httpResponse && httpResponse.data.results[0] && httpResponse.data.results[0].address_components[5]){
          state = httpResponse.data.results[0].address_components[5].long_name;
        }

        console.log(distance + " km");
		  
        Parse.Cloud.useMasterKey();

  		  var query = new Parse.Query(Parse.User);  		
    		
    		query.get(userID, {
        
  		    success: function(user) {
  		    	var email = user.get("email");
  		    	var username = user.get("username");
  		    	

            var locationInfo = "";

            if(city != "" && state != ""){
              locationInfo = " in " + city + ", " + state;
            }

            var msg = "Hey "+username+", your photo was overexposed by "+ user_full_username + locationInfo + distance;
            var htmlMsg = msg+ "<br><img src='"+ url + "'></img>";
            var subject = "2by2 - your photo was double exposed by "+ user_full_username;


            Notifications.sendNotifications(response,"overexposed",user.id,msg,htmlMsg,subject,photoID,locationInfo,user_full_id,user_full_username,msg);
          
          },
  	    	error: function(error) {
  	      		console.error("Got an error " + error.code + " : " + error.message);
  	      		response.error(error);
  	    	}
  	  	});

      },function(error){
        console.log(error);
      });  
	}
}

function getDistance(latlng,latlng_full){
  var arr = latlng.split(",");
  var arr_full = latlng_full.split(",");

  var lat1 = arr[0];
  var lon1 = arr[1];
  var lat2 = arr_full[0];
  var lon2 = arr_full[1];

  return getDistanceFromLatLonInMiles(lat1,lon1,lat2,lon2);
}

function getDistanceFromLatLonInMiles(lat1,lon1,lat2,lon2) {
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1); 
  var a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ; 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  var d = R * c; // Distance in km

  var inMiles = d * 0.62137;

  return Math.round(inMiles);
}

function deg2rad(deg) {
  return deg * (Math.PI/180);
}


