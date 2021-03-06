#!/usr/bin/ruby

require 'uri'
require "open-uri"
require 'rubygems'
require 'nokogiri'


=begin

Portfolio 2
	Workshop 5
Scrape Alice in Wonderland Wikipedia page
Filter out everything other than rendered Alphabet characters [a-zA-Z]
Store the original page and the filtered text

Author: Andrew Fitt
Date: 5/9/2018
CSG6206.2018.2

=end


@out_filename = 'original_page.txt'
@final_filename = 'processedPage.txt'

url = "https://en.wikipedia.org/wiki/Alice%27s_Adventures_in_Wonderland"

def writeFileOut(fileToWrite, content)
  begin
    file = File.open("#{fileToWrite}", "w")
  rescue IOError => e
    puts "Unable to open file [filename]"
    puts "Error: #{e}"
  else
    file.write(content)
  ensure
    file.close unless file.nil?
  end
end


begin

  @data = URI.parse(url).read
  writeFileOut(@out_filename, @data)

  htmldoc = Nokogiri::HTML(@data) #Use Nokogiri gem to parse the raw bytes into a html doc object
  htmldoc.css('script, link').each {|node| node.remove} #Select script and link nodes in the HTML and remove them from the page extracted

  #Match all HTML nodes (the element opening and closing tags) and substitue for empty/nil (Miller, 2013)
  #Also match any character other than a-z or A-Z and substitue empty/nil
  @page_text = htmldoc.css('body').text.gsub(/<(?:[^>=]|='[^']*'|="[^"]*"|=[^'"][^\s>]*)*>|[^a-zA-Z]+/, '')

  writeFileOut("#{@final_filename}", @page_text)
  puts "Done: Written files #{@out_filename} and #{@final_filename}"

rescue OpenSSL::SSL::SSLError => sslError
  puts "Unable to establish SSL connection to: #{url}"
rescue Errno::ECONNREFUSED => connRefused
  puts "Unable to connect to: #{url}"
rescue Errno::ENOENT => noEntry
  puts "#{noEntry}"
rescue Errno::EACCES => noAccess
  puts "Insufficient permission or access to file.  It may be open or marked as read only\n#{noAccess}"
rescue Exception => e
  puts "Something went wrong: #{e}"
end


#References
# Miller, R. O. (2013). "Stripping out HTML tags in string." from https://stackoverflow.com/questions/17665582/stripping-out-html-tags-in-string.