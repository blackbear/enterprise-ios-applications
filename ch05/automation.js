UIALogger.logStart("Find Toolbar");

var target = UIATarget.localTarget();
var window = target.frontMostApp().mainWindow();
window.logElementTree();
var toolbars = window.toolbars();
if (toolbars.length != 1) {
	UILogger.logFail("Did not find toolbar");
}

UIALogger.logStart("Find Output View");
var outputViews = window.textViews();
if (outputViews.length == 0) {
	UIALogger.logFail("Did not find output textview");
}

var outputView = outputViews[0];
UIALogger.logStart("Find Button");
var buttons = toolbars[0].buttons();
var zipButton = buttons["Zip Code"];
if (zipButton == null) {
	UILogger.logFail("Did not find zipcode button");
}

UIALogger.logStart("Test Zipcode Button");
zipButton.tap();
var result = outputView. withValueForKey("Postal Code: 03038\nCity: Derry\nCounty: Rockingham\nState: New Hampshire\nLatitude: 42.89N\nLongitude: 71.30W\n", "value");
if (result == null) {
	UILogger.logFail("Did not get expected result");
}
