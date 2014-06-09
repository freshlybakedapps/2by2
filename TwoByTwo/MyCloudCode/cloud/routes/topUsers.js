var locationArr = [];
var latLongArr = [];
var counter = [];
var usersArr = [];
var photoCounter = [];
var namesArr = [];
var likesArr = [];
var emailsArr = [];

exports.index = function(req, resp){
  var Photo = Parse.Object.extend("Photo");
  var photoquery = new Parse.Query(Photo);
  photoquery.count({
      success: function(count) {

          getTopUsers(resp,count,0);  
      },
      error: function(error) {
          console.log("Uh oh, something went wrong.");
      }
  });

  
};

function getTopUsers(resp,count,skip){
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
            var loc = photo.get("location_full_str");

            if(photo.get("state") == "half"){
              var user = photo.get("user");

              //console.log(user.id);

              var name = "";
              if(user){
                name = user.get("fullName");
                usersArr.push(user.id);
                photoCounter[user.id] = (photoCounter[user.id] || 0) + 1;
                namesArr[user.id] = name; 
                emailsArr[user.id] = user.get("email");
              }
              
            }


            if(photo.get("state") == "full"){

              var userFull = photo.get("user_full");
              if(userFull){
                var name_full = userFull.get("fullName");
                usersArr.push(userFull.id);
                photoCounter[userFull.id] = (photoCounter[userFull.id] || 0) + 1;
                namesArr[userFull.id] = name_full;
                emailsArr[userFull.id] = userFull.get("email");
              }
              
            } 
          };

          getTopUsers(resp,count,skip+1000);
          
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
              obj.email = emailsArr[uniqueUserArr[i]];
              uniqueUserArr[i] = obj;
            };

            
            //resp.render('locations',{});

            resp.render('topUsers', {users:uniqueUserArr.sort(compare)});

            
            
          }            
        
      },
      error: function(error) {
        resp.render('error', {error: error.message});        
        //console.log("ERRRRRRRRRRRROR: "+error.message);
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

