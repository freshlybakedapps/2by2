exports.index = function(req, resp){
	//console.log(req);	
	getPhoto(req.query.id,resp);	
};

function getPhoto(id,resp) { 
	console.log("Parse.User.current(): ",Parse.User.current());

	var currentUser = Parse.User.current();

            
	var Photo = Parse.Object.extend("Photo");
	var query = new Parse.Query(Photo);
	//query.limit(0);
	query.include("user");
	query.include("user_full");          
	        

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
	                
	                var username_half = data.user._serverData.username;
	                var username_full = "";

	                if(Parse.User.current() && username_half == Parse.User.current().attributes.username){
	                    username_half = "You!";
	                }

	                if(data.user_full){
	                    username_full = data.user_full._serverData.username;
	                }

	                if(Parse.User.current() && username_full == Parse.User.current().attributes.username){
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
	                
	                var markers;

	                if(data.location_half){
	                    if(data.location_half._longitude == 0){
	                        username_half+=" (?)";
	                    }else{
	                        markers = "&markers=icon:http://2by2.parseapp.com/images/red.png%7Ccolor:0xff3366%7C"+locationHalf._latitude+","+locationHalf._longitude;
	                    }
	                }                       

	                if(data.state == "full" && data.location_full){
	                    var locationFull = data.location_full;
	                    if(locationFull._longitude == 0){
	                        username_full+=" (?)";
	                    }else{
	                        markers+="&markers=icon:http://2by2.parseapp.com/images/green.png%7Ccolor:0x00cc99%7C"+locationFull._latitude+","+locationFull._longitude;
	                    }
	                }
	                //&center=Brooklyn+Bridge,New+York,NY&zoom=13
                	var mapImageURL = "http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDvTIlW1eCIiKGx9OsJuw1fWg_tvVUJRJA&style=saturation:-100%7Clightness:-57&size=500x500&maptype=roadmap"+markers+"&sensor=false";
            		
            		resp.render('pdp2', { 
							imageURL: imageURL,
							likeLength:likeLength,
							photoID:photosArr[i].id,
							mapImageURL:mapImageURL,
							user:data.user,							
							userFull:data.user_full,							
							currentUser:currentUser,
						});
            	}
                


	            
	        },
	        error: function(object, error) {
	            // The object was not retrieved successfully.
	            // error is a Parse.Error with an error code and description.
	            console.log("error: ",error);
	        }
		});
	}else{
	    console.log("no id");                
	}
}