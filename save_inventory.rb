require 'lib/timestamp'
require 'lib/storage'
require 'lib/resource'

settings = {
  :inventory => 'public/inventory',
}

# save System to inventory
# TODO: check identity.
# TODO: validate schema
json = STDIN.read
Poppet::Resource.new( JSON.parse(json) )
Poppet::Storage.timestamped_file(settings[:inventory]) do |f|
  f.print(json)
end
