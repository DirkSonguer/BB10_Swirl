// *************************************************** //
// User Item List Component
//
// This component shows a list of user items.
//
// Author: Dirk Songuer
// License: All rights reserved
// *************************************************** //

// import blackberry components
import bb.cascades 1.3

// shared js files
import "../global/globals.js" as Globals
import "../global/copytext.js" as Copytext

Container {
    id: userItemListComponent

    // signal if gallery is scrolled to start or end
    signal listBottomReached()
    signal listTopReached()
    signal listIsScrolling()

    // signal that comment has been added
    // note that the actual logic is done by the component
    signal commentAdded()

    // signal if item was clicked
    signal itemClicked(variant commentData)
    
    // signal if user was clicked
    signal profileClicked(variant userData)
    
    // signal that a link inside the description has been clicked
    // this can either be a username or a hashtag
    signal descriptionUsernameClicked(string username)
    signal descriptionHashtagClicked(string hashtag)

    // property that holds the id of the next image
    // this is given by Instagram for easy pagination
    property string paginationNextMaxId: ""

    // property that holds the current index
    // this is incremented as new items are added
    // to the list a provides the order the items were
    // added to the data model
    property int currentItemIndex: 0

    // properties to define how the list should be sorted
    property string listSortingKey: "timestamp"
    property alias listSortAscending: userItemListDataModel.sortedAscending

    // properties for the headline
    property alias headerText: mediaCommentHeader.headline
    property alias headerImage: mediaCommentHeader.image

    // signal to clear the gallery contents
    signal clearList()
    onClearList: {
        userItemListDataModel.clear();
    }

    // signal to add a new item
    // item is given as type InstagramCommentData
    signal addToList(variant item)
    onAddToList: {
        // console.log("# Adding item with ID " + item.commentId + " to comment list data model");
        userItemListComponent.currentItemIndex += 1;
        userItemListDataModel.insert({
                "commentData": item,
                "timestamp": item.createdTime,
                "currentIndex": userItemListComponent.currentItemIndex
            });
    }

    // this is a workaround to make the signals visible inside the listview item scope
    // see here for details: http://supportforums.blackberry.com/t5/Cascades-Development/QML-Accessing-variables-defined-outside-a-list-component-from/m-p/1786265#M641
    onCreationCompleted: {
        Qt.fullDisplaySize = DisplayInfo.width;
        Qt.itemClicked = userItemListComponent.itemClicked;
        Qt.profileClicked = userItemListComponent.profileClicked;
        Qt.descriptionUsernameClicked = userItemListComponent.descriptionUsernameClicked;
        Qt.descriptionHashtagClicked = userItemListComponent.descriptionHashtagClicked;

        if (userItemListComponent.headerText != "") {
            userItemList.scrollToPosition(0, ScrollAnimation.None);
            userItemList.scroll(-205, ScrollAnimation.Smooth);
        }
    }

    // layout orientation
    layout: DockLayout {
    }

    // list of Instagram popular media
    ListView {
        id: userItemList

        // associate the data model for the list view
        dataModel: userItemListDataModel

        leadingVisual: Container {
            id: mediaCommentHeaderContainer

            // layout orientation
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }

            // layout definition
            bottomPadding: 5

            // set initial visibility to false
            // will be set true when the headline is added
            visible: false

            // likes header
            PageHeader {
                id: mediaCommentHeader

                // layout definition
                bottomPadding: 5

                // set initial visibility to false
                // will be set true when the headline is added
                visible: false

                // make header component visible when content is added
                onHeadlineChanged: {
                    mediaCommentHeader.visible = true;
                    mediaCommentHeaderContainer.visible = true;
                }
            }

            // comment input container
            CommentInput {
                id: mediaCommentsInput

                // add comment signal
                onCommentAdded: {
                    userItemListComponent.commentAdded();
                    mediaCommentsInput.visible = true;
                }
            }
        }

        // layout orientation
        layout: StackListLayout {
            orientation: LayoutOrientation.TopToBottom
        }

        // define component which will represent list item GUI appearence
        listItemComponents: [
            ListItemComponent {
                type: "item"

                // define gallery view component as view for each list item
                Container {
                    id: imageGalleryItem

                    // layout orientation
                    layout: DockLayout {
                    }

                    // item positioning
                    verticalAlignment: VerticalAlignment.Fill
                    horizontalAlignment: HorizontalAlignment.Fill

                    // layout definition
                    topMargin: 1

                    MediaDescription {
                        // layout definition
                        preferredWidth: Qt.fullDisplaySize
                        minWidth: Qt.fullDisplaySize

                        // image description (profile picture, name and image description)
                        userimage: ListItemData.commentData.userData.profilePicture
                        username: ListItemData.commentData.userData.username
                        imagecaption: ListItemData.commentData.richText

                        // show only one line of the caption
                        captionMultiline: true
                        
                        onProfileClicked: {
                            // send user clicked event
                            Qt.profileClicked(ListItemData.commentData.userData);
                        }
                        
                        onDescriptionClicked: {
                            // send item clicked event
                            Qt.itemClicked(ListItemData.commentData);
                        }
                        
                        onDescriptionUsernameClicked: {
                            // send username clicked event
                            Qt.descriptionUsernameClicked(username);
                        }
                        
                        onDescriptionHashtagClicked: {
                            // send hashtag clicked event
                            Qt.descriptionHashtagClicked(hashtag);                           
                        }
                    }
                }
            }
        ]

        // add action for loading additional data after scrolling to bottom
        attachedObjects: [
            ListScrollStateHandler {
                id: scrollStateHandler
                onAtBeginningChanged: {
                    // console.log("# onAtBeginningChanged");
                    if (scrollStateHandler.atBeginning) {
                        userItemListComponent.listTopReached();
                    }
                }
                onAtEndChanged: {
                    // console.log("# onAtEndChanged");
                    if (scrollStateHandler.atEnd) {
                        userItemListComponent.listBottomReached();
                    }
                }
                onScrollingChanged: {
                    // console.log("# List is scrolling: " + scrollStateHandler.toDebugString());
                    if (! scrollStateHandler.atBeginning) {
                        userItemListComponent.listIsScrolling();
                    }
                }
            }
        ]
    }

    // attached objects
    attachedObjects: [
        // this will be the data model for the popular media list view
        GroupDataModel {
            id: userItemListDataModel
            sortedAscending: false
            sortingKeys: [ listSortingKey ]

            // items are grouped by the view and transformators
            // no need to set a behaviour by the data model
            grouping: ItemGrouping.None
        }
    ]
}
