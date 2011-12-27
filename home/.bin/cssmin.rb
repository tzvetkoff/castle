#!/usr/bin/env ruby

if ARGV.length == 0
  puts "Usage: #{$0} <css>"
  exit!
end

ARGV.each do |file|
  handle = File.open file
  css = handle.read
  handle.close

  css.delete! "\n"
  css.gsub! /:\s+/, ':'
  css.gsub! /\s*([{,!;}])\s*/, '\1'

  puts "/* #{file} */"
  puts css
  puts
end
