exports.index = function(req, resp){
	//req.query.id
	resp.render('profile', { title: 'Express' });
};