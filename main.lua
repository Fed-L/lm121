
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Seed the random number generator
math.randomseed( os.time() )

-- Configure image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}
local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )

-- Initialize variables
local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

local SPEED = 0.3
local direction = "noMove"
local speed = 300

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

-- Load the background
local background = display.newImageRect( backGroup, "background.jpg", 1024, 768 )
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImage("shipImage.png")
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody( ship, { radius=30, isSensor=true } )
ship.myName = "ship"

-- Display lives and score
livesText = display.newText( uiGroup, "Lives: " .. lives, 980, 80, native.systemFont, 36 )
scoreText = display.newText( uiGroup, "Score: " .. score, 720, 80, native.systemFont, 36 )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )


local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end

local function setVelocity(asteroid)
	if(ship.isBodyActive) then
		asteroid:setLinearVelocity( SPEED * (ship.x - asteroid.x), SPEED * (ship.y - asteroid.y))
	end
end

local function createAsteroid()

	local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody(newAsteroid, "dynamic", { radius=40, bounce=0.8 })
	newAsteroid.myName = "asteroid"
		
	local whereFrom = math.random( 3 )
		if ( whereFrom == 1 ) then
			-- From the left
			newAsteroid.x = -60
			newAsteroid.y = math.random( 1000 )
			setVelocity(newAsteroid)

		elseif ( whereFrom == 2 ) then
			-- From the top
			newAsteroid.x = math.random( display.contentWidth )
			newAsteroid.y = -60
			setVelocity(newAsteroid)
	
		elseif ( whereFrom == 3 ) then
			-- From the right
			newAsteroid.x = display.contentWidth + 60
			newAsteroid.y = math.random( 1000 )
			setVelocity(newAsteroid)
		end

		-- changes how they spin no spin atm
		newAsteroid:applyTorque( math.random( -3,3 ) )
end


local function gameLoop()

	-- Create new asteroid
	createAsteroid()

	-- Remove asteroids which have drifted off screen
	for i = #asteroidsTable, 1, -1 do
		local thisAsteroid = asteroidsTable[i]

		if ( thisAsteroid.x < -100 or
			 thisAsteroid.x > display.contentWidth + 100 or
			 thisAsteroid.y < -100 or
			 thisAsteroid.y > display.contentHeight + 100 )
		then
			display.remove( thisAsteroid )
			table.remove( asteroidsTable, i )

		else 
			-- update asteriods to move towards the ship
			setVelocity(thisAsteroid)
		end
	end
end


Runtime:addEventListener( "enterFrame", function()
    if direction =="right" then
        ship.rotation = 90   -- rotate to 45 degrees
        ship.x = ship.x + 10

    elseif ( direction== "left" ) then
        ship.rotation = 270   -- rotate to 45 degrees
	    ship.x = ship.x - 10
    elseif ( direction== "up") then
        ship.rotation = 360 -- rotate to 45 degrees
	    ship.y = ship.y - 10
    elseif ( direction== "down" ) then
        ship.rotation = 180 -- rotate to 45 degrees
	    ship.y = ship.y + 10
	end
end)

Runtime:addEventListener( "key",function(event)
	if event.phase=="up" then
		direction="noMove"
	elseif event.phase=="down" then
		direction=event.keyName
	end
end)

function onMouseEvent(event)
    if(event.phase == "began") then
        angle = math.deg(math.atan2((event.y-ship.y),(event.x-ship.x)))
        ship.rotation = angle + 90
    end
end


-- Called when a mouse event has been received.
local function onMouseEvent( event )
    -- Print the mouse cursor's current position to the log.
    local message = "Mouse Position = (" .. tostring(event.x) .. "," .. tostring(event.y) .. ")"
	print( message )
	if(ship.isBodyActive) then
    	deltaX = event.x - ship.x
		deltaY = event.y - ship.y
		ship.rotation = deltaY,deltaX
	end
end

-- code for bullets
function shoot( event )
    if ( event.phase == 'began' and ship.isBodyActive) then
        local projectile = display.newRect( ship.x, ship.y, 10, 30 )
        physics.addBody( projectile, 'dynamic',{isSensor=true} )
        projectile.gravityScale = 0
        projectile.isBullet = true
        projectile.myName = "laser"
        deltaX = event.x - ship.x
		deltaY = event.y - ship.y
        angle = math.atan2( deltaY, deltaX )   --*180/math.pi (this turns radians to degrees and messed things up.)
        physics.addBody( projectile)
        projectile:setLinearVelocity( math.cos( angle )*400 , math.sin( angle )*400  )
    end
