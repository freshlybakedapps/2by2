var photosPerPage = 32;
var page = 0;

exports.index = function(req, resp){
	getPhoto(req,resp);	
};

function getPhoto(req,resp,user,id) { 
	var Photo = Parse.Object.extend("Photo");	
    var query = new Parse.Query(Photo);
    
    if(req.params.type && req.params.type == "single"){
        query.equalTo("state", "half");
    }else if(req.params.type && req.params.type == "public"){
        query.equalTo("state", "full");
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
                        //username_half = "You!";
                    }

                    if(data.user_full){
                        username_full = data.user_full._serverData.username;
                    }

                    //console.log(username_full+" / "+user._serverData.username);

                    if(user && username_full == user._serverData.username){
                        //username_full = "You!";
                    }
                    
                    var imageURL = image._url;//.url                       
                    var likeLength = 0;
                    if(photosArr[i]._serverData.likes){
                        likeLength = photosArr[i]._serverData.likes.length;

                        //that.getLikesInfo(photosArr[i]._serverData.likes);
                    }



                    var locationHalf = data.location_half;
                    var location_half_str = data.location_half_str;
                    //location_half_str.replace(" ","");


                    //static maps doc: https://developers.google.com/maps/documentation/staticmaps/?csw=1#StyledMaps
                    //https://developers.google.com/maps/documentation/staticmaps/?csw=1#CustomIcons
                    //style map: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
                    //Get API key: https://cloud.google.com/console/project           
                    
                    var markers = "";

                    
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
                    

                    //markers = encodeURIComponent(markers);
                    //&center=Brooklyn+Bridge,New+York,NY&zoom=13
                    var mapImageURL = "http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDvTIlW1eCIiKGx9OsJuw1fWg_tvVUJRJA&style=saturation:-100%7Clightness:-57&size=500x500&maptype=roadmap"+markers+"&sensor=false";
                    
                    if(locations == 0){
                        if(data.state == "full"){
                            mapImageURL = "/markup/img/NoLocationSharedBoth@2x.png";
                        }else{
                            mapImageURL = "/markup/img/NoLocationShared@2x.png";
                        }
                        
                    }


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
                    socialImage:allPhotosData[0].imageURL
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