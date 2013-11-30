var mandrill = require('mandrill');
mandrill.initialize('xpHTh_PelNA7rlzTzWUe4g');



exports.sendMail = function(msg,htmlMsg,subject,username,email){
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

exports.sendPush = function(userID,msg){
	var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo('deviceType', 'ios');
    pushQuery.equalTo('channels', userID);//'SREzPjOawD');//

    //console.log("user.objectId: "+user.id);
    Parse.Push.send({
      where: pushQuery, // Set our Installation query
      data: {
        alert: msg 
      }
      }, {
      success: function() {
        // Push was successful
      },
      error: function(error) {
        throw "Got an error " + error.code + " : " + error.message;
      }
    });
}

