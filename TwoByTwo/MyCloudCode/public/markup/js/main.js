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

          Parse.FacebookUtils.logIn('email,user_about_me', {
              success: function (user) {
                  $("#fullname").html(Parse.User.current().changed.fullName);
                  $('#signin').hide();
                  $(".logout").show();
                  $("#fullname").show(); 
                  $(".need-to-log-in").hide();

                  if(!Parse.User.current()){
                      $(".picture-data").hide();
                  }else{
                      $(".picture-data").show();
                  }

                  //console.log(response);

                  if (!user.existed()) {
                      FB.api('/me', null, function(response) {
                          console.log(response);

                          user.set("username", response.first_name+response.last_name);
                          user.set("email", response.email);
                          user.set("facebookId", response.id);

                          user.save(null, {
                              success: function (n) {
                                  console.log("saved successfully");
                                  that.gotoProfile();

                              },
                              error: function (item,error) {
                                  console.log("User save error: " + error.message);
                              }
                          });
                      });
                  }else{
                    that.gotoProfile();
                  }            
                  
                  
              },
              error: function (user, error) {
                  console.log("Oops, something went wrong.", error);
              }
          });

          return false;
      });    
    },

        gotoProfile: function(){
          if(Parse.User.current()){
              location.href = "/profile/"+Parse.User.current().attributes.username;
          }
        }		
    }

    Index.init();
})