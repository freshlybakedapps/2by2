//https://www.parse.com/docs/cloud_modules_guide#images
var Image = require("parse-image");
var mandrill = require('mandrill');
mandrill.initialize('xpHTh_PelNA7rlzTzWUe4g');

Parse.Cloud.define("isUsernameUnique", function(request, response){
  
  
  var isUsernameUnique = "true";

  var usernameToCheck = request.params.username;
  
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  query.each(function(u) {
    var username = u.get("username");

    if(username == usernameToCheck){
      isUsernameUnique = "false";
      return;
    }
      

    
  }).then(function() {
    // Set the job's success status
    response.success(isUsernameUnique);
  }, function(error) {
    // Set the job's error status
    response.error("Uh oh, something went wrong. ", error);
  });

      

  
});



Parse.Cloud.define("findFriendsFromContacts", function(request, response){
  response.success("findFriendsFromContacts"); 
});


Parse.Cloud.define("follow", function(request, response){
  var userID = request.params.userID;
  var followingUserID = request.params.followingUserID;  
  
  var followQuery = new Parse.Query("Followers");
  followQuery.equalTo("userID", userID);
  followQuery.equalTo("followingUserID", followingUserID);

  followQuery.find({
  success: function(arr) {
    console.log(arr.length);
    if(arr.length < 1){
      var Followers = Parse.Object.extend("Followers");
      var followers = new Followers();
      followers.set("userID", userID);
      followers.set("followingUserID", followingUserID);

      followers.save(null, {
        success: function(follower) {      
          response.success(true);
        },
        error: function(follower, error) {      
          response.error('Failed to create new object, with error code: ' + error.description);
        }
      });
    }else{
      arr[0].destroy({
          success:function() {
               response.success(false);
          },
          error:function(error) {
               response.error('Could not delete object.');
          }
     });
      
    }
  },

  error: function(error) {
    response.error(error.description);
  }
});
});//follow function
  



Parse.Cloud.define("getFacebookFriends", function(request, response){
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  var user = request.params.user;
  var items = [];
  var followers = [];

  var twoByTwoUsers = [];

  var userQuery = new Parse.Query(Parse.User);
  userQuery.each(function(u) {
    var obj = {username:u.get("fullName"),id:u.id};
    twoByTwoUsers.push(obj);
  });

  var followQuery = new Parse.Query("Followers");
  followQuery.equalTo("userID", user);
  followQuery.each(function(f) {
    followers.push(f.get("followingUserID"));
  });

    //   
  
  query.get(user, {
    success: function(user) {
      var email = user.get("email");
      var username = user.get("username");
      Parse.Cloud.httpRequest({
        url:'https://graph.facebook.com/me/friends?access_token='+user.get('authData').facebook.access_token,
        success:function(httpResponse){
          var followersStr = followers.join();
          //console.log(user.get('authData').facebook.access_token);
          //response.success("getFacebookFriends: "+httpResponse.data.data.length);
          var friends = httpResponse.data.data;

          for (var i = friends.length - 1; i >= 0; i--) {
            var n1 = friends[i].name;
            for (var j = twoByTwoUsers.length - 1; j >= 0; j--) {
              var n2 = twoByTwoUsers[j].username;
              if(n1 == n2){
                var following = false;
                if(followersStr.indexOf(twoByTwoUsers[j].id) != -1){
                  following = true;
                }

                var obj ={name:friends[i].name,parseID:twoByTwoUsers[j].id,facebookID:friends[i].id,following:following};
                items.push(obj);
              }
            };
            
          };  

          response.success(items); 
        },
        error:function(httpResponse){
          response.error(httpResponse);
        }
      });
               
    },
    error: function(error) {
        console.error("Got an error " + error.code + " : " + error.message);
        response.error(error);
    }
  });
});

/*
Parse.Cloud.define("reverseGeocoding", function(request, response){

  var latlng = request.params.latlng;

  //48.77615073,9.16416465

  Parse.Cloud.httpRequest({
        url:'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&latlng='+latlng,
        success:function(httpResponse){
          response.success(httpResponse.data.results[0].address_components[4].long_name); 
        },
        error:function(httpResponse){
          response.error(httpResponse);
        }
      });  
});
*/

//Parse.Cloud.afterSave("Photo", function(request,response) {
Parse.Cloud.define("notifyUser", function(request, response) {
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
});

Parse.Cloud.define("likePhoto", function(request, response) {
  var query = new Parse.Query("Photo");
  var objid = request.params.objectid;
  var userWhoLiked = request.params.userWhoLiked;

  query.get(objid, {
    success: function(photo) {    	
    	var likesArray = photo.get("likes");

    	var likesCounter = 0

    	if(likesArray){
    		likesCounter = likesArray.length;
    		var didUserLikedPhoto = false;
    		
    		for (var i = likesCounter - 1; i >= 0; i--) {
    			if(likesArray[i] == userWhoLiked){
    				didUserLikedPhoto = true;
    				likesArray.splice(i, 1);
    				break;
    			}
    		};

    		if(!didUserLikedPhoto){
    			likesArray.push(userWhoLiked);
    			likesCounter++;	
    		}else{
    			likesCounter--;	
    		}
    	}else{
    		likesArray = new Array();
    		likesArray.push(userWhoLiked);
    		likesCounter++;	
    	}

    	//console.log(likesArray);
    	photo.set("likes",likesArray);
    	photo.save({likingPhoto:"yes"});
    	response.success(likesCounter); 
	},    
    error: function(error) {
      console.error("Got an error " + error.code + " : " + error.message);
      response.error(error);
    }
  });
});


