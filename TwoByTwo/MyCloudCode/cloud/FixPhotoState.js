exports.main = function(request, status){
	// Set up to modify user data
  Parse.Cloud.useMasterKey();
  var counter = 0;
  // Query for all users
  var Photo = Parse.Object.extend("Photo");
  var query = new Parse.Query(Photo);
  query.equalTo("state", "in-use");

  var date = new Date();
  
  query.each(function(photo) {
   var updatedAt = photo.updatedAt;
   var diffInMilliseconds = date.getTime() - updatedAt.getTime();
   var mins = (diffInMilliseconds/1000)/60;

  if(mins > 5){
    photo.set("state","half");
    return photo.save();
  }   
    
    
  }).then(function() {
  // Set the job's success status
  status.success("fixPhotoState completed successfully. ", counter);
  }, function(error) {
  // Set the job's error status
  status.error("Uh oh, something went wrong. ", error);
  });
}