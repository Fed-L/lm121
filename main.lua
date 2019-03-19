local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local player = display.newImageRect("spaceship.png", 100, 100)
player.x = ccx
player.y = ccy
physics.addBody( player, "dynamic", {bounce=0})


local direction = "noMove"
Runtime:addEventListener( "enterFrame", function()
    if direction =="right" then
        player.rotation = 90   -- rotate to 45 degrees

        player.x = player.x + 10

    elseif ( direction== "left" ) then
        player.rotation = 270   -- rotate to 45 degrees
	    player.x = player.x - 10
    elseif ( direction== "up") then
        player.rotation = 360 -- rotate to 45 degrees
	    player.y = player.y - 10
    elseif ( direction== "down" ) then
        player.rotation = 180 -- rotate to 45 degrees
	    player.y = player.y + 10
	end
end)

Runtime:addEventListener( "key",function(event)
	if event.phase=="up" then
		direction="noMove"
	elseif event.phase=="down" then
		direction=event.keyName
	end
end)


local function onScreenTouch( event )
  if (event.phase == "began") then
    speed = 800
    deltaX = event.x - player.x
    deltaY = event.y - player.y
    normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))

    angle = math.atan2( deltaY, deltaX ) * 180 / math.pi

    -- sin, cos = math.sin( angle ), math.cos( angle )

    -- sinT.text = sin
    -- cosT.text = cos


    bullet = display.newImageRect( "bullet.jpg",25,25 )
    bullet.x = player.x
    bullet.y = player.y

    physics.addBody( bullet )

-- 900 and 900 are speeds of bullet
    bullet:setLinearVelocity( normDeltaX  * 600, normDeltaY  * 600 )
  end
end

Runtime:addEventListener( "touch", onScreenTouch )
