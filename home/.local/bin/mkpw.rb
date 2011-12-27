#!/usr/bin/env ruby

count = 4
length = 8
charset = '01234567890abcdef'

ARGV.each do |arg|
	if (arg[0, 2].eql?('-h') || arg[0, 4].eql?('--he'))
		puts 'Usage: ' + File.basename($0) + ' [options]'
		puts 'Options:'
		puts '  -h                  # this ugly help message :-}'
		puts '  --help              #  and its long brother-alias :-}'
		puts '  -n=<count>          # count of passwords to generate'
		puts '  --count=<count>     #  default: 4'
		puts '  -l=<length>         # output passwords length'
		puts '  --length=<length>   #  default: 8'
		puts '  -c=<charset>        # passwords charset'
		puts '  --charset=<charset> #  default: 0123456789abcdef'
		exit!
	elsif (arg[0, 3].eql?('-n=') || (arg[0, 4].eql?('--co') && arg.include?('=')))
		count = arg.split('=')[1].to_i
	elsif (arg[0, 3].eql?('-l=') || (arg[0, 4].eql?('--le') && arg.include?('=')))
		length = arg.split('=')[1].to_i
	elsif (arg[0, 3].eql?('-c=') || (arg[0, 4] == '--ch' && arg.include?('=')))
		charset = arg.split('=')[1]
	end
end

count.times do
	out = ''
	length.times do
		out += charset[rand(charset.length), 1]
	end
	puts out
end
