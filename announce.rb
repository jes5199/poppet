require 'rubygems'
require 'json'
require 'lib/http'
require 'lib/execute'


settings = {
  "server" => 'http://localhost:3000/inventory',
  "facts" => './system_facts',
}

facts = {
}

#   system_facts/flat/*

# TODO: refactor into two scripts (collection, announcement)
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

p facts
json = JSON.dump( facts )

Poppet::HTTP.post(settings["server"], json)


