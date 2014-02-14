//https://www.parse.com/docs/cloud_modules_guide#images
var Image = require("parse-image");

exports.main = function(request, response){
	var photoID = request.params.photoID;

  var Photo = Parse.Object.extend("Photo");
  var query = new Parse.Query(Photo);

  query.get(photoID, {
    success: function(photo) {
      var image_full;
      var image_half;
      var theUrl;
      var currentState;

      if(photo.get("image_full")){
        image_full = photo.get("image_full")._url; 
      }
      
      if(photo.get("image_half")){
        image_half = photo.get("image_half")._url; 
      } 

      if(image_full){
        currentState = "full";
        theUrl = image_full;
      }else{
        currentState = "half";
        theUrl = image_half;
      } 

      console.log("URL: "+theUrl);  
      var cropped;  

      
      Parse.Cloud.httpRequest({
        url: theUrl
     
      }).then(function(response) {
        var image = new Image();
        return image.setData(response.buffer);
     
      }).then(function(image) {
        // Crop the image to the smaller of width or height.
        var size = Math.min(image.width(), image.height());
        return image.crop({
          left: (image.width() - size) / 2,
          top: (image.height() - size) / 2,
          width: size,
          height: size
        });
     
      }).then(function(image) {
        // Resize the image to 64x64.
        return image.scale({
          width: 157,
          height: 157
        });
     
      }).then(function(image) {
        // Make sure it's a JPEG to save disk space and bandwidth.
        return image.setFormat("JPEG");
     
      }).then(function(image) {
        // Get the image data in a Buffer.
        return image.data();
     
      }).then(function(buffer) {
        // Save the image into a new file.
        var base64 = buffer.toString("base64");    
        cropped = new Parse.File("thumbnail.jpg", { base64: base64 });
        return cropped.save();
     
      }).then(function(cropped) {
        // Attach the image file to the original object.
        photo.set("newThumbnail", cropped);
        photo.save();
     
      }).then(function(result) {
        var url = cropped.url();    
        
        response.success("imaged cropped: "+url);


      }, function(error) {
        response.error(error);
      });      
  },    
    error: function(error) {
      //console.error("Got an error " + error.code + " : " + error.message);
      response.error(error);
    }
  });

}	