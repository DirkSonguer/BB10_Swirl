// *************************************************** //
// Checkin Detail Page
//
// The checkin detail page.
//
// Author: Dirk Songuer
// License: CC BY-NC 3.0
// License: https://creativecommons.org/licenses/by-nc/3.0
// *************************************************** //

// import blackberry components
import bb.cascades 1.3
import bb.platform 1.3
import bb.system.phone 1.0

// set import directory for components
import "../components"

// shared js files
import "../global/globals.js" as Globals
import "../global/copytext.js" as Copytext
import "../foursquareapi/venues.js" as VenueRepository
import "../foursquareapi/checkins.js" as CheckinsRepository

// import image url loader component
import CommunicationInvokes 1.0

Page {
    id: checkinDetailPage

    // signal if venue data loading is complete
    signal venueDetailDataLoaded(variant venueData)

    // signal if venue data loading encountered an error
    signal venueDetailDataError(variant errorData)

    // signal if checkin data loading is complete
    signal checkinDataLoaded(variant checkinData)

    // signal if checkin data loading encountered an error
    signal checkinDataError(variant errorData)

    // signal if comment has been added
    signal addCommentDataLoaded(variant commentData)

    // signal if adding a comment encountered an error
    signal addCommentDataError(variant errorData)

    // property that holds the checkin data to load
    // this is filled by the calling page
    // contains only a limited object when filled
    // will be extended once the full data is loaded
    property variant checkinData

    // flag to check if checkin data detail object has been loaded
    property bool checkinDataDetailsLoaded: false

    // flag to check if venue data detail object has been loaded
    property bool venueDataDetailsLoaded: false

    // column count
    property int columnCount: 2

    ScrollView {
        // only vertical scrolling is needed
        scrollViewProperties {
            scrollMode: ScrollMode.Vertical
            pinchToZoomEnabled: false
        }

        // main container
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }

            // venue header
            CheckinHeader {
                id: checkinDetailHeader

                // venue was clicked, open detail page
                onVenueClicked: {
                    // console.log("# Venue clicked: " + checkinDetailPage.checkinData.venue);
                    var venueDetailPage = venueDetailComponent.createObject();
                    venueDetailPage.venueData = checkinDetailPage.checkinData.venue;
                    navigationPane.push(venueDetailPage);
                }

                // user was clicked, open detail page
                onUserClicked: {
                    // console.log("# User clicked: " + checkinDetailPage.checkinData.user);
                    var userDetailPage = userDetailComponent.createObject();
                    userDetailPage.userData = checkinDetailPage.checkinData.user;
                    navigationPane.push(userDetailPage);
                }

            }

            // container for the info tiles
            Container {
                id: checkinDetailTiles

                // layout orientation
                layout: GridLayout {
                    columnCount: checkinDetailPage.columnCount
                }

                // address tile
                LocationTile {
                    id: checkinDetailAddressTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / checkinDetailPage.columnCount
                    preferredWidth: DisplayInfo.width / checkinDetailPage.columnCount

                    // set initial visibility to false
                    // will be set if the venue has a given address
                    visible: false

                    // call bb maps on click
                    onClicked: {
                        locationBBMapsInvoker.go();
                    }

                    // TODO: Call menu with Google maps
                    onLongPress: {
                    }
                }

                // photos tile
                InfoTile {
                    id: checkinDetailPhotosTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / checkinDetailPage.columnCount
                    preferredWidth: DisplayInfo.width / checkinDetailPage.columnCount

                    // set initial visibility to false
                    // will be set if the venue has photos
                    visible: false

                    // open photo gallery page
                    onClicked: {
                        // console.log("# Photo tile clicked");
                        var photoGalleryPage = photoGalleryComponent.createObject();
                        photoGalleryPage.photoData = checkinDetailPage.checkinData.photos;
                        navigationPane.push(photoGalleryPage);
                    }
                }

                // likes tile
                LikeTile {
                    id: checkinDetailLikesTile

                    // layout definition
                    preferredHeight: DisplayInfo.width / checkinDetailPage.columnCount
                    preferredWidth: DisplayInfo.width / checkinDetailPage.columnCount
                }
            }

            // comment preview
            CommentTile {
                id: checkinDetailComments

                // layout definition
                preferredHeight: DisplayInfo.width / checkinDetailPage.columnCount
                preferredWidth: DisplayInfo.width

                // set initial visibility to false
                // will be set true if the comment data has been load
                visible: false

                // open comment page on click
                onClicked: {
                    // console.log("# Comment tile clicked");
                    var commentDetailPage = commentDetailComponent.createObject();
                    commentDetailPage.commentData = checkinDetailPage.checkinData.comments;
                    commentDetailPage.checkinId = checkinDetailPage.checkinData.checkinId;
                    navigationPane.push(commentDetailPage);
                }
            }

            // comment input
            CommentInput {
                id: checkinDetailCommentInput

                // set initial visibility to false
                // will be set true if the comment data has been load
                visible: false

                // comment should be added
                onTriggered: {
                    checkinDetailComments.visible = false;
                    checkinDetailCommentInput.visible = false;

                    CheckinsRepository.addComment(checkinDetailPage.checkinData.checkinId, commentText, checkinDetailPage);
                }
            }

            // standard loading indicator
            LoadingIndicator {
                id: loadingIndicator
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
            }

            // standard info message
            InfoMessage {
                id: infoMessage
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
            }
        }
    }

    // calling page handed over the checkin object
    // based on that, fill first data and load full venue object
    // note that this is a simplified checkin object without comments,
    // so we reload the full one as well
    onCheckinDataChanged: {
        // console.log("# Checkin object handed over to the page");

        // check if full venue object has been loaded
        if (! checkinDetailPage.venueDataDetailsLoaded) {
            // load full user object
            VenueRepository.getVenueData(checkinData.venue.venueId, checkinDetailPage);
        }

        // check if full checkin object has been loaded
        if (! checkinDetailPage.checkinDataDetailsLoaded) {
            // load full user object
            CheckinsRepository.getCheckinData(checkinData.checkinId, checkinDetailPage);
        }

        // checkin venue and user
        checkinDetailHeader.userImage = checkinData.user.profileImageLarge;
        checkinDetailHeader.userData = checkinData.user.firstName + " checked in at";
        checkinDetailHeader.venueData = checkinData.venue.name;
        checkinDetailHeader.timeData = checkinData.elapsedTime + " ago";

        // fill venue header image with venue category icon
        // this will later be overwritten if a venue photo is found
        if ((checkinData.venue.locationCategories != "") && (checkinDetailHeader.venueImage == "")) {
            checkinDetailHeader.venueImage = checkinData.venue.locationCategories[0].iconLarge;
        }

        // fill sticker header image with sticker category icon
        if (checkinData.sticker.imageFull != "") {
            checkinDetailHeader.stickerImage = checkinData.sticker.imageFull;
        }

        // fill sticker header image with sticker category icon
        if (checkinData.sticker.imageEffect != "") {
            checkinDetailHeader.stickerEffectImage = checkinData.sticker.imageEffect;
        }
        
        // fill mayor crown if user is mayor with checkin
        if (checkinData.isMayor != "false") {
            checkinDetailHeader.isMayor = checkinData.isMayor;
        }        

        // venue map
        checkinDetailAddressTile.zoom = "15";
        checkinDetailAddressTile.size = "400";
        checkinDetailAddressTile.venueLocation = checkinData.venue.location;
        checkinDetailAddressTile.webImage = checkinData.venue.locationCategories[0].iconLarge;

        // show address if formatted address is available
        // otherwise show name
        if (checkinData.venue.location.formattedAddress != "") {
            checkinDetailAddressTile.headline = checkinData.venue.location.formattedAddress;
        } else {
            checkinDetailAddressTile.headline = checkinData.venue.name;
        }

        // set data for bb maps invocation
        locationBBMapsInvoker.locationLatitude = checkinData.venue.location.lat;
        locationBBMapsInvoker.locationLongitude = checkinData.venue.location.lng;
        locationBBMapsInvoker.locationName = checkinData.venue.name;
        locationBBMapsInvoker.centerLatitude = checkinData.venue.location.lat;
        locationBBMapsInvoker.altitude = 200;
        checkinDetailAddressTile.visible = true;

        // check if checkin has photos
        if ((checkinData.photoCount > 0) && (checkinData.photos !== "")) {
            checkinDetailPhotosTile.webImage = checkinData.photos[0].imageMedium;
            checkinDetailPhotosTile.visible = true;
        }

        // like tile data
        checkinDetailLikesTile.checkinData = checkinData;

        // check for passport
        if ((DisplayInfo.width == 1440) && (DisplayInfo.width == 1440)) {
            // change column count to 3 to account for wider display
            checkinDetailPage.columnCount = 3;
        }
    }

    // full user object has been loaded
    // fill entire page components with data
    onVenueDetailDataLoaded: {
        // console.log("# Venue detail data loaded for venue " + venueData.venueId);

        // set data loaded flag to true
        checkinDetailPage.venueDataDetailsLoaded = true;

        // check if the venue has a photo
        // if so fill venue header image
        if ((venueData.photoCount > 0) && (venueData.photos !== "")) {
            checkinDetailHeader.venueImage = venueData.photos[(venueData.photos.length - 1)].imageMedium;
        } else if (venueData.locationCategories != "") {
            // only set icon if it has not been set already
            if (checkinDetailHeader.venueImage != venueData.locationCategories[0].iconLarge) {
                checkinDetailHeader.venueImage = venueData.locationCategories[0].iconLarge;
            }
        }
    }

    // checkin detail data has been loaded
    onCheckinDataLoaded: {
        // console.log("# Checkin detail data loaded for checkin " + checkinData.checkinId);

        // set data loaded flag to true
        checkinDetailPage.checkinDataDetailsLoaded = true;

        // fill comments list and show it if content is available
        if (checkinData.comments.length > 0) {
            checkinDetailComments.backgroundImage = checkinData.comments[0].user.profileImageLarge;
            checkinDetailComments.count = checkinData.comments.length + " comments";
            checkinDetailComments.bodytext = "\"" + checkinData.comments[0].text + "\"";
            checkinDetailComments.visible = true;
        }

        // show comment input field
        checkinDetailCommentInput.visible = true;

        // save checkinData to page object
        checkinDetailPage.checkinData = checkinData;
    }

    // comment data has been added
    onAddCommentDataLoaded: {
        // console.log("# Comment data has been added");

        // reload full user object with updated comments
        CheckinsRepository.getCheckinData(checkinData.checkinId, checkinDetailPage);

        // reset comment input field
        checkinDetailCommentInput.reset();
    }

    // invocation for opening other apps
    attachedObjects: [
        Phone {
            id: phoneDialer
        },
        CommunicationInvokes {
            id: communicationInvokes
        },
        // user detail page
        // will be called if user clicks on user item
        ComponentDefinition {
            id: userDetailComponent
            source: "UserDetailPage.qml"
        },
        // photo gallery page
        // will be called if user clicks on photo info tile
        ComponentDefinition {
            id: photoGalleryComponent
            source: "PhotoGalleryPage.qml"
        },
        // comment detail page
        // will be called if user clicks on comment item
        ComponentDefinition {
            id: commentDetailComponent
            source: "CommentDetailPage.qml"
        },
        // venue detail page
        // will be called if user clicks on venue item
        ComponentDefinition {
            id: venueDetailComponent
            source: "VenueDetailPage.qml"
        },
        // map invoker
        // used to hand over location data to bb maps
        LocationMapInvoker {
            id: locationBBMapsInvoker
        }
    ]
}
