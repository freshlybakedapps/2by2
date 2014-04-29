var mandrill = require('mandrill');
mandrill.initialize('xpHTh_PelNA7rlzTzWUe4g');
var _ = require('underscore.js');

var counter = 0;

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
    msg += "How about you take a new photo right now and show 'em how it's done!<br>";
  }  
  
  msg += "<br>Thanks, the 2by2 team.<br>";  
  //msg += "<a href='mailTo:2by2app@gmail.com'>Tell a friend about 2by2</a><br><br>";
  msg += '<A HREF="mailto:?subject=Invitation to join 2by2&body=Hey, 2by2 Is a fun and easy to make unexpected double exposure photos with friends (or with total strangers.) %0DHere is a link to download the app, it is totally free:%0D https://itunes.apple.com/us/app/2by2!/id836711608?ls=1&mt=8">Tell a friend about 2by2</A><br><br>'
  
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
    Parse.Cloud.useMasterKey();
    var query = new Parse.Query(Parse.User);
    query.exists("email");
    query.equalTo("digestEmailAlert", true);

    query.count({
        success: function(count) {
          //console.log("Count:-------"+count);
          main(request, status,count,0);
              
        },
        error: function(error) {
            console.log("Uh oh, something went wrong.");
        }
    });

    
}

function main(request, status,count,skip) {
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  query.exists("email");
  query.equalTo("digestEmailAlert", true);  
  query.limit(1000);
  query.skip(skip);
  
  //http://stackoverflow.com/questions/22275508/parse-com-cloud-job-promise-with-nested-query
  
  query.find().then(function(users) {
      if(users == 0){
        status.success('WeeklyDigest sent- '+ counter+" / "+count);
      }

      var promises = [];
      _.each(users, function(user) {
          promises.push((function(user){
              counter++;
              var promise = new Parse.Promise();
              
              var Photo = Parse.Object.extend("Photo");
              var photoquery = new Parse.Query(Photo);
              photoquery.equalTo("user", user);
              photoquery.include("user");
              
              var today = new Date();
              var lastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 7);
              photoquery.greaterThan('updatedAt', lastWeek);

              photoquery.find({  
                  success: function(arr) {
                      var totalLikes = 0;
                      var fullPhotos = 0;
                      var locations = [];
                      var followers = [];

                      var fullName = user.get("fullName");
                      var email = user.get("email");
                      
                      ////////

                      var followQuery = new Parse.Query("Followers");
                      followQuery.equalTo("userID", user.id);
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

                          
                          var msg = "You took "+arr.length+" photos this week";
                          var htmlMsg = weeklyMsg(fullName,arr,fullPhotos,totalLikes,followers,locations);
                          var subject = "2by2 weekly digest";




                          Parse.Cloud.httpRequest({ method: 'POST', headers: {
                            'Content-Type': 'application/json; charset=utf-8'
                            }, url: 'https://mandrillapp.com/api/1.0/messages/send.json', body: {
                            key: "xpHTh_PelNA7rlzTzWUe4g",
                            message: {
                              html: htmlMsg,
                              subject: subject,
                              from_email: "2by2app@gmail.com",
                              from_name: "2by2",
                              to: [
                                {
                                   email: email, //"jtubert@gmail.com",//
                                   name: fullName
                                }
                              ]
                            }

                            }, success: function(httpResponse) {

                              console.log("Email sent!");
                              promise.resolve();

                            }, error: function(httpResponse) {

                              console.log(httpResponse);
                              status.error(httpResponse.error); 

                          } });
                          
                          

                          
                      })               

                      ////////             
                         
                  },
                  error: function(error) {
                      status.error(error);
                  }

              });
              return promise;
          })(user));
      });
      return Parse.Promise.when(promises);
  })
  .then(function() {
      //status.success('WeeklyDigest successfully sent. - '+ counter);
      main(request, status,count,skip+1000)
  });
  

  
}