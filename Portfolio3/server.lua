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
-- @param arg
-- @return 1
----------------------------------------------------------------------------------------------
function errorHandler(err)
	print("Error: "..err)
	return 1
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
    return copas.addserver(assert(socket.bind("*", s_port)),
        function(c)
            return handler(copas.wrap(c), c:getpeername())
        end)
end
----------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------
-- Function: createListener
-- Create a socket listener and hand off to handler with connection "threading"
-- Default handler is for chat clients.  Option to include server admin handlers etc
-- Listens on all available host interfaces "0.0.0.0" TCPV4
-- @param s_port, handler
----------------------------------------------------------------------------------------------
local function chat_client_handler(c, host, port)
    local peer = host .. ":" .. port
    print("example connection from", peer)
	nickname = addClient(c:receive"*l",host,c) -- First line is the nickname
	print("get nick Status: "..nickname,clientList["nickname"])

    c:send("Hello "..nickname.."\n")
	while true do
	   cdata = c:receive"*l"
	   if (string.lower(cdata) == "#users") then c:send(getUsers()) end
	   if ((cdata == nil) or (cdata == "quit")) then
		removeClient(nickname)
		break
	   end -- if
	   print("data from", peer, cdata)
	end -- while
    print("example termination from", peer)
end





--------------------------------------------------------------------------------------------
-- Function: getSQLiteDBHandle
-- Generate a uniqueID for the connection using MD5 hash in hex
-- @param ip_address nickname
-- @return md5_sum_hex
----------------------------------------------------------------------------------------------
--function


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


----------------------------------------------------------------------------------------------
-- Function: logConnection
-- Log the connection of a client specifying inputs
-- @param id, nickname, ipaddress, date, time
-- @return boolean
----------------------------------------------------------------------------------------------
function logConnection(id,nickname,ip_addr)
	local date = os.date("%d/%m/%Y")
	local time = os.date("%H:%M")

	print(id, nickname, ip_addr, date, time)
	return true
end
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Function: logDisconnect
-- Log the disconnection of a client specifying the ID
-- @param id
-- @return boolean
----------------------------------------------------------------------------------------------
function logDisconnect(id)
	local date = os.date("%d/%m/%Y")
	local time = os.date("%H:%M")

	print(id, date, time)
	return true
end
----------------------------------------------------------------------------------------------







ip_addr = "127.0.0.1"
id = genConnectionID(ip_addr,arg[1])

logConnection(id, arg[1], ip_addr)
logDisconnect(id)