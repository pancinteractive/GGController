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

##### Use a listener function to do something on key release. Declare non-Runtime listeners before initializing the controller instance.
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

##### Accepted button labels for some different HID devices.
```lua
"buttonA"  --A button (O on OUYA, X on PS3)
"buttonB"  --B Button (A on OUYA, Circle on PS3)
"buttonX"  --X button (U on OUYA, Square on PS3)
"buttonY"  --Y button (Y on OUYA, Triangle on PS3)
"up"  --dPad Up
"down"  --dPad Down
"left"  --dPad Left
"right"  --dPad Right
"buttonSelect"  --Select/Back Button (not used on OUYA)
"buttonStart"  --Start/Home Button (not used on OUYA)
"buttonMode"  --Power On/Off button
"leftShoulderButton1"  --Top Left button on the front of the controller, sometimes called L1
"rightShoulderButton1"  --Top Right button on the front of the controller, sometimes called R1
"leftShoulderButton2"  --Bottom Left button on the front of the controller, sometimes called L2
"rightShoulderButton2"  --Bottom Right button on the front of the controller, sometimes called R2
"leftJoyStickButton"  --pressing down on the left Joystick Button
"rightJoystickButton"  --pressing down on the right Joystick button

```
