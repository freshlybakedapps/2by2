var likesArr = [];

exports.index = function(req, resp){
  var Photo = Parse.Object.extend("Photo");
  var photoquery = new Parse.Query(Photo);
  photoquery.count({
      success: function(count) {

          getTopLikes(resp,count,0);  
      },
      error: function(error) {
          console.log("Uh oh, something went wrong.");
      }
  });

  
};

function getTopLikes(resp,count,skip){
    var Photo = Parse.Object.extend("Photo");
    var photoquery = new Parse.Query(Photo);    

    Parse.Cloud.useMasterKey();
    photoquery.include("user");
    photoquery.include("user_full");
    
    photoquery.limit(1000); 
    photoquery.skip(skip);    
    
    photoquery.find({
      success: function(arr) { 
        if (arr.length > 0) {       
          for (var i = arr.length - 1; i >= 0; i--) {
            var photo = arr[i];           

            //get likes information
            if(photo.get("likes")){
              var obj = {};
              obj.counter = photo.get("likes").length;
              obj.photo = photo;
              obj.filter = photo.get("filter");
              likesArr.push(obj);
            }         
          };

          getTopLikes(resp,count,skip+1000);
          
          }else{
            resp.render('topLikes', {likesArr:likesArr.sort(compare)});
          }            
        
      },
      error: function(error) {        
        console.log("ERRRRRRRRRRRROR: "+error.message);
        resp.render('error', {error: error.message});     
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

