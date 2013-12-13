var Notifications = require('cloud/Notifications.js');

function weeklyMsg(fullName,arr,fullPhotos,totalLikes,followers,locations){
  var msg = "Hi "+fullName+", here is the quick scoop, this week: <br><br>";  
  
  if(arr.length != 0){
    msg += "You took "+arr.length+" photos<br>";  
  }

  if(fullPhotos != 0){
    msg += fullPhotos + " of your photos were double exposed from "+locations.join("., ")+".<br>";
  }
  
  if(totalLikes != 0){
    msg += "Your photos got "+totalLikes+" likes.<br>";
  }

  if(followers.length != 0){
    msg += "You had "+followers.length+" new followers.<br>";
  }

  

  if(fullPhotos == 0 && totalLikes == 0 && followers.length == 0 && arr.length == 0){
    msg += "What? no new activity?<br>";
    msg += "How about you take a new photo right now and show 'em how is done!<br>";
  }  
  
  msg += "<br>Thanks, the 2by2 team.<br>";  
  //msg += "<a href='mailTo:2by2app@gmail.com'>Tell a friend about 2by2</a><br><br>";
  msg += '<A HREF="mailto:?subject=Invitation to join 2by2&body=Hey, 2by2 Is a fun and easy to make unexpected double exposure photos with friends (or with total strangers.) %0DHere is a link to download the app, it is totally free:%0D http://2by2.parseapp.com">Tell a friend about 2by2</A><br><br>'
  
  msg += "PS: To stop receiving this email, turn weekly notification email off, in the app settings page.";

  return msg;
}

Array.prototype.pushUnique = function (item){
    if(this.indexOf(item) == -1) {    
        this.push(item);
        return true;
    }
    return false;
}

exports.main = function(request, status) {
  

   // Set up to modify user data
  Parse.Cloud.useMasterKey();
  
  // Query for all users
  var query = new Parse.Query(Parse.User);
  //query.include("email");
  //query.include("fullName");

  query.find({
    success: function(userArr) {
      for (var i = 0; i < userArr.length; i++) {
        
        console.log(userArr[i].get('username')+": "+userArr[i].get('authData').facebook.id);
        /*
        var userQuery = new Parse.Query(Photo);
        userQuery.equalTo("user", user);

        var userFullQuery = new Parse.Query(Photo);
        userFullQuery.equalTo("user_full", user);
        
        var photoquery = Parse.Query.or(userQuery, userFullQuery);
        photoquery.include("user");
        photoquery.include("user_full");
        */

        
        //var fullName = user.get("fullName");
        //console.log(fullName);

        (function(index, indexOfLastPush, _user) { 



        var Photo = Parse.Object.extend("Photo");
        var photoquery = new Parse.Query(Photo);
        photoquery.equalTo("user", _user);
        photoquery.include("user");
        //photoquery.include("likes");
        //photoquery.include("location_half");
        //photoquery.include("location_full");

        //var indexOfLastPush = userArr.length - 1;
        //var index = i;

        var today = new Date();
        var lastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 7);
        photoquery.greaterThan('updatedAt', lastWeek);
        
        
        photoquery.find({
          success: function(arr) {
            var totalLikes = 0;
            var fullPhotos = 0;
            var locations = [];
            var followers = [];

            var fullName = _user.get("fullName");
            var email = _user.get("email");
            
            



            var followQuery = new Parse.Query("Followers");
            followQuery.equalTo("userID", _user.id);
            followQuery.greaterThan('updatedAt', lastWeek);
            
            followQuery.each(function(f) {            
              followers.push("f");           
            }).then(function() {
              
                if(arr.length > 0){
                    for (var j = arr.length - 1; j >= 0; j--) {
                      var photo = arr[j];
                      var likesArr = photo.get("likes");
                      var state = photo.get("state");
                      if(likesArr && likesArr.length){
                        totalLikes += likesArr.length;
                      }
                      if(state == "full"){
                        fullPhotos++;
                      }
                      var location_full_str = photo.get("location_full_str");
                      if(location_full_str){
                        locations.pushUnique(location_full_str);
                      }
                    };                    
                }
                

                //if(email == "jtubert@hotmail.com"){
                  //console.log(locations.length);
                  var msg = "You took "+arr.length+" photos this week";
                  var htmlMsg = weeklyMsg(fullName,arr,fullPhotos,totalLikes,followers,locations);
                  var subject = "2by2 weekly digest";
                  Notifications.sendMail(msg,htmlMsg,subject,fullName,email); 

                  
                //}
                
              
            }, function(error) {
              // Set the job's error status
              console.log("Uh oh, something went wrong. ", error);
            });            
          },

          error: function(error) {
            console.log(error.description);
            if(index == indexOfLastPush){
              status.error(error.description);
            }
          }
        }).then(function() {
          // Set the job's success status
            if(index == indexOfLastPush){
              //status.success("weeklyDigestEmail completed successfully. ");
            }
            
          }, function(error) {
          // Set the job's error status
            console.log(error.description);

            if(index == indexOfLastPush){
              status.error(error.description);
            }
          });

        })(i,userArr.length-1,userArr[i]); 
        
      };    
      
    },
    error: function(error) {
      status.error(error.description);
    }
  });  
}