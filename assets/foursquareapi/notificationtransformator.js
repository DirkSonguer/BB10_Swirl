//*************************************************** //
// Notification Transformator Class
//
// This class contains methods to transform the data
// from Foursquare into usable stuctures.
//
// Author: Dirk Songuer
// License: All rights reserved
//*************************************************** //

// include other scripts used here
Qt.include(dirPaths.assetPath + "global/globals.js");
Qt.include(dirPaths.assetPath + "classes/helpermethods.js");
Qt.include(dirPaths.assetPath + "structures/notification.js");

// Class function that gets the prototype methods
function NotificationTransformator() {
}
// Extract all user data from a user object
// The resulting user data is in the standard user format as
// FoursquareUserData()
NotificationTransformator.prototype.getNotificationDataFromObject = function(notificationObject) {
	console.log("# Transforming notification item with id: " + notificationObject.ids[0]);

	var notificationData = new FoursquareNotificationData();
	
	notificationData.notificationID = notificationObject.ids[0];
	notificationData.referralID = notificationObject.referralId;

	notificationData.unread = notificationObject.unread;

	notificationData.text = notificationObject.text;

	notificationData.createdAt = notificationObject.createdAt;
	
	var helperMethods = new HelperMethods();
	notificationData.elapsedTime = helperMethods.formatTimestamp(notificationObject.createdAt);

	notificationData.image = notificationObject.image.fullPath;
	if (typeof notificationObject.icon != 'undefined') {
		notificationData.icon = notificationObject.icon.prefix + notificationObject.icon.sizes[(notificationObject.icon.sizes.length)-1] + notificationObject.icon.name;		
	}
	
	console.log("# Done transforming notification item");
	return notificationData;
};