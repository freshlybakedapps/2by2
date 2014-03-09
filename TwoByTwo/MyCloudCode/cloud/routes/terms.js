exports.index = function(req, resp){
	//req.query.access_token
	resp.render('terms', { title: 'Express' });
};