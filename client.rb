require 'lib/http'
require 'lib/policy/applier'
require 'rubygems'
require 'json'

settings = {
  "server" => 'http://localhost:4567/policy',
}

name = ARGV[0] #TODO: validate command lines
json = Poppet::HTTP.get(settings["server"] + "/by_name/" + name )

# TODO: split into apply.rb
applier = Poppet::Policy::Applier.new( JSON.parse( json ) )

applier.each do |res|
  p res
end
