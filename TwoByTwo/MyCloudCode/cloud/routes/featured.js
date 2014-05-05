var Helper = require('cloud/routes/Helper.js');


var photosPerPage = 32;
var page = 0;

exports.index = function(req, resp){
	getPhoto(req,resp);
};

function getPhoto(req,resp) { 
	var Photo = Parse.Object.extend("Photo");
	var query = new Parse.Query(Photo);
	query.equalTo("featured", true);       

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
                    var imageURL = image._url;//.url                       
                    var likeLength = 0;
                    if(photosArr[i]._serverData.likes){
                        likeLength = photosArr[i]._serverData.likes.length;                       
                    }
                    
                    var username_half = Helper.getUsernameHalf(data);
                    var username_full = Helper.getUsernameFull(data);
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

                resp.render('featured', { 
                    allPhotosData: allPhotosData,
                    page: page,
                    totalPhotos: count,
                    totalPages: Math.floor(count/photosPerPage),
                    socialImage: "http://www.2by2app.com/img?featured=true&amp;limit=100"
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