end


local function restoreShip()

	ship.isBodyActive = false
	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100

	-- Fade in the ship
	transition.to( ship, { alpha=1, time=4000,
		onComplete = function()
			ship.isBodyActive = true
			died = false
		end
	} )
end


local function onCollision( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
			 ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
		then
			-- Remove both the laser and asteroid
			display.remove( obj1 )
			display.remove( obj2 )

			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end

			-- Increase score
			score = score + 100
			scoreText.text = "Score: " .. score

		elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
				 ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
		then
			if ( died == false ) then
				died = true

				-- Update lives
				lives = lives - 1
				livesText.text = "Lives: " .. lives

				if ( lives == 0 ) then
					display.remove( ship )
				else
					ship.alpha = 0
					timer.performWithDelay( 1000, restoreShip )
				end
			end
		end
	end
end

Runtime:addEventListener( "collision", onCollision )
Runtime:addEventListener( 'touch', shoot )
Runtime:addEventListener( "mouse", onMouseEvent )
gameLoopTimer = timer.performWithDelay( 2500, gameLoop, 0 )

--
--Button 1
--
local widget = require( "widget" )
 
-- Function to handle button events
local function handleButtonEvent( event )
 
    if ( "ended" == event.phase ) then
        print( "Button was pressed and released" )
    end
end
 
local button1 = widget.newButton(
    {
        width = 120,
        height = 120,
        defaultFile = "buttonDefault.png",
        overFile = "buttonOver.png",
        label = "button",
        onEvent = handleButtonEvent
    }
)
 
-- Positioning the button
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenBot = display.contentHeight - display.screenOriginY
local screenRight = display.contentWidth - display.screenOriginX

button1.x = screenLeft + 110
button1.y = screenTop + 100
 
-- Change the button's label text
button1:setLabel( "" )

--
--Button 2
--
local widget = require( "widget" )
 
-- Function to handle button events
local function handleButtonEvent( event )
 
    if ( "ended" == event.phase ) then
        print( "Button was pressed and released" )
    end
end
 
local button2 = widget.newButton(
    {
        width = 120,
        height = 120,
        defaultFile = "buttonDefault2.png",
        overFile = "buttonOver2.png",
        label = "button2",
        onEvent = handleButtonEvent
    }
)
 
-- Positioning the button
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenBot = display.contentHeight - display.screenOriginY
local screenRight = display.contentWidth - display.screenOriginX

button2.x = screenLeft + 245
button2.y = screenTop + 100
 
-- Change the button's label text
button2:setLabel( "" )

--
--Inventory (Visuals Only - This code is not used for equipping items etc only displaying atm
--			 Please Update if changed!!!)
--
local itemImages =
{
    [0] = display.newImage('inventory_1.png'),
    [3] = display.newImage('Item 1.png'),
    [7] = display.newImage('Item 2.png'),
}

function getImageForItem(itemId)
    return itemImages[itemId] or itemImages[0]
end

local myInventoryBag={}
local maxItems = 9 -- change this to how many you want
local visibleItems = 3 -- show this many items at a time (with arrows to scroll to others)

-- show inventory items at index [first,last]
local function displayInventoryItems(first,last)
    local x = 0 -- first item goes here
    local y = 0 -- top of inventory row
    for i=first,last do
        image = getImageForItem(myInventoryBag[i])
        image.x = x + 286
        image.y = y + 85
        x = x + image.width
    end
end

-- show inventory items on a given "page"
local function displayInventoryPage(page)
    page = page or 1 -- default to showing the first page
    if page > maxItems then
        -- error! handle me!
    end
    local first = (page - 1) * visibleItems + 1
    local last = first + visibleItems - 1
    displayInventoryItems(first, last)
end

myInventoryBag[5] = 3 -- Hammer for instance
myInventoryBag[4] = 7 -- A metal Pipe for instance

displayInventoryPage(1)
displayInventoryPage(2)

