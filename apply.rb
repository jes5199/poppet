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
  "facts_timestamp"=> Poppet::Struct.by_keys( policy, ["Metadata", "facts_timestamp"]),
  "system_name"    => Poppet::Struct.by_keys( policy, ["Metadata", "system_name"]),
  "policy_version" => Poppet::Struct.by_keys( policy, ["Metadata", "policy_version"]),
  "imp_version"    => version,
}

history = Poppet::Changelog.new( {"Metadata" => metadata} )
applier.each do |res|
  imp_file = File.join(settings["imp"], res.data["Type"] + ".rb") # TODO: smarter executable finding, extract into lib
  imp = Poppet::Implementor.new( imp_file )
  if settings["dry_run"]
    if settings["always_nudge"]
      changes = imp.simulate_nudge( res )
    else
      changes = imp.simulate( res )
    end
  else
    if settings["always_nudge"]
      changes = imp.nudge( res )
    else
      changes = imp.change( res )
    end
  end
  history = history.concat( changes )
end
puts history.to_json
