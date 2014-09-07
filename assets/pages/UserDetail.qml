// *************************************************** //
// User Detail Page
//
// The user detail page shows details and metadata of
// the given user.
//
// Author: Dirk Songuer
// License: All rights reserved
// *************************************************** //

// import blackberry components
import bb.cascades 1.3
import bb.system.phone 1.0

// set import directory for components
import "../components"

// shared js files
import "../global/globals.js" as Globals
import "../global/copytext.js" as Copytext
import "../foursquareapi/users.js" as UsersRepository

// import image url loader component
import CommunicationInvokes 1.0

Page {
    id: userDetailPage

    // signal if user profile data loading is complete
    signal userDetailDataLoaded(variant userData)

    // signal if user profile data loading encountered an error
    signal userDetailDataError(variant errorData)

    // property that holds the user data to load
    // this is filled by the calling page
    // contains only a limited object when filled
    // will be extended once the full data is loaded
    property variant userData

    // flag to chek if user data detail object has been loaded
    property bool userDataDetailsLoaded: false

    // property for the friend image slideshow
    // a timer will update this to swap through the images
    property int currentFriendImage: 0

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

            UserHeader {
                id: userDetailHeader
            }

            Container {
                id: userDetailTiles

                // layout orientation
                layout: GridLayout {
                    columnCount: 2
                }

                // friends tile
                InfoTile {
                    id: userDetailFriendsTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / 2
                    preferredWidth: DisplayInfo.width / 2

                    // set initial visibility to false
                    // will be set if the user has friends
                    visible: false
                }

                // photos tile
                InfoTile {
                    id: userDetailPhotosTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / 2
                    preferredWidth: DisplayInfo.width / 2

                    // set initial visibility to false
                    // will be set if the user has photos
                    visible: false
                }

                // facebook contact tile
                InfoTile {
                    id: userDetailFacebookContactTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / 2
                    preferredWidth: DisplayInfo.width / 2

                    // set icon & label
                    // localImage: "asset:///images/icons/icon_facebook_w.png"
                    // imageScaling: ScalingMethod.None
                    headline: "Facebook"

                    // set initial visibility to false
                    // will be set if the user has stored facebook contacts
                    visible: false

                    // define facebook invocation
                    onClicked: {
                        communicationInvokes.openFacebookProfile(userDetailPage.userData.contact.facebook);
                    }
                }

                // twitter contact tile
                InfoTile {
                    id: userDetailTwitterContactTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / 2
                    preferredWidth: DisplayInfo.width / 2

                    // set icon & label
                    // localImage: "asset:///images/icons/icon_twitter_w.png"
                    // imageScaling: ScalingMethod.None
                    headline: "Twitter"

                    // set initial visibility to false
                    // will be set if the user has stored twitter contacts
                    visible: false

                    // define twitter invocation
                    onClicked: {
                        // communicationInvokes.sendTwitterMessage("@" + userDetailPage.userData.contactTwitter + ": ");
                        communicationInvokes.openTwitterProfile(userDetailPage.userData.contact.twitter);
                    }
                }

                // phone contact tile
                InfoTile {
                    id: userDetailPhoneContactTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / 2
                    preferredWidth: DisplayInfo.width / 2

                    // set icon & label
                    localImage: "asset:///images/icons/icon_call_w.png"
                    imageScaling: ScalingMethod.None
                    headline: "Call"

                    // set initial visibility to false
                    // will be set if the user has stored phone contacts
                    visible: false

                    // define phone invocation
                    onClicked: {
                        // phone class provides a dialer pad
                        phoneDialer.requestDialpad(userDetailPage.userData.contact.phone);
                    }
                }

                // sms contact tile
                InfoTile {
                    id: userDetailSMSContactTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / 2
                    preferredWidth: DisplayInfo.width / 2

                    // set icon & label
                    localImage: "asset:///images/icons/icon_sms_w.png"
                    imageScaling: ScalingMethod.None
                    headline: "Send SMS"

                    // set initial visibility to false
                    // will be set if the user has stored sms contacts
                    visible: false

                    // define SMS invocation
                    onClicked: {
                        communicationInvokes.sendTextMessage(userDetailPage.userData.contact.phone, "Hi there!", false);
                    }
                }

                // mail contact tile
                InfoTile {
                    id: userDetailMailContactTile

                    // layout definition
                    backgroundColor: Color.create(Globals.blackberryStandardBlue)
                    preferredHeight: DisplayInfo.width / 2
                    preferredWidth: DisplayInfo.width / 2

                    // set icon & label
                    localImage: "asset:///images/icons/icon_mail_w.png"
                    imageScaling: ScalingMethod.None
                    headline: "Send Mail"

                    // set initial visibility to false
                    // will be set if the user has stored sms contacts
                    visible: false

                    // define email invocation
                    onClicked: {
                        communicationInvokes.sendMail(userDetailPage.userData.contact.email, "Hi there!", "");
                    }
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

    // calling page handed over the simple user object
    // based on that, fill first data and load full user object
    onUserDataChanged: {
        // console.log("# Simple user object handed over to the page");

        // fill header data based on simple user object
        userDetailHeader.username = userData.fullName;
        userDetailHeader.profileImage = userData.profileImageLarge;

        // check if full user object has been loaded
        if (! userDetailPage.userDataDetailsLoaded) {
            // load full user object
            UsersRepository.getUserData(userData.userId, userDetailPage);
        }
    }

    // full user object has been loaded
    // fill entire page components with data
    onUserDetailDataLoaded: {
        // console.log("# User detail data loaded for user " + userData.userId);

        // store the full object and set flag to true
        userDetailPage.userDataDetailsLoaded = true;
        userDetailPage.userData = userData;

        // fill header data based on full user object
        userDetailHeader.bio = userData.bio;

        // get name of last venue the user checked in
        if (userData.checkins.length > 0) {
            userDetailHeader.lastCheckin = userData.checkins[0].venue.name;
        }

        // check if user has photos
        if (userData.photoCount > 0) {
            userDetailPhotosTile.headline = userData.photoCount + " Photos";
            userDetailPhotosTile.visible = true;

            // activate and show user photos if available
            if (userData.photos[0] !== "") {
                userDetailPhotosTile.webImage = userData.photos[0].imageFull;
            }
        }

        // check if user has friends
        if (userData.friends.length > 0) {
            // fill friends tile data
            userDetailFriendsTile.headline = userData.friendCount + " Friends";
            userDetailFriendsTile.visible = true;

            // activate and show friends image if available
            userDetailFriendsTile.webImage = userData.friends[0].profileImageLarge;
        }

        // activate invocation and show tile if twitter id is available
        if (userData.contact.twitter !== "") {
            userDetailTwitterContactTile.visible = true;
            userDetailTwitterContactTile.webImage = "http://avatars.io/twitter/" + userData.contact.twitter + "?size=large";
        }

        // activate invocation and show tile if facebook id is available
        if (userData.contact.facebook !== "") {
            userDetailFacebookContactTile.visible = true;
            userDetailFacebookContactTile.webImage = "https://graph.facebook.com/" + userData.contact.facebook + "/picture?type=large&width=400&height=400";
        }

        // activate invocation and show tile if phone number is available
        if (userData.contact.phone !== "") {
            userDetailPhoneContactTile.headline = "Call " + userData.fullName;
            userDetailPhoneContactTile.visible = true;
            userDetailSMSContactTile.visible = true;
        }

        // activate invocation and show tile if mail is available
        if (userData.contact.email !== "") {
            userDetailMailContactTile.visible = true;
        }
    }

    // invocation for opening other apps
    attachedObjects: [
        Phone {
            id: phoneDialer
        },
        CommunicationInvokes {
            id: communicationInvokes
        }
    ]
}
