exports.friend_left_comment_your_photo = "friend_left_comment_your_photo";
exports.friend_left_comment = "friend_left_comment";


exports.getCopy = function(category, dataObject){
	var copy;

	switch (category) {
      case exports.friend_left_comment_your_photo:
      	//onComment.js
      	//msg
        copy = "Your friend [username], just left a comment on your photo.";
        copy = copy.replace("[username]", dataObject.username);
        break;
      case exports.friend_left_comment:
      	//onComment.js
      	//msg
        copy = "Your friend [username], just left a comment on a photo you commented on.";
        copy = copy.replace("[username]", dataObject.username);
        break;      	
      default:
        copy = "[x]";
        break;
    }

    return copy;
}