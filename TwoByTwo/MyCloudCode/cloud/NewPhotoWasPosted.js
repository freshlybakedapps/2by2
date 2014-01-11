var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){  		
  var username = request.params.username;
  var userID = request.params.userID;      
  
  Parse.Cloud.run('getFacebookFriends', { user: userID }, {
      success: function(arr) {        
        for (var i = arr.length - 1; i >= 0; i--) {            
            var msg = "Hey "+arr[i].name+", "+username+" just posted a photo.";
            
            //var htmlMsg = msg+ "<br><img src='"+ url + "'></img>";
            var htmlMsg = msg;  
            htmlMsg += "<br>Collaborate by double exposing it... or not!.";
            htmlMsg += "<br><br>";
            htmlMsg += "Thanks,";
            htmlMsg += "<br>Team 2by2";
            htmlMsg += "<br>PS: To stop receiving this email, turn this notification off in the app settings page.";

            var subject = msg;

            if(i == 0){
              Notifications.sendNotifications(null,"newPhoto",arr[i].parseID,msg,htmlMsg,subject,"0","",userID,username,msg);    
            }else{
              Notifications.sendNotifications(null,"newPhoto",arr[i].parseID,msg,htmlMsg,subject,"0","",userID,username,msg);    
            }
                 
        };        
      },
      error: function(error) {
        console.log(error);
      }
    });

    


  

    

 
}