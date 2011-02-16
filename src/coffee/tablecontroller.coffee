class TableController
  
  constructor: (tabTitle, winTitle, icon) ->
    @win = Ti.UI.createWindow {
        title: winTitle,
        backgroundColor: '#fff',
        orientationModes: [
          Ti.UI.FACE_UP, Ti.UI.FACE_DOWN,
          Ti.UI.PORTRAIT, Ti.UI.UPSIDE_PORTRAIT,
          Ti.UI.LANDSCAPE_LEFT, Ti.UI.LANDSCAPE_RIGHT,
        ],
    }
    @tab = Ti.UI.createTab {
        icon: icon,
        title: tabTitle,
        window: @win,
    }
    @client = getClient()
        
    @win.addEventListener("focus", (e) => @refresh(e))
    
  # Must be implemented in concrete class
  getRootObject: () ->
    throw new NotImplementedException()

  refresh: (e) ->
    Ti.API.log("Refresh called, client.isConnected = " + @client.isConnected())
    # if (!this.win.connected && @client.isConnected())
    if @client.isConnected()
      view = @makeView(null)
      @win.connected = true
      @win.add(view)

  makeView: (oid) ->
    if oid == null
      object = @getRootObject()
    else
      object = @client.getInfo(oid)

    if object.isfolder
      return @makeTableView(object)
    else
      return @makeWebView(object)
      
  makeTableView: (folder) ->
    now = new Date().getTime() / 1000;
    last_header = null
    # create table view data object
    data = [];
    dumps(folder.children)
    for entry in folder.children
      row = makeRow(entry)

      if @group_by?
        age = now - entry[@group_by]
        header = makeHeader(age)
        if header != last_header
          row.header = header
          last_header = header

      data.push(row);

    # create table view
    view = Ti.UI.createTableView { data: data }
    view.info = folder

    # create table view event listener
    view.addEventListener('click', (e) => @clickOnTableView(e))
    
    return view
  
  makeWebView: (object) ->
    # TODO: move back to client
    url = @client.root_url + "/j/d/" + object.oid;
    xhr = Ti.Network.createHTTPClient();
    xhr.ondatastream = (e) => @updateProgressBar(e)
    xhr.onload = (e) => @updateWebView(e)
    xhr.open('GET', url);
    xhr.send(null)
    
    @xhr = xhr
    @webview = Ti.UI.createWebView()
    @webview.info = object
    
    return @webview
  
  updateWebView: (e) ->
    data = @xhr.responseData    
    @webview.data = data
    
  updateProgressBar: (e) ->
    Ti.API.log("progress: " + e.progress)
    
  clickOnTableView: (e) ->
    rowdata = e.rowData
    oid = rowdata.oid

    button = Titanium.UI.createButton { title: 'Metadata' }
    button.addEventListener("click", (e) => @flipView(e))

    win = Ti.UI.createWindow {
      title: e.rowData._title,
      rightNavButton: button,
    }
    button.window = win
    view = @makeView(oid)
    win.main_view = view
    win.info = view.info
    win.add(view)

    @tab.open(win, {animated: true})

  flipView: (e) ->
    button = e.source
    win = button.window
    if ! win.metadata_view
      view = @makeMetadataView(win.info)
      win.animate {
        view: view,
        transition: Titanium.UI.iPhone.AnimationStyle.FLIP_FROM_LEFT,
      }
      win.metadata_view = view
      button.title = "Back"
    else
      win.animate {
        view: win.main_view,
        transition: Titanium.UI.iPhone.AnimationStyle.FLIP_FROM_RIGHT,
      }
      win.metadata_view = null
      button.title = "Metadata"

  makeMetadataView: (info) ->
    html = "<html><body style='font-family:Helvetica,sans-serif;'>"
    html += "<h1>Metadata</h1>\n"
    html += "<p><b>Title:</b> " + info.title + "</p>"
    html += "<p><b>Description:</b> " + info['dc:description'] + "</p>"
    html += "<p><b>Creator:</b> " + info['dc:creator'] + "</p>"
    html += "<p><b>Created:</b> " + formatAge(info['dc:created']) + " ago</p>"
    html += "<p><b>Modified:</b> " + formatAge(info['dc:modified']) + " ago</p>"
    if info.mimetype
      html += "<p><b>MIME Type:</b> " + info.mimetype + "</p>"
    if info.size
      html += "<p><b>Size:</b> " + formatSize(info.size) + "</p>"
    html += "<p><b>Path:</b> " + info.path + "</p>"
    html += "</body></html>"
    return Ti.UI.createWebView {html: html}
    
@TableController = TableController