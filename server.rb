require 'sinatra'
require 'lib/poppet'

settings = {
  :inventory => 'public/inventory',
}

post '/inventory' do
  # save System to inventory
  # TODO: check identity.
  # TODO: validate schema
  Poppet::Storage.timestamped_file(settings[:inventory]) do |f|
    f.print(request.body)
  end
end
