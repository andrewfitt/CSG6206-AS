#!/usr/bin/lua5.3

socket = require'socket'
copas = require'copas'

connections = {}


function addClient(nickname,clientUID)
	if(

end



local function simple(host, port, handler)
    return copas.addserver(assert(socket.bind(host, port)),
        function(c)
            return handler(copas.wrap(c), c:getpeername())
        end)
end










function errorHandler(err)
	print("Error: "..err)
end




function getNickname(inputstring)
	nickname = string.lower(string.match(inputstring,"%a+"))
	return nickname
end



local function example_handler(c, host, port)
    local peer = host .. ":" .. port
	local state = true
    print("example connection from", peer)
	nickname = getNickname(c:receive"*l") -- First line is the nickname
	print("get nick Status: "..nickname)
    c:send("Hello "..nickname.."\n")
	while true do
	   cdata = c:receive"*l"
	   if (cdata == nil) or (cdata == "quit") then break end
	
	   print("data from", peer, cdata)

	end -- while state == true
    print("example termination from", peer)
end

--print("*", arg[1], example_handler)
print(simple("*", arg[1], example_handler))

return copas.loop()



-- copas.setErrorHandler(func)
-- copas.limit.new(max)
-- limitset:addthread(func [, ...])
-- limitset:wait()