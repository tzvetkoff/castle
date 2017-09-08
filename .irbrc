#!/usr/bin/env ruby

begin
  require 'awesome_print'
  AwesomePrint.irb!
rescue LoadError
end

require 'irb/completion' rescue nil

IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 255
IRB.conf[:HISTORY_FILE] = File.join(ENV['GEM_HOME'] || ENV['HOME'], '.irb-history')
