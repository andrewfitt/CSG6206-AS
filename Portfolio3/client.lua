#!/usr/bin/lua5.3
--------------------------------------------------------------------------------------------
-- LuaRocks Dependencies
--
-- Socket connectivity 
--    luarocks install luasocket

=-=-=-=-=-
Do i need Copas in the client?  maybe useful?

-- Copas for the handling of (psuedo) non-blocking IO on the socket handling (coroutine based)
--    luarocks install copas
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Global Require Statements

socket = require'socket'


--------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------
-- Function: errorHandler
-- Record errors to STDOUT and return an status code 0
-- @param err
-- @return 0
----------------------------------------------------------------------------------------------
function errorHandler(err)
	print("Error: "..err)
	return 0
end
--------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------
-- Function: validateIPAddr
-- Takes a string and returns 1 for valid ip address format
-- Expected format is [1..25
-- @param ipaddr
-- @return 
----------------------------------------------------------------------------------------------
function validateIPAddr(ipaddr)
	


	return 1
end
----------------------------------------------------------------------------------------------

