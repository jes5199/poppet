require 'lib/policy/applier'
require 'lib/execute'
require 'lib/implementor'
require 'rubygems'
require 'json'
require 'lib/changelog'
require 'lib/settings'

settings = Poppet::Settings.new

policy = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read ) # TODO factor out this pattern

version = Poppet::Execute.execute( settings["imp_version"] ).chomp
metadata = {
  "facts_version"  => Poppet::Struct.by_keys( policy, ["Metadata", "facts_version"]),
  "facts_timestamp"=> Poppet::Struct.by_keys( policy, ["Metadata", "facts_timestamp"]),
  "system_name"    => Poppet::Struct.by_keys( policy, ["Metadata", "system_name"]),
  "policy_version" => Poppet::Struct.by_keys( policy, ["Metadata", "policy_version"]),
  "imp_version"    => version,
}

applier = Poppet::Policy::Applier.new(
  policy,
  {
    "order_resources_by_name" => settings["order_resources_by_name"],
    "shuffle_salt"            => settings["resource_name_shuffle_salt"],
    "always_nudge"            => settings["always_nudge"],
    "dry_run"                 => settings["dry_run"],
    "implement"               => 'ruby implement.rb', #TODO: setting
    "metadata"                => metadata,
  }
)

history = applier.apply

puts history.to_json
