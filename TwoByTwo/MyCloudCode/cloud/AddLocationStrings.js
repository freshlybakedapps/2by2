exports.main = function(request, status){
  //Parse.Cloud.useMasterKey();  
  var Photo = Parse.Object.extend("Photo");
  var photoquery = new Parse.Query(Photo);

  var counter = 0;
  var locCounter = 0;
  

  photoquery.each(function(photo) {
    var location_full = photo.get("location_full"); 
    counter++;   

    
    if(photo.get("location_full_str") == undefined && photo.get("state") == "full"){
          
      Parse.Cloud.httpRequest({
        url:'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&latlng='+location_full.latitude + "," + location_full.longitude
      }).then(function(httpResponse){
        locCounter++;
        if(httpResponse.data.results[0]){          
          //Queens, Queens, Forest Hills, 72nd Avenue, 103-0-103-98
          //New York, Manhattan, Hell's Kitchen, West 39th Street, 318
          //Kings, Brooklyn, Bushwick, Knickerbocker Avenue, 276
          var str = httpResponse.data.results[0].address_components[2].long_name +", "+ httpResponse.data.results[0].address_components[5].short_name;
          //console.log(str);
          
          photo.set("location_full_str", str);
          return photo.save();
        }else{
          console.log('http://maps.googleapis.com/maps/api/geocode/json?sensor=false&latlng='+location_full.latitude + "," + location_full.longitude);
        }
      },function(error){
        console.log(error);
      });      
      
  }

    
  }).then(function() {
    console.log(counter+" / "+locCounter);
    // Set the job's success status
    //status.success("AddLocationString completed successfully. - "+counter+"/"+locCounter);
  }, function(error) {
    // Set the job's error status
    status.error("Uh oh, something went wrong. ", error);
  });
}