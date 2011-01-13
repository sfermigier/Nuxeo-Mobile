/**
 * Utility functions to generate the table views.
 */

Ti.include("util.js");

function formatSize(size) {
    if (size < 1024) {
        return size + " B";
    } else if (size < 1024 * 1024) {
        return Math.round(size / 1024) + " kB";
    } else if (size < 1024 * 1024 * 1024) {
        return Math.round(size / (1024 * 1024)) + " MB";
    } else {
        return Math.round(size / (1024 * 1024 * 1024)) + " GB";
    }
}

function formatAge(time) {
    var now = new Date().getTime() / 1000;
    var age = now - time;

    if (age < 60) {
        return Math.round(age) + " sec";
    } else if (age < 60 * 60) {
        return Math.round(age / 60) + " min";
    } else if (age < 60 * 60 * 24) {
        return Math.round(age / (60 * 60)) + " hours";
    } else if (age < 60 * 60 * 24 * 365) {
        return Math.round(age / (60 * 60 * 24)) + " days";
    } else {
        return Math.round(age / (60 * 60 * 24 * 365)) + " years";
    }
}

function makeHeader(age) {
    if (age < 60) {
        return "In the last minute";
    } else if (age < 60 * 60) {
        return "In the last hour";
    } else if (age < 60 * 60 * 24) {
        return "In the last day";
    } else if (age < 60 * 60 * 24 * 30) {
        return "In the last month";
    } else if (age < 60 * 60 * 24 * 365) {
        return "In the last year";
    } else {
        return "Long time ago";
    }
}

function makeInfoText(entry) {
    var infotext;
    if (entry.isfolder) {
        if (entry.childcount > 1) {
            infotext = entry.childcount + " children";
        } else if (entry.childcount == 1) {
            infotext = "1 child";
        } else {
            infotext = "Empty";
        }
    } else {
        if (entry.modified == entry.created) {
            infotext = "Created: " + formatAge(entry.modified) + " ago | ";
        } else {
            infotext = "Updated: " + formatAge(entry.modified) + " ago | ";
        }
        infotext += formatSize(entry.size);          
    }
    return infotext;
}

function getIconPath(entry) {
    var icon;
    if (!entry.mimetype) {
      entry.mimetype = "unknown";
    }
    if (entry.isfolder) {
        icon = "images/icon/folder.png";
    } else if (entry.mimetype == "application/pdf") {
        icon = "images/icon/page_white_acrobat.png";
    } else if (entry.mimetype.match("^image/")) {
        icon = "images/icon/camera.png";
    } else if (entry.mimetype.match("^movie/")) {
        icon = "images/icon/film.png";
    } else if (entry.mimetype == "text/html") {
        icon = "images/icon/html.png";
    } else if (entry.mimetype == "text/plain") {
        icon = "images/icon/page_white_text.png";
    } else if (entry.mimetype == "application/word"
            || entry.mimetype.match("vnd.openxmlformats")
            || entry.mimetype.match("ms-word")
            || entry.mimetype.match("ms-excel")
            || entry.mimetype.match("ms-powerpoint")) {
        icon = "images/icon/page_white_office.png";
    } else {
        icon = "images/icon/page_white.png";
    }
    return icon;
}

function makeRow(entry) {
    var row = Ti.UI.createTableViewRow({
        _title: entry.title,
        oid: entry.oid
    });

    if (entry.isfolder) {
        row.hasChild = true;
    } else {
        //row.hasDetail = true;
    }

    var title = entry.title;
    if (title.length > 30) {
        title = title.slice(0, 27) + "...";
    }
    var titleLabel = Ti.UI.createLabel({
        left: 28,
        top: 3,
        font: {fontWeight: 'bold', fontSize: 16},
        text: title,
        height: 'auto',
        width: 'auto'
    });
    row.add(titleLabel);

    var infotext = makeInfoText(entry);
    var infotextLabel = Ti.UI.createLabel({
        left: 28,
        top: 22,
        font: {fontSize: 12},
        color: "#333",
        text: infotext,
        height: 'auto'
    });
    row.add(infotextLabel);

    var icon_path = getIconPath(entry);
    var iconView = Ti.UI.createImageView({
        image: icon_path,
        left: 6,
        top: 14,
        height: 16,
        width: 16
    });
    row.add(iconView);

    return row;
}
