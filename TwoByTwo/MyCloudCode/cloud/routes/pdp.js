exports.index = function(req, resp){
	//req.query.id
	resp.render('pdp', { title: 'Express' });
};