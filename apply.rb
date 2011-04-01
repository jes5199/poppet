require 'lib/policy/applier'
require 'lib/execute'
require 'lib/implementor'
require 'rubygems'
require 'json'
require 'lib/changelog'
require 'lib/settings'

settings = Poppet::Settings.new
implement = 'ruby implement.rb' #TODO: setting

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
  nudge = settings["always_nudge"] || nudges[id]
  simulate = settings["dry_run"]
  action = case
  when simulate && nudge
    'simulate_nudge'
  when !simulate && nudge
    'nudge'
  when simulate && !nudge
    'simulate'
  else
    'change'
  end
  data = [action, res.data]
  changes_data = JSON.parse( Poppet::Execute.execute( implement, JSON.dump( data ) ) )
  changes = Poppet::Changelog.new(changes_data)
  if changes.makes_change?
    ( res.by_keys(["Metadata", "nudge"]) || [] ).each do |nudge_id|
      STDERR.puts "nudges: #{nudge_id.inspect}"
      nudges[nudge_id] = true # TODO: this happens too late to implement "nudged_by". Refactor!
    end
  end
  history = history.concat( changes )
end
puts history.to_json
