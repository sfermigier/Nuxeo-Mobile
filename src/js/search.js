Ti.include("views.js");

var win = Ti.UI.currentWindow;
var client = win.client;

var log = Ti.API.info;

var ftsQuery = "";

var searchView = Ti.UI.createView({
    width: 320,
    height: 420,
    visible: true
});

var searchField = Ti.UI.createTextField({
    color: '#333',
    top: 60,
    height: 35,
    width: 250,
    hintText: 'Fulltext query',
    keyboardType: Ti.UI.KEYBOARD_DEFAULT,
    returnKeyType: Ti.UI.RETURNKEY_DEFAULT,
    borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
    autocorrect: false
});
searchView.add(searchField);

var searchButton = Ti.UI.createButton({
    color: 'black',
    top: 120,
    title: "Search",
    width: 80,
    height: 35
});
searchView.add(searchButton);

// Event listeners

searchField.addEventListener('return', function() {
    searchField.blur();
});
searchField.addEventListener('change', function(e) {
    ftsQuery = e.value;
});

function getRootObject() {
    var object = {};
    object.children = client.search(ftsQuery);
    object.isfolder = true;
    return object;
}

function runSearch() {
    Ti.API.log("Running search");
    var resultWin = Ti.UI.createWindow({
        title: 'Search Result',
        backgroundColor: '#fff'
    });

    var view = makeTableView(null, getRootObject);
    resultWin.add(view);

    Ti.UI.currentTab.open(resultWin, {animated: true});
}

searchButton.addEventListener("click", function(e) {
    runSearch();
});

searchView.addEventListener("click", function(e) {
    searchField.blur();
});

win.add(searchView);
