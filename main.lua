local GGController = require( "GGController" )


local testInit2 = function( event )
    if event.key == "RIGHT" then 
		if event.phase == "pressed" and not GameSettings.movingHere then
			print( "RIGHT BUTTON PRESSED" )
		end
		if event.phase == "justReleased" then
			print( "RIGHT BUTTON JUST RELEASED" )
		end
    end
end
local testInit1 = function( event )
    if event.key == "FIRE" and event.phase == "justReleased" then
        print( "FIRE BUTTON JUST RELEASED" )
    end
end
local controller = GGController:new(1, testInit2)
controller:mapKey( "w", "UP" )
controller:mapKey( "s", "DOWN" )
controller:mapKey( "a", "LEFT" )
controller:mapKey( "d", "RIGHT" )	
controller:mapKey( "q", "FIRE" )
local onUpdate = function( event )
    if controller:isKeyPressed( "LEFT" ) then
        print( "MOVE PLAYER LEFT" )

    elseif controller:isKeyPressed( "RIGHT" ) then
        print( "MOVE PLAYER RIGHT" )
	end
    if controller:isKeyPressed( "UP" ) then
        print( "MOVE PLAYER UP" )
    elseif controller:isKeyPressed( "DOWN" ) then
        print( "MOVE PLAYER DOWN" )
    end
end
--Runtime:addEventListener( "enterFrame", onUpdate )
