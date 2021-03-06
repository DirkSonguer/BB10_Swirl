// *************************************************** //
// User Logout Sheet
//
// The user logout sheet uses a webview to trigger the
// logout functionality of Foursquare. The platform will
// invalidate the session keys accordingly.
//
// Author: Dirk Songuer
// License: CC BY-NC 3.0
// License: https://creativecommons.org/licenses/by-nc/3.0
// *************************************************** //

// import blackberry components
import bb.cascades 1.3

// set import directory for components
import "../components"

// shared js files
import "../global/globals.js" as Globals
import "../global/copytext.js" as Copytext

Page {
    id: userLogoutSheet

    Container {
        // layout orientation
        layout: DockLayout {
        }

        InfoMessage {
            id: infoMessage
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
        }

        // webview container
        Container {
            // this webview just calls the Foursquare logout functionality
            WebView {
                url: "https://de.foursquare.com/logout"
                maxHeight: 1
                maxWidth: 1
            }
        }
    }

    onCreationCompleted: {
        infoMessage.showMessage(Copytext.swirlLogoutSuccessMessage, Copytext.swirlLogoutSuccessTitle);
    }

    // close action for the sheet
    actions: [
        ActionItem {
            title: "Close and relogin"
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: "asset:///images/icons/icon_close.png"

            // close sheet when pressed
            // note that the sheet is defined in the main.qml
            onTriggered: {
                // close sheet
                logoutSheet.close();

                // create and open login sheet
                var loginSheetPage = loginComponent.createObject();
                loginSheet.setContent(loginSheetPage);
                loginSheet.open();
            }
        }
    ]

    // attached objects
    // this contains the sheets which are used for general page based popupos
    attachedObjects: [
        // sheet for login page
        // this is used by the main menu
        Sheet {
            id: loginSheet

            // attach a component for the about page
            attachedObjects: [
                ComponentDefinition {
                    id: loginComponent
                    source: "UserLogin.qml"
                }
            ]
        }
    ]
}
