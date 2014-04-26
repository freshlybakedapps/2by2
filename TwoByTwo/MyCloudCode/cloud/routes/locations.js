var locationArr = [];
var latLongArr = [];
var counter = [];
var usersArr = [];
var photoCounter = [];
var namesArr = [];
var likesArr = [];

exports.index = function(req, resp){
  var Photo = Parse.Object.extend("Photo");
  var photoquery = new Parse.Query(Photo);
  photoquery.count({
      success: function(count) {

          getLocations(resp,count,0);  
      },
      error: function(error) {
          console.log("Uh oh, something went wrong.");
      }
  });

  
};

function getLocations(resp,count,skip){
    var Photo = Parse.Object.extend("Photo");
    var photoquery = new Parse.Query(Photo);

    //photoquery.equalTo("state", "half");

    //photoquery.doesNotExist("location_half_str");

    Parse.Cloud.useMasterKey();
    photoquery.include("user");
    photoquery.include("user_full");

    //photoquery.include(["user.id"]);
    //photoquery.include(["user_full.id"]);
    //photoquery.include(["user.fullName"]);
    //photoquery.include(["user_full.fullName"]);

    //photoquery.include("likes");

    //photoquery.select("location_half", "location_full");
    
    photoquery.limit(1000); 
    photoquery.skip(skip);
    
    //http://gmaps-samples-v3.googlecode.com/svn/trunk/toomanymarkers/toomanymarkers.html
    //https://developers.google.com/maps/documentation/javascript/examples/maptype-styled-simple
    photoquery.find({
      success: function(arr) { 
        if (arr.length > 0) {       
          for (var i = arr.length - 1; i >= 0; i--) {
            var photo = arr[i];
            var loc = photo.get("location_full_str");

            if(photo.get("state") == "half"){
              var user = photo.get("user");
              
              var name = user.get("fullName");
              usersArr.push(user.id);
              photoCounter[user.id] = (photoCounter[user.id] || 0) + 1;
              namesArr[user.id] = name; 
            }


            if(photo.get("state") == "full"){

              var userFull = photo.get("user_full");
              if(userFull){
                var name_full = userFull.get("fullName");

                //console.log("xxxxxxxxxx: "+name_full);  

                usersArr.push(userFull.id);
                photoCounter[userFull.id] = (photoCounter[userFull.id] || 0) + 1;
                namesArr[userFull.id] = name_full;
              }
              
            }

            
            //get likes information
            if(photo.get("likes")){
              var obj = {};
              obj.counter = photo.get("likes").length;
              obj.photo = photo;
              obj.filter = photo.get("filter");
              likesArr.push(obj);
            }        


            //.get("username")

            var latLongObj = {};

            if(photo.get("location_full") && photo.get("location_full")._latitude != 0){
              var full_lat = photo.get("location_full")._latitude;
              var full_lon = photo.get("location_full")._longitude;
              var filter = photo.get("filter");

              latLongObj.full = {state:"full",filter:"Double",lat:full_lat,lon:full_lon};
            }

            if(photo.get("location_half") && photo.get("location_half")._latitude != 0){
              var half_lat = photo.get("location_half")._latitude;
              var half_lon = photo.get("location_half")._longitude;

              latLongObj.half = {state:"single",filter:"Single",lat:half_lat,lon:half_lon};
            }

            latLongArr.push(latLongObj);
            


            if(loc){
              counter[loc] = (counter[loc] || 0) + 1;

              locationArr.push(loc);
            }  
          };

          getLocations(resp,count,skip+1000);

          

          
          
          }else{
            var uniqueArr = locationArr.getUnique();
            for (var i = uniqueArr.length - 1; i >= 0; i--) {
              var obj = {};
              obj.counter = counter[uniqueArr[i]];
              obj.loc = uniqueArr[i];
              uniqueArr[i] = obj;
            };

            //get user info
            var uniqueUserArr = usersArr.getUnique();
            for (var i = uniqueUserArr.length - 1; i >= 0; i--) {
              var obj = {};
              obj.counter = photoCounter[uniqueUserArr[i]];
              obj.id = uniqueUserArr[i];
              obj.name = namesArr[uniqueUserArr[i]];
              uniqueUserArr[i] = obj;
            };

            
            //resp.render('locations',{});

            resp.render('locations', { likesArr:likesArr.sort(compare),users:uniqueUserArr.sort(compare),latLongArr:latLongArr, locations:  uniqueArr.sort(compare),totalPhotos:count});

            /*
            resp.render('locations', { 
              likesArr:likesArr.sort(compare),
              users:uniqueUserArr.sort(compare),
              latLongArr:latLongArr,
              locations:  uniqueArr.sort(compare),
              totalPhotos:count
            });
            */
            
          }            
        
      },
      error: function(error) {        
        console.log("ERRRRRRRRRRRROR: "+error.message);
      }
    });           
}



function compare(a,b) {
  if (a.counter < b.counter)
     return 1;
  if (a.counter > b.counter)
    return -1;
  return 0;
}


Array.prototype.getUnique = function(){
   var u = {}, a = [];
   for(var i = 0, l = this.length; i < l; ++i){
      if(u.hasOwnProperty(this[i])) {
         continue;
      }
      a.push(this[i]);
      u[this[i]] = 1;
   }
   return a;
}

