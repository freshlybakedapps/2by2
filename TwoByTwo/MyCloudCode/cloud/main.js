///////////////////////////////////////////////////////////////////
//WEBSITE
///////////////////////////////////////////////////////////////////
require('cloud/app.js');


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

var GetTwitterFriends = require('cloud/GetTwitterFriends.js');
Parse.Cloud.define("getTwitterFriends", function(request, response){
  GetTwitterFriends.main(request, response);
});

var NewUserRegistered = require('cloud/NewUserRegistered.js');
Parse.Cloud.define("newUserRegistered", function(request, response){
  NewUserRegistered.main(request, response);
});

var GetContactFriends = require('cloud/GetContactFriends.js');
Parse.Cloud.define("getContactFriends", function(request, response){
  GetContactFriends.main(request, response);
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

var NewPhotoWasPosted = require('cloud/NewPhotoWasPosted.js');
Parse.Cloud.define("newPhotoWasPosted", function(request, response) {
    NewPhotoWasPosted.main(request, response);
});

var GetFacebookId = require('cloud/GetFacebookId.js');
Parse.Cloud.define("getFacebookId", function(request, response) {
    GetFacebookId.main(request, response);
});

var LastPhotoURL = require('cloud/LastPhotoURL.js');
Parse.Cloud.define("lastPhotoURL", function(request, response) {
    LastPhotoURL.main(request, response);
});

var CreateThumbnails = require('cloud/CreateThumbnails.js');
Parse.Cloud.define("CreateThumbnails", function(request, response) {
  CreateThumbnails.main(request, response);
});


///////////////////////////////////////////////////////////////////
//CRON JOBS
///////////////////////////////////////////////////////////////////

var WeeklyDigest = require('cloud/WeeklyDigest.js');
Parse.Cloud.job("weeklyDigestEmail", function(request, status) {
  //if Monday
  if(new Date().getDay() == 1){
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

var CreateAllthumbnails = require('cloud/CreateAllthumbnails.js');
Parse.Cloud.job("CreateAllthumbnails", function(request, status) {
  CreateAllthumbnails.main(request, status);
});

var OnComment = require('cloud/OnComment.js');
Parse.Cloud.afterSave("Comment", function(request, response) {
  OnComment.main(request, response);
});

var OnPhotoCreated = require('cloud/OnPhotoCreated.js');
Parse.Cloud.afterSave("Photo", function(request, response) {
  OnPhotoCreated.main(request, response);
});


/*

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




