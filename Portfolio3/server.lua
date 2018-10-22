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
sqlite3 = require'sqlite3'
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Global Variables


--Client Connection Table
clientList = {}

--Chat Server Params
chatServerPort = ""
chatServerIPAddress = "*"

--SQLite3 DB Filename
sqliteFilename = "./chatter.sqlite"


--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Function: initDB
-- Create DB file and tables if they don't alread exist
-- Return status code 1 for fail and 0 for success
-- @param dbfilename
-- @return 0 or 1
----------------------------------------------------------------------------------------------
function initDB()
	db = sqlite3.open(sqliteFilename)
	db:exec[[
		CREATE TABLE connections (id PRIMARY KEY,nickname,ip_address,src_port,connect_date,connect_time,disconnect_date, disconnect_time);
		CREATE TABLE messages (id NOT NULL, nickname, message, msg_date, msg_time);
	]]
	db_insert_connection = assert( db:prepare("INSERT INTO connections VALUES (?, ?, ?, ?, ?, ?,NULL,NULL);COMMIT;") )
	db_update_connection = assert( db:prepare("UPDATE connections SET disconnect_date=?, disconnect_time=? WHERE id=? and nickname=?;COMMIT;") )
	db_insert_message = assert( db:prepare("INSERT INTO messages VALUES (?, ?, ?, ?, ?);COMMIT;") )
	return 0
end
--------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------
-- Function: validateCLIArgs
-- Validate that the commandline arguments are valid and if not terminate cleanly with the
-- syntax expectations.  Store the correct arguments in global variables.
-- Return status code 1 for fail and 0 for success
-- Output to STDOUT the correct syntax for the application
-- @param arg
-- @return 0 or 1
----------------------------------------------------------------------------------------------
function validateCLIArgs(...)
	if(arg[1]) then
		origArg1 = arg[1]
		chatServerPort = string.match(arg[1],"%d+")
		if(chatServerPort and origArg1)
		then
			if((string.len(origArg1) == string.len(chatServerPort)) and (tonumber(chatServerPort)>=1024) and (tonumber(chatServerPort)<=65535))
			then
				-- print("Valid port number: "..chatServerPort)
				return 0
			end
		end
	end
	print("Syntax error")
	print("Usage: server.lua [listening TCP port range:1024-65535]")
	print("Example: server.lua 10000")
	return 1
end
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
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
-- Function: removeClient
-- Remove a client connection from the internal list
-- @param nickname
-- @return 0
----------------------------------------------------------------------------------------------
function removeClient(nickname)
	clientList[nickname] = nil
end
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- Function: addClient
-- Adds the client connection to the client list.  If the nickname alread exists, reject the
-- notify the client and reject the connection.
-- @param nickname,c_host,c_port, c (connection object)
-- @return 0
----------------------------------------------------------------------------------------------
function addClient(nickname,c_host,c_port,c)
	clientUID = genClientUID(c_port,nickname)
	clientList[nickname] = {clientUID,c}
	logConnection(clientUID,nickname,c_host,c_port)
	for clientname, tbl in pairs(clientList) do
		if(c ~= tbl[2]) then
			tbl[2]:send(nickname.." joined the chat\n") -- tell everyone that a new user has joined
		end
	end
	return 0
end
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- Function: getClientDetails(nickname)
-- Gets the client details from the client list.
-- If the nickname doesn't exist, return nil,nil and err
-- @param nickname
-- @return clientUID,c,err
----------------------------------------------------------------------------------------------
function getClientDetails(nickname)
	local err = 1
	if(clientList[nickname] ~= nil) then
		clientUID = clientList[nickname][1]
		c = clientList[nickname][2]
		err = 0
	end		
	return clientUID, c, err
end
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- Function: getUsers()
-- Return the list of active users on the server as a string
-- @return users
----------------------------------------------------------------------------------------------
function getUsers()
	local users = "----User List----\n-----------------\n"
	for clientnickname,val in pairs(clientList) do
		users = users..clientnickname.."\n"
	end
	return users
end
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- Function: getNickname
-- Return the extracted user nickname if not already used
-- @param inputstring
-- @return nickname, 0 or 1
----------------------------------------------------------------------------------------------
function getNickname(inputstring)
	local nickname = string.match(inputstring,"%a+")
	if(nickname ~= "" and nickname ~= nil)
	then
		nickname = string.lower(nickname)
		if ((clientList[nickname]==nil) and (nickname ~= nil) and (nickname ~= "server")) then
			return nickname, 0 -- success, no existing nickname
		else
			return nickname, 1
		end
	else
		return "",1
	end
end
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-- Function: errorHandler
-- Record errors to STDOUT
-- @param err
----------------------------------------------------------------------------------------------
function errorHandler(err)
	print("Error: ",err)
end
----------------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------------
-- Function: startServer
-- Create a socket listener and hand off to handler with connection "threading"
-- Default handler is for chat clients.  Option to include server admin handlers etc
-- Listens on all available host interfaces "0.0.0.0" TCPV4
-- @param s_port, handler
----------------------------------------------------------------------------------------------
function startServer(s_port,handler)
	local s_host = chatServerIPAddress
	local skt = assert(socket.bind(s_host, s_port))
	copasServerObj = copas.addserver(skt, 
		function(c) 
			return handler(copas.wrap(c)) -- Accept the incoming TCP connection
        	end
	)
	local ip_addr,port,inet = skt:getsockname()
	print("Server running at "..ip_addr..":"..port)
	print("Awaiting client connection")
	return copasServerObj
	
