#!/usr/bin/lua5.3

socket = require'socket'
copas = require'copas'
md5 = require'md5'


clientMsgs = {}
clientList = {}


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




local function simple(host, port, handler)
    return copas.addserver(assert(socket.bind(host, port)),
        function(c)
		print(c:getpeername())
            return handler(copas.wrap(c), c:getpeername())
        end)
end


function addClient(inputstring,c)
	local nickname = getNickname(inputstring)
	clientList[nickname] = {genClientUID(c:getpeername()[2],nickname),c}
	for clientname, tbl in pairs(clientList) do
		if(c ~= tbl[2]) then
			tbl[2]:send(nickname.." joined the chat\n")
		end
	end
	return nickname
end

function removeClient(nickname)
	clientList[nickname] = nil
end

function getUsers()
	local users = ""
	for clientnickname,val in pairs(clientList) do
		users = users.."\n"..clientnickname
	end
	return users.."\n"
end


function errorHandler(err)
	print("Error: "..err)
end



function getNickname(inputstring)
	local nickname = string.lower(string.match(inputstring,"%a+"))
	return nickname
end



local function example_handler(c, host, port)
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


print(simple("*", arg[1], example_handler))

return copas.loop()



-- copas.setErrorHandler(func)
-- copas.limit.new(max)
-- limitset:addthread(func [, ...])
-- limitset:wait()