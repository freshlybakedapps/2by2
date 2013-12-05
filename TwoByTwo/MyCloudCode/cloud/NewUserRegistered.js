var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  var userID = request.params.userID;
  var newRegisteredUser_username = request.params.username;
  
  var counter = 0;
  

  var userQuery = new Parse.Query(Parse.User);
  userQuery.each(function(user) {
    var currentUser_fullName = user.get("fullName");

    
    

    //don't run this for the user that just registered
    if(user.id != userID){
        var url = 'https://graph.facebook.com/'+user.get('authData').facebook.id+'/friends?access_token='+user.get('authData').facebook.access_token;
        //var url =  "https://graph.facebook.com/"+user.get('authData').facebook.id+"?fields=friends.fields(name)&access_token="+user.get('authData').facebook.access_token;

        console.log(currentUser_fullName+" / "+url);
        Parse.Cloud.httpRequest({
          url:url,
          success:function(httpResponse){
            
            counter++;

            var facebookFriends = httpResponse.data.data;

            for (var i = facebookFriends.length - 1; i >= 0; i--) {
              var n1 = facebookFriends[i].name;

              if(newRegisteredUser_username == n1){
                //send email/notification to current user letting them know their friend just joined 2by2
                var msg = currentUser_fullName + ", "+ newRegisteredUser_username + " just joined 2by2!!";
                Notifications.sendPush(user.id,msg);
              }
              
              
            };
          },
          error:function(httpResponse){
            //response.error(httpResponse);
          }
        });
    }
    
  }).then(function() {
    //response.success("counter: "+counter);
  });
   
  
  
}