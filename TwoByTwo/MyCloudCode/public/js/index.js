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

    var Index = {
        init: function () {
            var user = Parse.User.current();
            if (user) {
                if (Parse.FacebookUtils.isLinked(user)) {
                    console.log(user);
                    this.getFacebookFriends(user);
                    $('#signin').hide();    
                }else{
                    $('.logout').hide(); 
                }                		
            }else{
                $('.logout').hide(); 
            }
            this.bind();
        },

        bind: function () {
			var that = this;
			
			$('.logout').click(function (e) {
				Parse.User.logOut();
				location.reload(true);
			}),
	
            $('#signin').click(function (e) {

                Parse.FacebookUtils.logIn(null, {
                    success: function (user) {
                        $('#signin').hide();           
                        that.getFacebookFriends(user);

                        // If it's a new user, let's fetch their name from FB
                        if (!user.existed()) {
                            //NEW USER
                        }else {
							FB.api('/me', function (response) {
                                if (!response.error) {
                                    //console.log(response.name);
									$('.logout').text(response.name + " - logout");
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

        getFacebookFriends: function(u){
            console.log(u.id);
            Parse.Cloud.run('getFacebookFriends', { user: u.id }, {
              success: function(result) {
                console.log(result);
                for (var i = result.length - 1; i >= 0; i--) {
                    var followText = "Follow";

                    if(result[i].following){
                        followText = "unFollow";
                    }


                    $("#friends").append(result[i].name+" | <a class='follow' data='"+result[i].parseID+"'href='#'>"+followText+"</a><br>");
                };

                $(".follow").click(function(e){
                    /*
                    Parse.Cloud.run('reverseGeocoding', { latlng: "40.71449017670348,-73.84379533474319"}, {
                      success: function(response) {
                        console.log(response);
                      },
                      error: function(error) {
                        
                      }
                    });
                    */

                    console.log($(this).attr('data'));
                    var that = $(this);
                    Parse.Cloud.run('follow', { userID: u.id, followingUserID:$(this).attr('data') }, {
                      success: function(following) {
                        //console.log("following: ",following,$(this));
                        if(following){
                            that.html("unFollow");
                        }else{
                             that.html("Follow");
                        }
                        //console.log(result);

                        
                      },
                      error: function(error) {
                        Parse.User.logOut();
                        var dialog_url= "https://www.facebook.com/dialog/oauth?"+"client_id=217295185096733&redirect_uri=" + encodeURIComponent("http://www.2by2app.com");
                        location.href = dialog_url;
                        console.log(dialog_url);
                        
                        //$('#signin').show();
                        //$('.logout').hide();  
                      }
                    });
                })
              },
              error: function(error) {
                console.log("getFacebookFriends: ",error); 
                Parse.User.logOut();
                location.reload(true);
                
                /*
                Parse.User.logOut();
                var dialog_url= "https://www.facebook.com/dialog/oauth?"+"client_id=217295185096733&redirect_uri=" + encodeURIComponent("http://www.2by2app.com");
                location.href = dialog_url;
                console.log(dialog_url); 
                */
              }
            });
        }

		
    }

    Index.init();
})