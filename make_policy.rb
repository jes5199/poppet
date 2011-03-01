require 'rubygems'
require 'json'
require 'lib/policy'
require 'lib/policy/maker'
require 'lib/storage'
require 'lib/resource/system'
require 'lib/settings'

settings = Poppet::Settings.new

#TODO validate command line
inventory = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read ) # TODO factor out this pattern
Poppet::Resource::System.new( inventory ) # validates the schema

name_by = ["Parameters"] + settings["name_by"]
name = Poppet::Struct.by_keys( inventory, name_by )

version = Poppet::Execute.execute( settings["policy_version"] ).chomp
metadata = {
  "system_name"    => name,
  "facts_version"  => Poppet::Struct.by_keys( inventory, ["Metadata", "facts_version"] ),
  "facts_timestamp"=> Poppet::Struct.by_keys( inventory, ["Metadata", "facts_timestamp"]),
  "policy_version" => version
}

policy = Poppet::Policy.new( { "Metadata" => metadata }, name )
Poppet::Policy::Maker.each(settings["policy_makers"]) do |policy_maker|
  policy = policy.combine( policy_maker.execute( inventory ) )
end

puts( JSON.dump( policy.data ) )

