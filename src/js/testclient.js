/**
 * Test script for the JSON client.
 *
 * See: http://jsunity.com/
 * And: http://developer.appcelerator.com/question/741/unit-testing-support
 * (Second answer).
 */
Ti.include("jsunity-0.6.js");
jsUnity.log = Ti.API.info;
jsUnity.attachAssertions();

Ti.include("client.js");

//var client = getClient();
var client = new Client("http://192.168.1.102:9998/m", "", "");
Ti.API.log("Testing: " + client.root_url + " "
    + client.username + " " + client.password);

var TestSuite = {
    suiteName: "Test Suite",

    testHome: function() {
        var info = client.getInfo();
        assertNotNull(info, "info not null");
        assertNotNull(info.children, "info.children not null");
        assertFalse(info.foobar);
    },

    testUpdates: function() {
        var info = client.getUpdates();
        assertNotNull(info);
        assertNotNull(info.children);
        assertFalse(info.foobar);
    },

    // Makes the compiler happy.
    "": ""
};

jsUnity.run(TestSuite);
