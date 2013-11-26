var mandrill = require('mandrill');
mandrill.initialize('xpHTh_PelNA7rlzTzWUe4g');

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




    	mandrill.sendEmail({
		    message: {
		      text: "url: "+ url,
		      html: "Photo was flagged: ("+currentState+" state)<br><p>Photo id: "+objid+"</p><br><p>This photo was flagged "+flagCounter+" time(s)</p><br><img src='"+ url + "'></img>",
		      subject: "2by2 - photo was flagged by user: "+ userWhoFlagged,
		      from_email: "2by2app@gmail.com",
		      from_name: "2by2 - Cloud Code",
		      to: [
		        {
		          email: "jtubert@gmail.com",
		          name: "John Tubert"
		        },
		        {
		          email: "2by2app@gmail.com",
		          name: "2by2 email box"
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
}