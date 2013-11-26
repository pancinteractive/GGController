-- Project: GGController
--
-- Date: November 23, 2013
--
-- File name: GGController.lua
--
-- Author: Graham Ranson of Glitch Games - www.glitchgames.co.uk
--
-- Comments: 
--
--		Makes working with HID controllers ( Ouya, GameStick, Nvidia Shield etc ) much simpler.
--
-- Copyright (C) 2012 Graham Ranson, Glitch Games Ltd.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this 
-- software and associated documentation files (the "Software"), to deal in the Software 
-- without restriction, including without limitation the rights to use, copy, modify, merge, 
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or 
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
----------------------------------------------------------------------------------------------------

local GGController = {}
local GGController_mt = { __index = GGController }

local json = require( "json" )
local abs = math.abs

GGController.KeyState = {}
GGController.KeyState.Pressed = "pressed"
GGController.KeyState.JustPressed = "justPressed"
GGController.KeyState.Released = "released"
GGController.KeyState.JustReleased = "justReleased"

GGController.EventType = {}
GGController.EventType.Key = "key"
GGController.EventType.Axis = "axis"

--- Initiates a new GGController object.
-- @param index The index for the controller. Optional, defaults to 1.
-- @param listener Callback function for the controller.
-- @return The new GGController object.
function GGController:new( index, listener )
    
    local self = {}
    
    setmetatable( self, GGController_mt )
    
    self.map = {}
   	self.axisList = {}
   	
   	self.keyStates = 
   	{
   		current = {},
   		previous = {}
  	}

    self:setIndex( index or 1 )
 	self:setListener( listener )

    Runtime:addEventListener( "key", self )
    Runtime:addEventListener( "axis", self )
    Runtime:addEventListener( "enterFrame", self )

    return self
    
end

--- Sets the index of this controller.
-- @param index The index to set.
function GGController:setIndex( index )
	self.index = index
end

--- Gets the index of this controller.
-- @return The index.
function GGController:getIndex()
	return self.index
end

--- Sets the listener function of this controller.
-- @param listener The function to set.
function GGController:setListener( listener )
	self.listener = listener
end

--- Gets the listener of this controller.
-- @return The function.
function GGController:getListener()
	return self.listener
end

--- Loads an axis list from a file.
-- @param name The filename for the list
-- @param baseDir The base directory where the list is stored. Optional, defaults to system.ResourceDirectory.
function GGController:loadAxisList( name, baseDir )

	local path = system.pathForFile( name, baseDir or system.ResourceDirectory )

	local file = io.open( path, "r" )
	
	if file then
		local data = file:read( "*a" ) 
		self:setAxisList( json.decode( data ) )
		io.close( file )
	end
	
	file = nil

end

--- Saves out the axis list to a file.
-- @param name The filename for the list.
function GGController:saveAxisList( name )
	
	local path = system.pathForFile( name, system.DocumentsDirectory )
	local data = json.encode( self:getAxisList() )
	local file = io.open( path, "w" )
	
	if file then
		file:write( data )
		io.close( file )
	end

	file = nil

end

--- Sets the current axis list for this controller.
-- @param map A table containing the list.
function GGController:setAxisList( list )
	self.axisList = list
end

--- Gets the current axis list. Used internally.
-- @return The list.
function GGController:getAxisList()	
	self.axisList = self.axisList or {}
	return self.axisList.axis or {}
end

--- Gets the name of an axis from its index. Used internally.
-- @return The name of the axis.
function GGController:getAxisName( index )
	for k, v in pairs( self:getAxisList() ) do
		if v == index then
			return k
		end
	end
end

--- Loads a mapping from a file.
-- @param name The filename for the mapping.
-- @param baseDir The base directory where the mapping is stored. Optional, defaults to system.ResourceDirectory.
function GGController:loadMap( name, baseDir )

	local path = system.pathForFile( name, baseDir or system.ResourceDirectory )
	print( path )
	local file = io.open( path, "r" )
	
	if file then
		local data = file:read( "*a" ) 
		self:setMap( json.decode( data ) )
		io.close( file )
	end
	
	file = nil

end

