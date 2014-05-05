var Helper = require('cloud/routes/Helper.js');

var photosPerPage = 32;
var page = 0;

exports.index = function(req, resp){
	//console.log(req);
	
	if(req.query.u){
		var currentUserID = req.query.u;
		Parse.Cloud.useMasterKey();    
		var query = new Parse.Query(Parse.User);  		
	  		
	  	query.get(currentUserID, {      
			success: function(user) {		    	
	          	getPhoto(req,resp,user,currentUserID);
	       	},
		    error: function(error) {
		      	console.log(error);
		    }
		});
	  }else{
	  	getPhoto(req,resp,null,null);	
	  }
};

exports.withUserID = function(req, resp){
    if(req.params.u){
        var currentUserID = req.params.u;
        Parse.Cloud.useMasterKey();    
        var query = new Parse.Query(Parse.User);

        console.log(currentUserID);

        query.equalTo("username", currentUserID);

        query.find({
            success: function(userArr) {
                if(userArr.length == 0){
                    resp.render('error', {error: "Username: "+currentUserID+" cannot be found."});
                    //resp.send("Username: "+currentUserID+" cannot be found.");
                }else{
                    getPhoto(req,resp,userArr[0],userArr[0].id);
                }
                
                
            },
            error: function(object, error) {
                // The object was not retrieved successfully.
                // error is a Parse.Error with an error code and description.
                //console.log("error: ",error);
                resp.render('error', {error: error});
            }
        });        
        /*    
        query.get(currentUserID, {      
            success: function(user) {               
                getPhoto(req,resp,user,currentUserID);
            },
            error: function(error) {
                console.log(error);
            }
        });
        */
      }
}

function getPhoto(req,resp,user,id) { 
	//console.log("Parse.User.current(): "+user);
	var id = req.query.id;

	var user2;

    if(id){
    	user2 = new Parse.User();
		user2.id = id;  
    }else{
    	if(user){
    		id = user.id;
    	}else{
    		//if there is no ID or U, the backend doesn't know which user is signed in and cannot display data
    		resp.render('profile2', { 
                    allPhotosData: null,
                    page: 0,
                    totalPhotos: 0,
                    totalPages: 0
                }); 
    	}   	
    }
            
	var Photo = Parse.Object.extend("Photo");
	var query;
    var query1 = new Parse.Query(Photo);
    var query2 = new Parse.Query(Photo);

	

	if(user2){
        query1.equalTo("user", user2);
        query2.equalTo("user_full", user2);    
        query = Parse.Query.or(query1, query2);		 
	}else{
		query1.equalTo("user", user);
        query2.equalTo("user_full", user);    
        query = Parse.Query.or(query1, query2);   
	}    

    query.count({
        success: function(count) {      
            return count;
        },
        error: function(error) {
            console.log("Uh oh, something went wrong.");
        }
    }).then(function(count) {
        query.include("user");
        query.include("user_full");
        query.descending("createdAt");    
        
        query.limit(photosPerPage);

        if(req.query.page){
            page = req.query.page;
        }

        query.skip(page*photosPerPage);
        //}
        query.find({
            success: function(photosArr) {
                var allPhotosData = [];

                for(var i=0;i<photosArr.length  ;i++){
                    
                    var photoData = {};
                    var data = photosArr[i].attributes;                      
                    var image = data.image_full;
                                        
                    if(!image){
                        image = data.image_half;
                    }
                    
                    var username_half = ".";
                    
                    if(data.user && data.user._serverData){
                        username_half = data.user._serverData.username;
                    }
                    
                    var username_full = "";                    

                    if(data.user_full && data.user_full._serverData){
                        username_full = data.user_full._serverData.username;
                    }                    
                    
                    var imageURL = image._url;//.url                       
                    var likeLength = 0;
                    if(photosArr[i] && photosArr[i]._serverData.likes){
                        likeLength = photosArr[i]._serverData.likes.length;                        
                    }                    
                    
                    if(data.location_half){
                        if(data.location_half._longitude == 0){
                            username_half+=" (?)";
                        }
                    }                       

                    if(data.state == "full" && data.location_full){
                        var locationFull = data.location_full;
                        if(locationFull._longitude == 0){
                            username_full+=" (?)";
                        }
                    }

                    var mapImageURL = Helper.getMapImageURL(data);


                    photoData.imageURL = imageURL;
                    photoData.likeLength = likeLength;
                    photoData.photoID = photosArr[i].id;
                    photoData.mapImageURL = mapImageURL;
                    photoData.user = data.user;                         
                    photoData.userFull = data.user_full;                            
                    photoData.currentUser = user;
                    photoData.username_half = username_half;
                    photoData.username_full = username_full;

                    allPhotosData.push(photoData);
                }

                resp.render('profile2', { 
                    allPhotosData: allPhotosData,
                    page: page,
                    totalPhotos: count,
                    totalPages: Math.floor(count/photosPerPage),
                    socialImage:(allPhotosData[0])?allPhotosData[0].imageURL:""
                });             
            },
            error: function(object, error) {
                resp.render('error', {error: error});
            }
        });
    });  
}