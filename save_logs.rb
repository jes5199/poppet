require 'lib/timestamp'
require 'lib/storage'
require 'lib/changelog'

settings = {
  "logs" => 'public/logs',
}

# save System to inventory
# TODO: check identity.
json = STDIN.read
Poppet::Changelog.new( JSON.parse(json) )
Poppet::Storage.timestamped_file(settings["logs"]) do |f|
  f.print(json)
end
