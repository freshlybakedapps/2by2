var Helper = require('cloud/routes/Helper.js');

exports.index = function(req, resp){	
	if(req.query.u){
		var currentUserID = req.query.u;
		Parse.Cloud.useMasterKey();    
		var query = new Parse.Query(Parse.User);  		
	  		
	  	query.get(currentUserID, {      
			success: function(user) {		    	
	          	getPhoto(req,resp,user);
	       	},
		    error: function(error) {
		    	resp.render('error', {error: error});		      	
		    }
		});
	  }else{
	  	getPhoto(req,resp,null);	
	  }
};

function getPhoto(req,resp,user) { 
	//console.log("Parse.User.current(): "+user);
	var Photo = Parse.Object.extend("Photo");
	var query = new Parse.Query(Photo);
	//query.limit(0);
	query.include("user");
	query.include("user_full");  

	var id = req.query.id || req.params.id;        
	        

	if(id){
	    query.equalTo("objectId", id);
	    
	    query.find({
	        success: function(photosArr) {
	            for(var i=0;i<photosArr.length  ;i++){
		            var data = photosArr[i].attributes;
	                var image = data.image_full;
	                if(!image){
	                    image = data.image_half;
	                }
	                var imageURL = image._url;//.url                       
	                var likeLength = 0;
	                if(photosArr[i]._serverData.likes){
	                    likeLength = photosArr[i]._serverData.likes.length;	                   
	                }
	                
                    var username_half = Helper.getUsernameHalf(data);
                    var username_full = Helper.getUsernameFull(data);
                    var mapImageURL = Helper.getMapImageURL(data);

            		resp.render('pdp2', { 
							imageURL: imageURL,
							likeLength:likeLength,
							photoID:photosArr[i].id,
							mapImageURL:mapImageURL,
							user:data.user,							
							userFull:data.user_full,							
							currentUser:user,
							username_half:username_half,
							username_full:username_full,
							socialImage:imageURL
						});
            	}            
	        },
	        error: function(object, error) {	            
	            resp.render('error', {error: error});
	        }
		});
	}else{
	    resp.render('error', {error: "No username or id"});	              
	}
}