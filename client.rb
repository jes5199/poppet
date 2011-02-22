require 'lib/http'
require 'lib/execute'
require 'rubygems'

settings = {
  "server"  => 'http://localhost:4567/policy',
  "imp_dir" => './imp/',
}

name = ARGV[0] #TODO: validate command lines
json = Poppet::HTTP.get(settings["server"] + "/by_name/" + name )

puts Poppet::Execute.execute( "ruby apply.rb", json )
