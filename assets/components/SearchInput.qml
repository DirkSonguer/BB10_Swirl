// *************************************************** //
// Search Input Component
//
// This component provides an input field for the
// search functionality. It also handles the actual
// sending of the search parameters and receives the
// answers, which are handed back to the using page
// via the respective signals.
//
// Author: Dirk Songuer
// License: GPL v2
// See: http://choosealicense.com/licenses/gpl-v2/
// *************************************************** //

// import blackberry components
import bb.cascades 1.2
import bb.system 1.2

// shared js files
import "../global/globals.js" as Globals
import "../global/copytext.js" as Copytext
import "../instagramapi/search.js" as SearchRepository

Container {
    id: searchInputComponent

    // signal if media search data loading is complete
    signal searchMediaDataLoaded(variant mediaDataArray, string paginationId)

    // signal that next media page should be loaded
    signal nextMediaPage(string paginationNextMaxId)

    // signal if user search data loading is complete
    signal searchUserDataLoaded(variant userDataArray)

    // signal if popular media data loading encountered an error
    signal searchDataError(variant errorData)
    
    // signal that search process has been triggered
    signal triggered()

    // flag to search for media or users
    property string searchType: "media"
    
    // property that contains the current search term
    property string currentSearchTerm: ""

    // make input field properties accessible by external components
    property alias text: searchInput.text
    property alias hintText: searchInput.hintText

    // layout orientation
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }

    // set initial visibility to false
    visible: true

    // comment input field
    TextField {
        id: searchInput

        // configure text field
        hintText: "Search media"
        clearButtonVisible: true
        inputMode: TextFieldInputMode.Chat

        // input behaviour and handling
        input {
            submitKey: SubmitKey.Submit
            onSubmitted: {
                if (submitter.text.length > 0) {
                    // console.log("# Searching for " + searchInputComponent.searchType + " with terms " + submitter.text);

                    if (searchInputComponent.searchType == "media") {
                        // load media items with given search terms
                        SearchRepository.getMediaSearchResults(submitter.text, 0, searchInputComponent);
                    } else {
                        // load users with given search terms
                        SearchRepository.getUserSearchResults(submitter.text, searchInputComponent);
                    }
                    
                    // store current search term
                    searchInputComponent.currentSearchTerm = submitter.text;
                    
                    // signal that loading process has been triggered
                    searchInputComponent.triggered();
                }
            }
        }
    }

    // comment submit button
    ImageButton {
        defaultImageSource: "asset:///images/icons/icon_search_dimmed.png"
        pressedImageSource: "asset:///images/icons/icon_search.png"
        onClicked: {
            // send the submit signal to the text input field
            searchInput.input.submitted(searchInput);
        }
    }
    
    // load next set of media items for current search
    onNextMediaPage: {
        SearchRepository.getMediaSearchResults(searchInputComponent.currentSearchTerm, paginationNextMaxId, searchInputComponent);
    }
}