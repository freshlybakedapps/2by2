///////////////////////////////////////////////////////////////////
//SERVICES
///////////////////////////////////////////////////////////////////

var IsUsernameUnique = require('cloud/IsUsernameUnique.js');
Parse.Cloud.define("isUsernameUnique", function(request, response){  
  IsUsernameUnique.main(request, response);
});

var Follow = require('cloud/Follow.js');
Parse.Cloud.define("follow", function(request, response){
  Follow.main(request, response);
});

var GetFacebookFriends = require('cloud/GetFacebookFriends.js');
Parse.Cloud.define("getFacebookFriends", function(request, response){
  GetFacebookFriends.main(request, response);
});

var LikePhoto = require('cloud/LikePhoto.js');
Parse.Cloud.define("likePhoto", function(request, response) {
  LikePhoto.main(request, response);
});

var FlagPhoto = require('cloud/FlagPhoto.js');
Parse.Cloud.define("flagPhoto", function(request, response) {
  FlagPhoto.main(request, response);
});

var NotifyUser = require('cloud/NotifyUser.js');
Parse.Cloud.define("notifyUser", function(request, response) {
    NotifyUser.main(request, response);
});

///////////////////////////////////////////////////////////////////
//CRON JOBS
///////////////////////////////////////////////////////////////////

var WeeklyDigest = require('cloud/WeeklyDigest.js');
Parse.Cloud.job("weeklyDigestEmail", function(request, status) {
  //if sunday
  if(new Date().getDay() == 0){
    WeeklyDigest.main(request, status);
  }else{
    status.success("Only run this on Sundays and today is not Sunday");
  } 
});

var FixPhotoState = require('cloud/FixPhotoState.js');
Parse.Cloud.job("fixPhotoState", function(request, status) {
  FixPhotoState.main(request, status);
});

var PhotosPerUser = require('cloud/PhotosPerUser.js');
Parse.Cloud.job("photosPerUser", function(request, status) {
  PhotosPerUser.main(request, status);
});

var AddLocationStrings = require('cloud/AddLocationStrings.js');
Parse.Cloud.job("addLocationStrings", function(request, status) {
  AddLocationStrings.main(request, status);
});

/*
var CreateThumbnails = require('cloud/CreateThumbnails.js');
Parse.Cloud.beforeSave("Photo", function(request, response) {
  CreateThumbnails.main(request, response);
});
*/

/*
Parse.Cloud.define("reverseGeocoding", function(request, response){
  var latlng = request.params.latlng;
  //48.77615073,9.16416465

  Parse.Cloud.httpRequest({
        url:'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&latlng='+latlng,
        success:function(httpResponse){
          response.success(httpResponse.data.results[0].address_components[4].long_name); 
        },
        error:function(httpResponse){
          response.error(httpResponse);
        }
      });
});
*/




