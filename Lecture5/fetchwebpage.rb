#!/usr/bin/ruby

# import library
require 'net/http'
require 'net/https'

uri = 'https://en.wikipedia.org/wiki/Alice%27s_Adventures_in_Wonderland'

# connect
http = Net::HTTP.get URI(uri)


# send request
headers, body = http.get(path)



# check reply code
if headers.code == "200"
  print body                        
else                                
  puts "#{headers.code} #{headers.message}" 
end
