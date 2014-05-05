exports.index = function(req, resp){
	//req.query.access_token
	resp.render('about', { title: 'about' });
};