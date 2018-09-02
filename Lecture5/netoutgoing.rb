#!/usr/bin/ruby

# import library
require 'socket'

#host = "google.com"
host = "127.0.0.1"
port = 88

# connect to server
s = TCPSocket.open(host, port)

# build web request
req = "GET /index.html HTTP/1.1\r\nHost: #{host}\r\n\r\n"

# send web request
s.print(req)

# get reply
data = s.recv(10000)

# show output
puts data

# close socket
s.close
