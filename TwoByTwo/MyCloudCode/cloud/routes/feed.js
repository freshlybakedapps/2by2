var Helper = require('cloud/routes/Helper.js');


var photosPerPage = 32;
var page = 0;

exports.index = function(req, resp){
	getPhoto(req,resp);	
};

function getPhoto(req,resp,user,id) { 
	var Photo = Parse.Object.extend("Photo");	
    var query1 = new Parse.Query(Photo);
    var query2 = new Parse.Query(Photo);
    var query = new Parse.Query(Photo);
    
    if(req.params.type && req.params.type == "single"){
        query.equalTo("state", "half");
    }else if(req.params.type && req.params.type == "public"){
        query.equalTo("state", "full");
    }else if(req.params.type && req.params.extra && req.params.type == "filter"){
        query.contains("filter", req.params.extra);
    }else if(req.params.type && req.params.extra && req.params.type == "comments"){
        query.greaterThanOrEqualTo("comment_count", req.params.extra);
    }else if(req.params.type && req.params.extra && req.params.type == "likes"){
        query.greaterThanOrEqualTo("likes", req.params.extra);
    }else if(req.params.type && req.params.type == "featured"){
        query.equalTo("featured", true);
    }else if(req.params.type && req.params.extra && req.params.type == "location"){
        query1.contains("location_half_str", req.params.extra);
        query2.contains("location_full_str", req.params.extra);
        query = Parse.Query.or(query1, query2); 
    }else if(req.params.type && req.params.extra && req.params.type == "user"){
        var userQuery = new Parse.Query(Parse.User);
        userQuery.equalTo("username", req.params.extra);
        query1.matchesQuery("user", userQuery);
        query2.matchesQuery("user_full", userQuery);
        query = Parse.Query.or(query1, query2);
    }

    query.count({
        success: function(count) {      
            return count;
        },
        error: function(error) {
            resp.render('error', {error: error});
            //console.log("Uh oh, something went wrong.");
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
                    
                    var username_half = "";
                    if(data.user){
                        data.user._serverData.username;
                    }
                    
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


                if(allPhotosData.length > 0){
                        resp.render('profile2', { 
                        allPhotosData: allPhotosData,
                        page: page,
                        totalPhotos: count,
                        totalPages: Math.floor(count/photosPerPage),
                        socialImage:allPhotosData[0].imageURL
                    });   
                }else{
                    //resp.send("No photos available for this query");
                    resp.render('error', {error: "No photos available for this query"});
                }

                          
            },
            error: function(object, error) {
                // The object was not retrieved successfully.
                // error is a Parse.Error with an error code and description.
                //console.log("error: ",error);
                resp.render('error', {error: error});
            }
        });
    });  
	  
	        
	
	
}