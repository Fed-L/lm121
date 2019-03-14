display.setStatusBar( display.HiddenStatusBar )
local storyboard = require("storyboard")
 
--to splashscreen
local options =
{
	effect = "crossFade",
	time = 2000,
	params = {var1 = "custom", myVar = "another" }
}
storyboard.gotoScene( "scenes.splash", options )