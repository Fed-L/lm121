local storyboard = require( "storyboard" )
local scene = storyboard=newScene()
local gameSetUp = require( "setting" )

local imageHeight
local imageWidth
local menuBg
local tapButton

local w.h = display.stageWidth, stageHeight

function scene:createScene( event )
  local grp = self.view
  imageHeight = display.viewableContentHeight
  imageWidth = display.viewableContentWidth
end 

function scene:enterScene ( event )
  localgrp = self.view 
  menuBg = display.newImageRect ( "images/menuBg.jpg" , imageWidth, imageHeight )
  menuBg.x = display.viewableContentWidth/2
  menuBg.y = display.viewableContentHeight/2

  tapButton = display.newImageRect ( "image =/menuBg.png" , 960/1.5 , 300/1.5 )
  tapButton.x = display.viewContentCenterX
  tapButton.y = (display.viewableContentHeight/2) + (display.viewableContentHeight*35)
  transition.to ( tapButton, {time=1000, alpha=1, onComplete = blink} )

  local function blink()
    if (tapButton.alpha > 0) then
      transition.to( tapButton, {time=1000, alpha=0, onComplete = blink } )
    else
      transition.to( tapButton, {time=1000, alpha=1, onComplete = blink } )
    end 
  end 

  timer.performWithDelay( 1000, blink, 0 )

  grp:insert( menuBg )
  grp:insert( tapButton )
end 

function scene:exitScene( event )

end 

funcion scene:destroyScene ( event )

end 