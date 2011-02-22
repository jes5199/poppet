require 'lib/timestamp'
require 'lib/storage'

settings = {
  :inventory => 'public/inventory',
}

# save System to inventory
# TODO: check identity.
# TODO: validate schema
Poppet::Storage.timestamped_file(settings[:inventory]) do |f|
  f.print(STDIN.read)
end
