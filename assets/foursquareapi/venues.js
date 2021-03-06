// *************************************************** //
// Venues Script
//
// This script is used to load, format and show venue
// related data.
//
// Author: Dirk Songuer
// License: CC BY-NC 3.0
// License: https://creativecommons.org/licenses/by-nc/3.0
// *************************************************** //

//include other scripts used here
if (typeof dirPaths !== "undefined") {
	Qt.include(dirPaths.assetPath + "global/foursquarekeys.js");
	Qt.include(dirPaths.assetPath + "classes/authenticationhandler.js");
	Qt.include(dirPaths.assetPath + "classes/configurationhandler.js");
	Qt.include(dirPaths.assetPath + "classes/networkhandler.js");
	Qt.include(dirPaths.assetPath + "foursquareapi/transformators.js");
	Qt.include(dirPaths.assetPath + "structures/venue.js");
}

// Load the full venue object for a given venue
// First parameter is the Foursquare venue id
// Second parameter is the id of the calling page, which will receive the
// venueDetailDataLoaded() signal
function getVenueData(venueId, callingPage) {
	// console.log("# Loading detail venue data for id: " + venueId);

	var req = new XMLHttpRequest();
	req.onreadystatechange = function() {
		// this handles the result for each ready state
		var jsonObject = network.handleHttpResult(req);

		// jsonObject contains either false or the http result as object
		if (jsonObject) {
			// prepare transformator and return object
			var venueData = venueTransformator.getVenueDataFromObject(jsonObject.response.venue);

			// console.log("# Done loading venue data");
			callingPage.venueDetailDataLoaded(venueData);
		} else {
			// either the request is not done yet or an error occured
			// check for both and act accordingly
			// found error will be handed over to the calling page
			if ((network.requestIsFinished) && (network.errorData.errorCode != "")) {
				// console.log("# Error found with code " +
				// network.errorData.errorCode + " and message " +
				// network.errorData.errorMessage);
				callingPage.venueDetailDataError(network.errorData);
				network.clearErrors();
			}
		}
	};

	// check if user is logged in
	if (!auth.isAuthenticated()) {
		// console.log("# User not logged in. Aborted loading venue data");
		return false;
	}

	var url = "";
	var foursquareUserdata = auth.getStoredFoursquareData();
	url = foursquarekeys.foursquareAPIUrl + "/v2/venues/" + venueId;
	url += "?oauth_token=" + foursquareUserdata["access_token"];
	url += "&v=" + foursquarekeys.foursquareAPIVersion;
	url += "&m=swarm";

	// console.log("# Loading venue data with url: " + url);
	req.open("GET", url, true);
	req.send();
}

// Load the full photo list for a given venue
// First parameter is the Foursquare venue id
// Second parameter is the id of the calling page, which will receive the
// venuePhotoDataLoaded() signal
function getVenuePhotos(venueId, callingPage) {
	// console.log("# Loading venue photo data for id: " + venueId);

	var req = new XMLHttpRequest();
	req.onreadystatechange = function() {
		// this handles the result for each ready state
		var jsonObject = network.handleHttpResult(req);

		// jsonObject contains either false or the http result as object
		if (jsonObject) {
			// prepare transformator and return object
			var photoData = photoTransformator.getPhotoDataFromArray(jsonObject.response.photos.items);

			// console.log("# Done loading venue data");
			callingPage.venuePhotosDataLoaded(photoData);
		} else {
			// either the request is not done yet or an error occured
			// check for both and act accordingly
			// found error will be handed over to the calling page
			if ((network.requestIsFinished) && (network.errorData.errorCode != "")) {
				// console.log("# Error found with code " +
				// network.errorData.errorCode + " and message " +
				// network.errorData.errorMessage);
				callingPage.venuePhotosDataError(network.errorData);
				network.clearErrors();
			}
		}
	};

	// check if user is logged in
	if (!auth.isAuthenticated()) {
		// console.log("# User not logged in. Aborted loading venue data");
		return false;
	}

	var url = "";
	var foursquareUserdata = auth.getStoredFoursquareData();
	url = foursquarekeys.foursquareAPIUrl + "/v2/venues/" + venueId + "/photos";
	url += "?oauth_token=" + foursquareUserdata["access_token"];
	url += "&v=" + foursquarekeys.foursquareAPIVersion;
	url += "&m=swarm";

	// console.log("# Loading venue photos with url: " + url);
	req.open("GET", url, true);
	req.send();
}

