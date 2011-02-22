require 'rubygems'
require 'sinatra'
require 'lib/timestamp'
require 'lib/storage'

settings = {
  :public    => 'public',
  :inventory => 'public/inventory',
}

set :public, settings[:public]

post '/inventory' do
  # save System to inventory
  # TODO: check identity.
  # TODO: validate schema
  # TODO: extract to save-to-inventory script
  Poppet::Storage.timestamped_file(settings[:inventory]) do |f|
    request.body.each do |chunk|
      f.print(chunk)
    end
  end
end