Parse.Cloud.define("flagPhoto", function(request, response) {
  var query = new Parse.Query("Photo");
  var objid = request.params.objectid;
  var userWhoFlagged = request.params.userWhoFlagged;

  query.get(objid, {
    success: function(photo) {
    	//"Photo saved: ("+currentState+")<img src='"+ url + "'></img>",
    	
    	var currentState = photo.get("state");
    	//console.log("photo: "+url);
    	var theURL;

    	if(currentState == "full"){
    		theURL = "image_full";
    	}else{
    		theURL = "image_half";
    	}

    	var url = photo.get(theURL)._url;

    	var flagCounter = photo.get("flag");
    	if(flagCounter){
    		flagCounter++;
		}else{
			flagCounter = 1;
		}

    	photo.set("flag", flagCounter);
    	photo.save();




    	mandrill.sendEmail({
		    message: {
		      text: "url: "+ url,
		      html: "Photo was flagged: ("+currentState+" state)<br><p>Photo id: "+objid+"</p><br><p>This photo was flagged "+flagCounter+" time(s)</p><br><img src='"+ url + "'></img>",
		      subject: "2by2 - photo was flagged by user: "+ userWhoFlagged,
		      from_email: "jtubert@gmail.com",
		      from_name: "2by2 - Cloud Code",
		      to: [
		        {
		          email: "jtubert@gmail.com",
		          name: "John Tubert"
		        },
		        {
		          email: "amin@amintorres.com",
		          name: "Amin Torres"
		        }
		      ]
		    },
		    async: true
		  }, {
		    success: function(httpResponse) { response.success("Email sent!"); },
		    error: function(httpResponse) { response.error("Uh oh, something went wrong"); }
		  });

    		//response.success();
	    },
	    error: function(error) {
	      console.error("Got an error " + error.code + " : " + error.message);
	      response.error(error);
	    }
	  });
});

/* 
Parse.Cloud.beforeSave("Photo", function(request, response) {
	var photo = request.object;

	var image_full;
	var image_half;
	var theUrl;
	var currentState;

	if(request.object.get("image_full")){
		image_full = request.object.get("image_full")._url;	
	}
	
	if(request.object.get("image_half")){
		image_half = request.object.get("image_half")._url;	
	}	

	if(image_full){
		currentState = "full";
		theUrl = image_full;
	}else{
		currentState = "half";
		theUrl = image_half;
	}	

	console.log("URL: "+theUrl);	
	var cropped;	

  
  Parse.Cloud.httpRequest({
    url: theUrl
 
  }).then(function(response) {
    var image = new Image();
    return image.setData(response.buffer);
 
  }).then(function(image) {
    // Crop the image to the smaller of width or height.
    var size = Math.min(image.width(), image.height());
    return image.crop({
      left: (image.width() - size) / 2,
      top: (image.height() - size) / 2,
      width: size,
      height: size
    });
 
  }).then(function(image) {
    // Resize the image to 64x64.
    return image.scale({
      width: 300,
      height: 300
    });
 
  }).then(function(image) {
    // Make sure it's a JPEG to save disk space and bandwidth.
    return image.setFormat("JPEG");
 
  }).then(function(image) {
    // Get the image data in a Buffer.
    return image.data();
 
  }).then(function(buffer) {
    // Save the image into a new file.
    var base64 = buffer.toString("base64");    
    cropped = new Parse.File("thumbnail.jpg", { base64: base64 });
    return cropped.save();
 
  }).then(function(cropped) {
    // Attach the image file to the original object.
    photo.set("newThumbnail", cropped);
    //photo.save();
 
  }).then(function(result) {
  	var url = cropped.url();	
  	
  	mandrill.sendEmail({
    message: {
      text: "url: "+ theUrl,
      html: "Photo saved: ("+currentState+")<img src='"+ url + "'></img>",
      subject: "2by2 - User took a photo",
      from_email: "jtubert@gmail.com",
      from_name: "2by2 - Cloud Code",
      to: [
        {
          email: "jtubert@gmail.com",
          name: "John Tubert"
        },
        {
          email: "amin@amintorres.com",
          name: "Amin Torres"
        }
      ]
    },
    async: true
  }, {
    success: function(httpResponse) { response.success("Email sent!"); },
    error: function(httpResponse) { response.error("Uh oh, something went wrong"); }
  });
	

    response.success();
  }, function(error) {
    response.error(error);
  });
});

*/