// Load a list of venues according to the explore feature of Foursquare
// First parameter is the current geolocation
// Second parameter is the search term to explore venues for
// Third parameter is the radius in meters to search in
// Forth parameter is the id of the calling page, which will receive the
// venueDataLoaded() signal
function explore(currentGeoLocation, searchQuery, searchSection, searchFriendsVisited, searchRadius, callingPage) {
	// console.log("# Loading venue data for location: " +
	// currentGeoLocation.latitude + "," + currentGeoLocation.longitude);

	var req = new XMLHttpRequest();
	req.onreadystatechange = function() {
		// this handles the result for each ready state
		var jsonObject = network.handleHttpResult(req);

		// jsonObject contains either false or the http result as object
		if (jsonObject) {
			// prepare transformator and return object
			var venueDataArray = venueTransformator.getVenueDataFromGroupArray(jsonObject.response.groups[0].items);
			var venueReasonArray = reasonTransformator.getReasonDataFromGroupArray(jsonObject.response.groups[0].items);

			// console.log("# Done loading venue data");
			callingPage.venueDataLoaded(venueDataArray, venueReasonArray);
		} else {
			// either the request is not done yet or an error occured
			// check for both and act accordingly
			// found error will be handed over to the calling page
			if ((network.requestIsFinished) && (network.errorData.errorCode != "")) {
				// console.log("# Error found with code " +
				// network.errorData.errorCode + " and message " +
				// network.errorData.errorMessage);
				callingPage.venueDataError(network.errorData);
				network.clearErrors();
			}
		}
	};

	// check if user is logged in
	if (!auth.isAuthenticated()) {
		// console.log("# User not logged in. Aborted loading venue data");
		return false;
	}

	var url = "";
	var foursquareUserdata = auth.getStoredFoursquareData();
	url = foursquarekeys.foursquareAPIUrl + "/v2/venues/explore";
	url += "?oauth_token=" + foursquareUserdata["access_token"];
	url += "&ll=" + currentGeoLocation.latitude + "," + currentGeoLocation.longitude;
	if (searchQuery != "")
		url += "&query=" + searchQuery;
	if (searchRadius > 0)
		url += "&radius=" + searchRadius;
	if (searchSection != 0)
		url += "&section=" + searchSection;
	if (searchFriendsVisited > 0)
		url += "&friendVisits=visited";
	url += "&v=" + foursquarekeys.foursquareAPIVersion;
	url += "&m=foursquare";

	// console.log("# Exploring venues with url: " + url);
	req.open("GET", url, true);
	req.send();
}

// Load a list of venues according to the search feature of Foursquare
// First parameter is the current geolocation
// Second parameter is the search term to search venues for
// Third parameter is the radius in meters to search in
// Forth parameter is the id of the calling page, which will receive the
// venueDataLoaded() signal
function search(currentGeoLocation, searchIntent, searchQuery, searchRadius, callingPage) {
	// console.log("# Loading venue data for location: " +
	// currentGeoLocation.latitude + "," + currentGeoLocation.longitude);

	var req = new XMLHttpRequest();
	req.onreadystatechange = function() {
		// this handles the result for each ready state
		var jsonObject = network.handleHttpResult(req);

		// jsonObject contains either false or the http result as object
		if (jsonObject) {
			// prepare transformator and return object
			// note: the search does not have reasons
			// resons array is returned empty because of compatibility reasons with this.explore()
			var venueDataArray = venueTransformator.getVenueDataFromArray(jsonObject.response.venues);
			var venueReasonArray = new Array();

			// console.log("# Done loading venue data");
			callingPage.venueDataLoaded(venueDataArray, venueReasonArray);
		} else {
			// either the request is not done yet or an error occured
			// check for both and act accordingly
			// found error will be handed over to the calling page
			if ((network.requestIsFinished) && (network.errorData.errorCode != "")) {
				// console.log("# Error found with code " +
				// network.errorData.errorCode + " and message " +
				// network.errorData.errorMessage);
				callingPage.venueDataError(network.errorData);
				network.clearErrors();
			}
		}
	};

	// check if user is logged in
	if (!auth.isAuthenticated()) {
		// console.log("# User not logged in. Aborted loading venue data");
		return false;
	}

	var url = "";
	var foursquareUserdata = auth.getStoredFoursquareData();
	url = foursquarekeys.foursquareAPIUrl + "/v2/venues/search";
	url += "?oauth_token=" + foursquareUserdata["access_token"];
	url += "&ll=" + currentGeoLocation.latitude + "," + currentGeoLocation.longitude;
	if (searchIntent != "")
		url += "&intent=" + searchIntent;
	if (searchQuery != "")
		url += "&query=" + searchQuery;
	if (searchRadius > 0)
		url += "&radius=" + searchRadius;
	url += "&v=" + foursquarekeys.foursquareAPIVersion;
	url += "&noCorrect=0";
	url += "&m=swarm";

	// console.log("# Searching for venues with url: " + url);
	req.open("GET", url, true);
	req.send();
}
