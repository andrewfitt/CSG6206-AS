#!/usr/bin/ruby

hash ={}
hash.default = 0

list=["A","A","B","C","D","D","D","Z","Z"]

=begin ### For loop style
for x in list do
hash[x]+=1
end
=end

list.each { |x| hash[x]+=1}

puts hash