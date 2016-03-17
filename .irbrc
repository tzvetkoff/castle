#!/usr/bin/env ruby

begin
  require 'awesome_print'
  AwesomePrint.irb!
rescue LoadError
end

IRB.conf[:PROMPT_MODE] = :SIMPLE
