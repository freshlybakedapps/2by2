exports.main = function(request, response){
    Parse.Cloud.useMasterKey();
    var user = request.params.user;
	var query = new Parse.Query(Parse.User);  		
  		
  	query.get(user.id, {      
		success: function(user) {		    	
          	response.success(user.get('authData').facebook.id);
       	},
	    error: function(error) {
	      	response.error(error);
	    }
	});
}