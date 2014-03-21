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

    var PDP = {
        init: function () {         
            if (Parse.User.current()) {
                $("#fullname").html(Parse.User.current().changed.fullName);
                $("#fullname").attr("href","profile?id="+Parse.User.current().id);                 
                $("#signin").hide();
                $(".logout").show();
                $("#fullname").show();

                if(!$.query.get("u")){
                    var q =  $.query.set("u",Parse.User.current().id);                
                    location.href = location.pathname+q;
                }
                this.getPhoto();                            
            }else{                
                $(".logout").hide();
                $("#fullname").hide();
                $("#signin").show();  
                this.getPhoto();
            }
            this.bind();
        },

        bind: function () {
            var that = this;            
            
            $('.logout').click(function (e) {
                Parse.User.logOut();

                var q = $.query.REMOVE("u");

                location.href = location.pathname+q;

                $(".picture-data").html("");
                //window.location.reload();
            }),

            $('.likes').click(function (e) {
                e.preventDefault();
                
                if (Parse.User.current()) {
                    var photoID = $(this).attr("data");
                    that.likePhoto(photoID);
                    var el = $(this).find("span")[0];                    

                    var pos = $(el).css("background-position");
                    var likeCount = Number($(this).attr("likeLength"));

                    if(pos.indexOf("-32px") > -1){
                        //unlike
                        likeCount--;
                        $(this).html("<span></span>"+likeCount);
                        var el = $(this).find("span")[0];  
                        $(el).css("background-position","0px");

                        var liArr = $(".like-list").find("li");
                        
                        for (var i = liArr.length - 1; i >= 0; i--) {
                            var data = $(liArr[i]).find("a").attr("data");
                            if(data == Parse.User.current().id){
                                $(liArr[i]).remove();
                            }
                        };

                        var liLength = $(".like-list").find("li").length;

                        if(liLength == 0){
                            $(".like-list").find("h3").html("");
                        }


                    }else{
                        //like
                        likeCount++;
                        $(this).html("<span></span>"+likeCount);
                        var el = $(this).find("span")[0];  
                        $(el).css("background-position","-32px");

                        var liLength = $(".like-list").find("li").length;
                        if(liLength == 0){
                            that.getLikesInfo([Parse.User.current().id]);
                        }

                        $(".like-list").find("h3").html("LIKERS");

                        

                    }
                }
                
                //console.log("likePhoto: "+);
                return false;
            }),

            

            $('#signin').click(function (e) {

                Parse.FacebookUtils.logIn(null, {
                    success: function (user) {
                        $("#fullname").html(Parse.User.current().changed.fullName);
                        $('#signin').hide();
                        $(".logout").show();
                        $("#fullname").show(); 
                        $(".need-to-log-in").hide();            
                        //that.getPhoto();

                        var q =  $.query.set("u",Parse.User.current().id);                
                        location.href = location.pathname+q;
                        /*
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
                        */
                    },
                    error: function (user, error) {
                        console.log("Oops, something went wrong.");
                    }
                });

                return false;
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

        getLikesInfo: function (arr) {
            //console.log("getLikesInfo",arr);
            $(".like-list").find("ul").html("");

            for (var i = arr.length - 1; i >= 0; i--) {
                var User = Parse.Object.extend("User");
                var query = new Parse.Query(User);
                query.equalTo("objectId", arr[i]);

                query.find({
                    success: function(users) {
                        //console.log(users[0]);
                        var url = 'https://graph.facebook.com/'+users[0]._serverData.facebookId+'/picture?type=square';
                        var html = '<li><a data="'+users[0].id+'" href="profile?id='+users[0].id+'"><img src="'+url+'" class="avatar" /></a></li>';
                        $(".like-list").find("ul").append(html);

                        if(users.length > 0){
                            $(".like-list").find("h3").html("LIKERS");
                        }
                    },
                    error: function(object, error) {
                        // The object was not retrieved successfully.
                        // error is a Parse.Error with an error code and description.
                        console.log(error);
                    }
                });
            }
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

        

        getPhoto: function () { 
            var that = this;
            //$("#main-content").html("");           
            var clicking = false;
            
            var Photo = Parse.Object.extend("Photo");
            var query = new Parse.Query(Photo);
            //query.limit(0);            
            
            var id = $.query.get("id");

            if(!id){
                location.href = "profile";
            }
            
            id = id.split("#")[0];
            
            id = id.replace("#","");            
            
            if(id){
                query.equalTo("objectId", id);
                
                query.find({
                success: function(photosArr) {
                    // The object was retrieved successfully.
                    
                    
        
                    if(photosArr.length == 0){
                        $("#main-content").html("<br><p>You have no photos.</p>");
                        return;
                    }                   

                    if($('.picture > .picture-wrapper').length){
                        that.centerImage();
                        $(window).smartresize(that.centerImage);
                    }

                    if(!Parse.User.current()){
                       $("#main-content").append('<div class="need-to-log-in"><p>You must be logged in too see and leave comments.</p></div>');
   
                    }
                    

                    //Mark pictures liked by curent user
                    for(var i=0;i<photosArr.length;i++){

                        var data = photosArr[i].attributes;
                        if(Parse.User.current() && data.likes){
                            for (var j = data.likes.length - 1; j >= 0; j--) {
                                

                                if(data.likes[j] == Parse.User.current().id){
                                    console.log(data.likes[j],Parse.User.current().id);
                                    //$(".picture-options").find().css("background-position","-32px");
                                    var el = $(".picture-options > a > span")[i];
                                    $(el).css("background-position","-32px");
                                }
                            };
                        }

                        if(photosArr[i]._serverData.likes){
                            if(Parse.User.current()){
                                that.getLikesInfo(photosArr[i]._serverData.likes);
                            }                            
                        }                        
                    }

                    

                    $('#commentButton').click(function(e){
                        e.preventDefault();

                        if($('#commentText').attr("value") == ""){
                            return;
                        }
                        

                        var Comment = Parse.Object.extend("Comment");
                        var comment = new Comment();

                        comment.set("text",$('#commentText').attr("value"));
                        comment.set("username", Parse.User.current().attributes.username);
                        comment.set("commentID", photosArr[0].id);
                        comment.set("facebookId", Parse.User.current().attributes.facebookId);
                        comment.set("userID", Parse.User.current().id);

                        console.log("Parse.User.current()",Parse.User.current());
                        
                        
                        comment.save(null, {
                            success: function (n) {
                                console.log("Comment saved success",Parse.User.current());
                                var html = "";
                                html+='<li>';
                                    html+='<a href="profile?id='+Parse.User.current().id+'"><img src="https://graph.facebook.com/'+Parse.User.current().changed.facebookId+'/picture?type=square" class="avatar" /></a>';
                                    html+='<div class="comment-data">';
                                        html+='<h3><a href="#">'+Parse.User.current().changed.username+'</a></h3>';
                                        html+='<p>';
                                            html+=$('#commentText').attr("value");
                                        html+='</p>';
                                    html+='</div>';
                                html+='</li>';
                                
                                $(".comment-list").find("ul").prepend(html);

                                $('#commentText').attr("value","");

                                $("#comment_"+photosArr[0].id).prev().html("<span></span>"+$(".comment-list").find("li").length);



                            },
                            error: function (item,error) {
                                console.log("Comment save error: " + error.message);
                            }
                        });
                    });

                    $('form').submit(function(e){
                        e.preventDefault();
                    });

                    $('#commentText').keypress(function (event) {
                      
                      if (event.keyCode == 10 || event.keyCode == 13) {
                        $('#commentButton').trigger( "click" );
                        event.preventDefault();
                        return false; 
                      }
                    });

                    $("#commentButton").bind('keyup', function(event){ 
                        if(event.keyCode == 13){ 
                            $('#commentButton').trigger( "click" );
                            return false; 
                        } 
                        event.preventDefault(); 
                    });

                    //ADD COMMENT COUNTER                                
                    for(var i=0;i<photosArr.length;i++){                      
                        var Comment = Parse.Object.extend("Comment");
                        var query = new Parse.Query(Comment);
                        query.equalTo("commentID", photosArr[i].id);                        

                        (function(index, length) { 
                            query.find({
                              success: function(arr) {
                                //console.log(arr);

                                // The count request succeeded. Show the count
                                //$("#comment_"+photosArr[index].id).html(" "+count);
                                $("#comment_"+photosArr[index].id).prev().html("<span></span>"+arr.length);

                                

                                if(Parse.User.current()){
                                    var html = "";

                                    for (var i = arr.length - 1; i >= 0; i--) {
                                        var serverData = arr[i]._serverData;
                                        console.log("photo comment: ",serverData.text,serverData.username,serverData.facebookId);
                                        html+='<li>';
                                            ////<a href="profile?id='+data.user.id+'">'+username_half+'</a>'
                                        
                                            html+='<a href="profile?id='+serverData.userID+'"><img src="https://graph.facebook.com/'+serverData.facebookId+'/picture?type=square" class="avatar" /></a>';
                                            html+='<div class="comment-data">';
                                                html+='<h3><a href="#">'+serverData.username+'</a></h3>';
                                                html+='<p>';
                                                    html+=serverData.text;
                                                html+='</p>';
                                            html+='</div>';
                                        html+='</li>';
                                    };

                                    //html+="</ul>";

                                    $(".comment-list").find("ul").html(html);

                                }
                                

                                
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
            }else{
                console.log("no id");
                location.href = "profile";
            }          
            
            
            
        }

    }

    PDP.init();
})




