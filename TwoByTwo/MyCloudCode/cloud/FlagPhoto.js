var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
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

    	var msg = "url: "+ url;
    	var htmlMsg = "Photo was flagged: ("+currentState+" state)<br><p>Photo id: "+objid+"</p><br><p>This photo was flagged "+flagCounter+" time(s)</p><br><img src='"+ url + "'></img>";
    	var subject = "2by2 - photo was flagged by user: "+ userWhoFlagged;
    	var username = "2by2 email box";
    	var email = "2by2app@gmail.com";
    	Notifications.sendMail(msg,htmlMsg,subject, username,email);
		response.success("email sent");
		
	 },
	 error: function(error) {
	      console.error("Got an error " + error.code + " : " + error.message);
	      response.error(error);
	 }
	});
}