require 'lib/execute'
require 'lib/http'


settings = {
  "server" => 'http://localhost:4567/inventory',
}

Poppet::HTTP.post(settings["server"], Poppet::Execute.execute('ruby system_facts.rb'))


