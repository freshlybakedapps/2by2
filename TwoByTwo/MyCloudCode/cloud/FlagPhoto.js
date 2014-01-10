var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
  var query = new Parse.Query("Photo");
  var objid = request.params.objectid;
  var type = request.params.type;
  var userWhoFlagged = request.params.userWhoFlagged;

  query.get(objid, {
    success: function(photo) {
    	//"Photo saved: ("+currentState+")<img src='"+ url + "'></img>",

        var user = photo.get("user");
    	
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


        ///////////////////////////////////////////
        // SEND ADMIN
        ///////////////////////////////////////////
    	var msg = "Photo was flagged as "+type;
    	var htmlMsg = "Photo was flagged as "+type+": ("+currentState+" state)<br><p>Photo id: "+objid+"</p><br><p>This photo was flagged "+flagCounter+" time(s)</p><br><img src='"+ url + "'></img>";
    	var subject = "2by2 - photo was flagged as "+type+" by user: "+ userWhoFlagged;
    	var username = "2by2 email box";
    	var email = "2by2app@gmail.com";
    	Notifications.sendMail(msg,htmlMsg,subject, username,email);

        //Notifications.addNotification(user.id,photo.id,"flag","0",userWhoFlagged,"",type);

        ///////////////////////////////////////////
        // SEND USER
        ///////////////////////////////////////////
        var typeS = type.replace("FlagType", "");
        typeS = typeS.toLowerCase();

        console.log(typeS);

        var msg = "Photo was flagged as: "+typeS;
        var htmlMsg = "Someone recently flagged your photo as: "+typeS+".";
        htmlMsg += "<br>We will review the image and take the necessary actions.";
        htmlMsg += "<br>Make sure to review our terms of services where we list the reasons an image may get flagged. Know that a violation of these terms may result in cancellation of your account without notice.";
        htmlMsg += "<br><br>Thanks,";
        htmlMsg += "<br>Team 2by2";
        var subject = msg;        

        Notifications.sendNotifications(null,"flag",user.id,msg,htmlMsg,subject,photo.id,"","","",type);

        //if this photo was double exposed, send a notification to other user as well.
        if(currentState == "full"){
            var userFull = photo.get("user_full");
            Notifications.sendNotifications(null,"flag",userFull.id,msg,htmlMsg,subject,photo.id,"","","",type);
        }

		//response.success("email sent");
		
	 },
	 error: function(error) {
	      console.error("Got an error " + error.code + " : " + error.message);
	      response.error(error);
	 }
	});
}