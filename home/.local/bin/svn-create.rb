#!/usr/bin/env ruby

base = '/home/polizei/tmp/svn/'

if ARGV.length < 2
	puts 'Usage: svn-create.rb <name> <description> [user=pass] ...'
	exit!
end

repo = base + ARGV.shift
desc = ARGV.shift

puts 'Creating repository `' + repo + '\' (' + desc + ') ...'
`svnadmin create #{repo}`

puts 'Setting up default configuration ...'
file = File.new(repo + '/conf/svnserve.conf', 'w')
file.write <<EOF
[general]
anon-access = read
auth-access = write
password-db = passwd
realm = #{desc}

EOF
file.close

puts 'Setting up users ...'
file = File.new(repo + '/conf/passwd', 'w')
file.puts '[users]'

ARGV.each do |arg|
	puts 'Adding user ' + arg.split('=')[0]
	file.puts arg.sub('=', ' = ')
end

`chmod a+w -R #{repo}`
