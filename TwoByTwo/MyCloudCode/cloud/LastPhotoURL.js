exports.main = function(request, response){
  var query = new Parse.Query("Photo");
  query.include("user");
  query.include("user_full");
  Parse.Cloud.useMasterKey();
  query.descending("createdAt"); //descending //ascending

  query.first({
    success: function(photo) {    	
		response.success(photo.get("image_half")._url + "|" + photo.get("user").get("username"));
        //response.success(photo);		
	 },
	 error: function(error) {	      
	      response.error(error);
	 }
	});
}