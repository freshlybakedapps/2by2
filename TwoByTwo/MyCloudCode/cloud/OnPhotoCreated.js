exports.main = function(request, response){
  	var photo = request.object;
  	var photoID = photo.id;
  	var updatedAt = photo.updatedAt;
  	var createdAt = photo.createdAt;

  	//if(photo.existed()){
  	
	  	Parse.Cloud.run('CreateThumbnails', { photoID: photoID }, {
			success: function(str) {        
				console.log(str);
			},
			error: function(error) {
				console.log(error);
			}
		});
	
  	//}
	
}