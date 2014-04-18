var WD = require('cloud/WeeklyDigest.js');

exports.main = function(request, status) {
	WD.main(request, status,1000,0);
}



