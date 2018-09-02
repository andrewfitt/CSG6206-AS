#!/usr/bin/ruby

hash = { :A => 2, :B => 3, :C => 7}

#puts hash[:A] + hash[:C]

for i in ('A'..'Z')
	if hash[:"#{i}"]
		puts hash[:"#{i}"]
	end
end