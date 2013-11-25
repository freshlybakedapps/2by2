exports.main = function(request, response){
  var userID = request.params.userID;
  var followingUserID = request.params.followingUserID;  
  
  var followQuery = new Parse.Query("Followers");
  followQuery.equalTo("userID", userID);
  followQuery.equalTo("followingUserID", followingUserID);

  followQuery.find({
  success: function(arr) {
    console.log(arr.length);
    if(arr.length < 1){
      var Followers = Parse.Object.extend("Followers");
      var followers = new Followers();
      followers.set("userID", userID);
      followers.set("followingUserID", followingUserID);

      followers.save(null, {
        success: function(follower) {      
          response.success(true);
        },
        error: function(follower, error) {      
          response.error('Failed to create new object, with error code: ' + error.description);
        }
      });
    }else{
      arr[0].destroy({
          success:function() {
               response.success(false);
          },
          error:function(error) {
               response.error('Could not delete object.');
          }
     });
      
    }
  },

  error: function(error) {
    response.error(error.description);
  }
});
}