--- Saves out the current mapping to a file.
-- @param name The filename for the mapping.
function GGController:saveMap( name )
	
	local path = system.pathForFile( name, system.DocumentsDirectory )
	local data = json.encode( self:getMap() )
	local file = io.open( path, "w" )
	
	if file then
		file:write( data )
		io.close( file )
	end

	file = nil

end

--- Sets the current mapping for this controller.
-- @param map A table containing the map.
function GGController:setMap( map )
	self.map = map
end

--- Gets the current mapping. Used internally.
-- @return The map.
function GGController:getMap()
	return self.map or {}
end

--- Sets the current mapped keys for this controller.
-- @param keys A table containing mappings of hardware keys to names.
function GGController:setMappedKeys( keys )
	self.map = self.map or {}
	self.map.keys = keys
	for k, v in pairs( self.map.keys ) do
		self:setPreviousKeyState( k, GGController.KeyState.Released )
		self:setKeyState( k, GGController.KeyState.Released )
	end
end

--- Gets the current mapped keys. Used internally.
-- @return The mapped keys.
function GGController:getMappedKeys()
	self.map = self.map or {}
	return self.map.keys or {}
end

--- Set the user-friendly name of a hardware key.
-- @param key The name of the hardware key.
-- @param name The user-friendly name for the key.
function GGController:setMappedKey( key, name )
	self.map.keys = self.map.keys or {}
	self.map.keys[ key ] = name
end

--- Get the user-friendly name of a hardware key. Used internally.
-- @param key The name of the hardware key.
-- @return The user-friendly name of the key.
function GGController:getMappedKey( key )
	self.map.keys = self.map.keys or {}
	return self.map.keys[ key ] or key
end

--- Maps a hardware key to a more user-friendly name.
-- @param key The name of the hardware key.
-- @param name The user-friendly name for the key.
function GGController:mapKey( key, name )
	self:setMappedKey( key, name )
end

--- Checks if a key is mapped. Used internally.
-- @param key The name of the hardware key.
-- @return True if the key is mapped, false otherwise.
function GGController:isKeyMapped( key )
	self.map.keys = self.map.keys or {}
	return self.map.keys[ key ] ~= nil
end

--- Sets the state a key is in. Used internally.
-- @param name The mapped name of the key.
-- @param state The state the key is in.
function GGController:setKeyState( name, state )
	self.keyStates.current[ self:getMappedKey( name ) ] = state
end

--- Gets the state a key is in.
-- @param name The mapped name of the key.
-- @return The state it was in.
function GGController:getKeyState( name )
	return self.keyStates.current[ self:getMappedKey( name ) ]
end

--- Sets the previous state a key was in. Used internally.
-- @param name The mapped name of the key.
-- @param state The state the key was in.
function GGController:setPreviousKeyState( name, state )
	self.keyStates.previous[ self:getMappedKey( name ) ] = state
end

--- Gets the previous state a key was in. Used internally.
-- @param name The mapped name of the key.
-- @return The state it was in.
function GGController:getPreviousKeyState( name )
	return self.keyStates.previous[ self:getMappedKey( name ) ]
end

--- Checks if a key is currently in a state.
-- @param name The mapped name of the key.
-- @param state The state to check.
-- @return True of the key is in the state, false otherwise.
function GGController:isKeyInState( name, state )
	return self:getKeyState( name ) == state
end

--- Checks if a key is currently pressed.
-- @param name The mapped name of the key.
-- @return True of the key is pressed, false otherwise.
function GGController:isKeyPressed( name )
	return self:isKeyInState( name, GGController.KeyState.Pressed )
end

--- Checks if a key is currently released.
-- @param name The mapped name of the key.
-- @return True of the key is released, false otherwise.
function GGController:isKeyReleased( name )
	return self:isKeyInState( name, GGController.KeyState.Released )
end

--- Checks if a key was just pressed.
-- @param name The mapped name of the key.
-- @return True of the key was just pressed, false otherwise.
function GGController:wasKeyJustPressed( name )
	return self:isKeyInState( name, GGController.KeyState.JustPressed )
end

--- Checks if a key was just released.
-- @param name The mapped name of the key.
-- @return True of the key was just released, false otherwise.
function GGController:wasKeyJustReleased( name )
	return self:isKeyInState( name, GGController.KeyState.JustReleased )
