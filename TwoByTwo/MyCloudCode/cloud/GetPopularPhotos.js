exports.main = function(request, response){
  var query = new Parse.Query("Photo");
  query.equalTo("featured", true); 
  query.include("user");
  query.include("user_full");
  Parse.Cloud.useMasterKey();
  query.descending("createdAt"); //descending //ascending

  query.find({
      success: function(photos) {    	
		    //response.success(photos);

        
        var photosArr = [];
        

        //response.success("xxx: "+photos.length);

        for (var j = photos.length - 1; j >= 0; j--) {

            var url = photos[j].get("image_full")._url;
            var username = photos[j].get("user").get("username");
            var username_full = photos[j].get("user_full").get("username");

            photosArr.push({ 
                "url"       : url,
                "username"  : username,
                "username_full": username_full 
            });
        }

        response.success(photosArr);
    

        
	    },
	 error: function(error) {	      
	      response.error(error);
	 }
	});
}