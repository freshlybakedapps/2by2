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
                                        
                    this.gotoProfile();                    
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
                        that.gotoProfile();

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

        gotoProfile: function(){
        	location.href = "profile.html";
        }		
    }

    Index.init();
})