exports.main = function(request, status){
// Set up to modify user data
  Parse.Cloud.useMasterKey();
  var counter = 0;
  // Query for all users
  var query = new Parse.Query(Parse.User);
  query.each(function(user) {
    var Photo = Parse.Object.extend("Photo");
    var photoquery = new Parse.Query(Photo);

    photoquery.equalTo("user", user);
    photoquery.count({
      success: function(count) {      
        counter++;
        user.set("numberOfPhotos", count);
          //status.message(result);
          return user.save();
          },
          error: function(error) {
          status.error("Uh oh, something went wrong.");
          }
        });  


    return user.save();
  }).then(function() {
  // Set the job's success status
  status.success("Migration completed successfully. ", counter);
  }, function(error) {
  // Set the job's error status
  status.error("Uh oh, something went wrong. ", error);
  });
 }