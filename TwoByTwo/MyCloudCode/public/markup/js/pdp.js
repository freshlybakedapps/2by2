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
                $("#signin").hide();
                $(".logout").show();
                $("#fullname").show();                
                this.getPhoto();               
            }else{
                //location.href = "pdp.html";
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
                window.location.reload();
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

        getLikesInfo: function (arr) {
            console.log("getLikesInfo",arr);

            for (var i = arr.length - 1; i >= 0; i--) {
                var User = Parse.Object.extend("User");
                var query = new Parse.Query(User);
                query.equalTo("objectId", arr[i]);

                query.find({
                    success: function(users) {
                        //console.log(users[0]);
                        var url = 'https://graph.facebook.com/'+users[0]._serverData.facebookId+'/picture?type=square';
                        var html = '<li><a href="profile?id='+users[0].id+'"><img src="'+url+'" class="avatar" /></a></li>';
                        $(".like-list").find("ul").append(html);
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
            $("#main-content").html("");           
            var clicking = false;
            
            var Photo = Parse.Object.extend("Photo");
            var query = new Parse.Query(Photo);
            //query.limit(0);
            query.include("user");
            query.include("user_full");    
            
            
            var id = this.getUrlVars()["id"];

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
                    console.log(photosArr[0]._serverData.likes);
                    var result = "";
        
                    if(photosArr.length == 0){
                        $("#main-content").html("<br><p>You have no photos.</p>");
                        return;
                    }

                    for(var i=0;i<photosArr.length  ;i++){
                        var data = photosArr[i].attributes;
                        console.log(data);
                        
                        var image = data.image_full;
                        
                        if(!image){
                            image = data.image_half;
                        }
                        
                        var username_half = data.user._serverData.username;
                        var username_full = "";

                        if(Parse.User.current() && username_half == Parse.User.current().attributes.username){
                            username_half = "You!";
                        }

                        if(data.user_full){
                            username_full = data.user_full._serverData.username;
                        }

                        if(Parse.User.current() && username_full == Parse.User.current().attributes.username){
                            username_full = "You!";
                        }
                        
                        var imageURL = image.url;                       
                        var likeLength = 0;
                        if(photosArr[i]._serverData.likes){
                            likeLength = photosArr[i]._serverData.likes.length;

                            that.getLikesInfo(photosArr[i]._serverData.likes);
                        }



                        var locationHalf = data.location_half;


                        //static maps doc: https://developers.google.com/maps/documentation/staticmaps/?csw=1#StyledMaps
                        //https://developers.google.com/maps/documentation/staticmaps/?csw=1#CustomIcons
                        //style map: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
                        //Get API key: https://cloud.google.com/console/project

                        //http://2by2.parseapp.com/images/red.png
                        //http://2by2.parseapp.com/images/green.png
                        
                        var markers;

                        if(data.location_half){
                            if(data.location_half._longitude == 0){
                                username_half+=" (?)";
                            }else{
                                markers = "&markers=icon:http://2by2.parseapp.com/images/red.png%7Ccolor:0xff3366%7C"+locationHalf._latitude+","+locationHalf._longitude;
                            }
                        }                       

                        if(data.state == "full" && data.location_full){
                            var locationFull = data.location_full;
                            if(locationFull._longitude == 0){
                                username_full+=" (?)";
                            }else{
                                markers+="&markers=icon:http://2by2.parseapp.com/images/green.png%7Ccolor:0x00cc99%7C"+locationFull._latitude+","+locationFull._longitude;
                            }
                        }
                        //&center=Brooklyn+Bridge,New+York,NY&zoom=13
                        var mapImageURL = "http://maps.googleapis.com/maps/api/staticmap?key=AIzaSyDvTIlW1eCIiKGx9OsJuw1fWg_tvVUJRJA&style=saturation:-100%7Clightness:-57&size=500x500&maptype=roadmap"+markers+"&sensor=false";

                        

                        result+='<div class="picture-viewer">';               
                        result+='<div class="picture">';
                            result+='<div class="picture-wrapper">';
                                result+='<img src="'+imageURL+'" alt="" />';                        
                            result+='</div>';

                            
                            result+='<div class="picture-options">';
                                result+='<a href="#" class="likes left">';
                                    result+='<span></span>'+likeLength;
                                result+='</a>';
                                result+='<a href="#" class="comments left">';
                                    result+='<span></span><a id="comment_'+photosArr[i].id+'"></a>';
                                result+='</a>';
                                /*
                                result+='<a href="#" class="delete right">';
                                    result+='<span></span>';
                                result+='</a>';
                                result+='<a href="#" class="location right">';
                                    result+='<span></span>';
                                result+='</a>';
                                */
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
                                            result+='<span></span> <a href="profile?id='+data.user.id+'">'+username_half+'</a>';
                                        result+='</li>';
                                        
                                        if(data.user_full){
                                            result+='<li>';
                                            result+='<span></span> <a href="profile?id='+data.user_full.id+'">'+username_full+'</a>';
                                            result+='</li>';
                                        }
                                        
                                    result+='</ul>';
                                result+='</nav>';
                            result+='</div>';
                        result+='</div>';
                        result+='</div>';

                        //only show this info if user is loggedin
                        if (Parse.User.current()) {
                            result+='<div class="picture-data">';
                                result+='<form class="upload-comment" action="">';
                                    result+='<input id="commentText" type="text" placeholder="Type a nice comment here..." value="" />';
                                    result+='<input id="commentButton" type="button" value="Post" />';
                                result+='</form>';
                                
                                result+='<nav class="like-list">';
                                    result+='<h3>Likers</h3>';
                                    result+='<ul>';
                                        
                                        
                                        
                                    result+='</ul>';
                                    /*
                                    result+='<a href="#" class="see-likers">';
                                        result+='See all likers';
                                    result+='</a>';
                                    */
                                result+='</nav>';
                                
                                result+='<nav class="comment-list">';
                                        
                                    result+='<ul>'; 
                                        /*                                       
                                        <li>
                                            <img src="img/avatar.jpg" class="avatar" />
                                            <div class="comment-data">
                                                <h3><a href="#">John Tubert</a></h3>
                                                <p>
                                                    Man, this is the bee’s knees
                                                </p>
                                            </div>
                                        </li>
                                        */
                                    result+='</ul>';
                                    
                                result+='</nav>';
                                /*
                                result+='<a href="#" class="load-more">';
                                    result+='Load More';
                                result+='</a>';
                                */
                            result+='</div>';
                        }


                    }


        
                    
        
                    $("#main-content").append(result);

                    if($('.picture > .picture-wrapper').length){
                        that.centerImage();
                        $(window).smartresize(that.centerImage);
                    }

                    if(!Parse.User.current()){
                       $("#main-content").append('<div class="need-to-log-in"><p>You must be logged in to see and leave comments.</p></div>');
   
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
                    }

                    

                    $('#commentButton').click(function(e){
                        e.preventDefault();
                        

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
                                console.log(arr);

                                // The count request succeeded. Show the count
                                //$("#comment_"+photosArr[index].id).html(" "+count);
                                $("#comment_"+photosArr[index].id).prev().html("<span></span>"+arr.length);

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




