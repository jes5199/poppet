require 'lib/policy/applier'
require 'lib/execute'
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
  imp = File.join(settings["imp"], res["Type"] + ".rb") # TODO: smarter executable finding, extract into lib
  results = Poppet::Execute.execute( imp, JSON.dump( [ "change", res ] ) )
  o = Poppet::Changelog.new( JSON.parse( results ) )
  history = history.concat( o )
end
puts history.to_json
