var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){  		
  var username = request.params.username;
  var userID = request.params.userID;      
  
  Parse.Cloud.run('getFacebookFriends', { user: userID }, {
      success: function(arr) {        
        for (var i = arr.length - 1; i >= 0; i--) {            
            var msg = "Your facebook friend "+username+", just took a photo, double expose it now!";            
            //var htmlMsg = msg+ "<br><img src='"+ url + "'></img>";
            var htmlMsg = msg;  
            htmlMsg += "<br><br>See photo.";
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