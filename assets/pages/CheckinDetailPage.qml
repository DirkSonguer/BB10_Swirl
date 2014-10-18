// *************************************************** //
// Checkin Detail Page
//
// The checkin detail page.
//
// Author: Dirk Songuer
// License: All rights reserved
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
    signal addCommentDataLoaded()

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

        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }

            VenueHeader {
                id: checkinDetailHeader

                // header was clicked
                onClicked: {
                    // open page with new venue object
                    var venueDetailPage = venueDetailComponent.createObject();
                    venueDetailPage.venueData = checkinDetailPage.checkinData.venue;
                    navigationPane.push(venueDetailPage);
                }
            }

            Container {
                id: checkinDetailTiles

                // layout orientation
                layout: GridLayout {
                    columnCount: 2
                }

                // user checkin details tile
                InfoTile {
                    id: checkinDetailUserCheckinTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / checkinDetailPage.columnCount
                    preferredWidth: DisplayInfo.width / checkinDetailPage.columnCount

                    // user was clicked, open detail page
                    onClicked: {
                        // console.log("# User clicked: " + userData.userId);
                        var userDetailPage = userDetailComponent.createObject();
                        userDetailPage.userData = checkinDetailPage.checkinData.user;
                        navigationPane.push(userDetailPage);
                    }
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
            CommentPreview {
                id: checkinDetailComments

                // layout definition
                // preferredHeight: DisplayInfo.width / checkinDetailPage.columnCount
                preferredWidth: DisplayInfo.width

                visible: false

                onCalculatedHeightChanged: {
                    console.log("# Calculated height changed to: " + calculatedHeight);
                    checkinDetailComments.preferredHeight = calculatedHeight + ui.sdu(2);
                }
            }

            // comment input
            CommentInput {
                id: checkinDetailCommentInput

                // comment should be added
                onTriggered: {
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

    // calling page handed over the simple venue object
    // based on that, fill first data and load full venue object
    onCheckinDataChanged: {
        // console.log("# Simple venue object handed over to the page");

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

        // location name
        checkinDetailHeader.name = checkinData.venue.name;

        // user name and image
        checkinDetailUserCheckinTile.bodytext = checkinData.user.firstName + " checked in here " + checkinData.elapsedTime + " ago";
        checkinDetailUserCheckinTile.webImage = checkinData.user.profileImageLarge;
        /*
         * // shout / message
         * if (checkinData.shout != "") {
         * checkinDetailShoutTile.bodytext = "\"" + checkinData.shout + "\"";
         * checkinDetailShoutTile.visible = true;
         * }
         */
        // location category
        if (checkinData.venue.locationCategories != "") {
            checkinDetailHeader.category = checkinData.venue.locationCategories[0].name;
        }

        // fill header image
        if (checkinData.venue.locationCategories != "") {
            checkinDetailHeader.image = checkinData.venue.locationCategories[0].iconLarge
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
            checkinDetailPhotosTile.webImage = checkinData.photos[0].imageFull;
            checkinDetailPhotosTile.visible = true;
        }

        // add comments to list
        if (checkinData.comments.length > 0) {
            checkinDetailComments.addToList(checkinData.comments);
            // checkinDetailComments.preferredHeight = checkinData.comments.length * ui.sdu(14);
            checkinDetailComments.visible = true;
        }

        // like tile data
        checkinDetailLikesTile.checkinData = checkinData;
    }

    // full user object has been loaded
    // fill entire page components with data
    onVenueDetailDataLoaded: {
        // console.log("# Venue detail data loaded for venue " + venueData.venueId);

        checkinDetailPage.venueDataDetailsLoaded = true;

        // fill header image
        if (venueData.photos != "") {
            checkinDetailHeader.image = venueData.photos[(venueData.photos.length - 1)].imageFull;
        } else if (venueData.locationCategories != "") {
            checkinDetailHeader.image = venueData.locationCategories[0].iconLarge
        }

        // location name
        checkinDetailHeader.name = venueData.name;

        // location category
        if (venueData.locationCategories != "") {
            checkinDetailHeader.category = venueData.locationCategories[0].name;
        }
    }

    onCheckinDataLoaded: {
        console.log("# Checkin detail data loaded for checkin " + checkinData.checkinId);

        checkinDetailPage.checkinDataDetailsLoaded = true;

        if (checkinData.comments.length > 0) {
            checkinDetailComments.clearList();
            checkinDetailComments.addToList(checkinData.comments);
            // checkinDetailComments.preferredHeight = checkinData.comments.length * ui.sdu(14);
            checkinDetailComments.visible = true;
        }
        //        checkinDetailPage.checkinData = checkinData;
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