exports.main = function(request, response){ 
  var isUsernameUnique = "true";

  var usernameToCheck = request.params.username;
  
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  query.each(function(u) {
    var username = u.get("username");

    if(username == usernameToCheck){
      isUsernameUnique = "false";
      return;
    }      

    
  }).then(function() {
    // Set the job's success status
    response.success(isUsernameUnique);
  }, function(error) {
    // Set the job's error status
    response.error("Uh oh, something went wrong. ", error);
  }); 
}