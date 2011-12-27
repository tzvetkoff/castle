#!/usr/bin/env ruby

require 'socket'

class Fixnum
	def to_bin_s(bits = 8)
		result = ''
		x = self
		while x > 0 do
			result += (x % 2).to_s
			x /= 2
		end
		return ('0' * (bits - result.length)) + result.reverse
	end

	def to_oct_s(octs = 4)
		result = ''
		x = self
		while x > 0 do
			result += (x % 8).to_s
			x /= 8
		end
		return ('0' * (octs - result.length)) + result.reverse
	end

	def to_hex_s(tetrades = 2, prefix = '0x')
		map = '0123456789ABCDEF'
		result = ''
		x = self
		while x > 0 do
			result += map[x % 16, 1]
			x /= 16
		end
		return prefix + ('0' * (tetrades - result.length)) + result.reverse
	end
end

class Bignum
	def to_bin_s(bits = 8)
		result = ''
		x = self
		while x > 0 do
			result += (x % 2).to_s
			x /= 2
		end
		return ('0' * (bits - result.length)) + result.reverse
	end

	def to_oct_s(octs = 4)
		result = ''
		x = self
		while x > 0 do
			result += (x % 8).to_s
			x /= 8
		end
		return ('0' * (octs - result.length)) + result.reverse
	end

	def to_hex_s(tetrades = 2, prefix = '0x')
		map = '0123456789ABCDEF'
		result = ''
		x = self
		while x > 0 do
			result += map[x % 16, 1]
			x /= 16
		end
		return prefix + ('0' * (tetrades - result.length)) + result.reverse
	end
end

class IPCalc
	def initialize(hostname = 'localhost')
		if hostname =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$/
			@ip = hostname.split('.').collect{ |x| x.to_i }
		else
			@ip = Socket.gethostbyname(hostname).last.split('').collect{ |x| x[0] }
		end
	end

	def to_s
		result = 'DEC (8/8/8/8) : ' + @ip.join('.') + "\n" +
				 'BIN (8/8/8/8) : ' + @ip.collect{ |x| x.to_i.to_bin_s }.join('.') + "\n" +
				 'OCT (8/8/8/8) : ' + @ip.collect{ |x| x.to_i.to_oct_s }.join('.') + "\n" +
				 'HEX (8/8/8/8) : ' + @ip.collect{ |x| x.to_i.to_hex_s }.join('.') + "\n" +
				 "\n" +
				 'DEC (8/8/16)  : ' + @ip[0, 2].join('.') + '.' + (@ip[2] * 256 + @ip[3]).to_s + "\n" +
				 'BIN (8/8/16)  : ' + @ip[0, 2].collect{ |x| x.to_i.to_bin_s }.join('.') + '.' + (@ip[2] * 256 + @ip[3]).to_i.to_bin_s(16) + "\n" +
				 'OCT (8/8/16)  : ' + @ip[0, 2].collect{ |x| x.to_i.to_oct_s }.join('.') + '.' + (@ip[2] * 256 + @ip[3]).to_i.to_oct_s(7) + "\n" +
				 'HEX (8/8/16)  : ' + @ip[0, 2].collect{ |x| x.to_i.to_hex_s }.join('.') + '.' + (@ip[2] * 256 + @ip[3]).to_i.to_hex_s(4) + "\n" +
				 "\n" +
				 'DEC (8/24)    : ' + @ip[0].to_s + '.' + ((@ip[1] * 256 + @ip[2]) * 256 + @ip[3]).to_s + "\n" +
				 'BIN (8/24)    : ' + @ip[0].to_i.to_bin_s + '.' + ((@ip[1] * 256 + @ip[2]) * 256 + @ip[3]).to_i.to_bin_s(24) + "\n" +
				 'OCT (8/24)    : ' + @ip[0].to_i.to_oct_s + '.' + ((@ip[1] * 256 + @ip[2]) * 256 + @ip[3]).to_i.to_oct_s(10) + "\n" +
				 'HEX (8/24)    : ' + @ip[0].to_i.to_hex_s + '.' + ((@ip[1] * 256 + @ip[2]) * 256 + @ip[3]).to_i.to_hex_s(6) + "\n" +
				 "\n" +
				 'DEC (32)      : ' + (((@ip[0] * 256 + @ip[1]) * 256 + @ip[2]) * 256 + @ip[3]).to_s + "\n" +
				 'BIN (32)      : ' + (((@ip[0] * 256 + @ip[1]) * 256 + @ip[2]) * 256 + @ip[3]).to_i.to_bin_s(32) + "\n" +
				 'OCT (32)      : ' + (((@ip[0] * 256 + @ip[1]) * 256 + @ip[2]) * 256 + @ip[3]).to_i.to_oct_s(13) + "\n" +
				 'HEX (32)      : ' + (((@ip[0] * 256 + @ip[1]) * 256 + @ip[2]) * 256 + @ip[3]).to_i.to_hex_s(8) + "\n"
	end
end

if $0 == __FILE__
	if ARGV.length < 1
		puts 'Usage: ' + File.basename($0) + ' <ip/hostname>'
		exit!
	end
	ARGV.each do |hostname|
		ip = IPCalc.new(hostname)
		puts ip
	end
end
