require 'lib/policy/applier'
require 'lib/execute'
require 'lib/implementor'
require 'rubygems'
require 'json'
require 'lib/changelog'
require 'lib/settings'

settings = Poppet::Settings.new

policy = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read ) # TODO factor out this pattern

applier = Poppet::Policy::Applier.new(
  policy,
  {
    "order_resources_by_name" => settings["order_resources_by_name"],
    "shuffle_salt"            => settings["resource_name_shuffle_salt"],
  }
)

version = Poppet::Execute.execute( settings["imp_version"] ).chomp
metadata = {
  "facts_version"  => Poppet::Struct.by_keys( policy, ["Metadata", "facts_version"]),
  "facts_timestamp"=> Poppet::Struct.by_keys( policy, ["Metadata", "facts_timestamp"]),
  "system_name"    => Poppet::Struct.by_keys( policy, ["Metadata", "system_name"]),
  "policy_version" => Poppet::Struct.by_keys( policy, ["Metadata", "policy_version"]),
  "imp_version"    => version,
}

# TODO: This has gotten way too long to be in an executable.
history = Poppet::Changelog.new( {"Metadata" => metadata} )
nudges = {}
applier.each do |id, res|
  imp_file = File.join(settings["imp"], res.data["Type"] + ".rb") # TODO: smarter executable finding, extract into lib
  imp = Poppet::Implementor.new( imp_file )
  if settings["always_nudge"] || nudges[id]
    if settings["dry_run"]
      changes = imp.simulate_nudge( res )
    else
      changes = imp.nudge( res )
    end
  else
    if settings["dry_run"]
      changes = imp.simulate( res )
    else
      changes = imp.change( res )
    end
  end
  if changes.makes_change?
    ( res.by_keys(["Metadata", "nudge"]) || [] ).each do |nudge_id|
      STDERR.puts "nudges: #{nudge_id.inspect}"
      nudges[nudge_id] = true # TODO: this happens too late to implement "nudged_by". Refactor!
    end
  end
  history = history.concat( changes )
end
puts history.to_json
