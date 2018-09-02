#!/usr/bin/ruby

require 'uri'
require "open-uri"
require 'rubygems'
require 'nokogiri'


=begin
	Workshop 5
Scrape ALice in Wonderland Wikipedia page
Filter out everything other than rendered Alphabet characters [a-zA-Z]
Store the original page and the filtered text

Author: Andrew Fitt
Date: 22/8/2017
CSG6206

=end






@out_filename = 'AiW.txt'
@final_filename = 'finalFile.out'




url="https://en.wikipedia.org/wiki/Alice%27s_Adventures_in_Wonderland"


def writeFileOut(fileToWrite,dataWriteMe)
	@responseCode=0
	begin
		file = File.open("#{fileToWrite}", "w")
	rescue IOError => e
		puts "Unable to open file [filename]"
		puts "Error: #{e}"
		responseCode=1
	else
		file.write(dataWriteMe)
		responseCode=0
	ensure
		file.close unless file.nil?
	end
	return #{responseCode}
end



@data = URI.parse(url).read
writeFileOut(@out_filename,@data)



htmldoc = Nokogiri::HTML(@data) #Use Nokogiri gem to parse the raw bytes into a html doc object
htmldoc.css('script, link').each { |node| node.remove } #Select script and link nodes in the HTML and remove them from the page extracted


#Match all HTML nodes (the element opening and closing tags) and substitue for empty/nil (Miller, 2013)
#Also match any character other than a-z or A-Z and substitue empty/nil
@page_text = htmldoc.css('body').text.gsub(/<(?:[^>=]|='[^']*'|="[^"]*"|=[^'"][^\s>]*)*>|[^a-zA-Z]+/,'')

#puts @page_text

writeFileOut("#{@final_filename}",@page_text)
puts "Done: Written files #{@out_filename} and #{@final_filename}"


#References
# Miller, R. O. (2013). "Stripping out HTML tags in string." from https://stackoverflow.com/questions/17665582/stripping-out-html-tags-in-string.