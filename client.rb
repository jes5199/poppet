require 'lib/http'
require 'lib/policy/applier'
require 'lib/execute'
require 'rubygems'
require 'json'

settings = {
  "server"  => 'http://localhost:4567/policy',
  "imp_dir" => './imp/',
}

name = ARGV[0] #TODO: validate command lines
json = Poppet::HTTP.get(settings["server"] + "/by_name/" + name )

# TODO: split into apply.rb
applier = Poppet::Policy::Applier.new( JSON.parse( json ) )

applier.each do |res|
  imp = File.join("imp", res["type"] + ".rb") # TODO: smarter executable finding
  p Poppet::Execute.execute( imp, JSON.dump( [ "change", res ] ) )
  #TODO build a report
end
