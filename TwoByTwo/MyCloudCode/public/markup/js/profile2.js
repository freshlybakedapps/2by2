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
                $("#fullname").attr("href","profile?id="+Parse.User.current().id); 


            	
                if(!$.query.get("u") || ($.query.get("u") != Parse.User.current().id)){
            		var q =  $.query.set("u",Parse.User.current().id);                
                    location.href = location.pathname+q;                 
                    
                }
                
							
            }else{
                if($.query.get("u")){
                    var q =  $.query.remove("u");                
                    location.href = location.pathname+q;  
                }
            }

			this.getPhotos();	
            this.bind();

            this.showAsGrid();
            $("body").removeClass("list");
            $("body").addClass("thumbs");
        },

        bind: function () {
			var that = this;

            

            $("a").each(function( index ) {
                var href = $(this).attr("href");

                if(href && (href.indexOf(location.host) > -1 || href.indexOf("http") == -1)){
                    if($.query.get("u")){
                        if(href.indexOf("?") > -1){
                            $(this).attr("href",href+"&u="+$.query.get("u"));
                        }else{
                            $(this).attr("href",href+"?u="+$.query.get("u"));
                        }

                        
                    }
                }

                
            }),

            $('.likes').click(function (e) {
                e.preventDefault();
                
                if (Parse.User.current()) {
                    var photoID = $(this).attr("data");
                    that.likePhoto(photoID);
                    var el = $(this).find("span")[0];                    

                    var pos = $(el).css("background-position");
                    var likeCount = Number($(this).attr("likelength"));

                    if(pos.indexOf("-32px") > -1){
                        //unlike
                        likeCount--;
                        $(this).html("<span></span>"+likeCount);
                        var el = $(this).find("span")[0];  
                        $(el).css("background-position","0px");

                        $(this).attr("likelength",likeCount);
                    }else{
                        //like
                        likeCount++;
                        $(this).html("<span></span>"+likeCount);
                        var el = $(this).find("span")[0];  
                        $(el).css("background-position","-32px");

                        $(this).attr("likelength",likeCount);

                    }
                }
                
                //console.log("likePhoto: "+);
                return false;
            }),
			
			$('.logout').click(function (e) {
				Parse.User.logOut();
				//location.href = "/";

                //var q = $.query.REMOVE("u");

                if(location.href.indexOf("?") > -1){
                    location.href = location.href.split("?")[0];
                }else{
                    location.reload(true);
                }
                
			}),

            $('.previous').click(function (e) {
                e.preventDefault();

                var page = Number($.query.get('page'));
                if(page > 0){
                    page--;
                }

                var newQuery = $.query.set('page',page);   
                var newURL = location.pathname+newQuery.toString();       
                location.href = newURL;
                //console.log(newURL);
                
            }),

            $('.next').click(function (e) {
                e.preventDefault();

                var page = Number($.query.get('page'));
                //dont' know how many pages I have yet
                page++;                

                var newQuery = $.query.set('page',page);   
                var newURL = location.pathname+newQuery.toString();       
                location.href = newURL;
                
                console.log("totalPages: "+$('.next').attr("totalPages"));
                
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

        getURLLastParam: function(){
            return window.location.href.split("/").pop();
        },

        getAllComments: function(){
            var Comment = Parse.Object.extend("Comment");
            var query = new Parse.Query(Comment);
            //query.equalTo("commentID", photosArr[i].id);
            query.limit(10000);
            var commentMap = []; 

            query.find({
                success: function(commentsArr) {
                    var len = commentsArr.length;

                    for (var i = len - 1; i >= 0; i--) {
                        var current = commentsArr[i]._serverData;
                        if(!commentMap[current.commentID]){
                            commentMap[current.commentID] = [];
                            
                        }

                        commentMap[current.commentID].push(current);
                    };

                    for(var id in commentMap){
                        if($("#comment_"+id)){
                            $("#comment_"+id).prev().html("<span></span>"+commentMap[id].length);
                        }
                    }

                    //console.log(len);
                    

                },
                error: function(object, error) {
                    // The object was not retrieved successfully.
                    // error is a Parse.Error with an error code and description.
                    console.log(error);
                }
            });

        },

        likePhoto: function(objectid){
            var userWhoLikedID = Parse.User.current().id;
            var userWhoLikedUsername = Parse.User.current().changed.username;

            console.log("likePhoto: "+userWhoLikedUsername);

            Parse.Cloud.run('likePhoto', { objectid: objectid, userWhoLikedID: userWhoLikedID, userWhoLikedUsername:userWhoLikedUsername}, {
              success: function(str) {        
                console.log("LikePhoto"+str);
              },
              error: function(error) {
                console.log("likePhoto error: ",error);
              }
            });
        },


        getPhotos: function () {
        	var that = this;			
			var clicking = false;
			
            var id = this.getUrlVars()["id"];
            
            /*
            var id = this.getURLLastParam();
            if(id.indexOf("?") > -1){
                id = id.split("?")[0];
            }

            console.log(id);
            */
            

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
		              
                    /*
					if(photosArr.length == 0){
						$("#main-content").html("<br><p>You have no photos.</p>");
						return;
					}
                    */		


					if($('.picture > .picture-wrapper').length){
                        that.centerImage();
                        $(window).smartresize(that.centerImage);
                    }

					//ADD LIKE PICTURES
								
		            for(var i=0;i<photosArr.length;i++){

                        var index = i*2;

                        

		            	var data = photosArr[i].attributes;
						if(Parse.User.current() && data.likes){

                            //console.log($(".picture-options > a > span").length+" / "+photosArr.length);

							for (var j = data.likes.length - 1; j >= 0; j--) {
								

								if(data.likes[j] == Parse.User.current().id){
									var el = $(".picture-options > a > span")[index];
									$(el).css("background-position","-32px");
								}


							};
						}

                        /*
                        var el = $(".picture-options > a")[index];
                                    
                        console.log($(el));

                        $(el).click(function (e) {
                            //that.likePhoto(photosArr[i].id);
                            console.log(photosArr[i].id);
                            return false;
                        })
                        */

                        
                        /*
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
                        */						
					}				
		        },
		        error: function(object, error) {
		            // The object was not retrieved successfully.
		            // error is a Parse.Error with an error code and description.
		            console.log(error);
		        }
		    });

            that.getAllComments();
			
        }

    }

    List.init();
})