Parse.Cloud.job("fixPhotoState", function(request, status) {
  // Set up to modify user data
  Parse.Cloud.useMasterKey();
  var counter = 0;
  // Query for all users
  var Photo = Parse.Object.extend("Photo");
  var query = new Parse.Query(Photo);
  query.equalTo("state", "in-use");

  var date = new Date();
  
  query.each(function(photo) {
	 var updatedAt = photo.updatedAt;
	 var diffInMilliseconds = date.getTime() - updatedAt.getTime();
	 var mins = (diffInMilliseconds/1000)/60;

	if(mins > 5){
		photo.set("state","half");
		return photo.save();
	} 	
		
		
  }).then(function() {
	// Set the job's success status
	status.success("fixPhotoState completed successfully. ", counter);
  }, function(error) {
	// Set the job's error status
	status.error("Uh oh, something went wrong. ", error);
  });
});

Parse.Cloud.job("photosPerUser", function(request, status) {
  // Set up to modify user data
  Parse.Cloud.useMasterKey();
  var counter = 0;
  // Query for all users
  var query = new Parse.Query(Parse.User);
  query.each(function(user) {
		var Photo = Parse.Object.extend("Photo");
		var photoquery = new Parse.Query(Photo);

		photoquery.equalTo("user", user);
		photoquery.count({
			success: function(count) {	    
				counter++;
				user.set("numberOfPhotos", count);
					//status.message(result);
					return user.save();
				  },
				  error: function(error) {
					status.error("Uh oh, something went wrong.");
				  }
				});  


	  return user.save();
  }).then(function() {
	// Set the job's success status
	status.success("Migration completed successfully. ", counter);
  }, function(error) {
	// Set the job's error status
	status.error("Uh oh, something went wrong. ", error);
  });
});


Parse.Cloud.job("weeklyDigestEmail", function(request, status) {
  // Set up to modify user data
  Parse.Cloud.useMasterKey();
  
  // Query for all users
  var query = new Parse.Query(Parse.User);
  //query.include("email");
  //query.include("fullName");

  query.find({
    success: function(userArr) {
      for (var i = userArr.length - 1; i >= 0; i--) {
        var Photo = Parse.Object.extend("Photo");
        
        var user = userArr[i];
        
        /*
        var userQuery = new Parse.Query(Photo);
        userQuery.equalTo("user", user);

        var userFullQuery = new Parse.Query(Photo);
        userFullQuery.equalTo("user_full", user);
        
        var photoquery = Parse.Query.or(userQuery, userFullQuery);
        photoquery.include("user");
        photoquery.include("user_full");
        */

        var photoquery = new Parse.Query(Photo);
        photoquery.equalTo("user", user);
        photoquery.include("user");
        photoquery.include("likes");
        //photoquery.include("location_half");
        //photoquery.include("location_full");

        
        var today = new Date();
        var lastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 7);
        photoquery.greaterThan('updatedAt', lastWeek);

        
        
        photoquery.find({
          success: function(arr) {
            
            var totalLikes = 0;

            if(arr.length > 0){
                
                /*
                for (var j = arr.length - 1; j >= 0; j--) {
                  var photo = arr[j];
                  var likesArr = photo.get("likes");
                  if(likesArr && likesArr.length){
                    totalLikes += likesArr.length;
                  }

                };
                */


                var user = arr[0].get("user");
                var fullName = user.get("fullName");
                var email = user.get("email"); 

                if(email == "jtubert@hotmail.com"){

                var msg = "Hi "+fullName+", this is your quick 2by2 digest, this week: <br><br>";
                /*
                msg += "You took "+arr.length+" photos<br>";
                msg += "XX of your photos were double exposed from: New York, New York., Atlanta., Brooklyn, New York., etc.<br>";
                msg += "Your photos got "+totalLikes+" likes.<br>";
                msg += "You had XX new followers.<br><br>";
                msg += "Thanks, the 2by2 team.<br>";
                msg += "Check out our blog.<br>";
                msg += "Tell a friend about 2by2<br><br>";
                msg += "PS: To stop receiving this email, turn weekly notification email off, in the app settings page.";
                */


                mandrill.sendEmail({
                  message: {
                    text: "msg",
                    html: ""+msg,
                    subject: "Your 2by2 weekly digest",
                    from_email: "jtubert@gmail.com",
                    from_name: "2by2",
                    to: [               
                      {
                        email: email,//"jtubert@gmail.com",
                        name: fullName
                      }
                    ]
                  },
                  async: true
                }, {
                  success: function(httpResponse) {console.log("Email sent! "+email);},
                  error: function(httpResponse) { console.log("Email not sent, something went wrong");}
                });

              }

            }
              
            
            
            
          },

          error: function(error) {
            if(i == -1){
              status.error(error.description);
            }
          }
        }).then(function() {
          // Set the job's success status
            if(i == -1){
              status.success("weeklyDigestEmail completed successfully. ");
            }
            
          }, function(error) {
          // Set the job's error status
            if(i == -1){
              status.error("Uh oh, something went wrong. ", error);
            }
          });
        
      };

     // status.success("weeklyDigestEmail completed successfully. ");

      
    },
    error: function(error) {
      status.error(error);
    }
  });


  
});