end
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Function: chatClientHandler
-- Create a chat with the incoming tcp connection from the server listener
-- Manages the client chat communications and processes.  Takes the client object as input
-- @param c
----------------------------------------------------------------------------------------------
local function chatClientHandler(c)
	local msg = ""
	local s_ipaddr,s_port = c:getsockname()
	c:send("Connected to server "..s_ipaddr..":"..s_port.."\n")
	inputstring = c:receive"*l"
	local nickname, err = getNickname(inputstring)	 -- First line received is the nickname
	if((err == 1) and (nickname ~= nil) and (nickname ~= ""))
	then
		c:send("Sorry, the nickname: "..nickname.." is already taken or reserved.  Try again with a new nickname.\n")
		c:send([[Valid nicknames are lowercase alphabetic without numbers or special characters or spaces.]].."\n")
		c:send([[Example: Valid:"simone", Invalid:"653246", Special case:"spider monkey" results in "spider" only.]].."\n")
		c:send([[         Special case:"L33tH4x0r" results in "lthxr" only (note truncation and lowercase).]].."\n")
		c:send([["server" is a reserved nickname.]].."\n")
		return
	elseif((err == 1) and ((nickname == nil) or (nickname == "")))
	then
		c:send("Sorry, you have not provided valid text that allowed me to create a nickname for you.")
		c:send([[Valid nicknames are lowercase alphabetic without numbers or special characters or spaces.]].."\n")
		c:send([[Example: Valid:"simone", Invalid:"653246", Special case:"spider monkey" results in "spider" only.]].."\n")
		c:send([[         Special case:"L33tH4x0r" results in "lthxr" only (note truncation and lowercase).]].."\n")
		c:send([["server" is a reserved nickname.]].."\n")
		return
	end
	local c_host,c_port,inet_if = c:getpeername()
	local resp = addClient(nickname,c_host,c_port,c)
	c:send("Hello "..nickname.."\n".."Enter message: ")
	while true do
		cdata = c:receive"*l"
		if(cdata ~= nil) then
			logMsg(nickname,cdata)
		end
		if ((cdata == nil) or (cdata == "#quit"))   		--[[ Client #quit or connection closed--]]
		then
			logDisconnect(nickname)
			removeClient(nickname)
			return
		end
		if(string.lower(cdata) == "#users")			--[[List #users Command--]]
		then
			c:send(getUsers())
		end
		if((string.char(string.byte(cdata)) == "@") and (string.match(cdata,"%a+") ~= nil) and (string.match(cdata,"%a+") ~= ""))	--[[Send to specific client--]]
		then
			tgt_nickname, msg = string.match(cdata,"(%a+)%s*(.*)")
			tgt_nickname = string.lower(tgt_nickname)
			tgt_clientUID, tgt_clientconn, getUserErr = getClientDetails(tgt_nickname)
			if (tgt_nickname == "server")
			then
				msg = "@"..nickname.." I am not allowed to speak"
				logMsg("server",msg)
				c:send("[server]: "..msg.."\n")
			elseif(getUserErr == 1)
			then
				c:send("Unknown user: "..tgt_nickname.."\n")
				c:send(getUsers())				
			else
				logMsg(nickname,cdata)
				tgt_clientconn:send("["..nickname.."]: "..cdata.."\n")	--[[Send original string--]]
			end
		else 								--[[Send to eveyone except the server--]]
			for clientname, tbl in pairs(clientList)
			do
				if(clientname ~= nickname) --[[Don't send to self--]]
				then
					tgt_nickname = clientname
					tgt_clientconn = tbl[2]
					tgt_clientconn:send("["..nickname.."]: "..cdata.."\n")	--[[Send original string--]]
				end
			end

		end 							--[[if message transmission to user or group--]]
		c:send("Enter message: ")
	end
end
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Function: logMsg
-- Create a DB entry for the message sent by the client and write to STDOUT
-- @param nickname, msg
-- @return 0 or 1
----------------------------------------------------------------------------------------------
function logMsg(nickname, msg)
	local date = os.date("%d/%m/%Y")
	local time = os.date("%H:%M")
	clientUID, clientconn, getUserErr = getClientDetails(nickname)
	db_insert_message:bind(clientUID,nickname,msg,date,time)
	db_insert_message:exec()
	print("["..nickname.."]: "..msg)
	return 0
end
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Function: logConnection
-- Log the connection of a client specifying inputs
-- @param clientUID,nickname, c_host,c_port
-- @return 0 or 1
----------------------------------------------------------------------------------------------
function logConnection(clientUID,nickname,c_host,c_port)
	local date = os.date("%d/%m/%Y")
	local time = os.date("%H:%M")
	db_insert_connection:bind(clientUID, nickname, c_host, c_port, date, time)
	db_insert_connection:exec()
	print(">> "..nickname.." connected from "..tostring(c_host).." at "..date.." "..time)
	return 0
end
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------
-- Function: logDisconnect
-- Log the disconnection of a client specifying the nickname
-- @param nickname
-- @return 0 or 1
----------------------------------------------------------------------------------------------
function logDisconnect(nickname)
	local date = os.date("%d/%m/%Y")
	local time = os.date("%H:%M")
	db_update_connection:bind(date, time,clientUID, nickname)
	db_update_connection:exec()
	print("<< "..nickname.." disconnected at "..time)
	return 0
end
----------------------------------------------------------------------------------------------


----- MAIN -------

if(validateCLIArgs()==1) then return end
initDB()
function startSrv() startServer(chatServerPort, chatClientHandler) end

status = xpcall(startSrv,errorHandler)
copas.loop()



