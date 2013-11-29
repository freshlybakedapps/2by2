var mandrill = require('mandrill');
mandrill.initialize('xpHTh_PelNA7rlzTzWUe4g');

exports.main = function(request, response){
  var query = new Parse.Query("Photo");
  query.include("user");
  query.include("user_full");

  var objid = request.params.objectid;
  var userWhoLiked = request.params.userWhoLiked;

  query.get(objid, {
    success: function(photo) {    	
    	var likesArray = photo.get("likes");
        var state = photo.get("state");
        var user = photo.get("user");
        

        var overexposeEmailAlert = user.get("overexposeEmailAlert");
        var overexposePushAlert = user.get("overexposePushAlert");
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

        //if user liked a photo, this service is unlikning the photo so we should only send notifications if liking the photo
        if(!didUserLikedPhoto){
            var msg = "One of your photos was liked!";


            //don't send a notification if I am liking my own photo
            if(userWhoLiked != user.id){
                if(overexposePushAlert == true){
                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo('deviceType', 'ios');
                    pushQuery.equalTo('channels', user.id);//'SREzPjOawD');//

                    //console.log("user.objectId: "+user.id);
                    Parse.Push.send({
                      where: pushQuery, // Set our Installation query
                      data: {
                        alert: msg 
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

              if(overexposeEmailAlert == true){
                    mandrill.sendEmail({
                    message: {
                      text: msg,
                      html: msg + "<br><img src='"+ url + "'></img>",
                      subject: "2by2 - photo was liked",
                      from_email: "2by2app@gmail.com",
                      from_name: "2by2",
                      to: [                     
                        {
                          email: email, //"jtubert@gmail.com",
                          name: username
                        }
                      ]
                    },
                    async: true
                  }, {
                    success: function(httpResponse) { console.log("Email sent!"); },
                    error: function(httpResponse) { console.log("Uh oh, something went wrong"); }
                  });
                }else{
                    console.log("emailAlerts - user doesn't want to receive email alerts");
                }
            }

            

              if(state == "full"){
                var user_full = photo.get("user_full");
                var overexposeEmailAlert_full = user_full.get("overexposeEmailAlert");
                var overexposePushAlert_full = user_full.get("overexposePushAlert");
                var username_full = user_full.get("username");
                var email_full = user_full.get("email");

                if(userWhoLiked != user_full.id){
                    if(overexposePushAlert_full == true){
                        var pushQuery = new Parse.Query(Parse.Installation);
                        pushQuery.equalTo('deviceType', 'ios');
                        pushQuery.equalTo('channels', user_full.id);//'SREzPjOawD');//

                        Parse.Push.send({
                          where: pushQuery, // Set our Installation query
                          data: {
                            alert: "One of your double exposed photos was liked!"
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

                      if(overexposeEmailAlert_full == true){
                            mandrill.sendEmail({
                            message: {
                              text: msg,
                              html: msg + "<br><img src='"+ url + "'></img>",
                              subject: "2by2 - photo was liked",
                              from_email: "2by2app@gmail.com",
                              from_name: "2by2",
                              to: [                     
                                {
                                  email: email_full, //"jtubert@gmail.com",
                                  name: username_full
                                }
                              ]
                            },
                            async: true
                          }, {
                            success: function(httpResponse) { console.log("Email sent!"); },
                            error: function(httpResponse) { console.log("Uh oh, something went wrong"); }
                          });
                        }else{
                            console.log("emailAlerts - user doesn't want to receive email alerts");
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