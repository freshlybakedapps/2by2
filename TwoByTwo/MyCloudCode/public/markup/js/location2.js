Parse.initialize("6glczDK1p4HX3JVuupVvX09zE1TywJRs3Xr2NYXg", "qlOiXmQEpBNU2i9Ictj0zfKtHlgTzCDm2c0uImMu");






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

var locationArr = [];
var latLongArr = [];
var counter = [];
var usersArr = [];
var photoCounter = [];
var namesArr = [];
var likesArr = [];



window.fbAsyncInit = function() {
        // init the FB JS SDK        
    
        Parse.FacebookUtils.init({
          appId      : '217295185096733',                        // App ID from the app dashboard
      channelUrl : 'channel.html', // Channel file for x-domain comms
          status     : false, // check login status
          cookie     : true, // enable cookies to allow Parse to access the session
          xfbml      : true  // parse XFBML
        });
      };
      (function(d, debug){
         var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
         if (d.getElementById(id)) {return;}
         js = d.createElement('script'); js.id = id; js.async = true;
         js.src = "//connect.facebook.net/en_US/all" + (debug ? "/debug" : "") + ".js";
         ref.parentNode.insertBefore(js, ref);
       }(document, /*debug*/ false));



$(function () {
    Parse.$ = jQuery; 


    var Locations = {


        init: function () {
            var that = this;
            var Photo = Parse.Object.extend("Photo");
            var photoquery = new Parse.Query(Photo);
            photoquery.count({
                success: function(count) {
                    that.getLocations(count,0); 
                    that.bind(); 
                },
                error: function(error) {
                    console.log("Uh oh, something went wrong.");
                }
            });           
        },

        bind: function () {
          var that = this;
        },        

        getLocations: function (count,skip) {
          var that = this;
          var Photo = Parse.Object.extend("Photo");
          var photoquery = new Parse.Query(Photo);

          //photoquery.equalTo("state", "half");

          //photoquery.doesNotExist("location_half_str");

          //Parse.Cloud.useMasterKey();
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
                    window.likesArr.push(obj);
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

                that.getLocations(count,skip+1000);

                

                
                
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

                  //resp.render('locations', { likesArr:null,users:null,latLongArr:latLongArr,mapURL: getMapURL(uniqueArr.sort(compare)), locations:  uniqueArr.sort(compare),totalPhotos:count});



              var uniqueUserArr = uniqueUserArr.sort(compare);
              window.users = [];                
              for(var i=0; i<20; i++) {
                window.users.push({'info': uniqueUserArr[i].name +"("+uniqueUserArr[i].id+") - "+ uniqueUserArr[i].counter});
              }

              console.log(window.users);

              var likesArr = window.likesArr.sort(compare)
              window.likes = [];                
              for(var i=0; i<20; i++) {
                window.likes.push({'info': "http://www.2by2app.com/pdp/"+likesArr[i].photo.id +"("+likesArr[i].filter +") - "+likesArr[i].counter});
              }

              window.markers = {};
              window.markers.locations = [];

              for(var i=0; i<latLongArr.length; i++) {
                if(latLongArr[i].half){
                  window.markers.locations.push({'name': latLongArr[i].half.filter,'location':[latLongArr[i].half.lat,latLongArr[i].half.lon]});
                }
                if(latLongArr[i].full){
                  window.markers.locations.push({'name': latLongArr[i].full.filter,'location':[latLongArr[i].full.lat,latLongArr[i].full.lon]});
                }
              }


              var tableData = "";  
              var locations = uniqueArr.sort(compare);            
              tableData+="<tr>";
                    tableData+="<td><b>Count ("+count+")</b></td>";
                    tableData+="<td><b>Location ("+locations.length+")</b></td>";  
              tableData+="</tr>";

              tableData+="<tr>";
                    tableData+="<td></td>";
                    tableData+="<td></td>";  
              tableData+="</tr>";
                
              for(var i=0; i<locations.length; i++) {
                    tableData+="<tr>";
                    tableData+="<td>"+locations[i].counter+"</td><td>"+locations[i].loc+"</td>";
                    tableData+="</tr>";
              }   

                $("#thetable").html(tableData);        
            

              //console.log(window.markers);
                  /*
                  resp.render('locations', { likesArr:likesArr.sort(compare),
                    users:uniqueUserArr.sort(compare),
                    latLongArr:latLongArr,mapURL: getMapURL(uniqueArr.sort(compare)), 
                    locations:  uniqueArr.sort(compare),
                    totalPhotos:count});
                  */


                  window.initialize();
                }            
              
            },
            error: function(error) {        
              console.log("ERRRRRRRRRRRROR: "+error.message);
            }
          });   


         
        },
        error: function(object, error) {
                // The object was not retrieved successfully.
                // error is a Parse.Error with an error code and description.
                console.log(error);
        }
    }      

    Locations.init();
})