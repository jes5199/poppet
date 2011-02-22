require 'rubygems'
require 'sinatra'
require 'lib/execute'

settings = {
  :public    => 'public',
}

set :public, settings[:public]

post '/inventory' do
  Poppet::Execute.execute( "ruby save_inventory.rb", request.body.read )
end
