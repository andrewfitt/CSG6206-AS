#!/usr/bin/lua5.3

socket = require'socket'
copas = require'copas'

function handler(c, host, port)
	local peer = host .. ":" .. port
	print("connection from", peer)
	c:send("Hello\r\n")
	print("data from", peer, (c:receive"*l"))
end
copas.addserver(assert(socket.bind("*",arg[1])),
                function(c) return handler(copas.wrap(c), c:getpeername()) end
)
copas.loop()