exports.getDistance = function(lat1, lat2, lon1, lon2){
	var R = 6371; // km
    var dLat = (lat2-lat1).toRad();
    var dLon = (lon2-lon1).toRad();
    var lat1 = lat1.toRad();
    var lat2 = lat2.toRad();
    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
    return R * c;
}

exports.getUsernameHalf = function(data){
    var username_half = ".";
                    
    if(data.user && data.user._serverData){
        username_half = data.user._serverData.username;
    }     
    
    if(data.location_half){
        if(data.location_half._longitude == 0){
            username_half+=" (?)";
        }
    }
    return username_half;
}

exports.getUsernameFull = function(data){    
    var username_full = "";                    

    if(data.user_full && data.user_full._serverData){
        username_full = data.user_full._serverData.username;
    }                 

    if(data.state == "full" && data.location_full){
        var locationFull = data.location_full;
        if(locationFull._longitude == 0){
            username_full+=" (?)";
        }
    }
    return username_full;
}

exports.getMapImageURL = function(data){
	//static maps doc: https://developers.google.com/maps/documentation/staticmaps/?csw=1#StyledMaps
    //https://developers.google.com/maps/documentation/staticmaps/?csw=1#CustomIcons
    //style map: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
    //Get API key: https://cloud.google.com/console/project
	var locationHalf = data.location_half;
    var location_half_str = data.location_half_str;   
    
    var markers = "";
    var locations = 0;

    
    if(data.location_half){
        if(data.location_half._longitude == 0){
            //
        }else{
            if(location_half_str && location_half_str != ""){
                markers = "&markers=icon:http://www.2by2app.com/images/red.png%7Ccolor:0xff3366%7C"+encodeURIComponent(location_half_str);
                locations++;
            }
            //markers += "&visible="+(locationHalf._latitude+0.01)+","+(locationHalf._longitude+0.01);
        }
    }                       

    if(data.state == "full" && data.location_full){
        var locationFull = data.location_full;
        if(locationFull._longitude == 0){
            //
        }else{
            var location_full_str = data.location_full_str;

            if(location_full_str && location_full_str != ""){
                markers+="&markers=icon:http://www.2by2app.com/images/green.png%7Ccolor:0x00cc99%7C"+encodeURIComponent(location_full_str);
                locations++;
            }
            //markers += "&visible="+(locationFull._latitude+0.01)+","+(locationFull._longitude+0.01);
        }
    }

    if(locations == 2 && location_full_str == location_half_str){
        markers = "&markers=icon:http://www.2by2app.com/images/SameLocation.png%7Ccolor:0xff3366%7C"+encodeURIComponent(location_half_str);
    }
    

    //markers = encodeURIComponent(markers);
    //&center=Brooklyn+Bridge,New+York,NY&zoom=13
    var mapImageURL = "http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDvTIlW1eCIiKGx9OsJuw1fWg_tvVUJRJA&style=saturation:-100%7Clightness:-57&size=500x500&maptype=roadmap"+markers+"&sensor=false";
    
    if(locations == 0){
        if(data.state == "full"){
            mapImageURL = "/markup/img/NoLocationSharedBoth@2x.png";
        }else{
            mapImageURL = "/markup/img/NoLocationShared@2x.png";
        }
        
    }

    return mapImageURL;
}