var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
  var query = new Parse.Query("Photo");
  query.include("user");
  query.include("user_full");

  var objid = request.params.objectid;
  var userWhoLiked = request.params.userWhoLiked;
  var userWhoLikedUsername = request.params.userWhoLikedUsername;

  query.get(objid, {
    success: function(photo) { 

        console.log(userWhoLikedUsername);   	
    	var likesArray = photo.get("likes");
        var state = photo.get("state");
        var user = photo.get("user");
        

        var likesEmailAlert = user.get("likesEmailAlert");
        var likesPushAlert = user.get("likesPushAlert");
        var username = user.get("username");
        var email = user.get("email");



    	var likesCounter = 0

        var url;

        if(state == "full"){
            url = photo.get("image_full")._url;
            
        }else{
            url = photo.get("image_half")._url;
        }

        var didUserLikedPhoto = false;

    	if(likesArray){
    		likesCounter = likesArray.length;
    		
    		
    		for (var i = likesCounter - 1; i >= 0; i--) {
    			if(likesArray[i] == userWhoLiked.id){
    				didUserLikedPhoto = true;
    				likesArray.splice(i, 1);
    				break;
    			}
    		};

    		if(!didUserLikedPhoto){
    			likesArray.push(userWhoLiked.id);
    			likesCounter++;	
    		}else{
    			likesCounter--;	
    		}
    	}else{
    		likesArray = new Array();
    		likesArray.push(userWhoLiked.id);
    		likesCounter++;	
    	}

    	//console.log(likesArray);
    	photo.set("likes",likesArray);
    	photo.save({likingPhoto:"yes"});

        //if user liked a photo, this service is unlikning the photo so we should only send notifications if liking the photo
        if(!didUserLikedPhoto){
            if(state == "full"){
                var user_full = photo.get("user_full");
                var overexposeEmailAlert_full = user_full.get("overexposeEmailAlert");
                var overexposePushAlert_full = user_full.get("overexposePushAlert");
                var username_full = user_full.get("username");
                var email_full = user_full.get("email");
                var msg = userWhoLikedUsername + " just liked your double exposed photo.";
                var htmlMsg = msg + "<br><img src='"+ url + "'></img>";
                var subject = "2by2 - photo was liked";

                if(userWhoLiked.id != user_full.id && userWhoLiked.id != user.id){
                    if(overexposePushAlert_full == true){
                        Notifications.sendPush(user_full.id,msg);
                    }

                    if(overexposeEmailAlert_full == true){
                        Notifications.sendMail(msg,htmlMsg,subject, username,email);
                    }
                }

            }else{
                //Amin T just liked your photo.

                var msg = userWhoLikedUsername+ " just liked your photo." ;
                var htmlMsg = msg + "<br><img src='"+ url + "'></img>";
                var subject = "2by2 - photo was liked";

                //don't send a notification if I am liking my own photo
                if(userWhoLiked.id != user.id){
                    if(likesPushAlert == true){
                        Notifications.sendPush(user.id,msg);
                    }

                    if(likesEmailAlert == true){
                        Notifications.sendMail(msg,htmlMsg,subject, username,email);
                    }
                }
            }
        }
            
            response.success(likesCounter); 


	},    
    error: function(error) {
      console.error("Got an error " + error.code + " : " + error.message);
      response.error(error);
    }
  });
}