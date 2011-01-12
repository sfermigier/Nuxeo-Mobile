Ti.include "client.js"
Ti.include "views.js"
Ti.include "tablecontroler.js"

# Remove in production code
#Ti.include "testclient.js"

# this sets the background color of the master UIView (when there are no windows/tab groups on it)
Ti.UI.setBackgroundColor '#000'

# Create Browse view / tab
class BrowseControler extends TableControler  
  constructor: () ->
    super("Browse", "Root", "images/cabinet.png")
    
  getRootObject: () ->
    return @client.getInfo()
    
browseControler = new BrowseControler()

# Create updates view / tab
class UpdatesControler extends TableControler  
  constructor: () ->
    super("Updates", "Recently Modified", "images/updates.png")
    @group_by = "modified"

  getRootObject: () ->
    object = {}
    object.children = @client.getUpdates()
    object.isfolder = true
    return object

updatesControler = new UpdatesControler()

# Create History view / tab

class HistoryControler extends TableControler  
  constructor: () ->
    super("History", "Recently Viewed", "images/clock.png")
    @group_by = "visited"

  getRootObject: () ->
    object = {}
    object.children = @client.getHistory()
    object.isfolder = true
    return object

historyControler = new HistoryControler()

# Search

searchWin = Ti.UI.createWindow {
    title: 'Search',
    backgroundColor: '#fff',
}
searchTab = Ti.UI.createTab {
    icon: 'images/magnify.png',
    title: 'Search',
    window: searchWin
}

# Settings (to be refactored)
settingsWin = Ti.UI.createWindow {
    title: 'Settings',
    backgroundColor: '#fff',
}
settingsTab = Ti.UI.createTab {
    icon: 'images/settings.png',
    title: 'Settings',
    window: settingsWin
}
root.settingsWin = settingsWin
Ti.include "settings.js"

# Create tab group
tabGroup = Ti.UI.createTabGroup()
tabGroup.addTab(browseControler.tab)
tabGroup.addTab(updatesControler.tab)
tabGroup.addTab(historyControler.tab)
#tabGroup.addTab(searchTab)
tabGroup.addTab(settingsTab)

if getClient().isConnected()
    tabGroup.open(0)
else
    tabGroup.open(4)
