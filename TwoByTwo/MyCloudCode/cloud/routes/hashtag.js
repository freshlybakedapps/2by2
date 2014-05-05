var Helper = require('cloud/routes/Helper.js');

var photosPerPage = 32;
var page = 0;

exports.index = function(req, resp){
	var Comment = Parse.Object.extend("Comment");
	var commentQuery = new Parse.Query(Comment);
	commentQuery.contains("text", "#"+req.params.hash);

	commentQuery.find({
            success: function(commentsArr) {
            	var idArray = [];

            	

            	for (var i = commentsArr.length - 1; i >= 0; i--) {
            		//console.log(commentsArr[i].attributes.commentID);
            		idArray.push(commentsArr[i].attributes.commentID);
            	};
            	getPhoto(req,resp,idArray);

            },
            error: function(object, error) {
                // The object was not retrieved successfully.
                // error is a Parse.Error with an error code and description.
                console.log("error: ",error);
            }
    });
	
};

function getPhoto(req,resp,idArray) { 
	//console.log("Parse.User.current(): "+user);
	var Photo = Parse.Object.extend("Photo");
	var query = new Parse.Query(Photo);
	query.containedIn("objectId", idArray);       

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

                    

                    if(data.user_full){
                        username_full = data.user_full._serverData.username;
                    }

                    
                    
                    var imageURL = image._url;//.url                       
                    var likeLength = 0;
                    if(photosArr[i]._serverData.likes){
                        likeLength = photosArr[i]._serverData.likes.length;

                        //that.getLikesInfo(photosArr[i]._serverData.likes);
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
                    photoData.currentUser = null;
                    photoData.username_half = username_half;
                    photoData.username_full = username_full;

                    allPhotosData.push(photoData);
                }                

                resp.render('hashtag', { 
                    allPhotosData: allPhotosData,
                    page: page,
                    totalPhotos: count,
                    totalPages: Math.floor(count/photosPerPage),
                    socialImage: "http://www.2by2app.com/img?featured=true",
                    hasgtag:req.params.hash
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