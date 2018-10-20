#!/usr/bin/lua5.3
--------------------------------------------------------------------------------------------
-- LuaRocks Dependencies
--
-- Socket connectivity 
--    luarocks install luasocket
-- SQLite DB for logging
--    luarocks install sqlite3
-- MD5 for unique connection identifier
--    luarocks install md5
-- Copas for the handling of (psuedo) non-blocking IO on the socket handling (coroutine based)
--    luarocks install copas
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Global Require Statements

socket = require'socket'
copas = require'copas'
md5 = require'md5'
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Global Variables


--Client Connection Table
clientList = {}


--------------------------------------------------------------------------------------------




--------------------------------------------------------------------------------------------
-- Function: validateCLIArgs
-- Validate that the commandline arguments are valid and if not terminate cleanly with the
-- syntax expectations.  Return error code 1 for fail and 0 for success
-- Output to STDOUT the correct syntax for the application
-- @param arg
-- @return 1 or 0
----------------------------------------------------------------------------------------------
function validateCLIArgs(arg)
	for i in arg do
		print("Arg: "..tostring(i))
	end
	return 0 -- if ok
end
----------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------
-- Function: genClientUID
-- Generate a uniqueID for the connection using MD5 hash in hex
-- @param ip_address nickname
-- @return md5_sum_hex
----------------------------------------------------------------------------------------------
function genClientUID(c_ip,nickname)
	local val = tostring(c_ip)..tostring(nickname)..tostring(socket.gettime())
	return md5.sumhexa(val) -- return an md5 hex value for the connection ID
end
----------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------
-- Function: errorHandler
-- Record errors to STDOUT and return an status code 1
-- @param err
-- @return 1
----------------------------------------------------------------------------------------------
function errorHandler(err)
	print("Error: "..err)
	return 1
end
----------------------------------------------------------------------------------------------




--------------------------------------------------------------------------------------------
-- Function: createListener
-- Create a socket listener and hand off to handler with connection "threading"
-- Default handler is for chat clients.  Option to include server admin handlers etc
-- Listens on all available host interfaces "0.0.0.0" TCPV4
-- @param s_port, handler
----------------------------------------------------------------------------------------------
function startServer(s_port,handler)
	copas.setErrorHandler(errorHandler)
	return copas.addserver(assert(socket.bind("*", s_port)),
        	function(c) return handler(copas.wrap(c)) -- Accept the incoming TCP connection
        end)
end
----------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------
-- Function: chatClientHandler
-- Create a chat with the incoming tcp connection from the server listener
-- Manages the client chat communications and processes.  Takes the client object as input
-- @param c
----------------------------------------------------------------------------------------------
local function chatClientHandler(c)

	nickname = addClient(c:receive"*l",c) -- First line received is the nickname
	logConnection(nickname,c:getpeername())

	c:send("Hello "..nickname.."\n".."Enter message: ")
	while true do
	   cdata = c:receive"*l"
	   c:send("Enter message: ")
	   if (string.lower(cdata) == "#users") then c:send(getUsers()) end
	   if ((cdata == nil) or (cdata == "#quit")) then
		removeClient(nickname)
		break
	   end -- if
	end -- while
end





--------------------------------------------------------------------------------------------
-- Function: getSQLiteDBHandle
-- Generate a uniqueID for the connection using MD5 hash in hex
-- @param ip_address nickname
-- @return md5_sum_hex
----------------------------------------------------------------------------------------------
--function


----------------------------------------------------------------------------------------------






----------------------------------------------------------------------------------------------
-- Function: logConnection
-- Log the connection of a client specifying inputs
-- @param nickname, c_ipaddr,c_host
-- @return boolean
----------------------------------------------------------------------------------------------
function logConnection(nickname,c_ipaddr,c_host, )
	local date = os.date("%d/%m/%Y")
	local time = os.date("%H:%M")
	print(">> "..nickname.." connected from "..tostring(c_ipaddr).." at "..date.." "..time)
	return true
end
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Function: logDisconnect
-- Log the disconnection of a client specifying the nickname
-- @param nickname
-- @return boolean
----------------------------------------------------------------------------------------------
function logDisconnect(nickname,time)
	print("<< "..nickname.." disconnected at "..time)
	return true
end
----------------------------------------------------------------------------------------------







ip_addr = "127.0.0.1"
id = genConnectionID(ip_addr,arg[1])

logConnection(id, arg[1], ip_addr)
logDisconnect(id)