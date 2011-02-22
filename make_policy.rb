require 'rubygems'
require 'json'
require 'lib/policy'
require 'lib/policy/maker'
require 'lib/storage'

settings = {
  :policy_makers => "policy_makers/*",
  :name_by => ['hostname']
}

#TODO validate command line
inventory = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read ) # TODO factor out this pattern
#TODO validate schema

name_by = ["data"] + settings[:name_by]
name = Poppet::Struct.by_keys( inventory, name_by )
policy = Poppet::Policy.new( {}, name )
Poppet::Policy::Maker.each(settings[:policy_makers]) do |policy_maker|
  policy = policy.combine( policy_maker.execute( inventory ) )
end

puts( JSON.dump( policy.data ) )

