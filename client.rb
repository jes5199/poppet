require 'lib/http'
require 'lib/execute'
require 'lib/settings'

include Poppet::Execute::EscapeWithLittleE

settings = Poppet::Settings.new

name = ARGV[0] #TODO: validate command lines
url  = settings["policy_server"] + "/by_name/" + name
if settings['use_last_known_good_policy']
  json = Poppet::Execute.execute('ruby last_known_good.rb ' + e(url) )
else
  json = Poppet::HTTP.get( url )
end

puts Poppet::Execute.execute( "ruby apply.rb", json )
