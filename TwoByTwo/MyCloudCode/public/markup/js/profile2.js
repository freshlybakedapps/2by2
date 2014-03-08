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

            	if(!this.getUrlVars().u){
            		if(!this.getUrlVars().id){
            			location.href = location.href.replace("#","")+"?u="+Parse.User.current().id;
            		}else{
            			location.href = location.href.replace("#","")+"&u="+Parse.User.current().id;
            		}                    
                    
                }
							
            }

			this.getPhotos();	
            this.bind();
        },

        bind: function () {
			var that = this;
			
			$('.logout').click(function (e) {
				Parse.User.logOut();
				location.href = "/";
			}),
			
			
			$('.thumb-icon').click(function (e) {				
				if($("body").hasClass("thumbs")){
					console.log("list");
					that.showAsList();
					$("body").removeClass("thumbs");
					$("body").addClass("list");
				}else{
					console.log("thumbs");
					that.showAsGrid();
					$("body").removeClass("list");
					$("body").addClass("thumbs");
				}
												
			}),

			$('#signin').click(function (e) {

                Parse.FacebookUtils.logIn(null, {
                    success: function (user) {
                        $("#fullname").html(Parse.User.current().changed.fullName);
                        $('#signin').hide();
                        $(".logout").show();
                        $("#fullname").show();             
                        //that.getPhoto();

                        // If it's a new user, let's fetch their name from FB
                        if (!user.existed()) {
                            //NEW USER
                        }else {
                            FB.api('/me', function (response) {
                                if (!response.error) {
                                    console.log(response.name);
                                    $("#fullname").html(response.name);
                                    //$('.logout').text(response.name + " - logout");
                                }
                            });
                            
                        }
                    },
                    error: function (user, error) {
                        console.log("Oops, something went wrong.");
                    }
                });

                return false;
            });             
        },

        centerImage: function(){
            $('.picture > .picture-wrapper').each(function(){
                var width = $(this).width();
                $(this).css({
                    height : width
                });
                var imgLoader = new Image();
                var $img = $(this).find('img');
                imgLoader.onload = function(){
                    var imageWidth = $img.width(),
                    imageHeight = $img.height();
                    console.log(width, imageWidth, imageHeight);
                    $img.css({
                        top : (width - imageHeight) / 2
                    });
                };
                imgLoader.src = $img.attr('src');
            });
        },

		showAsGrid: function (){
			$(".picture-viewer").css({display : 'block', float: 'left', padding: 5, width : '25%'});
			$(".picture").css("width","100%");
			$(".picture-options").hide();
			$(".picture-map").hide();
			$("#main-content").css('overflow', 'hidden');
			this.centerImage();			
		},
		
		showAsList: function (){
			$(".picture-viewer, .picture, .picture-options, .picture-map, #main-content").removeAttr('style');
			this.centerImage();	
		},

		getUrlVars: function() {
            var vars = [],
                hash;
            var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            var i;
            for (i = 0; i < hashes.length; i++) {
                hash = hashes[i].split('=');
                vars.push(hash[0]);
                vars[hash[0]] = hash[1];
            }
            return vars;
        },

        

        getPhotos: function () {
        	var that = this;			
			var clicking = false;
			var id = this.getUrlVars()["id"];

            if(id){
            	id = id.split("#")[0];
            	id = id.replace("#","");   
            }else{
            	if(Parse.User.current()){
            		id = Parse.User.current().id;
            	}else{
            		location.href = "/";
            	}
            	
            }

            if(!Parse.User.current()){
            	$(".logout").hide();
            	$("#signin").show();
            }else{
            	$(".logout").show();
            	$("#signin").hide();
            }
            
            var user = new Parse.User();
			user.id = id;
			    
            
            
                
			
            var Photo = Parse.Object.extend("Photo");
            var query = new Parse.Query(Photo);
			//query.limit(0);
			
			query.equalTo("user", user);
			//query.equalTo("objectId", id);
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


					if($('.picture > .picture-wrapper').length){
                        that.centerImage();
                        $(window).smartresize(that.centerImage);
                    }

					//ADD COMMENT COUNTER
					//photosArr.length					
		            for(var i=0;i<photosArr.length;i++){

		            	var data = photosArr[i].attributes;
						if(Parse.User.current() && data.likes){
							for (var j = data.likes.length - 1; j >= 0; j--) {
								

								if(data.likes[j] == Parse.User.current().id){
									//console.log(data.likes[j],Parse.User.current().id);
									//$(".picture-options").find().css("background-position","-32px");
									var el = $(".picture-options > a > span")[i];
									$(el).css("background-position","-32px");
								}
							};
						}


		                var Comment = Parse.Object.extend("Comment");
						var query = new Parse.Query(Comment);
						query.equalTo("commentID", photosArr[i].id);						

						(function(index, length) { 
							query.count({
							  success: function(count) {
							    // The count request succeeded. Show the count
							    //$("#comment_"+photosArr[index].id).html(" "+count);
							    $("#comment_"+photosArr[index].id).prev().html("<span></span>"+count);

							    //console.log("photo comment count: ",$("#comment_"+photosArr[index].id));
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