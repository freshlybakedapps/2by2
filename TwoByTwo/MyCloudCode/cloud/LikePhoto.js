exports.main = function(request, response){
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
}