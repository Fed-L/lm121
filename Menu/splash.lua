local storyboard = require("storyboard")
local scene = storyboard.newScene()
local splashScreen

function scene:createScene(event)
	--splash screen
	local grp = self.view
	local w = display.viewableContentWidth
	local h = display.viewableContentHeight
	splashScreen = display.newImageRect("images/splashScreen.png" , w , h)
	splashScreen.x = display.viewableContentWidth/2
	splashScreen.y = display.viewableContentHeight/2
	grp:insert( splashScreen )
	--end of splashScreen
end

function scene:enterScene(event)
	local function toMenu()
		local option = {
			effect = "crossFade",
			time = 1000
		}
		storyboard.gotoScene("scenes.menu", options)
	end
	function scene:exitScene(event)
		print("exit")
	end
	
	scene:addEventListener( "createScene", scene )
	scene:addEventListener( "exitScene", scene )
	scene:addEventListener( "enterScene", scene )
	return scene