GGController
============

Makes working with HID controllers ( Ouya, GameStick, Nvidia Shield etc ) much simpler.

Basic Usage
-------------------------

##### Require The Code
```lua
local GGController = require( "GGController" )
```

##### Create a controller object
```lua
local controller = GGController:new()
```

##### Create a controller object with an index ( defaults to 1 if not included )
```lua
local controller = GGController:new( 3 )
```

##### Create a controller object with an index and a listener function
```lua
local controller = GGController:new( 1, listener )
```

##### Map some hardware keys to game-specific names.
```lua
controller:mapKey( "w", "UP" )
controller:mapKey( "s", "DOWN" )
controller:mapKey( "a", "LEFT" )
controller:mapKey( "d", "RIGHT" )
controller:mapKey( "q", "FIRE" )
controller:mapKey( "e", "FIREFAST" )
```

##### Load a mapping from a file.
```lua
controller:loadMap( "default.map", system.ResourceDirectory )
```

##### Set a mapped key. Could be used to allow for players to change the mapping in game.
```lua
controller:setMappedKey( "i", "UP" )
```

##### Save out the current mapping to a file.
```lua
controller:saveMap( "myCustomMap.map" )
```

##### Use an enterFrame handler to do stuff
```lua
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
Runtime:addEventListener( "enterFrame", onUpdate )
```

##### Use a listener function to do something on key release.
```lua
local listener = function( event )
	if event.key == "FIRE" and event.phase == "justReleased" then
		print( "FIRE BUTTON JUST RELEASED" )
	end
end
```

##### Use a runtime listener function to do something on key held.
```lua
local listener = function( event )
	if event.key == "UP" and event.phase == "pressed" then
		print( "UP BUTTON IS PRESSED" )
	end
end
Runtime:addEventListener( "controller", listener )
```