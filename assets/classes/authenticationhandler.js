// *************************************************** //
// Authenticationhandler Script
//
// This script handles the current Foursquare user that
// is authenticated for the application.
// This includes the actual authentication process as
// well as general checks if the user is already
// authenticated or not.
// The general userdata will be stored in the local
// app database (table: userdata).
// Note that it's a class that needs to be defined first:
// auth = new AuthenticationHandler();
//
// Author: Dirk Songuer
// License: All rights reserved
// *************************************************** //

// include other scripts used here
if (typeof dirPaths !== "undefined") {
	Qt.include(dirPaths.assetPath + "global/foursquarekeys.js");
}

// singleton instance of class
var auth = new AuthenticationHandler();

// class function that gets the prototype methods
function AuthenticationHandler() {
}

// This checks a given URL for oauth data
// It can either be a token if the authentication was successful
// or it can contain an error with respective message
AuthenticationHandler.prototype.checkFoursquareAuthenticationUrl = function(url) {
	// console.log("# Checking Foursquare URL for authentication information: "
	// + url.toString());

	var currentURL = url.toString();
	var returnStatus = new Array();

	// set default status
	returnStatus["status"] = "NOT_RELEVANT";

	// authentication was successful: the URL contains the redirect address as
	// well the token code
	if ((currentURL.indexOf(foursquarekeys.foursquareRedirectUrl) === 0) && (currentURL.indexOf("access_token=") > 0)) {
		// cut URL from string and extract the foursquare token
		var foursquareTokenCode = "";
		var tokenStartPosition = currentURL.indexOf("access_token=");
		foursquareTokenCode = currentURL.substr((tokenStartPosition + 13));

		// if there is an Foursquare token, store it and set the return status
		if (foursquareTokenCode.length > 0) {
			// console.log("# Found Foursquare access token code: " +
			// foursquareTokenCode);
			this.validateAccessToken(foursquareTokenCode);
			returnStatus["status"] = "AUTH_SUCCESS";
		}
	}

	// an error occured: the URL contains the error parameters
	if ((currentURL.indexOf(foursquarekeys.foursquareRedirectUrl) === 0) && (currentURL.indexOf("error=") > 0)) {
		// cut URL from string so that only the error message is left
		var stringIndexPosition = currentURL.indexOf("/?");
		var errorString = "";
		errorString = currentURL.substr((stringIndexPosition + 2));

		// split the error messages into an array
		var errorMessageList = new Array();
		errorMessageList = errorString.split("&");
		
		// go through the list of messages and put them into the return array
		for ( var index in errorMessageList) {
			var errorMessage = new Array();
			errorString = errorMessageList[index];
			errorMessage = errorString.split("=");
			returnStatus[errorMessage[0]] = errorMessage[1].replace(/\+/g, ' ');
		}

		returnStatus["status"] = "AUTH_ERROR";
	}

	// console.log("# Done checking Foursquare URL for authentication
	// information: " + returnStatus);
	return returnStatus;
};

// This validates an access token by calling a restricted method (/users/self)
// which requires a valid access token
// If the response contains a user object, the token is valid
// This also extracts the user id of the user that is logged in, which is stored
// in the database along with the token
AuthenticationHandler.prototype.validateAccessToken = function(accessToken) {
	// console.log("# Validating access token");

	var req = new XMLHttpRequest();
	req.onreadystatechange = function() {
		if (req.readyState === XMLHttpRequest.DONE) {
			if (req.status != 200) {
				// console.log("# Error happened while validating access token,
				// got HTTP status " + req.status);
				return;
			}

			// check response content
			// the correct response should contain a user object
			var jsonObject = eval('(' + req.responseText + ')');
			if ((jsonObject.error == null) && (jsonObject["response"]["user"].id != null)) {
				var userid = jsonObject["response"]["user"].id;
				auth.storeFoursquareData(userid, accessToken);
				// console.log("# Done validating access token for user " +
				// userid);
			}
		}
	};

	var url = "https://api.foursquare.com/v2/users/self?oauth_token=" + accessToken + "&v=" + foursquarekeys.foursquareAPIVersion;
	// console.log("# Checking URL: " + url);

	req.open("GET", url, true);
	req.send();
};

// Store the access token for a user into the database along with the user id
// Note that only one Foursquare token can exist in the database at any given
// time
AuthenticationHandler.prototype.storeFoursquareData = function(userId, accessToken) {
	// console.log("# Storing userdata into database for user: " + userId + "
	// with token: " + accessToken);

	// check if there is already user data in the database
	if (auth.isAuthenticated()) {
		// console.log("# User already has a stored access token");
		return;
	}

	var db = openDatabaseSync("Swirl", "1.0", "Swirl persistent data storage", 1);

	db.transaction(function(tx) {
		tx.executeSql('CREATE TABLE IF NOT EXISTS userdata(id TEXT, access_token TEXT)');
	});

	var dataStr = "INSERT INTO userdata VALUES(?, ?)";
	var data = [ userId, accessToken ];
	db.transaction(function(tx) {
		tx.executeSql(dataStr, data);
	});

	// console.log("# Done storing userdata into database");
};

// Get the stored access token for the user
// Note that only one Foursquare token can exist in the database at any given
// time
AuthenticationHandler.prototype.getStoredFoursquareData = function() {
	// console.log("# Getting stored userdata from database for user");

	var foursquareUserdata = new Array();
	var db = openDatabaseSync("Swirl", "1.0", "Swirl persistent data storage", 1);

	db.transaction(function(tx) {
		tx.executeSql('CREATE TABLE IF NOT EXISTS userdata(id TEXT, access_token TEXT)');
	});

	db.transaction(function(tx) {
		var rs = tx.executeSql("SELECT * FROM userdata");
		if (rs.rows.length > 0) {
			foursquareUserdata = rs.rows.item(0);
		}
	});

	// console.log("# Done getting stored userdata from database for user");
	return foursquareUserdata;
};

// Check if the user is currently authenticated with Foursquare
// From the application point of view this is the case if a token exists in the
// database
// Note that the token might be invalid / rejected by Foursquare but this is
// handled by the errorhandler (which also deletes an invalid token)
AuthenticationHandler.prototype.isAuthenticated = function() {
	// console.log("# Checking if user is authenticated");
	var userdata = new Array();

	// get the userdata from the persistent database
	// if data is available the user already has a token
	userdata = this.getStoredFoursquareData();

	if (userdata["id"] != null) {
		// user already has a token
		// console.log("# User is authenticated with id " + userdata["id"] + " and token " + userdata["access_token"] + ". Returning true");
		return true;
	}

	// user does not have a token
	// console.log("# User is not authenticated. Returning false");
	return false;
};

// Logout user by deleting the current token from the database
// As the isAuthenticated method relies on the database content it will return
// false from now on
AuthenticationHandler.prototype.deleteStoredFoursquareData = function() {
	var db = openDatabaseSync("Swirl", "1.0", "Swirl persistent data storage", 1);

	db.transaction(function(tx) {
		tx.executeSql('DROP TABLE userdata');
	});

	return true;
};
