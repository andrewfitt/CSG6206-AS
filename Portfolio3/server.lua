#!/usr/bin/lua5.3
--------------------------------------------------------------------------------------------
-- LuaRocks Dependencies

-- luarocks install luasocket
-- luarocks install sqlite3
-- luarocks install md5
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Global Require Statements

socket = require'socket'
md5 = require'md5'

--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Function: genConnectionID
-- Generate a uniqueID for the connection using MD5 hash in hex
-- @param ip_address nickname
-- @return md5_sum_hex
----------------------------------------------------------------------------------------------
function genConnectionID(ip,nickname)
	local val = ip..nickname..socket.gettime() --concatenate ip, nickname and timestamp
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