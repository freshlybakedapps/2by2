//https://www.parse.com/docs/cloud_modules_guide#images
var Image = require("parse-image");
var mandrill = require('mandrill');

mandrill.initialize('xpHTh_PelNA7rlzTzWUe4g');

Parse.Cloud.afterSave("Photo", function(request,response) {
  	var state = request.object.get("state");
  	

  	

  	if(state == "full"){
  		var user_full = request.object.get("user_full");
  		var user = request.object.get("user");
  		var url = request.object.get("image_full")._url;
  		//console.log(url);
		Parse.Cloud.useMasterKey();

		
		var pushQuery = new Parse.Query(Parse.Installation);
		pushQuery.equalTo('deviceType', 'ios');
		pushQuery.equalTo('channels', user.id);


		//console.log("user.objectId: "+user.id);

		Parse.Push.send({
			where: pushQuery, // Set our Installation query
			data: {
				alert: "Your photo was overexposed! "+ url
			}
			}, {
			success: function() {
				// Push was successful
			},
			error: function(error) {
				throw "Got an error " + error.code + " : " + error.message;
			}
		});


  		

  		var query = new Parse.Query(Parse.User);  		
  		
  		query.get(user.id, {
		    success: function(user) {
		    	var email = user.get("email");
		    	var username = user.get("username");
		    	var emailAlerts = user.get("emailAlerts");		    	

		    	if(emailAlerts == true){
		    		console.log("emailAlerts - user opt-in");
		    		mandrill.sendEmail({
				    message: {
				      text: "url: "+url,
				      html: "Your photo was just double exposed. <br><img src='"+ url + "'></img>",
				      subject: "2by2 - your photo was double exposed",
				      from_email: "jtubert@gmail.com",
				      from_name: "2by2 - Cloud Code",
				      to: [				        
				        {
				          email: email,
				          name: username
				        }
				      ]
				    },
				    async: true
				  }, {
				    //success: function(httpResponse) { response.success("Email sent!"); },
				    //error: function(httpResponse) { response.error("Uh oh, something went wrong"); }
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