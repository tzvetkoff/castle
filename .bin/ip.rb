#!/usr/bin/env ruby

require 'socket'

module NumExt
  def to_bin_s(len = 8)
    to_s(2).rjust(len, '0')
  end

  def to_oct_s(len = 4)
    to_s(8).rjust(len, '0')
  end

  def to_hex_s(len = 2, prefix = '0x')
    "#{prefix}#{to_s(16).rjust(len, '0')}"
  end
end

module ArrExt
  def map_with_index
    idx = -1

    self.map do |x|
      idx += 1
      yield(x, idx)
    end
  end

  def sum
    inject(0, &:+)
  end
end

if RUBY_VERSION >= '2.4.0'
  Integer.send(:include, NumExt)
else
  Fixnum.send(:include, NumExt) if RUBY_VERSION < '2.4.0'
  Bignum.send(:include, NumExt) if RUBY_VERSION < '2.4.0'
end

Array.send(:include, ArrExt)

class IPCalc
  attr_reader :src, :ip

  def initialize(hostname = 'localhost')

    if hostname =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$/
      @src = hostname.split('.').map(&:to_i)
      @ip = hostname.split('.').map(&:to_i).map_with_index{ |x, y| 256 ** (3 - y) * x }.sum.then do |i|
        [(i / 256 ** 3), (i / 256 ** 2 % 256), (i / 256 % 256), (i % 256)]
      end
    else
      @src = Socket.gethostbyname(hostname).last.chars.map(&:ord)
      @ip = Socket.gethostbyname(hostname).last.chars.map(&:ord)
    end
  end

  def to_s
    result = ''

    result << "ORI (???????) : #{src.join('.')}\n"
    result << "ORI (32)      : #{src.map_with_index{ |x, y| 256 ** (3 - y) * x }.sum}\n"
    result << "\n"

    result << "DEC (8/8/8/8) : #{ip.join('.')}\n"
    result << "BIN (8/8/8/8) : #{ip.map(&:to_bin_s).join('.')}\n"
    result << "OCT (8/8/8/8) : #{ip.map(&:to_oct_s).join('.')}\n"
    result << "HEX (8/8/8/8) : #{ip.map(&:to_hex_s).join('.')}\n"
    result << "\n"

    result << "DEC (8/8/16)  : #{ip[0, 2].join('.')}.#{ip[2] * 256 + ip[3]}\n"
    result << "BIN (8/8/16)  : #{ip[0, 2].map(&:to_bin_s).join('.')}.#{(ip[2] * 256 + ip[3]).to_bin_s(16)}\n"
    result << "OCT (8/8/16)  : #{ip[0, 2].map(&:to_oct_s).join('.')}.#{(ip[2] * 256 + ip[3]).to_oct_s(8)}\n"
    result << "HEX (8/8/16)  : #{ip[0, 2].map(&:to_hex_s).join('.')}.#{(ip[2] * 256 + ip[3]).to_hex_s(4)}\n"
    result << "\n"

    result << "DEC (8/24)    : #{ip[0]}.#{ip[1] * 65536 + ip[2] * 256 + ip[3]}\n"
    result << "BIN (8/24)    : #{ip[0].to_bin_s}.#{(ip[1] * 65536 + ip[2] * 256 + ip[3]).to_bin_s(24)}\n"
    result << "OCT (8/24)    : #{ip[0].to_oct_s}.#{(ip[1] * 65536 + ip[2] * 256 + ip[3]).to_oct_s(12)}\n"
    result << "HEX (8/24)    : #{ip[0].to_hex_s}.#{(ip[1] * 65536 + ip[2] * 256 + ip[3]).to_hex_s(6)}\n"
    result << "\n"

    result << "DEC (32)      : #{ip.map_with_index{ |x, y| 256 ** (3 - y) * x }.sum}\n"
    result << "BIN (32)      : #{ip.map_with_index{ |x, y| 256 ** (3 - y) * x }.sum.to_bin_s(32)}\n"
    result << "OCT (32)      : #{ip.map_with_index{ |x, y| 256 ** (3 - y) * x }.sum.to_oct_s(16)}\n"
    result << "HEX (32)      : #{ip.map_with_index{ |x, y| 256 ** (3 - y) * x }.sum.to_hex_s(8)}\n"
  end
end

if $0 == __FILE__
  if ARGV.length < 1
    puts 'Usage: ' + File.basename($0) + ' <ip/hostname>'
    exit! 1
  end

  ARGV.each do |hostname|
    puts IPCalc.new(hostname)
  end
end
