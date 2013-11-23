Parse.initialize("6glczDK1p4HX3JVuupVvX09zE1TywJRs3Xr2NYXg", "qlOiXmQEpBNU2i9Ictj0zfKtHlgTzCDm2c0uImMu");

function initialize(){
    var Photo = Parse.Object.extend("Photo");
    var query = new Parse.Query(Photo);
    query.descending("updatedAt");
    query.equalTo("state", "full");
    query.include("user");
    query.include("user_full");

    query.find({
        success: function(photosArr) {
            // The object was retrieved successfully.
            //console.log(photosArr);

            var result = '<table border="1">';

            for(var i=0;i<photosArr.length;i++){
                var data = photosArr[i].changed;
                var user = photosArr[i].attributes.user.attributes.username;
                var userFull = photosArr[i].attributes.user_full.attributes.username;
                result+="<tr>";
                result+="<td><div class='image'><img style='padding:0px;' src='"+data.image_full.url+"'><p class='caption'>Photo by: "+user+" / "+userFull+"</p></div></td>";
                result+='<td><div class="map" id="map_canvas'+i+'"></div></td>';
                result+="</tr>";
                

                //console.log(photosArr[i]);

                //console.log(data.location_full._latitude);
                //console.log(data.location_full._longitude);
            }

            result += '</table>';

            $("body").append(result);
            
            for(var i=0;i<photosArr.length;i++){
                var data = photosArr[i].changed;
                var user = photosArr[i].attributes.user.attributes.username;
                var userFull = photosArr[i].attributes.user_full.attributes.username;
                
                //var myLatlng1 = new google.maps.LatLng(-25.363882,131.044922);
                var myLatlng1 = new google.maps.LatLng(data.location_half._latitude,data.location_half._longitude);
                var myLatlng2 = new google.maps.LatLng(data.location_full._latitude,data.location_full._longitude);
                showMap2(i, myLatlng1, myLatlng2, user, userFull);
            }


            
        },
        error: function(object, error) {
            // The object was not retrieved successfully.
            // error is a Parse.Error with an error code and description.
            console.log(error);
        }
    });
}



function showMap2(mapid, fromAddress, toAddress, user, userFull){
  var bounds = new google.maps.LatLngBounds();

  var mapOptions = {
    zoom: 11,
    center: fromAddress,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }

  var infowindow_half = new google.maps.InfoWindow({
      content: user,
      maxWidth: 200
  });

  var infowindow_full = new google.maps.InfoWindow({
      content: userFull,
      maxWidth: 200
  });

  var map = new google.maps.Map(document.getElementById('map_canvas'+mapid), mapOptions);

  var marker1 = new google.maps.Marker({
      position: fromAddress,
      map: map,
      title: user
  });

  var marker2 = new google.maps.Marker({
      position: toAddress,
      map: map,
      title: userFull
  });

  bounds.extend(marker1.position);
  bounds.extend(marker2.position);  

  

  

   infowindow_half.open(map,marker1);
   infowindow_full.open(map,marker2);


  

  //now fit the map to the newly inclusive bounds
    map.fitBounds(bounds);      
}

google.maps.event.addDomListener(window, 'load', initialize);

