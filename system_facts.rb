require 'rubygems'
require 'json'
require 'lib/execute'
require 'lib/resource/system'


settings = {
  "facts" => './system_facts',
}

facts = {
}

#   system_facts/flat/*
# TODO: typecast numerics?
Dir.glob( File.join( settings["facts"], "flat", "*" ) ) do |filename|
  name = File.basename(filename).sub(/\..*/,'')
  value = Poppet::Execute.execute(filename).chomp
  facts[name] = value
end

#   system_facts/structured/*
Dir.glob( File.join( settings["facts"], "structured", "*" ) ) do |filename|
  json = Poppet::Execute.execute(filename)
  # TODO validate schema
  facts.merge!( JSON.parse( json ) )
end

system_resource = Poppet::Resource::System.new(facts)

puts JSON.dump( system_resource.data )



