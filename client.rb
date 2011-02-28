require 'lib/http'
require 'lib/execute'
require 'lib/settings'

settings = Poppet::Settings.new

name = ARGV[0] #TODO: validate command lines
json = Poppet::HTTP.get(settings["policy_server"] + "/by_name/" + name )

puts Poppet::Execute.execute( "ruby apply.rb", json )
