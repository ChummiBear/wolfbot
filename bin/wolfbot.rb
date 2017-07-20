#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path('../../lib' , __FILE__)
require 'wolfbot'

Thread.abort_on_exception = true

channel = Wolfbot::Twitch.new
channel.listen

while (channel.running)
  command = gets.chomp

  command =='quit' ? channel.stop : channel.send(command)
end
puts 'Exited.'