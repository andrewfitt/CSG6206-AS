#!/usr/bin/ruby

syntax="This ruby script reads a file and does something random\nSyntax: #{$0} <file_name>"

@freq_chars = {}
@freq_chars.default = 0
@vowels = ["A","E","I","O","U"]

#puts "$0            : #{$0}"
#puts "__FILE__      : #{__FILE__}"
#puts "$PROGRAM_NAME : #{$PROGRAM_NAME}"



def alpha(char)
	char =~ /[a-zA-Z]/
end



ARGV.each { |x| puts "ARG #{x}"} if ARGV.length >= 1

#puts "something #{ARGV.length}"


if !File.file?("#{ARGV[0]}")
	puts "Error: File does not exist or is inaccessible"
	puts "#{syntax}"
	exit
else
	#puts "File exists"
	file_contents = IO.binread("#{ARGV[0]}")
	puts "Sentences: " + file_contents.scan(/\s+[^.!?]*[.!?]/).size.to_s
	puts "Words: " + file_contents.scan(/\b[a-zA-Z'-]+/).size.to_s
	
	file_contents.upcase.split('').each do |character|
		#puts alpha(character)
		@freq_chars[character]+=1 if alpha(character)
	end
	@freq_chars = @freq_chars.sort.to_h

	puts "Vowel Count"

	@vowels.each { |k| puts "#{k}: "+@freq_chars["#{k}"].to_s }
	puts "\nConsonant Count"
	

	@freq_char.each { |k| if @vowels.exclude?("#{k}") { puts "#{k}: "+@freq_chars["#{k}"].to_s }}

end