exports.main = function(request, status){
	// Set up to modify user data
  Parse.Cloud.useMasterKey();  
  var Photo = Parse.Object.extend("Photo");
  var query = new Parse.Query(Photo);  

  
  
  query.each(function(photo) {
    if(photo.newThumbnail == undefined){
      Parse.Cloud.run('CreateThumbnails', { photoID: photo.id }, {
      success: function(str) {        
        console.log(str);
      },
      error: function(error) {
        console.log(error);
      }
    });
    }
    

  
    
  }).then(function() {
    // Set the job's success status
    //status.success("fixPhotoState completed successfully. ", counter);
  }, function(error) {
    // Set the job's error status
    //status.error("Uh oh, something went wrong. ", error);
  });
}