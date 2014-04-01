var locationArr = [];
var latLongArr = [];
var counter = [];
var usersArr = [];
var photoCounter = [];
var namesArr = [];

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
    Parse.Cloud.useMasterKey();
    photoquery.include("user");
    photoquery.include("user_full");
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

            var user = photo.get("user");
            var userFull = photo.get("user_full");
            var name = user.get("fullName");
            usersArr.push(user.id);
            photoCounter[user.id] = (photoCounter[user.id] || 0) + 1;
            namesArr[user.id] = name; 


            if(photo.get("state") == "full"){
              var name_full = userFull.get("fullName");
              usersArr.push(userFull.id);
              photoCounter[userFull.id] = (photoCounter[userFull.id] || 0) + 1;
              namesArr[userFull.id] = name_full;
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


            resp.render('locations', { users:uniqueUserArr.sort(compare),latLongArr:latLongArr,mapURL: getMapURL(uniqueArr.sort(compare)), locations:  uniqueArr.sort(compare),totalPhotos:count});
          }            
        
      },
      error: function(error) {        
        console.log(error);
      }
    });           
}

function getMapURL(arr){
  var markers = "&markers=";

  for (var i = 0; i < 50; i++) {
    markers += encodeURIComponent(arr[i].loc)+"|";
   
  };
                    
  
  return "http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDvTIlW1eCIiKGx9OsJuw1fWg_tvVUJRJA&style=saturation:-100%7Clightness:-57&size=500x500&maptype=roadmap"+markers+"&sensor=false";

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

