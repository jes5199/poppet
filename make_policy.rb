require 'rubygems'
require 'json'
require 'lib/policy'
require 'lib/policy_maker'
require 'lib/storage'

settings = {
  :policy_makers => "policy_makers/*",
  :name_by => ['hostname']
}

#TODO validate command line
inventory = JSON.parse( ARGV[0] ? File.read(ARGV[0]) : STDIN.read )
#TODO validate schema

name = Poppet::Struct.by_keys( inventory, settings[:name_by] )
policy = Poppet::Policy.new( {}, name )
Poppet::PolicyMaker.each(settings[:policy_makers]) do |policy_maker|
  policy = policy.combine( policy_maker.execute( inventory ) )
end

puts( JSON.dump( policy.data ) )

