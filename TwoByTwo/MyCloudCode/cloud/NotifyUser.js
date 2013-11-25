exports.main = function(request, response){
	//var state = request.object.get("state");
    
    var state = "full";

    
      
  	
    if(state == "full"){
  		//var user_full = request.object.get("user_full");
  		//var user = request.object.get("user");
  		//var url = request.object.get("image_full")._url;
      var user_full_username = request.params.user_full_username;
      var user = request.params.user;
      var url = request.params.url;


      var latlng = request.params.locationFull;
      var city = "{no location}";
      var state = "{no location}";

      Parse.Cloud.httpRequest({
        url:'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&latlng='+latlng,
        success:function(httpResponse){
          city = httpResponse.data.results[0].address_components[4].long_name; 
          state = httpResponse.data.results[0].address_components[5].long_name; 
        },
        error:function(httpResponse){
          //response.error(httpResponse);
          city = "{no location}";
        }
      });  


      console.log(url);
		  
      Parse.Cloud.useMasterKey();

		  var query = new Parse.Query(Parse.User);  		
  		
  		query.get(user.id, {
      
		    success: function(user) {
		    	var email = user.get("email");
		    	var username = user.get("username");
		    	var emailAlerts = user.get("emailAlerts");
          var pushAlerts = user.get("pushAlerts");

          var pushQuery = new Parse.Query(Parse.Installation);
          pushQuery.equalTo('deviceType', 'ios');
          pushQuery.equalTo('channels', user.id);//'SREzPjOawD');//

             
          if(pushAlerts == true){
            //console.log("user.objectId: "+user.id);
            Parse.Push.send({
              where: pushQuery, // Set our Installation query
              data: {
                alert: "Hey "+username+", your photo was overexposed by "+ user_full_username + " in " + city + ", " + state
              }
              }, {
              success: function() {
                // Push was successful
              },
              error: function(error) {
                throw "Got an error " + error.code + " : " + error.message;
              }
            });

          }
      
   		    	

		    	if(emailAlerts == true){
		    		console.log("emailAlerts - user opt-in");
		    		mandrill.sendEmail({
				    message: {
				      text: "url: "+url,
				      html: "Hey "+username+", your photo was overexposed by "+ user_full_username + " in " + city + ", " + state + "<br><img src='"+ url + "'></img>",
				      subject: "2by2 - your photo was double exposed by "+ user_full_username,
				      from_email: "jtubert@gmail.com",
				      from_name: "2by2 - Cloud Code",
				      to: [				        
				        {
				          email: email, //"jtubert@gmail.com",
				          name: username
				        }
				      ]
				    },
				    async: true
				  }, {
				    success: function(httpResponse) { response.success("Email sent!"); },
				    error: function(httpResponse) { response.error("Uh oh, something went wrong"); }
				  });
		    	}else{
		    		console.log("emailAlerts - user doesn't want to receive email alerts");
		    	}

		    	
			
			},
	    	error: function(error) {
	      		console.error("Got an error " + error.code + " : " + error.message);
	      		response.error(error);
	    	}
	  	});
	}
}