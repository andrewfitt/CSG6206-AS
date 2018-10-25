#!/usr/bin/lua5.3
--------------------------------------------------------------------------------------------
-- LuaRocks Dependencies
--
-- Socket connectivity 
--    luarocks install luasocket
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
-- Function: isIPAddress
-- The IP Address validation is not complete to the correct IPV4 classes, merely that the
-- octets contain valid numbers.
-- @param ipAddr_str
-- @return 0 or 1
----------------------------------------------------------------------------------------------
function isIPAddress(ipAddr_str)
	if(ipAddr_str) then
		local origIP = string.match(ipAddr_str,"%d+.%d+.%d+.%d+")
		if(origIP == ipAddr_str) then
			local a,b,c,d = string.match(ipAddr_str,"(%d+).(%d+).(%d+).(%d+)")
			if(tonumber(a) < 1 or tonumber(a) > 254 or tonumber(b) < 0 or 
					tonumber(b) > 255 or tonumber(c) < 0 or
					tonumber(c) > 255 or tonumber(d) < 0 or tonumber(d) > 255)
			then
				return 0
			end
		else
			return 1
		end
	else
		return 1
	end
	return 
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
	local failure = false

	if ((arg[1] ~= nil) and (arg[2] ~= nil) and (arg[3] ~= nil))
	then

-- Check nickname

		local nickname = string.match(arg[1],"%a+")
		if(nickname ~= nil) then
			if(string.lower(nickname) ~= arg[1])
			then
				print("nickname may only contain lowercase alphabetic chars [a-z]")
				failure = true
			end
		else
			failure = true
		end
	
-- Check Target IP

		if(isIPAddress(arg[2]) == 0) then
			print("Please enter a valid IPV4 Address")
			failure = true
		end

-- Check Target Port

		server_port = string.match(arg[3],"%d+")
		if((server_port ~= arg[3]) or (tonumber(server_port) < 1) or (tonumber(server_port) > 65535))
		then
			print("server port must be a number in the range [1-65535]")
			failure = true
		end


	else
		print("Insufficient parameters")
		failure = true
	end
	if(failure == true)
	then
		print("Syntax error")
		print("Usage: client.lua [nickname] [server IP address] [server port]" )
		print("Example: client.lua john 127.0.0.1 10000")
		return 1
	else
		return 0
	end
end
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-- Function: connectToServer
-- TODO - Improve the receive and send with asynchronous keyboard handling.  Unable to yield
--		the keyboard interrupt and display buffered receive channel.
-- @param nickname,s_host,s_port
-- @return 0
----------------------------------------------------------------------------------------------
function connectToServer(nickname,s_host,s_port)
	local conn = assert(socket.tcp())
	local msgStack = {}
	local sendMsg = ""
	connResult, resDescription = conn:connect(s_host, s_port)

	if (connResult == nil) then
		errorHandler(resDescription)
		return 0
	end
	
	print("Connected to server "..tostring(s_host)..":"..tostring(s_port))
	conn:send(nickname.."\n");
	conn:settimeout(1)
	while true do
		while true do		-- Receive all incoming messages
			local sdata, rcv_status = conn:receive"*l"
			if(sdata == nil)
			then
				break
			end
			msgStack[#msgStack+1] = sdata
		end
		if(msgStack ~= nil) then
			for i,v in ipairs(msgStack) do
				print(v)
			end
			msgStack = {}
		end
		sendMsg = getInputFromUser()
		if(sendMsg == "#quit")
		then
			conn:close()
			break
		end
		send_status,send_err = conn:send(sendMsg)
		if((send_status == nil) or (send_err == "closed"))
		then
			conn:close()
			break
		end
	end
	conn:close()
end
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-- Function: getInputFromUser
-- Take input from the user and pass it back to the calling function
-- @return userMsg
----------------------------------------------------------------------------------------------
function getInputFromUser()
	io.write("Enter message: ")
	userMsg = io.read("*l").."\n"
	return userMsg
end
----------------------------------------------------------------------------------------------

if(validateCLIArgs() == 0) then
	connectToServer(arg[1],arg[2],arg[3])
end
