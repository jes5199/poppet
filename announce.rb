require 'lib/execute'
require 'lib/http'
require 'lib/settings'

settings = Poppet::Settings.new

Poppet::HTTP.post(settings["inventory_server"], Poppet::Execute.execute('ruby system_facts.rb'))


