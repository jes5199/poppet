require 'rubygems'
require 'json'
require 'lib/execute'
require 'lib/resource/system'
require 'lib/settings'
require 'lib/timestamp'

settings = Poppet::Settings.new

facts = {
}

#   system_facts/flat/*
# Question: should we typecast numerics? (Probably not. They're "structured", but only numerical, as a work-around)
Dir.glob( File.join( settings["facts"], "flat", "*" ) ) do |filename|
  name = File.basename(filename).sub(/\..*/,'')
  value = Poppet::Execute.execute(filename).chomp
  facts[name] = value
end

#   system_facts/structured/*
Dir.glob( File.join( settings["facts"], "structured", "*" ) ) do |filename|
  json = Poppet::Execute.execute(filename)
  facts.merge!( JSON.parse( json ) )
end

version = Poppet::Execute.execute( settings["facts_version"] ).chomp
metadata = {
  "facts_version"   => version,
  "facts_timestamp" => Poppet::Timestamp.now
}

system_resource = Poppet::Resource::System.new({"Metadata" => metadata}, facts)

puts JSON.dump( system_resource.data )



