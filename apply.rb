require 'lib/policy/applier'
require 'lib/execute'
require 'lib/implementor'
require 'rubygems'
require 'json'
require 'lib/changelog'
require 'lib/settings'

settings = Poppet::Settings.new

policy = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read ) # TODO factor out this pattern

applier = Poppet::Policy::Applier.new( policy )

version = Poppet::Execute.execute( settings["imp_version"] ).chomp
metadata = {
  "facts_version"  => Poppet::Struct.by_keys( policy, ["Metadata", "facts_version"]),
  "system_name"    => Poppet::Struct.by_keys( policy, ["Metadata", "system_name"]),
  "policy_version" => Poppet::Struct.by_keys( policy, ["Metadata", "policy_version"]),
  "imp_version"    => version,
}

history = Poppet::Changelog.new( {"Metadata" => metadata} )
applier.each do |res|
  imp = File.join(settings["imp"], res.data["Type"] + ".rb") # TODO: smarter executable finding, extract into lib
  changes = Poppet::Implementor.new( imp ).change( res )
  history = history.concat( changes )
end
puts history.to_json
