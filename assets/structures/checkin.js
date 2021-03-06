// *************************************************** //
// Checkin Data Structure
//
// This structure holds metadata related to a checkin
//
// Author: Dirk Songuer
// License: CC BY-NC 3.0
// License: https://creativecommons.org/licenses/by-nc/3.0
// *************************************************** //

if (typeof dirPaths !== "undefined") {
	Qt.include(dirPaths.assetPath + "structures/sticker.js");
}

// data structure for Foursquare checkin
function FoursquareCheckinData() {
	// checkin id
	this.checkinId = "";
	
	// shout / message for the checkin
	this.shout = "";

	// timestamps
	this.createdAt = "";
	this.elapsedTime = "";

	// distances
	this.distance = "";

	// liked state
	this.userHasLiked = "";
	
	// current interaction counts
	this.commentCount = "";
	this.likeCount = "";
	this.photoCount = "";
	
	// mayorship status
	this.isMayor = "";

	// this is filled by a FoursquareUserData object
	this.user = "";

	// this is filled by a FoursquareVenueData object
	this.venue = "";
	
	// this is filled by an array of FoursquareScoreData objects
	this.scores = "";

	// this is filled by an array of FoursquareStickerData objects
	this.sticker = new FoursquareStickerData();
	
	// this is filled by an array of FoursquareNotificationData objects
	this.notifications = "";

	// this is filled by an array of FoursquarePhotoData objects
	this.photos = "";
		
	// this is filled by an array of FoursquareCommentData objects
	this.comments = "";
	
	// this is filled by a FoursquareLikeData object
	this.likes = "";
}