end

--- Checks if the event is for this controller. Used internally.
-- @param event The event table.
-- @return True if the event was meant for this controller, false otherwise.
function GGController:isEventForThisController( event )
	
	local device = event.device or {}
	local descriptor = device.descriptor

	if not descriptor then
		descriptor = "Joystick 1"
	end

	if descriptor ~= "Joystick " .. self:getIndex() then
		return false
	end

	return true

end

--- Key handler for this controller. Used internally.
-- @param event The event table.
function GGController:key( event )

	if not self:isEventForThisController( event ) then
		return false
	end

	local phase = event.phase
	local key = event.keyName

	if self:isKeyMapped( key ) then
		if phase == "down" then
			self:setKeyState( key, GGController.KeyState.Pressed )
		elseif phase == "up" then
			self:setKeyState( key, GGController.KeyState.Released )
		end
		return true
	end

	return false

end

--- Axis handler for this controller. Used internally.
-- @param event The event table.
function GGController:axis( event )

	if not self:isEventForThisController( event ) then
		return false
	end

	local axisList = self:getAxisList()

	if axisList then

		axisList.noise = axisList.noise or 0 

		local normalizedValue = event.normalizedValue

		if abs( normalizedValue ) > axisList.noise then
			self:fireAxisEvents( event.axis.number, normalizedValue, event.rawValue )
		end

	end

end

--- Enter frame handler for this controller. Used internally.
-- @param event The event table.
function GGController:enterFrame( event )
	
	self:updateKeyStates()

	local keys = self:getMappedKeys()
	for k, v in pairs( keys ) do
		self:fireKeyEvents( k )
	end

end

--- Updates the current key states. Used internally.
function GGController:updateKeyStates()
	local keys = self:getMappedKeys()
	for k, v in pairs( keys ) do
		if self:isKeyPressed( k ) then -- Check to see if the key was JUST PRESSED
			if self:getPreviousKeyState( k ) ~= GGController.KeyState.Pressed then
				self:setPreviousKeyState( k, GGController.KeyState.Pressed )
				self:setKeyState( k, GGController.KeyState.JustPressed )
			end
		elseif self:isKeyReleased( k ) then -- Check to see if the key was JUST RELEASED
			if self:getPreviousKeyState( k ) ~= GGController.KeyState.Released then
				self:setPreviousKeyState( k, GGController.KeyState.Released )
				self:setKeyState( k, GGController.KeyState.JustReleased )
			end
		elseif self:wasKeyJustPressed( k ) then -- Switch from JUST PRESSED to regular PRESSED i.e. held down
			self:setPreviousKeyState( k, GGController.KeyState.Pressed )
			self:setKeyState( k, GGController.KeyState.Pressed )
		elseif self:wasKeyJustReleased( k ) then -- Switch from JUST RELEASED to regular RELEASED
			self:setPreviousKeyState( k, GGController.KeyState.Released )
			self:setKeyState( k, GGController.KeyState.Released )
		end
	end
end

--- Fires off events for a key. Used internally.
-- @param key The key for the event.
function GGController:fireKeyEvents( key )
	local keyEvent = { name = "controller", type = GGController.EventType.Key, key = self:getMappedKey( key ), phase = self:getKeyState( key ), index = self:getIndex() }
	if self:getListener() then	
		self:getListener()( keyEvent )
	end
	Runtime:dispatchEvent( keyEvent )
end

--- Fires off events for the axis. Used internally.
-- @param index The index of the axis.
-- @param normalized The normalized value of the axis.
-- @param raw The raw value of the axis.
function GGController:fireAxisEvents( index, normalized, raw )
	local keyEvent = { name = "controller", type = GGController.EventType.Axis, axis = self:getAxisName( index ), normalized = normalized, raw = raw, index = self:getIndex() }
	if self:getListener() then	
		self:getListener()( keyEvent )
	end
	Runtime:dispatchEvent( keyEvent )
end

--- Destroys this GGController object.
function GGController:destroy()
	Runtime:removeEventListener( "key", self )
    Runtime:removeEventListener( "axis", self )
    Runtime:removeEventListener( "enterFrame", self )
end

return GGController