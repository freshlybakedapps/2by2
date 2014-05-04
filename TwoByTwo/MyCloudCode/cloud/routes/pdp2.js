exports.index = function(req, resp){
	//console.log(req);
	
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
		      	//console.log(error);
		    }
		});
	  }else{
	  	getPhoto(req,resp,null);	
	  }
};


function getPhoto(req,resp,user) { 
	console.log("Parse.User.current(): "+user);

            
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
	                
	                var username_half = "";
                    
                    if(data.user && data.user._serverData){
                        username_half = (data.user._serverData.username);
                    }
                    
                    var username_full = "";

                    /*
                    if(user && username_half == user._serverData.username){
                        //username_half = "You!";
                    }
                    */

                    if(data.user_full && data.user_full._serverData){
                        username_full = (data.user_full._serverData.username);
                    }

                    //console.log(username_full+" / "+user._serverData.username);

                    /*
                    if(user && username_full == user._serverData.username){
                        //username_full = "You!";
                    }
                    */
	                
	                var imageURL = image._url;//.url                       
	                var likeLength = 0;
	                if(photosArr[i]._serverData.likes){
	                    likeLength = photosArr[i]._serverData.likes.length;

	                    //that.getLikesInfo(photosArr[i]._serverData.likes);
	                }



	                var locationHalf = data.location_half;
	                var location_half_str = data.location_half_str;


	                //static maps doc: https://developers.google.com/maps/documentation/staticmaps/?csw=1#StyledMaps
	                //https://developers.google.com/maps/documentation/staticmaps/?csw=1#CustomIcons
	                //style map: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
	                //Get API key: https://cloud.google.com/console/project

	                //http://www.2by2app.com/images/red.png
	                //http://www.2by2app.com/images/green.png
	                
	                var markers = "";

	                /*
	                if(data.location_half){
	                    if(data.location_half._longitude == 0){
	                        username_half+=" (?)";
	                    }else{
	                        markers = "&markers=icon:http://www.2by2app.com/images/red.png%7Ccolor:0xff3366%7C"+locationHalf._latitude+","+locationHalf._longitude;
	                        markers += "&visible="+(locationHalf._latitude+0.01)+","+(locationHalf._longitude+0.01);
	                    }
	                }                       

	                if(data.state == "full" && data.location_full){
	                    var locationFull = data.location_full;
	                    if(locationFull._longitude == 0){
	                        username_full+=" (?)";
	                    }else{
	                        markers+="&markers=icon:http://www.2by2app.com/images/green.png%7Ccolor:0x00cc99%7C"+locationFull._latitude+","+locationFull._longitude;
	                        markers += "&visible="+(locationFull._latitude+0.01)+","+(locationFull._longitude+0.01);
	                    }
	                }
	                */

	                var locations = 0;

	                if(data.location_half){
                        if(data.location_half._longitude == 0){
                            username_half+=" (?)";
                        }else{
                            if(location_half_str && location_half_str != ""){
                                markers = "&markers=icon:http://www.2by2app.com/images/red.png%7Ccolor:0xff3366%7C"+encodeURIComponent(location_half_str);
 								locations++;
                            }
                            //markers += "&visible="+(locationHalf._latitude+0.01)+","+(locationHalf._longitude+0.01);
                        }
                    }                       

                    if(data.state == "full" && data.location_full){
                        var locationFull = data.location_full;
                        if(locationFull._longitude == 0){
                            username_full+=" (?)";
                        }else{
                            var location_full_str = data.location_full_str;

                            if(location_full_str && location_full_str != ""){
                                markers+="&markers=icon:http://www.2by2app.com/images/green.png%7Ccolor:0x00cc99%7C"+encodeURIComponent(location_full_str);
                            	locations++;
                            }
                            //markers += "&visible="+(locationFull._latitude+0.01)+","+(locationFull._longitude+0.01);
                        }
                    }

                    if(locations == 2 && location_full_str == location_half_str){
                        markers = "&markers=icon:http://www.2by2app.com/images/SameLocation.png%7Ccolor:0xff3366%7C"+encodeURIComponent(location_half_str);
                    }

	                //&center=Brooklyn+Bridge,New+York,NY&zoom=13
                	var mapImageURL = "http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDvTIlW1eCIiKGx9OsJuw1fWg_tvVUJRJA&style=saturation:-100%7Clightness:-57&size=500x500&maptype=roadmap"+markers+"&sensor=false";
            		
                	if(locations == 0){
                        if(data.state == "full"){
                        	mapImageURL = "/markup/img/NoLocationSharedBoth@2x.png";
                        }else{
                        	mapImageURL = "/markup/img/NoLocationShared@2x.png";
                        }
                        
                    }


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
	            // The object was not retrieved successfully.
	            // error is a Parse.Error with an error code and description.
	            resp.render('error', {error: error});
	        }
		});
	}else{
	    resp.render('error', {error: "No username or id"});
	    console.log("no id");                
	}
}