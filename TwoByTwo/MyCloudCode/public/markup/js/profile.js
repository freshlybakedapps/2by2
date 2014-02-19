Parse.initialize("6glczDK1p4HX3JVuupVvX09zE1TywJRs3Xr2NYXg", "qlOiXmQEpBNU2i9Ictj0zfKtHlgTzCDm2c0uImMu");

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

    var List = {
        init: function () {			
            if (Parse.User.current()) {
            	$("#fullname").html(Parse.User.current().changed.fullName);
				this.getPhotos();				
            }else{
				location.href = "index.html";
			}
            this.bind();
        },

        bind: function () {
			var that = this;
			
			$('.logout').click(function (e) {
				Parse.User.logOut();
				location.href = "index.html";
			}),
			
			$('.logo').click(function (e) {				
				if($(".thumb").css("width") == "115px"){
					that.showAsList();
				}else{					
					that.showAsGrid();
				}
								
			})            
        },

		showAsGrid: function (){						
			$(".thumb").css("width","115px");
			//$(".thumb").css("height","115px");
			$(".thumb").css("margin","5px");
			$(".sketch").css("width","115px");
			//$(".sketch").css("height","115px");
			
			
			$(".sketch").css("display","inline");
			//$(".sketch").css("background-color","white");	
						
			$(".commentsCount").hide();
		},
		
		showAsList: function (){			
			$(".thumb").css("width","90%");
			$(".thumb").css("margin","5%");
			
			$(".sketch").css("width","100%");
			//$(".sketch").css("height","100%");
			
			
			$(".sketch").css("display","block");
			$(".sketch").css("background-color","#e5e5e5");	
						
			$(".commentsCount").show();
		},

        getPhotos: function () {			
			var clicking = false;
			
            var Photo = Parse.Object.extend("Photo");
            var query = new Parse.Query(Photo);
			//query.limit(0);
			query.include("user");
			query.include("user_full");
			query.equalTo("user", Parse.User.current());
            query.descending("createdAt");
			
			//query.equalTo("image", "8c6b2872-43f9-404b-b1fe-e756a1cec608-file");
			$("#images").html("");
			$("#images").show();
            
			query.find({
		        success: function(photosArr) {
		            // The object was retrieved successfully.
		            //console.log(photosArr);
					var result = "";
		
					if(photosArr.length == 0){
						$("#main-content").html("<br><p>You have no photos.</p>");
						return;
					}

					//photosArr.length					
		            for(var i=0;i<10;i++){
		                var data = photosArr[i].attributes;
		                console.log(data);


		                
		                var image;
		                if(data.state == "half"){
		                	image = data.image_half;
		                }else{
		                	image = data.image_full;
		                }
		                
		                var username_half = data.user._serverData.username;
		                
		                var imageURL = image.url;		                
		                var likeLength = 0;
		                if(data.likes){
		                	likeLength = data.likes.length;
		                }

		                var locationHalf = data.location_half;


		                //static maps doc: https://developers.google.com/maps/documentation/staticmaps/?csw=1#StyledMaps
		                //style map: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
		                //Get API key: https://cloud.google.com/console/project
		                
		                var markers;

		                if(data.location_half){
		                	markers = "&markers=color:0xff3366%7C"+locationHalf._latitude+","+locationHalf._longitude;
		                }		                

		                if(data.state == "full" && data.location_full){
							var locationFull = data.location_full;
		                	markers+="&markers=color:0x00cc99%7C"+locationFull._latitude+","+locationFull._longitude;
		                }
		                //&center=Brooklyn+Bridge,New+York,NY&zoom=13
		                var mapImageURL = "http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDvTIlW1eCIiKGx9OsJuw1fWg_tvVUJRJA&style=saturation:-100&size=500x500&maptype=roadmap"+markers+"&sensor=false";


		                result+='<div class="picture-viewer">';               
		                result+='<div class="picture">';
	                        result+='<img src="'+imageURL+'" alt="" />';
	                        result+='<div class="picture-options">';
	                            result+='<a href="#" class="likes left">';
	                                result+='<span></span>'+likeLength;
	                            result+='</a>';
	                            result+='<a href="#" class="comments left">';
	                                result+='<span></span><a id="comment_'+photosArr[i].id+'"></a> :: <b>View details</b>';
	                            result+='</a>';
	                            result+='<a href="#" class="delete right">';
	                                result+='<span></span>';
	                            result+='</a>';
	                            result+='<a href="#" class="location right">';
	                                result+='<span></span>';
	                            result+='</a>';
	                            result+='<br class="clr" />';
	                        result+='</div>';
	                    result+='</div>';
	                    result+='<div class="picture-map">';
	                        result+='<img src="'+mapImageURL+'" alt="" />';
	                        //result+='<div class="mask"></div>';
	                        result+='<div class="user-list">';
	                            result+='<nav>';
	                                result+='<ul>';
	                                    result+='<li>';
	                                        result+='<span></span> '+username_half;
	                                    result+='</li>';
	                                    
	                                    if(data.user_full){
	                                    	result+='<li>';
	                                        result+='<span></span> '+data.user_full._serverData.username;
	                                    	result+='</li>';
	                                    }
	                                    
	                                result+='</ul>';
	                            result+='</nav>';
	                        result+='</div>';
	                    result+='</div>';
	                    result+='</div>';

		            }
		
					
		
					$("#main-content").append(result);

					//ADD COMMENT COUNTER
					//photosArr.length					
		            for(var i=0;i<10;i++){		                
		                var Comment = Parse.Object.extend("Comment");
						var query = new Parse.Query(Comment);
						query.equalTo("commentID", photosArr[i].id);

						console.log(photosArr[i].id);

						(function(index, length) { 
							query.count({
							  success: function(count) {
							    // The count request succeeded. Show the count
							    $("#comment_"+photosArr[index].id).html(" "+count);
							    console.log("photo comment count: ",$("#comment_"+photosArr[index].id));
							  },
							  error: function(error) {
							    console.log(error);
							  }
							});
						})(i,photosArr.length-1);						
					}				
		        },
		        error: function(object, error) {
		            // The object was not retrieved successfully.
		            // error is a Parse.Error with an error code and description.
		            console.log(error);
		        }
		    });
			
        }

    }

    List.init();
})