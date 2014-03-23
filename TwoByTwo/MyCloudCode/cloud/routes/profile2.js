var photosPerPage = 30;
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
      }else if(req.params.u){

        getPhoto(req,resp,null,req.params.u);    
      }
}

function getDistance(lat1, lat2, lon1, lon2){
    var R = 6371; // km
    var dLat = (lat2-lat1).toRad();
    var dLon = (lon2-lon1).toRad();
    var lat1 = lat1.toRad();
    var lat2 = lat2.toRad();
    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
    return R * c;
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
                    
                    var username_half = data.user._serverData.username;
                    var username_full = "";

                    if(user && username_half == user._serverData.username){
                        username_half = "You!";
                    }

                    if(data.user_full){
                        username_full = data.user_full._serverData.username;
                    }

                    //console.log(username_full+" / "+user._serverData.username);

                    if(user && username_full == user._serverData.username){
                        username_full = "You!";
                    }
                    
                    var imageURL = image._url;//.url                       
                    var likeLength = 0;
                    if(photosArr[i]._serverData.likes){
                        likeLength = photosArr[i]._serverData.likes.length;

                        //that.getLikesInfo(photosArr[i]._serverData.likes);
                    }



                    var locationHalf = data.location_half;


                    //static maps doc: https://developers.google.com/maps/documentation/staticmaps/?csw=1#StyledMaps
                    //https://developers.google.com/maps/documentation/staticmaps/?csw=1#CustomIcons
                    //style map: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
                    //Get API key: https://cloud.google.com/console/project

                    //http://2by2.parseapp.com/images/red.png
                    //http://2by2.parseapp.com/images/green.png
                    
                    var markers = "";

                    if(data.location_half){
                        if(data.location_half._longitude == 0){
                            username_half+=" (?)";
                        }else{
                            markers = "&markers=icon:http://2by2.parseapp.com/images/red.png%7Ccolor:0xff3366%7C"+locationHalf._latitude+","+locationHalf._longitude;
                            markers += "&visible="+(locationHalf._latitude+0.01)+","+(locationHalf._longitude+0.01);
                        }
                    }                       

                    if(data.state == "full" && data.location_full){
                        var locationFull = data.location_full;
                        if(locationFull._longitude == 0){
                            username_full+=" (?)";
                        }else{
                            markers+="&markers=icon:http://2by2.parseapp.com/images/green.png%7Ccolor:0x00cc99%7C"+locationFull._latitude+","+locationFull._longitude;
                            markers += "&visible="+(locationFull._latitude+0.01)+","+(locationFull._longitude+0.01);
                        }
                    }
                    //&center=Brooklyn+Bridge,New+York,NY&zoom=13
                    var mapImageURL = "http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDvTIlW1eCIiKGx9OsJuw1fWg_tvVUJRJA&style=saturation:-100%7Clightness:-57&size=500x500&maptype=roadmap"+markers+"&sensor=false";
                    

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
                    totalPages: Math.floor(count/photosPerPage)
                });             
            },
            error: function(object, error) {
                // The object was not retrieved successfully.
                // error is a Parse.Error with an error code and description.
                console.log("error: ",error);
            }
        });
    });  
	  
	        
	
	
}