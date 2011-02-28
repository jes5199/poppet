require 'lib/timestamp'
require 'lib/storage'
require 'lib/changelog'
require 'lib/settings'

settings = Poppet::Settings.new

# save System to inventory
# TODO: check identity.
json = STDIN.read
Poppet::Changelog.new( JSON.parse(json) )
Poppet::Storage.timestamped_file(settings["logs"]) do |f|
  f.print(json)
end
