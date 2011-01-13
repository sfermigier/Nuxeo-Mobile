###
The client is a singleton that manages the requests to the server.

Is also manages the history.
###

# A default URL while I'm developing the app.
DEFAULT_URL = "http://10.213.3.8:9998/m"
DEBUG = false

HISTORY_SIZE = 20

Ti.include "util.js"

class Client

  constructor: (@root_url, @username, @password) ->
    @history = @getHistory()
    
  isConnected: () ->
    root_info = @getInfo()
    return root_info != null

  getInfo: (oid) ->
    if oid
      url = @root_url + "/j/i/" + oid
    else
      url = @root_url + "/j/i/"
    info = @httpGetJson(url)
    if info != null
      @logHit(info)
      
    # Should probably be sorted server-side
    if info and info.children
      info.children.sort((x, y) ->
        t1 = x.title.toLowerCase()
        t2 = y.title.toLowerCase()
        if t1 < t2 then -1 
        else if t1 > t2 then 1
        else 0
      )
    return info
  
  # History management
  
  logHit: (info) ->
    info.visited = Math.round(new Date().getTime() / 1000)
    @history = @history.filter((x) -> x.oid != info.oid)
    @history.unshift(info)
    if @history.length > HISTORY_SIZE
      @history = @history.slice(0, HISTORY_SIZE)
    @saveHistory()

  getHistory: () ->
    history = Ti.App.Properties.getString("history")
    if (history == null)
      history = []
    else
      history = JSON.parse(history)
    return history

  saveHistory: () ->
    Ti.App.Properties.setString("history", JSON.stringify(@history))

  clearHistory: () ->
    @history = []
    @saveHistory()
  
  # REST calls
  
  getUpdates: () ->
    url = @root_url + "/j/updates"
    return @httpGetJson(url)

  search: (fts) ->
    fts = encodeURI(fts)
    url = @root_url + "/j/search?q=" + fts
    return @httpGetJson(url)

  httpGetJson: (url) ->
    htcon = @httpGet(url)
    @lastHttpStatus = htcon.status
    if htcon.status != 200
        return null
    Ti.API.log(htcon.responseText)
    return JSON.parse(htcon.responseText)

  testConnection: (url, username, password) ->
    xhr = @httpGet(url, username, password)
    Ti.API.log("Status" + xhr.status)
    return xhr.status == 200

  httpGet: (url, username=null, password=null) ->
    if username == null
        username = @username
    if password == null
        password = @password
        
    Ti.API.log("GET: " + url + " " + username + " " + password)

    xhr = Ti.Network.createHTTPClient();
    xhr.open('GET', url, false);

    if (username || password)
        xhr.setRequestHeader('Authorization',
                'Basic ' + Ti.Utils.base64encode(username + ':' + password));
    xhr.send(null);
    Ti.API.log("Status" + xhr.status)
    return xhr;

  #createWebView: (oid) ->
  #  url = this.root_url + "/j/d/" + oid;
  #  return Ti.UI.createWebView({url: url});

# Singleton
_client = null;
getClient = () ->
  if _client != null
    return _client

  if DEBUG
    return new Client(DEFAULT_URL, "", "")
    
  props = Ti.App.Properties
  url = props.getString("url")
  if !url
    url = DEFAULT_URL
  username = props.getString("username")
  password = props.getString("password")
  Ti.API.log(url + " " + username + " " + password)
  _client = new Client(url, username, password)
  return _client

# Export
@Client = Client
@getClient = getClient
