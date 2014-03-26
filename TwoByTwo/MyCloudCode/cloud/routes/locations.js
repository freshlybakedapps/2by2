exports.index = function(req, resp){
  getLocations(resp);  
};

function getLocations(resp){
    var Photo = Parse.Object.extend("Photo");
    var photoquery = new Parse.Query(Photo);
    photoquery.limit(1000); 
    var locationArr = [];
    var counter = [];

    photoquery.find({
      success: function(arr) {        
        for (var i = arr.length - 1; i >= 0; i--) {
          var photo = arr[i];
          var loc = photo.get("location_full_str");
          if(loc){
            counter[loc] = (counter[loc] || 0) + 1;

            locationArr.push(loc);
          }  
        }

        return locationArr;

      },error: function(error) {
            console.log(error);
          }

        //var uniqueArr = locationArr.getUnique();        
        
        
      }).then(function(locArr) {
          photoquery.skip(1000);

          photoquery.find({
            success: function(arr) {        
              for (var i = arr.length - 1; i >= 0; i--) {
                var photo = arr[i];
                var loc = photo.get("location_full_str");
                if(loc){
                  counter[loc] = (counter[loc] || 0) + 1;

                  locationArr.push(loc);
                }  
              };

              var uniqueArr = locationArr.getUnique();

              

              for (var i = uniqueArr.length - 1; i >= 0; i--) {
                var obj = {};
                obj.counter = counter[uniqueArr[i]];
                obj.loc = uniqueArr[i];

                uniqueArr[i] = obj;
              };

              resp.render('locations', { locations:  uniqueArr.sort(compare),totalPhotos:1000+arr.length});            
              
            },
            error: function(error) {        
              console.log(error);
            }
          });           
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

