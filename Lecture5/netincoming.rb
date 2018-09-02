#!/usr/bin/ruby

# import library
require 'socket'

# start server listening on port
server = TCPServer.open(88)

# main loop to accept connections
loop {
  # accept connection
  client = server.accept
  # send data
  client.puts("Have some data!")

  # receive data
  data = ""
  while (tmp = client.recv(10))
	    data += tmp
  end
}