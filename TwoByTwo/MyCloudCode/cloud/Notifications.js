var mandrill = require('mandrill');
mandrill.initialize('xpHTh_PelNA7rlzTzWUe4g');


/*
    var query = new Parse.Query("Comments");
query.equalTo("post", 123);
 
query.find().then(function(results) {
  // Collect one promise for each delete into an array.
  var promises = [];
  _.each(results, function(result) {
    // Start this delete immediately and add its promise to the list.
    promises.push(result.destroy());
  });
  // Return a new promise that is resolved when all of the deletes are finished.
  return Parse.Promise.when(promises);
 
}).then(function() {
  // Every comment was deleted.
});



  */


exports.sendNotifications = function(response,notificationType,userID,msg,htmlMsg,subject,photoID,locationString,byUserID,byUsername,content){
  //NOTIFICATION TYPES
  // - comment
  // - overexposed
  // - follow
  // - like
  // - newUser
  // - flag
  // - newPhoto


  console.log("(sendNotifications) - "+notificationType+"    /   "+userID);

  Parse.Cloud.useMasterKey();

  var query = new Parse.Query(Parse.User);



  query.get(userID, {
    success: function(user) {
      var email = user.get("email");
      var username = user.get("username");
      

      var userAllowsPush;
      var userAllowsEmail;

      if(notificationType == "overexposed"){
        userAllowsEmail = user.get("overexposeEmailAlert");
        userAllowsPush = user.get("overexposePushAlert");
      }else if(notificationType == "comment"){
        userAllowsEmail = user.get("commentsEmailAlert");
        userAllowsPush = user.get("commentsPushAlert");
      }else if(notificationType == "follow"){
        userAllowsEmail = user.get("followsEmailAlert");
        userAllowsPush = user.get("followsPushAlert");
      }else if(notificationType == "like"){
        userAllowsEmail = user.get("likesEmailAlert");
        userAllowsPush = user.get("likesPushAlert");
      }else if(notificationType == "newUser"){
        userAllowsEmail = true;
        userAllowsPush = true;
      }else if(notificationType == "flag"){
        userAllowsEmail = true;
        userAllowsPush = false;
      }else if(notificationType == "newPhoto"){
        userAllowsEmail = false;
        userAllowsPush = true;
      }

      console.log("(sendNotifications/success) - "+notificationType+"    /   "+user.id + " / " + byUserID + " / " + email);

      //var digestEmailAlert = user.get("digestEmailAlert");

      //This should always happen (unless is the same user)
      if(user.id != byUserID){
        
        if(byUserID && byUserID != ""){
          var query2 = new Parse.Query(Parse.User);
          query2.get(byUserID, {
            success: function(u) {
              var facebookID = u.get('authData').facebook.id;
              console.log("byUserID/facebookID: "+ facebookID);
              addNotification(user.id,photoID,notificationType,byUserID,byUsername,locationString,content,facebookID);
            },
            error: function(error) {
                console.log("Got an error " + error);

                if(response){
                  response.error(error);
                }
            }
          });
        }else{
          addNotification(user.id,photoID,notificationType,byUserID,byUsername,locationString,content,"");
        }
        

        
      }
      
      if(userAllowsPush == true){
        sendPush(user.id,msg,photoID);
      }
      
      if(userAllowsEmail == true){
        console.log("send email...");
        sendMail(msg,htmlMsg,subject, username,email);
      }
      
      if(response){
        response.success("Notifications sent");
      }
      
    
    },
    error: function(error) {
        console.log("Got an error " + error);

        if(response){
          response.error(error);
        }
    }
  });

}


function addNotification(notificationID,photoID,notificationType,byUserID,byUsername,locationString,content,facebookID){
  console.log("addNotification"+" / "+notificationID+" / "+photoID+" / "+notificationType+" / "+byUserID+" / "+byUsername+" / "+locationString);
  var Notification = Parse.Object.extend("Notification");
  var notification = new Notification();
  notification.set("notificationID", notificationID);
  notification.set("photoID", photoID);
  notification.set("notificationType", notificationType);
  notification.set("byUserID", byUserID);
  notification.set("byUsername", byUsername);
  notification.set("locationString", locationString);
  notification.set("content", content);

  if(facebookID && facebookID != ""){
    notification.set("facebookID",facebookID);
  }
  


  notification.save(null, {
    success: function (n) {
        console.log("Save ok");
    },
    error: function (item,error) {
        console.log("Save error: " + error.message);
    }
});
}

function sendMail(msg,htmlMsg,subject,username,email){
    mandrill.sendEmail({
        message: {
          text: msg,
          html: htmlMsg,
          subject: subject,
          from_email: "2by2app@gmail.com",
          from_name: "2by2",
          to: [                     
            {
              email: email, //"jtubert@gmail.com",//
              name: username
            }
          ]
        },
        async: true
      }, {
        success: function(httpResponse) { console.log("Email sent!"); },
        error: function(httpResponse) { console.log("Uh oh, something went wrong"); }
      });
}

function sendPush(userID,msg,photoID){
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo('deviceType', 'ios');
  pushQuery.equalTo('channels', userID);//'SREzPjOawD');//

    console.log("user.objectId: "+userID);
    Parse.Push.send({
      where: pushQuery, // Set our Installation query
      data: {
        alert: msg,
        badge: "Increment",
        p: photoID 
      }
      }, {
      success: function() {
        console.log("success: '"+msg+"' was sent!");
      },
      error: function(error) {
        console.log("Got an error " + error.code + " : " + error.message);
      }
    });
}

exports.addNotification = function(notificationID,photoID,notificationType,byUserID,byUsername,locationString,content){
  addNotification(notificationID,photoID,notificationType,byUserID,byUsername,locationString,content);
}

exports.sendMail = function(msg,htmlMsg,subject,username,email){
	  sendMail(msg,htmlMsg,subject,username,email);
}

exports.sendPush = function(userID,msg,photoID){
	 sendPush(userID,msg,photoID);
}

