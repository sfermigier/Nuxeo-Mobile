# Needs to be cleaned up

win = root.settingsWin
client = getClient()

log = Ti.API.info;

urlVal = Ti.App.Properties.getString("url");
usernameVal = Ti.App.Properties.getString("username");
passwordVal = Ti.App.Properties.getString("password");

configView = Ti.UI.createView {
    width: 320,
    height: 420,
    visible: true,
}

top = 40;

# URL

label1 = Ti.UI.createLabel {
    top: top,
    text: 'Nuxeo server:',
    textAlign: 'center',
    font: {
        fontSize: 18,
        fontWeight:'bold',
        fontStyle:'italic',
    },
    height: 'auto',
    width: 'auto',
    color: 'black',
}
configView.add(label1)

urlField = Ti.UI.createTextField {
    color: '#333',
    value: urlVal,
    top: top+30,
    height: 35,
    width: 250,
    hintText: 'Server URL or hostname',
    keyboardType: Ti.UI.KEYBOARD_URL,
    returnKeyType: Ti.UI.RETURNKEY_DEFAULT,
    borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
    autocorrect: false,
}
urlField.addEventListener('return', () -> urlField.blur())
urlField.addEventListener('change', (e) ->
    urlVal = e.value)
configView.add(urlField);

# Username and Password

top = 120;

label2 = Ti.UI.createLabel({
    text: 'Credentials:',
    textAlign: 'center',
    font: {
        fontSize: 18,
        fontWeight:'bold',
        fontStyle:'italic'
    },
    height: 'auto',
    width: 'auto',
    color: 'black',
    top: top
});
configView.add(label2);

# Username

usernameField = Ti.UI.createTextField({
    color: '#333',
    value: usernameVal,
    top: top+30,
    height: 32,
    width: 250,
    hintText: 'Username',
    keyboardType: Ti.UI.KEYBOARD_ASCII,
    returnKeyType: Ti.UI.RETURNKEY_DEFAULT,
    borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
    autocorrect: false
});
usernameField.addEventListener('return', () -> usernameField.blur())
usernameField.addEventListener('change', (e) ->
    usernameVal = e.value)
configView.add(usernameField);

# Password

passwordField = Ti.UI.createTextField({
    color: '#333',
    value: passwordVal,
    top: top+70,
    height: 32,
    width: 250,
    hintText: 'Password',
    keyboardType: Ti.UI.KEYBOARD_ASCII,
    returnKeyType: Ti.UI.RETURNKEY_DEFAULT,
    borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
    autocorrect: false,
    passwordMask: true
});
passwordField.addEventListener('return', () -> passwordField.blur())
passwordField.addEventListener('change', (e) ->
    passwordVal = e.value)
configView.add(passwordField);

# Save

saveButton = Ti.UI.createButton({
    color: 'black',
    top: top+120,
    title: "Save",
    width: 80,
    height: 32
});
configView.add(saveButton);

# Event listeners

koAlert = () ->
    dialog = Ti.UI.createAlertDialog({
        title: "Bad credentials",
        message: "Something is wrong with either your URL or your credentials.",
        buttonNames: ['Try again']
    });
    dialog.show();

okAlert = () ->
    dialog = Ti.UI.createAlertDialog({
        title: "Everything's fine",
        message: "You can now start browsing your Nuxeo repository.",
        buttonNames: ['OK']
    });
    dialog.show();

saveConfig = () ->
    props = Ti.App.Properties;
    props.setString("username", usernameVal);
    props.setString("password", passwordVal);
    props.setString("url", urlVal);

    client.root_url = urlVal;
    client.username = usernameVal;
    client.password = passwordVal;

validate = () =>
    ok = true;
    if !urlVal.match("^http://") && ! urlVal.match("^https://")
        url = "https://" + urlVal + "/nuxeo/site/m";
        ok = client.testConnection(url + "/j/i/", usernameVal, passwordVal);
        if (!ok)
            url = "http://" + urlVal + "/nuxeo/site/m";
            ok = client.testConnection(url + "/j/i/", usernameVal, passwordVal);
        if (!ok)
            koAlert();
        else
            urlVal = url;
            saveConfig();
            okAlert();
    else
        if !client.testConnection(urlVal + "/j/i/", usernameVal, passwordVal)
            koAlert();
        else
            saveConfig();
            okAlert();

saveButton.addEventListener("click", (e) -> validate())

configView.addEventListener("click", (e) ->
    urlField.blur();
    usernameField.blur();
    passwordField.blur();
)

win.add(configView);

# Help

HELP = '<html><body style="font-family: Helvetica, sans-serif;">\n' +
    '<h3>Help about this application</h3>\n' +
    '<p>Nuxeo Mobile is a mobile client for the Nuxeo EP enterprise Content Management Platform.</p>\n' +
    '<p>For more information about the Nuxeo EP platform, <a href="http://www.nuxeo.com/">Click Here</a></p>' +
    '</body></html>';

showHelp = (e) ->
    view = Ti.UI.createWebView({html: HELP})
    if  e.source.title == "Help"
        win.animate({
            view: view,
            transition: Titanium.UI.iPhone.AnimationStyle.FLIP_FROM_RIGHT
        });
        e.source.title = "Back";
    else
        win.animate({
            view: configView,
            transition: Titanium.UI.iPhone.AnimationStyle.FLIP_FROM_LEFT
        });
        e.source.title = "Help";

helpButton = Titanium.UI.createButton { title: 'Help' }
helpButton.addEventListener("click", showHelp);
win.rightNavButton = helpButton;
