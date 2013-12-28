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

    	var msg = "Photo was flagged as "+type;
    	var htmlMsg = "Photo was flagged as "+type+": ("+currentState+" state)<br><p>Photo id: "+objid+"</p><br><p>This photo was flagged "+flagCounter+" time(s)</p><br><img src='"+ url + "'></img>";
    	var subject = "2by2 - photo was flagged as "+type+" by user: "+ userWhoFlagged;
    	var username = "2by2 email box";
    	var email = "2by2app@gmail.com";
    	Notifications.sendMail(msg,htmlMsg,subject, username,email);

        Notifications.addNotification(user.id,photo.id,"flag","0",userWhoFlagged,"",type);

		response.success("email sent");
		
	 },
	 error: function(error) {
	      console.error("Got an error " + error.code + " : " + error.message);
	      response.error(error);
	 }
	});
}