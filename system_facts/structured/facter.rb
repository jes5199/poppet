#!/usr/bin/ruby

facter = `facter --json 2> /dev/null`
if $? == 0
  puts '{ "facter": '
  puts facter
  puts '}'
  exit
end

require 'rubygems'
require 'json'
require 'yaml'
facter = `facter --yaml 2> /dev/null`
if $? == 0
  puts JSON.dump( "facter" => YAML.load(facter) )
  exit
end

puts "{}"
