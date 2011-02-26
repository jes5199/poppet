require 'lib/timestamp'
require 'lib/storage'
require 'lib/resource'

settings = {
  :logs => 'public/logs',
}

# save System to inventory
# TODO: check identity.
# TODO: validate schema
json = STDIN.read
Poppet::Resource.new( JSON.parse(json) )
Poppet::Storage.timestamped_file(settings[:logs]) do |f|
  f.print(json)
end
