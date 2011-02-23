#!/usr/bin/ruby

ohai = `ohai`
if $? == 0
  puts '{ "ohai": '
  puts ohai
  puts '}'
else
  puts "{}"
end
