var Buffer = require('buffer').Buffer;

exports.index = function(req, resp){
	var Grid = Parse.Object.extend("Grid");
	var query = new Parse.Query(Grid);


	if(req.query.username){
		query.equalTo("username", req.query.username);
	}

	if(req.query.featured){
		query.equalTo("featured", true);
	}

	if(req.query.limit){
		query.equalTo("limit", req.query.limit);
	}
	
	query.find({
		success: function(gridArr) {
            var data = gridArr[0].attributes;
            var base64String = data.image64;
  			var buffer1 = new Buffer(base64String, 'base64');
  			//resp.render('img', { img: buffer1.toString('base64') }); 

  			resp.set('Content-Type', 'image/jpeg');
  			resp.send(buffer1); 
	    },
        error: function(object, error) {
            // The object was not retrieved successfully.
            // error is a Parse.Error with an error code and description.
            console.log("error: ",error);
        }
    });


};



 
