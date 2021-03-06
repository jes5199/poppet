require 'rubygems'
require 'sinatra'
require 'lib/execute'
require 'lib/settings'

settings = Poppet::Settings.new

set :public, settings["public"]

post '/inventory' do
  Poppet::Execute.execute( "ruby save_inventory.rb", request.body.read )
end

post '/logs' do
  Poppet::Execute.execute( "ruby save_logs.rb", request.body.read )
end
